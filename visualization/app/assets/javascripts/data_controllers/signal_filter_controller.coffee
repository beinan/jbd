#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 18:12:56
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 22:29:44

define [
  "jquery"
], ($) ->
  
  class SignalFilterController
    
    constructor: (options) ->
      @options = options
      #init a treegrid for query results
      
      
     
    pop: ()->
      #collect signals from 
      #collect_signals = (row) ->

      treegrid_options = 
        idField: 'id',
        treeField:'_id',
        selectOnCheck: false,
        columns:[[
          {title:'Class Name',field:'_id',width:280},
          {title:'Reads',field:'reads',width:48},
          {title:'Writes',field:'writes',width:48},
          {title:'Selected',field:'ck', checkbox:true,width:80},
        ]]
        onCheck: (row, index)-> #bind event on checkbox selected
          if(row.children?)
            for child in row.children
              $('#field-visitor-treegrid').treegrid("checkRow", child.id)
            
          #console.log "row selected", row
          
        onUncheck: (row, index)->  #bind event on checkbox unselected
          console.log "row unselected", row
          
      $('#field-visitor-treegrid').treegrid(treegrid_options)        
      $('#field-visitor-treegrid').treegrid("loadData", @signal_data())
        
      $("#signal-filter-window").window("open")
    
      #$('#search-result-treegrid').treegrid("loadData", data.results)
    
    

  return SignalFilterController