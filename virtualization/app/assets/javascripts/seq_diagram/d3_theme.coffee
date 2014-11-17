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
      actor_columns = d3.select(container).selectAll("g").data(@diagram.actors)
      actor_columns.enter().append("g")
      actor_columns.exit().remove()
      actor_columns.attr("id", (a)-> "actor_" + a.index)
      actor_columns.each (a) ->
        theme.draw_actor_head a,this


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
        console.log(d)
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
          x_center = d.rect.x + d.rect.width / 2
          y_bottom = d.rect.y + d.rect.height + 12
          "M#{x_center} #{y_bottom} L#{x_center} #{y_bottom+300}" 
        ) 
        .attr("stroke", "gray")
        .attr("stroke-width", 3)
        .attr("stroke-dasharray", "20,10,5,5,5,10")

  return D3Theme
