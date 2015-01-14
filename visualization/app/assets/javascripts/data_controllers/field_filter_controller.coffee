# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-10 22:00:59
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:37:11
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

    #construct the data of the tree view of the signals                   
    #update_signal_tree_data:(jvm_process)->
        
          #dict[class_name][field_name][thread_id].push signal;
      
      # data = []
      # counter = 0 #create an increasing id for easyui treegrid      
      
      # #generate field rows for each field under the class
      # generate_fields_rows = (class_info)->
      #   fields = []
      #   for field_name, field_info of class_info
      #     fields.push
      #       id: ++counter
      #       _id: field_name
      #       children: generate_threads_rows(field_info)
      #       state : "closed"
      #   return fields

      # #generate thread rows for each thread under the field
      # generate_threads_rows = (field_info)->
      #   threads = []
      #   for thread_id, signals_in_thread of field_info
      #     # signals = (
      #     #   {id: ++ counter, _id: signal.title(), signal: signal} for singal in signals_in_thread
      #     # )
      #     reads = 0
      #     writes = 0
      #     for signal in signals_in_thread
      #       if(signal.get("field_visitor").get("msg_type") is "field_getter")
      #         reads++
      #       else
      #         writes++

      #     threads.push
      #       id: ++counter
      #       _id: thread_id
      #       reads : reads
      #       writes : writes
      #       signals: signals_in_thread
      #   return threads

      # for class_name, class_info of dict
      #   data.push
      #     id: ++counter
      #     _id : class_name
      #     children: generate_fields_rows(class_info)        
                
      # return data                  
            
  return FieldFilterController