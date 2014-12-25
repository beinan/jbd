define [ "underscore", "seq_diagram/theme"], (_ , Theme) ->
  
  class Actor
    constructor:(alias, name, index) ->
      @alias = alias
      @name  = name
      @index = index
      @lifelines = []    
    
    
    addLifeline: (name, data) ->
      new_lifeline = new Lifeline(name, data)
      new_lifeline.depth = 0 #root level lifeline
      new_lifeline.actor = this
      @lifelines.push(new_lifeline)
      return new_lifeline


  class Signal
    constructor:(fromActor, fromLifeline, toActor, toLifeline, message, data) ->
      @type       = "Signal"
      @fromActor     = fromActor
      @toActor     = toActor
      @fromLifeline   = fromLifeline
      @toLifeline  = toLifeline
      @message    = message
      @data       = data

    isSelf: ->
      return @fromActor.index == @toActor.index

  class Lifeline
    
    constructor: (name, data) ->
      @name = name
      @data = data
      @signals = []
      @sub_lifelines = []
      
    addSignal: (s) ->
      @signals.push(s)

    addSubLifeline: (name, data) ->
      new_lifeline = new Lifeline name, data
      new_lifeline.depth = @depth + 1
      new_lifeline.actor = @actor
      @sub_lifelines.push(new_lifeline)
      return new_lifeline


  class Diagram
    constructor: ->
      @title = "untitled"
      @actors = []
      @signals = []
      @events = {}
      
      default_options = theme: "d3"
      options = _.defaults(options or {}, default_options)
      ConcreteTheme = Theme.getTheme(options.theme) 
      @drawing_theme = new ConcreteTheme(this)

    addActor:(actor_name) ->
      actor = _.find @actors, (actor) ->
        return actor.name == actor_name
      if actor
        return actor 
      console.log "create new actor", actor_name
      new_actor = new Actor(actor_name, actor_name, @actors.length)
      @actors.push(new_actor)
      return new_actor

    addSignal:(fromActor, fromLifeline, toActor, toLifeline, message, data) ->
      new_signal = new Signal(fromActor, fromLifeline, toActor, toLifeline, message, data)
      @signals.push(new_signal)
      if new_signal.toLifeline is null  #if tolifeline is null, create a new one
        if new_signal.isSelf() 
          new_signal.toLifeline = fromLifeline.addSubLifeline(message, data)      
        else
          new_signal.toLifeline = toActor.addLifeline(message, data)      

      new_signal.toLifeline.addSignal(new_signal)
      fromLifeline.addSignal(new_signal)

      return new_signal

    
    drawSVG : (container, options) ->
      @reorganize()
      @drawing_theme.draw container
      return

    #sort the actors and signals for better visualization
    reorganize: ->
      @signals.sort (a, b)->
        return  a.data["invocation_id"] - b.data["invocation_id"]
          

    trigger : (event_name, source_dom, source_data)->
      if @events[event_name]
        for handler in @events[event_name]
          handler(source_dom, source_data)
    
    on : (event_name, handler)->
      if @events[event_name]
        @events[event_name].push(handler)
      else
        @events[event_name] = [handler]

  return Diagram