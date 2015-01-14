define [
  "jquery"
  
  "views/class_method_query_view"  
], ($, ClassMethodQueryView) ->
  
  class ClassMethodFilterController
    
    constructor: (options) ->
      @options = options
      @container = $(options.container)

      #@recordFilters = new RecordFilterColl
      
      # #init a treegrid for query results
      # treegrid_options = 
      #   idField: 'id',
      #   treeField:'_id',
      #   selectOnCheck: false,
      #   columns:[[
      #     {title:'Class Name',field:'_id',width:280},
      #     {field:'invocation_count',title:'Invocation Count',width:100,align:'right'},
      #     {field:'thread_count',title:'Thread Count',width:90,align:'right'},          
      #     {title:'Selected',field:'ck', checkbox:true,width:80},
      #   ]]
      #   onCheck: (row, index)-> #bind event on checkbox selected
      #     console.log "row selected", row
      #     options.record_filters.add
      #       id: row.filter_string
      #       type: row.filter_type
      
      #   onUncheck: (row, index)->  #bind event on checkbox unselected
      #     console.log "row unselected", row
      #     options.record_filters.remove
      #       id: row.filter_string
      #       type: row.filter_type    

      
      
     
    pop: (jvm_process)->
      console.log "hay", jvm_process      
      @container.modal("show")
      controller = this
      jvm_process.get_class_meta (meta)->
        view = new ClassMethodQueryView
          collection: meta
        view.render()
        body = controller.container.find(".modal-body")
        body.html(view.el)

      @container.on "hidden.bs.modal", ()->
        jvm_process.load_actors()  
                      
            
  return ClassMethodFilterController