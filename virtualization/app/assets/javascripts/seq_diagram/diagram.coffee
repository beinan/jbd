define [ "underscore", "seq_diagram/theme"], (_ , Theme) ->
  class Actor
    constructor:(alias, name, index) ->
      @alias = alias
      @name  = name
      @index = index

  class Signal
    constructor:(actorA, linetype, arrowtype, actorB, message) ->
      @type       = "Signal"
      @actorA     = actorA
      @actorB     = actorB
      @linetype   = linetype
      @arrowtype  = arrowtype
      @message    = message

    isSelf: ->
      return @actorA.index == @actorB.index


  class Diagram
    title: "untitled"
    actors: []
    signals: []
    
      
    addActor:(actor_name) ->
      new_actor = new Actor(actor_name, actor_name, @actors.length)
      @actors.push(new_actor)
      return new_actor

    addSignal:(actorA, linetype, arrowtype, actorB, message) ->
      new_signal = new Signal(actorA, linetype, arrowtype, actorB, message)
      @signals.push(new_signal)
      return new_signal

    drawSVG : (container, options) ->
      default_options = theme: "d3"
      options = _.defaults(options or {}, default_options)
      ConcreteTheme = Theme.getTheme(options.theme) 
      drawing = new ConcreteTheme(this)
      drawing.draw container
      return

  return Diagram