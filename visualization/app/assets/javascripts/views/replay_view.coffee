# Replay View
# @Author: Beinan
# @Date:   2015-01-13 22:52:31
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:54:26

define [
  "jquery"
  "backbone"
  "d3"
  ], ($, Backbone, d3) ->

  class ReplayView extends Backbone.View
    
    initialize: ()->
      @table = d3.select(@el).append("table").attr("class", "table table-bordered")  
      @table.append("thead").append("tr").selectAll("td").data(@collection.models).enter()
        .append("td").text (field)->
          field.get("field_name")

      @table.append("tbody").append("tr").selectAll("td").data(@collection.models).enter()
        .append("td").text (field)->
          "N/A"
        .each (field)->
          dom = this
          field.on "change:value", ()->
            d3.select(dom).text field.get("value")

      process_bar = d3.select(@el).append("div").attr("class", "progress")
        .append("div").attr
          "class": "progress-bar"
          "role":"progressbar" 
          "aria-valuenow":"#{@model.get("pos")}" 
          "aria-valuemin":"0" 
          "aria-valuemax":"#{@model.get("total")}"
          "style" : "width:0%"
        .text(@model.get("pos") + "/" + @model.get("total"))   

      @model.on "change:pos", ()->
        process_bar.attr
          "aria-valuenow":"#{@model.get("pos")}" 
          "style": "width: #{@model.get("pos") / @model.get("total") * 100}%"
        .text @model.get("pos") + "/" + @model.get("total")  
      ,@
    render: ()->

  return ReplayView