# CoffeeScript
# @Author: Beinan
# @Date:   2014-12-24 22:09:52
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 17:40:16
define [
  "jquery"
  "db/db_query"
  "models/actor"  
  "views/panel_view"
  "views/seq_diagram_view"
], ($, dbQuery, Actor, PanelView, SeqDiagramView) ->
  
  
  class SeqDiagramController
    
    constructor: (options)->
      @options = options
      
    show: (jvm)->
      
      @panel = new PanelView
        title: "Sequence Diagram for " + jvm.id 
        class_name: "warning"
      @options.container.append(@panel.el)
    
      @diagram_view = new SeqDiagramView
        model: jvm
        el : @panel.body
      @diagram_view.render() 

      $(@panel.footer).append('<a href="#reasoning/' + jvm.id + 
        '" class="btn btn-primary">Dependency Graph</a>') 

      $(@panel.footer).append('<a href="#replay/' + jvm.id + 
        '" class="btn btn-warning">Replay</a>') 

      query_btn = $('<input class="btn btn-default query-button" type="button" value="Discard">')
      $(@panel.footer).append(query_btn) 
      controller = this
      $(query_btn).on "click", ()->
        controller.panel.remove()
      
       

  return SeqDiagramController