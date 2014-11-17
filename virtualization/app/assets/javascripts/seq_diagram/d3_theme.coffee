define [
  "jquery"
  "d3"
  "raphael"
  "seq_diagram/diagram"
], ($, d3, Raphael, Diagram) ->
  
  class D3Theme 
    diagram: undefined
    constructor:(diagram)->
      console.log diagram
      @diagram = diagram

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
        lifeline.signals.forEach (s)->
          max = s.y + 10 if s.y > max
          min = s.y - 10 if s.y < min
        return [min, max]

      actor_columns.each (a) ->
        console.log("haha", a.lifelines)
        actor_column_g = this
        a.lifelines.forEach (l) ->
          minmax = life_range l 
          d3.select(actor_column_g).append("rect")
            .attr("width", 10 ) 
            .attr("height", minmax[1] - minmax[0])
            .attr("x", a.x_center - 5)
            .attr("y", minmax[0])
            .attr({"style" : "fill:Mintcream;stroke:black;stroke-width:1;opacity:0.8"})

    
    draw_signals: (container)->   
      signals = d3.select(container).selectAll(".signal-group").data(@diagram.signals)
      signals.enter().append("g")
      signals.exit().remove()
      #draw message
      signals.attr("id", (s, i)-> "signal_" + i)
        .attr("class", "signal-group")
      #draw path
      signals.append("text")
        .text((s) -> s.message)
        .attr("x", (s) -> s.actorA.x_center + 30)
        .attr("y", (s, i) -> 100 + i * 80)

      signals.append("path")
        .attr("id", (s, i) -> "path_for_signal_" + i)
        .attr("d", (s, i) ->
          from_x = s.actorA.x_center
          to_x = s.actorB.x_center - 14
          s.y = y = 110 + i * 80
          "M#{from_x} #{y} L#{to_x} #{y}" 
        )   
        .attr("stroke", "olivedrab")
        .attr("stroke-width", 4)
        .attr("stroke-dasharray", "5,5")
        .attr("marker-end", "url(#Triangle)")

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
