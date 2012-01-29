Spine = require('spine')
$ = require('jqueryify')
# Although a hand feels kinda like a model, 
# it's temporal, and also can access DOM.
# Would need a model if we want persistance

class Hand extends Spine.Controller
  history: []
  canSplit: false
  softAces: 0
  score: 0
  hasBusted: false
  hasSurrendered: false

  constructor: ->
    super
    @cards = []
    @player.el.append @el

  takeCard: (card) =>
    @cards.push card
    @score += card.value
    @softAces++ if card.value is 11
    @hasBlackjack = true if @score is 21 and @isFirstPlay()
    @canSplit = true if @cards[0].value is @cards[1]?.value and @isFirstPlay()

    if @score > 21
      if @softAces > 0 then @convertAce() else @bust()

    @el.append require('views/card')(card)
  
  convertAce: ->
    @score -= 10
    @softAces--
    if @score > 21 then @bust()
  
  split: ->
    @canSplit = false
    card = @cards.pop()
    @score -= card.value
    @softAces-- if card.value is 11
    card

  bust: ->
    @el.append('<span class="busted">Busted</span>')
    @hasBusted = true

  isSoft: -> @softAces.length > 0
  isFirstPlay: -> @cards.length is 2

module.exports = Hand