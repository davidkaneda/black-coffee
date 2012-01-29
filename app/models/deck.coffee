Spine = require('spine')
Card = require('models/card')

class Deck extends Spine.Model
  @configure 'Deck', 'cards'
  cards: []
  constructor: ->
    @cards.push( new Card(index: i, suit: suit) ) for i in [1..13] for suit in ['hearts', 'diams', 'spades', 'clubs']
    super

module.exports = Deck