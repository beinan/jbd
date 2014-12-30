# CoffeeScript
# @Author: Beinan
# @Date:   2014-12-24 22:09:52
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 23:15:01
define [
  "jquery"
  "db/db_query"
  "models/actor"  
  "collections/actor_coll"
  "collections/signal_coll"
  "views/seq_diagram_view"
], ($, dbQuery, Actor, ActorColl, SignalColl, SeqDiagramView) ->
  
  
  class MethodDesc
    constructor: (desc) ->
      @owner = desc.split('#')[0]
      @method = desc.split('#')[1].split('(')[0] + "()"


  class SeqDiagramController
    
    constructor: (options)->
      @options = options
      @actors = new ActorColl()
      @signals = new SignalColl()
      @diagram_view = new SeqDiagramView
        collection:@actors

      controller = this
      options.record_filters.on "add", (filter)->
        #console.log "data filter added" , filter
        dbQuery filter.mongo_query_obj("method_enter"),
          (data)->
            #console.log "data filter:query result",data
            for method_entry in data
              controller.add_method_entry method_entry
              
      # @diagram.on "selection_change", (dom, data)->
      #   console.log data
      #   $('#prop-window').window('open')
      #   method_desc = new MethodDesc data.data.method_desc
      #   grid_data = 
      #     rows:[
      #       {name:"Class Name", value:method_desc.owner, group:"Method Info"},
      #       {name:"Method Name", value:method_desc.method, group:"Method Info"},
      #       {name:"a", value:"b", group:"Method Arguments", editor:"text"},
      #       {name:"a", value:"b", group:"Method Arguments", editor:"text"}
      #     ]
      #   $('#prop-grid').propertygrid
      #       data: grid_data
      #       showGroup: true
      #       scrollbarSize: 0
      #   $('#prop-grid').propertygrid('appendRow', data.data);


    add_method_entry: (method_entry)->
      #console.log "add method entry", method_entry
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

      @query_invokder_signals(actor, lifeline)


    query_invokder_signals:(to_actor, to_lifeline)->
      #query the invoker information
      dbQuery
        invocation_id: to_lifeline.get("invocation_id") - 1
        thread_id: to_lifeline.get("thread_id")
        msg_type: "method_invoke"
        , (data) ->
          if(data.length > 0)
            from_id = data[0].parent_invocation_id + "@" + data[0].thread_id
            to_id = to_lifeline.id
            @signals.add
              from_id: from_id
              to_id: to_id

    # query_signals: (from_actor, from_lifeline)->
    #   #TODO:jvm id
    #   dbQuery 
    #     parent_invocation_id: from_lifeline.get("invocation_id")
    #     thread_id: from_lifeline.get("thread_id")
    #     msg_type: "method_invoke" 
    #     , (data)->
    #       #console.log "add_signals: query result", data
    #       for inv in data
    #         invokee_id = (data.invocation_id + 1) + "@" + data.thread_id
    #         to_actor = Actor.lookup_actor_by_lifeline_id invokee_id
    #         if(to_actor?)
    #           console.log("add signal:", data.method_desc)



    # start: ->
    #   that = this

    #   dbQuery {msg_type: "method_enter", method_desc:{$regex: "^samples"}},
    #     (data)->
    #       console.log data 
    #       me = that.diagram.addActor("Me")
    #       method_desc = new MethodDesc(data[0]["method_desc"])
    #       invokee = that.diagram.addActor(method_desc.owner)
          
    #       #enter point
    #       method_name = method_desc.method
                    
    #       invoker_lifeline = invokee.addLifeline(method_name, data[0])
    #       s = that.diagram.addSignal(me, invoker_lifeline, invokee, null, method_name, data[0])          
          
    #       that.launch(invokee, s.toLifeline)
 
    #       that.draw()
    
    # #collect the invocation information of a lifeline      
    # launch: (invoker, lifeline) ->
    #   that = this
    #   dbQuery 
    #     parent_invocation_id: lifeline.data.invocation_id,
    #     msg_type: "method_invoke" 
    #     (data)->
    #       data.sort (a, b)->
    #         a["invocation_id"] - b["invocation_id"]
    #       #for each method invocatio from invoker
    #       this_controller = that
    #       for invoc_data in data
                      
    #         method_desc = new MethodDesc(invoc_data["method_desc"])
    #         invokee = that.diagram.addActor(method_desc.owner)
    #         method_name = method_desc.method
            

    #         s = that.diagram.addSignal(invoker, lifeline, invokee, null, method_name, invoc_data)
            
    #         s.toLifeline.data.invocation_id = s.toLifeline.data.invocation_id + 1 #IMPROVE ME
    #         that.launch invokee, s.toLifeline
    #       that.draw()  
          

    # draw: ->
    #   @diagram.drawSVG(@options.container)

  # 
  # a = diagram.addActor("A")
  # b = diagram.addActor("B")
  # c = diagram.addActor("C")
  # s = diagram.addSignal(a, 1, 1, b, "Hello")
  # s = diagram.addSignal(a, 1, 1, a, "back")
  # diagram.addSignal a, 1, 1, c, "back"
  # diagram.addSignal c, 1, 1, b, "back"
  # console.log diagram.actors
  # diagram.drawSVG "diagram"
  
  return SeqDiagramController
