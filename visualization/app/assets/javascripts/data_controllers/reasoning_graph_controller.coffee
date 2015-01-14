#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-03 19:47:38
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 19:39:33

define [
  "jquery"
  "d3"
  "models/actor"
], ($, d3, Actor) ->
  
  class ReasoningGraphController
    
    constructor: (options) ->
      @options = options
      @container = options.container
      #init a treegrid for query results
      @jvm_processes = options.jvm_processes 
      
     
    show: ()->
      nodes = []
      links = []
      for jvm in @jvm_processes.models
        graph = jvm.generate_signal_dependency_graph()
        console.log graph
        nodes.push.apply(nodes, graph.nodes) #concat nodes and graph.nodes
        links.push.apply(links, graph.links)
      
      
      tick = ->
        path.attr "d", (d) ->
          dx = d.target.x - d.source.x
          dy = d.target.y - d.source.y
          dr = Math.sqrt(dx * dx + dy * dy)
          #"M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y
          "M" + d.target.x + "," + d.target.y + "A" + dr + "," + dr + " 0 0,1 " + d.source.x + "," + d.source.y


        node.attr "transform", (d) ->
          "translate(" + d.x + "," + d.y + ")"

  
      force = d3.layout.force()
        .nodes(nodes)
        .links(links)
        .size([400, 400])
        .linkDistance(60)
        .charge(-300)
        .on("tick", tick)
        .start()

      svg = d3.select("#reasoning-graph")
      
      svg.html("")
      #build the arrow.
      svg.append("svg:defs").selectAll("marker")
        .data(["end"])      # Different link/path types can be defined here
        .enter().append("svg:marker")    #This section adds in the arrows
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 15)
        .attr("refY", -1.5)
        .attr("markerWidth", 8)
        .attr("markerHeight", 8)
        .attr("orient", "auto")
        .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5");      
      
      mouseover = ->
        d3.select(this).select("circle").transition().duration(750).attr "r", 16
        
      mouseout = ->
        d3.select(this).select("circle").transition().duration(750).attr "r", 8
        
      
      path = svg.append("svg:g")
        .selectAll("path")
        .data(force.links())
        .enter().append("svg:path")
        .attr("marker-end", "url(#end)")
        .attr "class", (d) ->
          "link " + d.type

      node = svg.selectAll(".node")
        .data(force.nodes())
        .enter()
        .append("g")
        .attr "class", (d)->
          if(d.get("field_visitor")?)
            return "node " + d.get("field_visitor").get("msg_type")
          else
            return "node method" 
        .on("mouseover", mouseover)
        .on("mouseout", mouseout).call(force.drag)
      node.append("circle").attr "r", 8
      node.append("text").attr("x", 12).attr("dy", ".35em").text (d) ->
        d.title()

        #$('#search-result-treegrid').treegrid("loadData", data.results)
            
  return ReasoningGraphController