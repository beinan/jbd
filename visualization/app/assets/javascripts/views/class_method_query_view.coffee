#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-10 15:55:06
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 21:09:17

define [
  "jquery"
  "backbone"
  "d3"
  ], ($, Backbone, d3) ->

  class ClassMethodQueryView extends Backbone.View
    
    className: "tree"
    initialize: ()->
      @render_filter()
    bind_tree_events: ()->
      $(@el).find("li:has(ul)").addClass("parent_li").find(" > span").attr "title", "Collapse this branch"
      $(@el).find("li.parent_li > span").on "click", (e) ->
        children = $(this).parent("li.parent_li").find(" > ul > li")
        if children.is(":visible")
          children.hide "fast"
          $(this).attr("title", "Expand this branch").find(" > i")
            .addClass("glyphicon-plus").removeClass "glyphicon-minus"
        else
          children.show "fast"
          $(this).attr("title", "Collapse this branch").find(" > i")
            .addClass("glyphicon-minus").removeClass "glyphicon-plus"
        e.stopPropagation()
        return #parent_li click handler end

      
    render_filter: ()->
      class_meta_li = d3.select(@el).append("div").attr("class", "tree")
        .append("ul")
        .selectAll("li").data(@collection.models)
        .enter().append("li")

      class_meta_span = class_meta_li.append("span")
        .attr('class', "alert-warning")
      class_meta_span.append("i").attr("class", "glyphicon glyphicon-minus")
      class_meta_span.append("class_name_entry")
        .text (d) ->  d.id  
      class_meta_li.append("pick_me").text("Pick up this class")
      class_meta_li.append("input")
        .attr("type", "checkbox")
        .property("checked", (d) -> d.get("checked"))
        .on "click",  (d)->
          console.log "class checked", $(this).is(':checked')
          d.set("checked", $(this).is(':checked'))


      #two dementional 
      method_meta_li = class_meta_li
        .append("ul")
        .selectAll("li").data((class_meta)-> d3.entries(class_meta.get("value")))
        .enter().append("li")
      method_meta_li.append("span").html (method_meta)-> 
        '<i class="glyphicon glyphicon-minus"></i> ' + method_meta.key

      method_meta_li.append("pick_me").text("Pick up this method")
      method_meta_li.append("input")
        .attr("type", "checkbox")
        .property("checked", (d) -> d.value.checked)
        .on "click",  (d)->
          console.log "method checked", $(this).is(':checked')
          d.value.checked = $(this).is(':checked')

      
      @bind_tree_events()

  return ClassMethodQueryView