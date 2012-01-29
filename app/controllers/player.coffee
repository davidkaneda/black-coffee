Spine = require('spine')
$ = require('jqueryify')

class Player extends Spine.Controller
  tag: 'div'
  handHistory: []
  hands: []
  bankroll: 1000
  currentBet: 40

  # Should do this sometime...
  # bindings:
  #   ''

  # 1: Hit
  # 2: Stand
  # 3: Double
  # 4: Split
  # 5: Split, if allowed to double
  # 6: Surrender, if allowed, otherwise hit
  strategy: [
    [1,1,1,1,1,1,1,1,1,1]
    [1,3,3,3,1,1,1,1,1,1]
    [3,3,3,3,3,3,3,3,1,1]
    [3,3,3,3,3,3,3,3,3,1]
    [1,1,2,2,2,1,1,1,1,1]
    [2,2,2,2,2,1,1,1,1,1]
    [2,2,2,2,2,1,1,1,1,1]
    [2,2,2,2,2,1,1,1,6,1]
    [2,2,2,2,2,1,1,6,6,6]
    [2,2,2,2,2,2,2,2,2,2] # Hard 17
    [1,1,1,3,3,1,1,1,1,1]
    [1,1,1,3,3,1,1,1,1,1]
    [1,1,3,3,3,1,1,1,1,1]
    [1,1,3,3,3,1,1,1,1,1]
    [1,3,3,3,3,1,1,1,1,1]
    [2,3,3,3,3,2,2,1,1,1]
    [2,2,2,2,2,2,2,2,2,2]
    [2,2,2,2,2,2,2,2,2,2] # Soft 20
    [5,5,4,4,4,4,1,1,1,1]
    [5,5,4,4,4,4,1,1,1,1]
    [1,1,1,5,5,1,1,1,1,1]
    [3,3,3,3,3,3,3,3,1,1]
    [5,4,4,4,4,1,1,1,1,1]
    [4,4,4,4,4,4,1,1,1,1]
    [4,4,4,4,4,4,4,4,4,4]
    [4,4,4,4,4,2,4,4,2,2]
    [2,2,2,2,2,2,2,2,2,2]
    [4,4,4,4,4,4,4,4,4,4] # AA
  ]

  constructor: ->
    super
    @render()
    @$flash = @$('.flash')

  render: ->
    @el.html require('views/player')(@)

  bet: (newbet) ->
    @currentBet = parseInt newbet if newbet
    $('input[name=wager]').val(newbet) if newbet
    @$('.bankroll span').html @bankroll - @currentBet
    @$('.bet span').html @currentBet

  checkStrategy: (hand, dealercard) ->
    if hand.canSplit
      bestplay = @strategy[16 + hand.score / 2][dealercard-2]
    else if hand.softAces.length > 0 
      bestplay = @strategy[hand.score-1][dealercard-2]
    else if hand.score < 8
      bestplay = 1 # Hit
    else if hand.score > 17
      bestplay = 2 # Stand
    else
      bestplay = @strategy[hand.score - 8][dealercard-2]

    switch bestplay
      when 1 then bp = 'player should hit.'
      when 2 then bp = 'player should stand.'
      when 3 then bp = 'player should double down.'
      when 4, 5 then bp = 'player should split.'
      when 6 then bp = 'player should surrender.'

    @$('.strategy').html "#{ hand.score } against a #{ dealercard }, #{ bp }"
    @log hand
  
  flash: (msg, cls, autoclear) ->
    cls ?= 'info'
    clearTimeout @flashVisible?
    if msg then @$flash.html(msg).prop('class', "flash #{ cls }").show(200) else @hideFlash
    setTimeout @hideFlash, 2500
  
  hideFlash: => @$flash.hide( 200 )

  clearMessages: ->
    @hideFlash
    @$('.strategy').hide()

module.exports = Player