# Field filter controller
# @Author: Beinan
# @Date:   2015-01-10 22:00:59
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:43:30
define [
  "jquery"
  "views/field_filter_view"  
], ($, FieldFilterView) ->
  
  class FieldFilterController
    
    constructor: (options) ->
      @options = options
      @container = $(options.container)
      @jvms = options.jvm_processes
    
      
     
    show: ()->
        
      view = new FieldFilterView
        collection: @jvms
      view.render()
      body = @container.find(".panel-body")
      body.html(view.el)

            
  return FieldFilterController