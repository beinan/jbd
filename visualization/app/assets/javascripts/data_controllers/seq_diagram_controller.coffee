# CoffeeScript
# @Author: Beinan
# @Date:   2014-12-24 22:09:52
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 17:40:16
define [
  "jquery"
  "db/db_query"
  "models/actor"  
  "views/seq_diagram_view"
], ($, dbQuery, Actor, SeqDiagramView) ->
  
  
  class SeqDiagramController
    
    constructor: (options)->
      @options = options
      @diagram_view = new SeqDiagramView
        collection: @options.jvm_processes
        el : $(options.container).get(0)

    draw: ()->
      @diagram_view.render() 
      

    
  return SeqDiagramController