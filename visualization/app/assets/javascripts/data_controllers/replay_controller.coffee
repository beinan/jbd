# Replay controller
# @Author: Beinan
# @Date:   2015-01-13 22:36:40
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:55:18

define [
  "jquery"
  "views/replay_view"  
], ($, ReplayView) ->
  
  class ReplayController
    
    constructor: (options) ->
      @options = options
      @container = $(options.container)
      @jvms = options.jvm_processes    
      @view = new ReplayView
        collection: @jvms
        el: @container.get(0)
      
     
    show: ()->        
      @view.render()
      
            
  return ReplayController