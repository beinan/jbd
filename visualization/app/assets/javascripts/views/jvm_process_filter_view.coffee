#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-09 23:46:39
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 21:44:19

define [
  "backbone"
  "d3"
  ], (Backbone, d3) ->

  class JVMProcessFilterView extends Backbone.View
    initialize: ()->
      console.log "JVM process filter view is initializing"
    
    
    render: ()->
      jvm_items = d3.select(@el)
        .append("ul")
        .selectAll("li").data(@collection.models)
        .enter().append("li")
      jvm_items.append("span").html (jvm_process) -> 
        '<i class="glyphicon glyphicon-zoom-in"></i>' + jvm_process.id 
      jvm_items.append("a")
        .text(" Build a MongoDB query to start")
        .attr("href", (jvm_process)-> "#query_classes/#{jvm_process.id}")
      
      jvm_items.append("ul")
      jvm_items.each (jvm_process) ->
        jvm_process_dom = this
        jvm_process.actors.on "add", (actor)->
          actor_item = d3.select(jvm_process_dom).select("ul").append("li").datum(actor)
          actor_item.append("span").html (actor) -> 
            '<i class="glyphicon glyphicon-plus"></i>' + actor.title() 
          actor_item.append("ul")
            
  return JVMProcessFilterView
