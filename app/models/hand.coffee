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
    @el = @render().appendTo(@player.el)
    @$scoreCount = @$('.score')
    @log @$scoreCount

  render: -> require('views/hand')(@)

  takeCard: (card) =>
    @cards.push card
    @log card
    @score += card.value if !card.facedown

    @softAces++ if card.value is 11
    @hasBlackjack = true if @score is 21 and @isFirstPlay()
    @canSplit = true if @cards[0].value is @cards[1]?.value and @isFirstPlay()

    if @score > 21
      if @softAces > 0 then @convertAce() else @bust()

    card.el = @el.append require('views/card')(card)
    @updateScore()
  
  turnOverCard: (card) ->
    card.facedown = false
    card.el.html require('views/card')(card)

  convertAce: ->
    @score -= 10
    @softAces--
    if @score > 21 then @bust()
    @updateScore()
  
  split: ->
    @canSplit = false
    card = @cards.pop()
    @score -= card.value
    @softAces-- if card.value is 11
    card
    @updateScore()

  bust: ->
    @player.flash('Busted', 'loss')
    @hasBusted = true

  updateScore: -> @$scoreCount.html @score

  isSoft: -> @softAces.length > 0
  isFirstPlay: -> @cards.length is 2

module.exports = Hand