var request = require('request'),
  RSVP = require('rsvp'),
  schedule = require('./schedule'),
  EventSource = require('eventsource'),
  baseUrl = 'http://www.reddit.com',
  knownShadowbans = {},
  lastRedditRequestTimeByUrl = {},
  lastRedditRequestTime,
  defaultUserAgent = 'unspecified user agent';

function NodewhalSession(userAgent) {
  var self = this;
  self.userAgent = userAgent || defaultUserAgent;
  self.session = {
    cookieJar: request.jar()
  };

  self.newSubmissions = [];
  self.login = function (username, password) {
    return self.post(baseUrl + '/api/login', {
      form: {
        api_type: 'json',
        passwd: password,
        rem: true,
        user: username
      }
    }).then(function (data) {
        if (data && data.json && data.json.errors && data.json.errors.length) {
          throw data.json.errors;
        }
        Object.keys(data.json.data).forEach(function (key) {
          self.session[key] = data.json.data[key];
        });
        return self;
      });
  };

  self.submit = function (subreddit, kind, title, urlOrText, resubmit) {
    urlOrText = urlOrText || '';
    kind = (kind || 'link').toLowerCase();
    var form = {
      api_type: 'json',
      kind: kind,
      title: title,
      sr: subreddit,
      resubmit: resubmit,
      uh: self.session.modhash
    };
    if (kind === 'self' || !urlOrText) {
      form.text = urlOrText;
    } else {
      form.url = urlOrText;
    }
    return self.post(baseUrl + '/api/submit', {form: form}).then(function (data) {
      if (data && data.json && data.json.errors && data.json.errors.length) {
        throw data.json.errors;
      }
      if (data && data.json && data.json.data) {
        return data.json.data;
      }
      return data;
    });
  };

  self.get = function (url, opts) {
    return self.req(url, 'get', opts);
  };

  self.post = function (url, opts) {
    return self.req(url, 'post', opts);
  };

  self.req = function (url, method, opts) {
    return Nodewhal.respectRateLimits(method, url).then(function () {
      opts = opts || {};
      if (self.session && self.session.cookieJar) {
        opts.jar = self.session.cookieJar;
      }
      opts.headers = opts.headers || {};
      opts.headers['User-Agent'] = self.userAgent;
      return Nodewhal.rsvpRequest(method, url, opts);
    }).then(function (body) {
        var json;
        try {
          json = JSON.parse(body);
        } catch (e) {
          throw e;
        }
        if (json && json.error) {
          throw Error(json.error);
        }
        return json;
      }, function (error) {
        throw error;
      });
  };
}

function Nodewhal(userAgent) {
  return new NodewhalSession(userAgent);
}

Nodewhal.schedule = schedule;

Nodewhal.rsvpRequest = function (method, url, opts) {
  return new RSVP.Promise(function (resolve, reject) {
    if (!method || method === 'get') {
      method = request;
    } else {
      method = request[method];
    }
    method(url, opts, function (error, response, body) {
      if (error) {
        reject(error);
      } else {
        resolve(body);
      }
    });
  });
};

Nodewhal.respectRateLimits = function (method, url) {
  return new RSVP.Promise(function (resolve, reject) {
    var now = new Date(),
      minInterval = 2100,
      minUrlInterval = 30100,
      lastUrlInterval, lastUrlTime = lastRedditRequestTimeByUrl[url],
      interval = now - lastRedditRequestTime;

    if (method == 'get' && lastUrlTime) {
      lastUrlInterval = now - lastUrlTime;
    }
    if (lastRedditRequestTime && interval < minInterval) {
      resolve(schedule.wait(minInterval - interval).then(function () {
        return Nodewhal.respectRateLimits(method, url);
      }));
    } else {
      if (lastUrlInterval && lastUrlInterval < minUrlInterval) {
        resolve(schedule.wait(minUrlInterval - lastUrlInterval).then(function () {
          return Nodewhal.respectRateLimits(method, url);
        }));
      } else {
        lastRedditRequestTime = now;
        lastRedditRequestTimeByUrl[url] = now;
        resolve(true);
      }
    }
  }).then(undefined, function (error) {
      if (error.stack) {
        console.error(error.stack);
      }
      throw error;
    });
};

module.exports = Nodewhal;
