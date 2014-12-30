# view of a sequence diagram
# @Author: Beinan
# @Date:   2014-12-27 19:22:23
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 16:49:00
define [
  "backbone"
  "d3"
  ], (Backbone, d3) ->

    
  class ActorView extends Backbone.View
    initialize:()->
      #console.log "A new ActorView is initializing", @el
      @actor_column = d3.select(@el) #actor column is a group contains head and lifelines
      @actor_column.datum(@model).attr("id", "actor-group-" + @model.id)
      this_view = this
      @draw_actor()

      @model.set("x", 50)    
      @model.set("width", @actor_column[0][0].getBBox().width)  #width of the actor column
      @model.on("change:x", (model, new_x) ->
        if model.previous('x')?
          console.log "change:x from #{model.previous('x')} to #{new_x}"
          x_diff = new_x - model.previous('x')
          this_view.actor_column.attr "transform", "translate(#{x_diff})"
      )       

    events:
      "click rect": "click_handler"

    
    click_handler: ()->
      console.log "click", @model.title()

    draw_actor: ()->
      head_text = @actor_column.append("text")
        .text(@model.title())
        .attr("x", 0)
        .attr("y", 50)
      

      head_rect_box = head_text[0][0].getBBox()         
      x_center = head_rect_box.x + head_rect_box.width / 2
      y_bottom = head_rect_box.y + head_rect_box.height + 12

      head_rect = @actor_column.append("rect")
        .attr
          "width": head_rect_box.width + 20 
          "height": head_rect_box.height + 20
          "x" : head_rect_box.x - 10
          "y": head_rect_box.y - 10
          "style" : "fill:gray;stroke:black;stroke-width:2;opacity:0.5"
          "rx":5
          "ry":5

      @actor_column.append("path").attr
        "d": "M#{x_center} #{y_bottom} L#{x_center} #{y_bottom+300}" 
        "stroke": "gray"
        "stroke-width": 3
        "stroke-dasharray": "20,10,5,5,5,10"


  class SeqDiagramView extends Backbone.View
    el: "svg"
    initialize: ()->
      console.log "Sequence Diagram view is initializing"
      @svg = d3.select(@el)
      @collection.on "add", @new_actor_added, @ 
    
    #event handler for new actor added    
    new_actor_added: (actor) ->
      diagram_view = this
 
      actor_view = new ActorView  #draw an actor 
        model : actor
        el : @el = @svg.append("g")[0][0] #create a new actor column group, and set @el to it
      
      actor.set("view", actor_view)
      @render()

    render: ()->
      console.log "seqDiagramView is rendering"
      x = 80
      for actor in @collection.models
        actor.set("x",x)
        x = x + actor.get("width") + 20 

  return SeqDiagramView

