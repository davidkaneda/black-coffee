Spine = require('spine')
$ = require('jqueryify')

class PlayerControls extends Spine.Controller
  el: $('.player-controls')
  events:
    'click input:not(:disabled)': 'play'
  enabled: false

  play: (e) ->
    @trigger $(e.currentTarget).prop 'value' if @enabled
  
  enable: (control) ->
    if control
      @$("input[value=\"#{ control }\"]").prop('disabled', false) 
    else
      @el.removeClass('disabled')
      @enabled = true

  disable: (control) ->
    if control
      @$("input[value=\"#{ control }\"]").prop('disabled', true) 
    else
      @el.addClass('disabled')
      @enabled = false

  reset: ->
    @enable 'double'
    @enable 'surrender'

  updateControls: (hand) ->
    if hand.canSplit then @enable('split') else @disable('split')
    if hand.cards.length > 2
      @disable 'split'
      @disable 'double'
      @disable 'surrender'

module.exports = PlayerControls