#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-10 00:00:07
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 00:22:41

define [
  "jquery",
  "routes"
], ($, routes) ->

  class GroupByJVMProcess
    @map: ()->
      if(this.method_desc?)
        info = 
          count : 1
          start_time: this.created_datetime
        emit(this.jvm_name, info)
    
    @reduce: (jvmname, infos)->
      result = 
        count : 0
      for info in infos
        result.count += info.count
        result.start_time = info.start_time
      result
        
    @map_reduce: (success_callback)->
      r = routes.controllers.MainController.mapReduce("trace")
      request = 
        url: r.url,
        type: r.type,
        dataType : 'json',
        contentType : 'application/json; charset=utf-8',
        data: JSON.stringify({map: this.map.toString(), reduce:this.reduce.toString()}),
        success: success_callback

      console.debug("Map Reduce request:", request)  
      $.ajax(request)

  return GroupByJVMProcess

