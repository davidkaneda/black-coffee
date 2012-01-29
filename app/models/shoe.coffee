Spine = require('spine')
Deck = require('models/deck')

class Shoe extends Spine.Model
  @configure 'Shoe', 'cards', 'decks'
  cards: []
  decks: 6
  preShuffle: true
  runningCount: 0

  constructor: (config) ->
    super
    @decks = config.decks
    @cards = new Deck().cards for i in [1..@decks]
    @shuffle() if @preShuffle;

  shuffle: ->
    @cards.sort -> 0.5 - Math.random()
  
  drawCard: (facedown) ->
    card = @cards.pop()

    if !facedown
      if 9 < card.value or card.value == 1
        @runningCount--
      else if card.value < 7
        @runningCount++

    card.facedown = facedown

    console.log "Dealing #{ if !facedown then (card.shortName + card.shortSuit) else 'facedown' }", card, "(running count is #{ @runningCount })"

    card

module.exports = Shoe