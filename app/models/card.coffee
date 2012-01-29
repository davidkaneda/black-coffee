Spine = require('spine')

class Card extends Spine.Model
  @configure 'Card', 'index', 'value', 'suit', 'name', 'shortSuit', 'shortName'

  constructor: ->
    super

    switch @index
      when 1 then @shortName = 'A'
      when 13 then @shortName = 'K'
      when 12 then @shortName = 'Q'
      when 11 then @shortName = 'J'
      else @shortName = @index 

    switch @index
      when 13, 12, 11 then @value = 10
      when 1 then @value = 11
      else @value = @index

    @shortSuit = @suit[0]

    @longName = @shortName + ' (' + @suit + ')'

module.exports = Card