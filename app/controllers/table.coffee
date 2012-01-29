Spine = require('spine')
$ = require('jqueryify')
PlayerControls = require('controllers/player_controls')

# Table is the visual representation of the gamestate

class Table extends Spine.Controller

  constructor: ->
    super

  clearHands: =>
    player.render() for player in @house.players
    @house.dealer.render()

module.exports = Table