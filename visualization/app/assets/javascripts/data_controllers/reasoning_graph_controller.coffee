#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-03 19:47:38
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 16:36:40

define [
  "jquery"
  "d3"
  "models/actor"
], ($, d3, Actor) ->
  
  class ReasoningGraphController
    
    constructor: (options) ->
      @options = options
      #init a treegrid for query results
      
      
     
    pop: ()->
      $("#reasoning-window").window("open")
      nodes = []
      nodes_by_thread = {}
      links = []
      for signal in @options.signals.models
        node = signal
        nodes.push node
        if nodes_by_thread[signal.get("thread_id")]?
          nodes_by_thread[signal.get("thread_id")].push node                   
        else
          nodes_by_thread[signal.get("thread_id")] = [node]

      console.log "nodes", nodes_by_thread
      for thread_id, nodes_of_thread of nodes_by_thread
        nodes_of_thread.sort (a, b)->
          a.get("invocation_id") - b.get("invocation_id")
        for node, i in nodes_of_thread
          if i != 0 #ignore the first node
            links.push
              source: nodes_of_thread[i]
              target: nodes_of_thread[i - 1]  
          
      
      # Compute the distinct nodes from the links.
      #links.forEach (link) ->
        #link.source = nodes[link.source] or (nodes[link.source] = name: link.source)
        #link.target = nodes[link.target] or (nodes[link.target] = name: link.target)
        #return

      tick = ->
        link.attr("x1", (d) ->
          d.source.x
        ).attr("y1", (d) ->
          d.source.y
        ).attr("x2", (d) ->
          d.target.x
        ).attr "y2", (d) ->
          d.target.y

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
      
      
      mouseover = ->
        d3.select(this).select("circle").transition().duration(750).attr "r", 16
        
      mouseout = ->
        d3.select(this).select("circle").transition().duration(750).attr "r", 8
        
      link = svg.selectAll(".link")
        .data(force.links())
        .enter().append("line")
        .attr("class", "link")
      node = svg.selectAll(".node")
        .data(force.nodes())
        .enter()
        .append("g")
        .attr("class", "node")
        .on("mouseover", mouseover)
        .on("mouseout", mouseout).call(force.drag)
      node.append("circle").attr "r", 8
      node.append("text").attr("x", 12).attr("dy", ".35em").text (d) ->
        d.title()

        #$('#search-result-treegrid').treegrid("loadData", data.results)
            
  return ReasoningGraphController