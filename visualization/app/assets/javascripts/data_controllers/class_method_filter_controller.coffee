define [
  "jquery"
  "mapreducer/group_by_method"
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
        onCheck: @rowOnCheck #bind event on checkbox selected
        onUncheck: @rowOnUncheck  #bind event on checkbox unselected
    
      $('#search-result-treegrid').treegrid(treegrid_options)        
      $("#class-search-box").searchbox     
        searcher: @searcher #bind searcher function

    rowOnCheck: (row, index)->
      console.log "row selected", row
      @options.record_filters.add
        key: row._id
        
    rowOnUncheck: (index, row)->
      console.log index, row
      
     
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
          for method_name, value of entry.value  #for each method
            invocation_entry = 
              id: ++counter
              _id: method_name
              invocation_count: value.count
              class_name: entry._id  #for further query
              state: "closed"
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