# Model of jvm process
# @Author: Beinan
# @Date:   2015-01-09 23:35:00
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 21:03:43

define [
  "jquery"
  "backbone"
  "db/db_query"
  "db/group_by_method"
  "models/signal_dep_graph"
  "collections/actor_coll"
  "collections/signal_coll"
  "collections/class_meta_coll"
], ($, Backbone, dbQuery, GroupByMethod, SignalDepGraph, ActorColl, SignalColl, ClassMetaColl) ->

  class MethodDesc
    constructor: (desc) ->
      @owner = desc.split('#')[0]
      @method = desc.split('#')[1].split('(')[0] + "()"
  
  class JVMProcess extends Backbone.Model
    initialize: ()->
      @actors = new ActorColl
      @signals = new SignalColl
      @replay_process_model = new Backbone.Model
    
    load_actors: ()->
      model = this
      model.get_class_meta().then (class_meta_coll)->
        promises = []
        for class_meta in class_meta_coll.models
          for query in class_meta.mongo_query_objs("method_enter") 
            #console.log "query",query
            promises.push(dbQuery(query))
            
        console.log promises
        $.when.apply($, promises).then ()->
          #data is in the arguments           
          #console.log "data filter:query result",arguments
          add_actor_promises = []
          
          #if there is only one promise, arguments is not a two dimentional array
          for query in (if promises.length is 1 then [arguments] else arguments)
            for method_entry in query[0]
              #console.log "method entry", method_entry                
              add_actor_promises.push model.add_actor_from_method_entry(method_entry)
          #return the following promise as the final result of load_actors() function
          $.when.apply($, add_actor_promises)
          
            
    add_actor_from_method_entry: (method_entry)->
      console.log "add method entry", method_entry
      method_desc = new MethodDesc method_entry["method_desc"]
      actor_id = method_desc.owner
      if method_entry.owner_ref?  #for non-static method, add object ref id
        actor_id = actor_id + ":" + method_entry.owner_ref
      
      actor = @actors.add #duplicated actors will be ignored
        id: actor_id
        owner: method_desc.owner
        owner_ref: method_entry.owner_ref

      lifeline = actor.add_lifeline 
        id: method_entry.invocation_id + "@" + method_entry.thread_id
        method_name: method_desc.method
        thread_id: method_entry.thread_id
        invocation_id: method_entry.invocation_id
      qf_promise = @query_field_visitor(actor, lifeline)  

      #@query_invokee_signals(actor, lifeline)
      qi_promise = @query_invoker_signals(actor, lifeline)
        
      #return a promise
      return $.when(qf_promise, qi_promise)
      
    query_field_visitor: (from_actor, from_lifeline)->
      model = this
      #query the invoker information
      dbQuery
        parent_invocation_id: from_lifeline.get("invocation_id")
        thread_id: from_lifeline.get("thread_id")
        msg_type: {"$regex": "^field_"}  #field_setter or field_getter
      .then (data) ->
          for field_visitor in data
            from_id = from_lifeline.id
            to_id = field_visitor.invocation_id + "@" + field_visitor.thread_id
            #console.log "field_visitor", field_visitor
            signal = model.signals.add
              id: to_id #todo: now using to_id as the id, which may be not unique
              from_id: from_id
              to_id: to_id
              thread_id: field_visitor.thread_id
              invocation_id: field_visitor.invocation_id

            signal.set_field_visitor(field_visitor)

    query_invokee_signals: (from_actor, from_lifeline) ->
      model = this
      #query the invoker information
      dbQuery
        parent_invocation_id: from_lifeline.get("invocation_id")
        thread_id: from_lifeline.get("thread_id")
        msg_type: "method_invoke"  #field_setter or field_getter
      .then (data) ->
          for method_invoke in data
            from_id = from_lifeline.id
            to_id = method_invoke.invocation_id + "@" + method_invoke.thread_id
            #console.log "field_visitor", field_visitor
            signal = model.signals.add
              id: to_id #todo: now using to_id as the id, which may be not unique
              from_id: from_id
              to_id: to_id
              thread_id: method_invoke.thread_id
              invocation_id: method_invoke.invocation_id
            signal.set_method_invocation(method_invoke)
            
    query_invoker_signals:(to_actor, to_lifeline)->
      model = this
      #query the invoker information
      dbQuery
        invocation_id: to_lifeline.get("invocation_id") - 1
        thread_id: to_lifeline.get("thread_id")
        msg_type: "method_invoke"
      .then (data) ->
          console.log "method_invoker query", data
          if(data.length > 0)
            from_id = data[0].parent_invocation_id + "@" + data[0].thread_id
          else
            from_id = "unknown" + "@" + to_lifeline.get("thread_id")
          to_id = to_lifeline.id
          model.signals.add
            id: to_id #todo: now using to_id as the id, which may be not unique
            from_id: from_id
            to_id: to_id
            thread_id: to_lifeline.get("thread_id")
            invocation_id: to_lifeline.get("invocation_id") - 1
    
    #get class and method meta data of this jvm process
    #return a defered object of class meta information
    get_class_meta: ()->  
      if @class_meta?
        deferred = $.Deferred()
        deferred.resolve  @class_meta
        return deferred

      meta_coll = new ClassMetaColl
      model = this          
      GroupByMethod.map_reduce().then (data)->
        for entry in data.results #for each class
          entry.id = entry._id
          meta_coll.add(entry)
        model.class_meta = meta_coll
        return meta_coll
        #callback meta_coll  
          
      

    get_field_tree_filter: ()->
      if !@field_tree_filter?
        @field_tree_filter = {}
      for signal, i in @signals.models
        if(signal.get("field_visitor")?)
          class_name = signal.get("field_visitor").class_name
          field_name =  signal.get("field_visitor").field_name  
          thread_id = signal.get("thread_id")  
          @field_tree_filter[class_name] ?= {}
          @field_tree_filter[class_name][field_name] ?= {checked: true}
          @field_tree_filter[class_name][field_name][thread_id] ?= 1
      console.log "get_field_tree_filter", @field_tree_filter
      @field_tree_filter

    generate_signal_dependency_graph: ()->
      field_filter = @get_field_tree_filter()
      graph = new SignalDepGraph @signals.models,field_filter
      return graph 
      
            
  return JVMProcess

