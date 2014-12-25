define [
  "jquery"
  "d3"
  "raphael"
  "seq_diagram/diagram"
], ($, d3, Raphael, Diagram) ->
  
  LIFELINE_WIDTH = 14
  SIGNAL_HEIGHT = 55

  class D3Theme 
    
    constructor:(diagram)->
      console.log diagram
      @diagram = diagram

      @diagram.on("selection_change", @selection_change)

    selection_change: (source_dom, source_data)->
      if @previous_selection # clear previous selection
        d3.select(@previous_selection)
          .style("stroke", @previous_stroke).style("stroke-width", @previous_stroke_width)
      @previous_selection = source_dom
      @previous_stroke = d3.select(source_dom).style("stroke")
      @previous_stroke_width = d3.select(source_dom).style("stroke-width")
      d3.select(source_dom).style("stroke", "red").style("stroke-width",3)

    draw: (container)->
      theme = this
      
      actor_columns = d3.select(container).selectAll(".actor_column").data(@diagram.actors)
      actor_columns.enter().append("g")
      actor_columns.exit().remove()
      actor_columns.attr("id", (a)-> "actor_" + a.index)
        .attr("class", "actor_column")

      actor_columns.each (a) ->
        theme.draw_actor_head a,this

      @draw_signals container 
      @draw_lifelines container

    draw_lifelines: (container) ->
      actor_columns = d3.select(container).selectAll(".actor_column")
      #calculate the range of each lifeline by its signals and sub-lifelines
      life_range = (lifeline) ->
        max = Number.MIN_VALUE
        min = Number.MAX_VALUE
        console.log "call",lifeline.signals
        lifeline.signals.forEach (s)->
          max = s.y + 20 if s.y > max
          min = s.y - 10 if s.y < min
        lifeline.sub_lifelines.forEach (sub_lifeline)->
          life_range sub_lifeline
          max = sub_lifeline.max + 10 if sub_lifeline.max > max
          min = sub_lifeline.min = 10 if sub_lifeline.min < min
        lifeline.max = max
        lifeline.min = min  
      

      this_diagram = @diagram
      draw_lifeline = (actor_column_g, x_center, lifeline) ->        
        d3.select(actor_column_g).append("rect")
          .attr("width", LIFELINE_WIDTH) 
          .attr("height", lifeline.max - lifeline.min)
          .attr("x", x_center + LIFELINE_WIDTH * (lifeline.depth - 0.5))
          .attr("y", lifeline.min)
          .attr({"style" : "fill:Mintcream;stroke:black;stroke-width:1;opacity:0.8"})
          .on("click", () -> 
            this_diagram.trigger("selection_change", this, lifeline))

        lifeline.sub_lifelines.forEach (sub_lifeline)-> 
          draw_lifeline actor_column_g, x_center, sub_lifeline

      actor_columns.each (a) ->
        actor_column_g = this #dom context
        x_center = a.x_center
        a.lifelines.forEach (lifeline) -> # for each root level lifeline
          life_range lifeline
          draw_lifeline actor_column_g, x_center, lifeline 
          
    
    draw_signals: (container)->         
      signals = d3.select(container).selectAll(".signal-group").data(@diagram.signals)
      signals.selectAll("text").remove()
      signals.selectAll("path").remove()
      
      signals.enter().append("g")
      signals.exit().remove()
      #draw message
      signals.attr("id", (s, i)-> "signal_" + i)
        .attr("class", "signal-group")
      #draw text and path for each signal
      #s is the signail, i is the index
      signals.each (s, i)->
        s.y = 110 + i * SIGNAL_HEIGHT
        text = d3.select(this).selectAll("text").data([{data:s, index:i, y:s.y}])
        text.enter().append("text")
          .text(s.message)
          .attr("x", s.fromActor.x_center + 30)
          .attr("y", -> 
            if s.isSelf()
              80 + i * SIGNAL_HEIGHT
            else
              100 + i * SIGNAL_HEIGHT
          )
        text.exit().remove()

        path = d3.select(this).selectAll("path").data([{data:s, index:i, y:s.y}])
        path.enter().append("path")
          .attr("id", "path_for_signal_" + i)
          .attr("d", () ->
            from_x = s.fromActor.x_center + s.fromLifeline.depth * LIFELINE_WIDTH
            to_x = s.toActor.x_center + s.toLifeline.depth * LIFELINE_WIDTH
            y = s.y
            if s.isSelf()
              y = y - 20
              "M#{from_x} #{y} L#{to_x + 40} #{y} L#{to_x + 40} #{y + 20} L#{to_x + 14} #{y + 20}"
            else
              "M#{from_x} #{y} L#{to_x - 14} #{y}" 
          )   
          .attr("stroke", "olivedrab")
          .attr("stroke-width", 4)
          .attr("stroke-dasharray", "5,5")
          .attr("marker-end", "url(#Triangle)")
          .attr("style", "fill:none")
        path.exit().remove()

    draw_actor_head: (a, column) ->
      head_data = [{name:a.name}]
      x_left = 50 + 180 * a.index
      head_texts = d3.select(column).selectAll(".actor-head-text").data(head_data)
      head_texts.enter().append("text")
      head_texts.exit().remove()
      head_texts.attr("class", "actor-head-text")
        .attr("id", (d) -> d.name)
        .attr("x", x_left)
        .attr("y", (d, i) -> 50 + i * 100)
        .attr("font-size", 18)
        .text((d) -> d.name)
      head_texts.each (d) -> #calculate width and height
        d.rect = this.getBBox()
        a.x_center = d.rect.x + d.rect.width / 2

      head_rects = d3.select(column).selectAll(".actor-head-rect").data(head_data)
      head_rects.enter().append("rect")
      head_rects.exit().remove()
      head_rects.attr("class", "actor-head-rect")
        .attr("id", (d) -> "rect_for_" + d.name)
        .attr("width", (d) -> d.rect.width + 20 ) 
        .attr("height", (d) -> d.rect.height + 20)
        .attr("x", (d) -> d.rect.x - 10)
        .attr("y", (d) -> d.rect.y - 10)
        .attr({"style" : "fill:gray;stroke:black;stroke-width:2;opacity:0.5", "rx":5, "ry":5})

      head_vertical_path = d3.select(column).selectAll(".actor-head-path").data(head_data)
      head_vertical_path.enter().append("path")
      head_vertical_path.exit().remove()
      head_vertical_path.attr("class", "actor-head-path")
        .attr("id", (d) -> "path_for_" + d.name)
        .attr("d", (d) ->
          y_bottom = d.rect.y + d.rect.height + 12
          "M#{a.x_center} #{y_bottom} L#{a.x_center} #{y_bottom+300}" 
        ) 
        .attr("stroke", "gray")
        .attr("stroke-width", 3)
        .attr("stroke-dasharray", "20,10,5,5,5,10")

  return D3Theme
