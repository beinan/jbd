#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-10 22:04:07
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 14:56:48
define [
  "jquery"
  "backbone"
  "d3"
  ], ($, Backbone, d3) ->

  class FieldFilterView extends Backbone.View
    
    className: "tree"
    initialize: ()->
      
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

      
    render: ()->
      jvm_li = d3.select(@el)
        .append("ul")
        .selectAll("li").data(@collection.models)
        .enter().append("li")

      jvm_span = jvm_li.append("span")
        .attr('class', "alert-warning")
      jvm_span.append("i").attr("class", "glyphicon glyphicon-minus")
      jvm_span.append("class_name_entry")
        .text (d) ->  d.id  
      

      #two dementional 
      class_li = jvm_li
        .append("ul")
        .selectAll("li").data((jvm)-> d3.entries(jvm.get_field_tree_filter()))
        .enter().append("li")
      class_li.append("span").html (class_data)-> 
        '<i class="glyphicon glyphicon-minus"></i> ' + class_data.key

      
      field_li = class_li
        .append("ul")
        .selectAll("li").data((class_data)-> d3.entries(class_data.value))
        .enter().append("li")
      field_li.append("span").html (field_data)-> 
        '<i class="glyphicon glyphicon-minus"></i> ' + field_data.key

      field_li.append("pick_me").text("Visualize this field")
      field_li.append("input")
        .attr("type", "checkbox")
        .property("checked", (d) -> d.value.checked)
        .on "click",  (d)->
          console.log "hay method", this.checked
          d.value.checked = this.checked
      
      @bind_tree_events()

  return FieldFilterView