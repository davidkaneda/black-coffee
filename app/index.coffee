require('lib/setup')

Deck = require('models/deck')
Spine = require('spine')
Shoe = require('models/shoe')
House = require('controllers/house')
PlayerControls = require('controllers/player_controls')

class App extends Spine.Controller
  constructor: ->
    @controls = new PlayerControls
    @house = new House controls: @controls
    super

module.exports = App