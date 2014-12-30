define [
  "jquery"
  "db/group_by_method"
], ($, GroupByMethod) ->
  
  class ClassMethodFilterController
    
    constructor: (options) ->
      @options = options
      #init a treegrid for query results
      treegrid_options = 
        idField: 'id',
        treeField:'_id',
        selectOnCheck: false,
        columns:[[
          {title:'Class Name',field:'_id',width:280},
          {field:'invocation_count',title:'Invocation Count',width:100,align:'right'},
          {field:'thread_count',title:'Thread Count',width:90,align:'right'},          
          {title:'Selected',field:'ck', checkbox:true,width:80},
        ]]
        onCheck: (row, index)-> #bind event on checkbox selected
          console.log "row selected", row
          options.record_filters.add
            id: row.filter_string
            type: row.filter_type
      
        onUncheck: (row, index)->  #bind event on checkbox unselected
          console.log "row unselected", row
          options.record_filters.remove
            id: row.filter_string
            type: row.filter_type    

      $('#search-result-treegrid').treegrid(treegrid_options)        
      $("#class-search-box").searchbox     
        searcher: @searcher #bind searcher function

      
     
    pop: ()->
      $("#class-method-filter-window").window("open")
    
    searcher: (value, query_type)->            
      counter = 0 #create an increasing id for easyui treegrid
      GroupByMethod.map_reduce (data)->
        console.log data
        for entry in data.results #for each class
          entry.children = []
          entry.id = ++counter
          entry.state = "closed"
          entry.filter_type = "class"
          entry.filter_string = entry._id
          for method_name, value of entry.value  #for each method
            invocation_entry = 
              id: ++counter
              _id: method_name
              invocation_count: value.count
              class_name: entry._id  #for further query
              state: "closed"
              filter_type: "method"
              filter_string : entry._id + "#" + method_name
              children: []  #for easyui tree structure
               
            thread_count = 0
            for thread_id, thread_invo_count of value.thread_info
              #for each thread of each method invocation
              invocation_entry.children.push
                id:++counter
                _id: "thread:" + thread_id
                invocation_count: thread_invo_count
                class_name: entry._id
                method_name: method_name
              thread_count++
            invocation_entry["thread_count"] = thread_count
            entry.children.push invocation_entry
            
        $('#search-result-treegrid').treegrid("loadData", data.results)
                      
            
  return ClassMethodFilterController