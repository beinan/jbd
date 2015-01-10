#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 18:12:56
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 20:12:09

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
    
    #construct the data of the tree view of the signals                   
    signal_data:()->
      dict = {}
      for signal, i in @options.signals.models
        if(signal.get("field_visitor")?)
          class_name = signal.get("field_visitor").class_name
          field_name =  signal.get("field_visitor").field_name  
          thread_id = signal.get("thread_id")  
          dict[class_name] ?= {}
          dict[class_name][field_name] ?= {}
          dict[class_name][field_name][thread_id] ?= []
          dict[class_name][field_name][thread_id].push signal;

      data = []
      counter = 0 #create an increasing id for easyui treegrid      
      
      #generate field rows for each field under the class
      generate_fields_rows = (class_info)->
        fields = []
        for field_name, field_info of class_info
          fields.push
            id: ++counter
            _id: field_name
            children: generate_threads_rows(field_info)
            state : "closed"
        return fields

      #generate thread rows for each thread under the field
      generate_threads_rows = (field_info)->
        threads = []
        for thread_id, signals_in_thread of field_info
          # signals = (
          #   {id: ++ counter, _id: signal.title(), signal: signal} for singal in signals_in_thread
          # )
          reads = 0
          writes = 0
          for signal in signals_in_thread
            if(signal.get("field_visitor").get("msg_type") is "field_getter")
              reads++
            else
              writes++

          threads.push
            id: ++counter
            _id: thread_id
            reads : reads
            writes : writes
            signals: signals_in_thread
        return threads

      for class_name, class_info of dict
        data.push
          id: ++counter
          _id : class_name
          children: generate_fields_rows(class_info)        
                
      return data

  return SignalFilterController