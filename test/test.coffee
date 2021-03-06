Object.size = (obj) ->
  size = 0
  key = undefined
  for key of obj
    size++  if obj.hasOwnProperty(key)
  size

assert = require("assert")
Nodewhal = require("../nodewhal")
should = require("chai").should()
chai = require("chai")
chaiAsPromised = require("chai-as-promised")
require("mocha-as-promised")()
chai.use chaiAsPromised

describe "Nodewhal", ->
  ua = "Nodewhal Test Runner"
  nw = Nodewhal(ua)
  defaultUserAgent = "noob-nodewhal-dev-soon-to-be-ip-banned"

  it "Should use the user-agent passed in the constructor.", ->
    nw.userAgent.should.equal ua

  it "Should use a default user agent if one isn't passed in the constructor.", ->
    nw_no_useragent = Nodewhal()
    nw_no_useragent.userAgent.should.equal defaultUserAgent


  describe "Non-logged in functions.", ->
    describe "User information.", ->
      valid_user = "yishan"
      non_existent_user = "joishvcshuifndsalkju904j3wmkwlatgf"
      shadowbanned_user = "FUCKpepsi_next"
      it "Should return user-information properly for a real user.", ->
        nw.aboutUser(valid_user).should.eventually.have.deep.property "name", valid_user

      it "Should return an error for a user that doesn't exist.", ->
        nw.aboutUser(non_existent_user).should.eventually.be.rejectedWith 404

      describe "Shadowbans", ->
        it "Should show a shadow-banned user as shadow-banned.", ->
          nw.checkForShadowban(shadowbanned_user).should.eventually.be.rejectedWith "shadowban"

        it "Should show a non-shadow-banned user as non-shadow-banned.", ->
          nw.checkForShadowban(valid_user).should.eventually.be.resolved


    describe "Listings", ->
      it "Should return appropriate submission for closed subreddit.", ->
        nw.listing("/r/reddit.com",
          max: 1
        ).should.eventually.have.deep.property "t3_lghsk.author", "yellowcakewalk" # Should always return this as /r/reddit.com is closed for business.

    ###it "Should return var max entries when var max is appropriately set.", (done) ->  // This fails miserably atm
      max = 8
      nw.listing("/r/reddit.com",
        max: max
      ).then (listing) ->
        Object.size(listing).should.equal max###

    describe "byId", ->
      it "Should grab one ID if passed as a string.", ->
        nw.byId("t3_1rptxk").should.eventually.have.deep.property "author", "reddit"

      it "Should prepend t3_ if it doesn't exist in the passed strings.", ->
        nw.byId("1rptxk").should.eventually.have.deep.property "author", "reddit"

      it "Should accept a list of >100 IDs and transparently return a single object with those IDs.", ->
        id_list = ['1ryfk0', '1rxdfj', '1safjd', '1sagl9', '1sa3hn', '1ryt8j', '1sahzv', '1rxihn', '1ryule', '1rz1i2',
                   '1sao62', '1saaju', '1sa63h', '1ryebh', '1rxwd0', '1ry5j4', '1rynga', '1safto', '1ry8ko', '1s9yh7',
                   '1sa4xh', '1sacc8', '1s9y7s', '1sa2gr', '1sa5n8', '1rxssi', '1sa0eg', '1ry6lz', '1rya2p', '1rxxas',
                   '1rx3u4', '1sae9n', '1sa7gg', '1ryomq', '1sa262', '1sai8l', '1qj6xd', '1ryfwa', '1s9vof', '1rwouq',
                   '1ryi7q', '1qek9w', '1sa2rd', '1sajag', '1ryjo1', '1rxzxw', '1rxyo0', '1sa44k', '1qp3bu', '1s9y41',
                   '1sadec', '1qzugv', '1qcl3e', '1sabrm', '1rh8ws', '1sa7g6', '1r5057', '1rx0o8', '1ry8vd', '1sa6qu',
                   '1ryd6l', '1ry8vu', '1sa7te', '1sahd7', '1r5728', '1ryajm', '1rjtrc', '1qj8bv', '1rym70', '1rkw8n',
                   '1ry28v', '1sa1de', '1r2rhn', '1r86fb', '1rwxqi', '1rythz', '1ryp7p', '1ry4sa', '1ry327', '1sae87',
                   '1sar0i', '1q69ti', '1s9qnf', '1qjlua', '1ryrwj', '1rylty', '1rxjua', '1qhehw', '1s9xf7', '1sa0vj',
                   '1s9lw0', '1r5msc', '1sajgm', '1rwzyi', '1ry7pa', '1sac70', '1salmr', '1rxqkv', '1sa3ta', '1r6jss',
                   '1sbt1f', '1sbt1e', '1sbt1d', '1sbt1c', '1sbt1b', '1sbt19', '1sbt18', '1sbt17', '1sbt15', '1sbt14',
                   '1sbt13', '1sbt11', '1sbt10', '1sbt0z', '1sbt0y', '1sbt0x', '1sbt0w', '1sbt0v', '1sbt0t', '1sbt0u',
                   '1sbt0s', '1sbt0r', '1sbt0q', '1sbt0p', '1sbt0o', '1sbt0n', '1sbt0m', '1sbt0l', '1sbt0k', '1sbt0j',
                   '1sbt0i', '1sbt0h', '1sbt0g', '1sbt0f', '1sbt0e', '1sbt0d', '1sbt0c', '1sbt0b', '1sbt0a', '1sbt09',
                   '1sbt08', '1sbt07', '1sbt06', '1sbt04', '1sbt03', '1sbt02', '1sbt01', '1sbt00', '1sbszz', '1sbszy',
                   '1sbszx', '1sbszv', '1sbszu', '1sbszt', '1sbszr', '1sbszp', '1sbszn', '1sbszm', '1sbszk', '1sbszj',
                   '1sbszi', '1sbszh', '1sbszg', '1sbszf', '1sbsze', '1sbszc', '1sbsza', '1sbsz9', '1sbsz8', '1sbsz4',
                   '1sbsz3', '1sbsz2', '1sbsz0', '1sbsyz', '1sbsyy', '1sbsyx', '1sbsyw', '1sbsyv', '1sbsyu', '1sbsyt',
                   '1sbsys', '1sbsyr', '1sbsyq', '1sbsyp', '1sbsyo', '1sbsyn', '1sbsym', '1sbsyk', '1sbsyj', '1sbsyi',
                   '1sbsyh', '1sbsyg', '1sbsyf', '1sbsyd', '1sbsyc', '1sbsyb', '1sbsy9', '1sbsy8', '1sbsy7', '1sbsy6']
        nw.byId(id_list).then (listing) ->
          Object.size(listing).should.equal id_list.length