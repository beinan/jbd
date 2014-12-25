define [
  "jquery"
  "mapreducer/group_by_method"
], ($, GroupByMethod) ->
  
  class DiagramDataFilter
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
          {title:'Selected',field:'ck', checkbox:true,width:280},
        ]]
        onCheck: (index, row)->
          console.log index, row
          console.log "aaaa",$('#search-result-treegrid').treegrid("getRows")
        onUncheck: (index, row)->
          console.log index, row
          
      $('#search-result-treegrid').treegrid(treegrid_options)        
      $("#class-search-box").searchbox
        searcher: (value, query_type)->            
          counter = 0 #create an increasing id for easyui treegrid
          GroupByMethod.map_reduce (data)->
            console.log data
            for entry in data.results #for each class
              entry.children = []
              entry.id = ++counter
              entry.state = "closed"
              for key, value of entry.value  #for each method
                entry.children.push 
                  id: ++counter
                  _id: key
                  invocation_count: value
                  class_name: entry._id  #for further query
            $('#search-result-treegrid').treegrid("loadData", data.results)
                          
      
      #open a dialog for searching
      $("#search-button").bind "click", (e)->
        $("#search-window").window("open")
        
      $("#search-result-selection-apply").bind "click", (e) ->
        options.selectionChanged {}


  return DiagramDataFilter