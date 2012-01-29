Spine = require('spine')
Shoe = require('models/shoe')
Player = require('controllers/player')
Hand = require('models/hand')
Table = require('controllers/table')

class House extends Spine.Controller
  el: $('body')
  @extend Spine.Events
  settings: { deckSize: 6 }
  discarded: []
  players: []
  
  rules:
    standOnSoft17: true
    insurancePays2to1: true
    insuranceAllowed: true
    blackjackPays3to2: true
  
  events:
    'click input[name=new]': 'deal'
    'input input[name=wager]': 'changewager'
  
  elements:
    '.bet-controls': 'bet'

  constructor: () ->
    super

    @dealer = new Player(name: 'Dealer', el: $('#dealer'), isDealer: true)
    @players.push new Player(name: 'Dave', el: $('#player-1'))
    # @players.push new Player(name: 'Player 2', el: $('#player-2'))

    @controls.bind 'hit', @hitActiveHand
    @controls.bind 'stand', @endActiveHand
    @controls.bind 'double', @doubleActiveHand
    @controls.bind 'split', @splitActiveHand

    @controls.bind 'play', => @controls.updateControls @activeHand

    @shoe = new Shoe(decks: @settings.deckSize)

    @table = new Table(house: @)

    @log "Shuffling", @shoe ,"with #{ @shoe.cards.length } cards (#{ @settings.deckSize } decks)"
  
  changewager: (e) =>
    @players[0].bet($(e.target).val())
  
  deal: ->
    hand.el.remove() for hand in @playedHands if @playedHands
    @bet.hide()
    @hands = []
    @playedHands = []
    delete @activeHand
    @hands.push new Hand(player: player) for player in @players
    @dealer.hand = new Hand(player: @dealer)

    for i in [1,2]
      @dealCardToHand @hands[j] for player, j in @players
      @dealCardToSelf(@dealer.hand, i)
    @startPlay()

  startPlay: ->
    if @dealer.hand.cards[1].value is 11
      @log 'offerInsurance'
      if @checkForBlackjack()
        @log "payInsurance"
        @concludeHand()
      else
        @nextHand()
    else if @dealer.hand.cards[1].value is 10
      if !@checkForBlackjack() then @nextHand() else @concludeHand()
    else
      @nextHand()

  checkForBlackjack: -> @dealer.hand.score is 21 and @dealer.hand.cards.length is 2

  nextHand: ->
    @playedHands.push @activeHand if @activeHand and @activeHand.player isnt @dealer
    hand = @hands.shift()
    if hand then @dealPlayerHand(hand) else @dealDealerHand()

  dealPlayerHand: (hand) =>
    @activeHand = hand
    @controls.updateControls @activeHand

    # In case we have split
    @hitActiveHand() if hand.cards.length == 1

    @log "It is #{hand.player.name}'s turn."

    if hand.hasBlackjack
      @nextHand()
    else if hand.score is 21
      @log "Automatically standing on 21"
      @nextHand()
    else
      @controls.enable()
      hand.player.checkStrategy hand, @dealer.hand.cards[1].value
    
  dealDealerHand: =>
    @controls.disable()
    
    @log "#{ @dealer.name } reveals a #{ @dealer.hand.cards[0].shortName + @dealer.hand.cards[0].shortSuit} and has #{ @dealer.hand.score }"

    while @dealer.hand.score < 18
      if @dealer.hand.score isnt 17 or !@rules.standOnSoft17
        @dealer.hand.takeCard @shoe.drawCard()
        @log "Dealer hits, has #{ @dealer.hand.score }"
        @log "Dealer busts!" if @dealer.hand.hasBusted
      else
        break
    
    @concludeHand()
    @playedHands.push @dealer.hand

  hitActiveHand: =>
    @dealCardToHand @activeHand

    if @activeHand.hasBusted
      @log "#{ @activeHand.player.name } busted with #{ @activeHand.score}"
      @endActiveHand()
    else
      @activeHand.player.checkStrategy(@activeHand, @dealer.hand.cards[1].value)
  
  endActiveHand: =>
    @controls.disable()
    @controls.reset()
    @bet.show()
    @nextHand()
  
  doubleActiveHand: =>
    @log "#{ @activeHand.player.name } is doubling down!"
    @activeHand.player.currentBet *= 2
    @hitActiveHand()
    @endActiveHand()

  splitActiveHand: =>
    @log "#{ @activeHand.player.name } is splitting."

    # Create a new hand for the player
    secondhand = new Hand(player: @activeHand.player)
    secondhand.takeCard @activeHand.split()
    @hands.unshift secondhand
    @hitActiveHand()

  dealCardToHand: (hand) -> hand.takeCard @shoe.drawCard()

  dealCardToSelf: (hand, round) ->
    card = @shoe.drawCard(facedown: true)
    hand.takeCard card
    @log if round isnt 1 then "Dealing the #{ card.shortName + card.shortSuit } to the dealer." else "Dealing face down to dealer."

    return card
   
  concludeHand: ->
    for hand in @playedHands
      @log hand.player.bankroll
      if @dealer.hand.hasBusted or ( hand.score > @dealer.hand.score ) and !hand.hasBusted
        @log hand.player.currentBet
        @log ":) #{ hand.player.name } wins #{ hand.player.currentBet }."
        hand.player.bankroll += hand.player.currentBet
      else if hand.score < @dealer.hand.score || hand.hasBusted
        @log ":( #{ hand.player.name } loses #{ hand.player.currentBet }."
        hand.player.bankroll -= hand.player.currentBet
      else if hand.score is @dealer.hand.score
        @log ":| #{ hand.player.name } pushes."
      
      # Just to update the display for the next one
      hand.player.bet()

module.exports = House