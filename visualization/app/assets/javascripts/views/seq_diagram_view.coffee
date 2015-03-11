# view of a sequence diagram
# @Author: Beinan
# @Date:   2014-12-27 19:22:23
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 21:07:23
define [
  "backbone"
  "d3"
  ], (Backbone, d3) ->

  class SignalView extends Backbone.View
    initialize:()->
      @signal_row = d3.select(@el) 
      @from_actor = @model.from_actor()
      @to_actor = @model.to_actor()
      @thread_id = @model.get("thread_id")
      @signal_row.datum(@model).attr("id", "signal-group-" + @model.id)
      @draw_signal()


    height:()->
      @signal_row[0][0].getBBox().height
        

    render: (y)->
      @model.y = y + @height()
      @signal_row.attr "transform", "translate(0,#{y})"
      sig_arrow_y = y + @height()
      update_lifeline_position = (lifeline)->
        lifeline.set("min_y",sig_arrow_y ) if lifeline? and sig_arrow_y < lifeline.get("min_y")
        lifeline.set("max_y",sig_arrow_y ) if lifeline? and sig_arrow_y > lifeline.get("max_y")
        
      update_lifeline_position @model.from_lifeline()
      update_lifeline_position @model.to_lifeline()

      return @height()

    from_x: ()->
      if @from_actor?
        return @from_actor.get("x_center") + @from_actor.get("thread_x_center_off")[@thread_id]
      
      if @to_actor?
        return @to_actor.get("x_center") - 150
      return -1

    to_x : ()->
      if @to_actor?
        return @to_actor.get("x_center") + @to_actor.get("thread_x_center_off")[@thread_id]
      if @from_actor?
        return @from_actor.get("x_center")  + 150
      return -1

    draw_signal: ()->
      
      from_x = @from_x()
      to_x = @to_x()
          
      text = @signal_row.append("text")
        .text(@model.title())
        .attr("x", (from_x + to_x)/2 - 20)
        .attr("y", 0)
        
      y = 12

      if @from_actor == @to_actor            
        path_d = "M#{from_x} #{y} L#{to_x + 40} #{y} L#{to_x + 40} #{y + 20} L#{to_x } #{y + 20}"
      else
        path_d = "M#{from_x} #{y} L#{to_x} #{y}" 
      
      path = @signal_row.append("path")
        .attr("id", "path_for_signal_" + @model.id)
        .attr("d", path_d)   
        .attr("stroke", "olivedrab")
        .attr("stroke-width", 2)
        #.attr("stroke-dasharray", "5,1")
        .attr("marker-end", "url(#end)")
        .attr("style", "fill:none")
      
      bbox = text[0][0].getBBox()
      @signal_row.append("rect")
        .attr
          "width": bbox.width 
          "height": bbox.height
          "x" : bbox.x
          "y": bbox.y 
          "style" : "opacity:0"

        .each (model) ->
          
          content = $("<div></div>")
          # rows = d3.select(content[0]).append("table").attr
          #   "class": "table table-striped"
          # .selectAll("tr").data(d3.entries(model.attributes)).enter().append("tr")
          # rows.append("td").text (d) -> d.key
          # rows.append("td").text (d) -> d.value
          model.to_lifeline().params (params)->
            console.log "params", params
            rows = d3.select(content[0]).append("table").attr
              "class": "table table-striped"
            .selectAll("tr").data(params).enter().append("tr")
            rows.append("td").text (d) -> d
            #rows.append("td").text (d) -> d.value

          $(this).popover
            title: "Method Invocation"
            content: content
            container: "body"
            html: true

  class ActorView extends Backbone.View
    initialize:()->
      @actor_column = d3.select(@el) #actor column is a group contains head and lifelines
      @actor_column.datum(@model).attr("id", "actor-group-" + @model.id)
      this_view = this
      @draw_actor()
      
      # @model.set("width", @actor_column[0][0].getBBox().width)  #width of the actor column
      # @model.set("x", 50)    
      # @model.on("change:x", (model, new_x) ->
      #   if model.previous('x')?
      #     console.log "change:x from #{model.previous('x')} to #{new_x}"
      #     x_diff = new_x - model.previous('x')
      #     this_view.actor_column.attr "transform", "translate(#{x_diff})"
      # )       

    render: (x)->
      @actor_column.attr "transform", "translate(#{x})"
      x_center = @model.get("x_center")
      @model.set("x_center", x_center + x)
      
      return @actor_column[0][0].getBBox().width

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
      head_rect = @actor_column.append("rect")
        .attr
          "width": head_rect_box.width + 20 
          "height": head_rect_box.height + 20
          "x" : head_rect_box.x - 10
          "y": head_rect_box.y - 10
          "style" : "fill:gray;stroke:black;stroke-width:2;opacity:0.5"
          "rx":5
          "ry":5

      x_center = head_rect_box.x + head_rect_box.width / 2
      y_bottom = head_rect_box.y + head_rect_box.height + 12

      thread_x_center_off = {}
      
      thread_count = @model.get_thread_ids().length
      for thread_id, i in @model.get_thread_ids()
        thread_x_off = (i - thread_count/2) * 20
        thread_x_center_off[thread_id] = thread_x_off
        color = if i % 2 is 0 then d3.rgb("#E9967A") else d3.rgb("#8FBC8F")
        @actor_column.append("rect").attr
          "class": "thread_line"
          "width": 20
          "height": 0 #will be update when all signals have been placed
          "x": x_center + thread_x_off - 10
          "y": y_bottom 
          "style" : "fill:#{color};opacity:0.25"

      
      lifeline_rects = @actor_column.selectAll(".lifeline_rect")
        .data(@model.lifelines.models).enter()
        .append("rect")
        .attr 
          "class": "lifeline_rect" 
          "width": 10 
          "height": 0 # will be update after the signals have been placed
          "y" : 0  # will be update after the signals have been placed
          "style" : "fill:gray;stroke:black;stroke-width:2;opacity:0.5"
          "rx":5
          "ry":5
        .attr "x", (lifeline)->
          x_center + thread_x_center_off[lifeline.get("thread_id")] - 5
        .each (lifeline) ->
          lifeline.set("max_y", 0)
          lifeline.set("min_y", Number.MAX_VALUE)
          lifeline.on "change:min_y change:max_y", (model)->
            height = model.get("max_y") - model.get("min_y") + 20
            height = 0 if height < 0
            d3.select(this).attr
              y: model.get("min_y") - 10
              height: height
          , this    
              
      @model.set("x_center", x_center)
      @model.set("thread_x_center_off", thread_x_center_off)
            


          
    update_center_path: (y)->
      @actor_column.selectAll(".thread_line").attr("height", y)  

  class SeqDiagramView extends Backbone.View
    
    initialize: ()->
      console.log "Sequence Diagram view is initializing"
      @svg = d3.select(@el).append("svg").attr
        width: 50000
        height: 54000
      #@collection.on "add", @new_actor_added, @ 
      #build the arrow.
      @svg.append("svg:defs").selectAll("marker")
        .data(["end"])      # Different link/path types can be defined here
        .enter().append("svg:marker")    #This section adds in the arrows
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 10)
        .attr("refY", 0)
        .attr("markerWidth", 8)
        .attr("markerHeight", 8)
        .attr("orient", "auto")
        .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5");          
    
    render: ()->
      @svg.selectAll("g").remove() #clear all the actor and signals
      console.log "seqDiagramView is rendering"
      x = 80
      y = 80
      jvm = @model
      graph = jvm.generate_signal_dependency_graph()
      jvm.sorted_signals = graph.top_sort()
      console.log "sorted signals" ,jvm.sorted_signals 
      
      for actor in jvm.actors.models
        actor_width = @render_actor actor, x
        x = x + actor_width + 20
            
      for signal in jvm.sorted_signals
        if !signal.get("field_visitor")?        
          signal_height = @render_signal signal, y
          y = y + signal_height + 10

      for actor in jvm.actors.models
        if actor.get("view")?
          actor.get("view").update_center_path(y)
      
      #replay progress
      progress_line = @svg.append("line").attr
        x1: 0
        x2: x + 200
        y1: 0
        y2: 0
        style: "stroke:rgb(255,0,0);stroke-width:2"
      jvm.replay_process_model.on "change:pos", ()->
        pos = jvm.replay_process_model.get("pos") 
        y = jvm.sorted_signals[pos].y
        if y?
          progress_line.attr
            y1: y
            y2: y

      @svg.attr
        width: x + 300
        height: y   
    render_signal: (signal, y) ->
      signal_view = new SignalView
        model: signal
        el : @svg.append("g")[0][0] #create a new signal row group, and set @el to it
      return signal_view.render(y)

    render_actor: (actor, x)->
      actor_view = new ActorView  #draw an actor 
        model : actor
        el : @svg.append("g")[0][0] #create a new actor column group, and set @el to it          
      actor.set("view", actor_view)
      return actor_view.render(x)
          
  return SeqDiagramView

