# JVM Process Filter Data Controller
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-09 23:23:19
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 00:28:32
define [
  "jquery"
  "db/group_by_jvm_process"
  "views/jvm_process_filter_view"
], ($, GroupByJVMProcess, JVMProcessFilterView) ->
  
  class JVMProcessFilterController
    
    constructor: (options) ->
      @options = options
      @view = new JVMProcessFilterView
        collection: options.jvm_processes
        el: $(options.container).get(0)
      
      controller = this
      GroupByJVMProcess.map_reduce (data)->
        for jvm_info in data.results
          controller.options.jvm_processes.add
            id: jvm_info._id
            count : jvm_info.value.count
        controller.view.render()
      
  return JVMProcessFilterController