#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 18:12:56
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 21:07:19

define [
  "jquery"
], ($) ->
  
  class SignalFilterController
    
    constructor: (options) ->
      @options = options
      #init a treegrid for query results
      
      
     
    pop: ()->
      $("#signal-filter-window").window("open")
    
      #$('#search-result-treegrid').treegrid("loadData", data.results)
                      
            
  return SignalFilterController