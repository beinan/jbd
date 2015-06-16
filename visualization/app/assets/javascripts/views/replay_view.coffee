# Replay View
# @Author: Beinan
# @Date:   2015-01-13 22:52:31
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:54:26

define [
  "jquery"
  "backbone"
  "d3"
  "views/tab_view"
  "views/source_code_view"
  ], ($, Backbone, d3, TabView, SourceCodeView) ->

  class ReplayView extends Backbone.View
    
    initialize: ()->
      tab = new TabView
        tab_keys: ["Monitor", "Source"]
        
      @$el.append(tab.el)
        
      #value monitor table
      @table = d3.select(tab.get_tab_body("Monitor")).append("table").attr("class", "table table-bordered")  
      @table.append("thead").append("tr").selectAll("td").data(@collection.models).enter()
        .append("td").text (field)->
          field.get("field_name")

      #render value monitor table
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
  
      #event handler on position changed
      @model.on "change:pos", ()->
        process_bar.attr
          "aria-valuenow":"#{@model.get("pos")}" 
          "style": "width: #{@model.get("pos") / @model.get("total") * 100}%"
        .text @model.get("pos") + "/" + @model.get("total")  
      ,@

      detail_div = d3.select(@el).append("div").attr("class", "debug-detail")
      status_span = detail_div.append("span")
        .attr("class","label label-info")
        .attr("style", "font-size:14px; margin-right: 10px;")
        .text "no status available"

      @model.on "change:status", ()->
        status_span.text @model.get("status")
        #console.log "current signal in replay process", @model.get("current_signal")
        
      ,@

      
      #source code view
      source_code_view = new SourceCodeView
        el: tab.get_tab_body("Source")
        model: @model
        
      view = @
      step_into_button = detail_div.append("button")
        .attr
          "class":"btn btn-success"
        .text("Step Into")  
        .on "click",()->
          if view.model.get("current_method_invocation")?
            to_lifeline = view.model.get("current_method_invocation").to_lifeline()
            console.log "current method invocation", to_lifeline
            tab.show("Source")
            #getting code by classname and method name
            source_code_view.show(to_lifeline)
          else
            alert("Replay context is not reday: current method invocation is unavailable.")
     
  

  return ReplayView
