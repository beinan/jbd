define [
  "jquery"
  "d3"
  "raphael"
  "seq_diagram/diagram"
  "data_controllers/seq_diagram_data_filter"
], ($, d3, Raphael, Diagram, DiagramDataFilter) ->
  
  dbQuery = (q, callback) ->
    qr = jsRoutes.controllers.MainController.query()
    $.ajax
      url: qr.url
      type: qr.type
      dataType: "json"
      contentType: "application/json; charset=utf-8"
      data: JSON.stringify(q)
      success: callback

  class MethodDesc
    constructor: (desc) ->
      @owner = desc.split('#')[0]
      @method = desc.split('#')[1].split('(')[0] + "()"


  class SeqDiagramController
    
    constructor: (container)->
      @diagram = new Diagram()
      @container = container
      @dataFilter = new DiagramDataFilter
        selectionChanged: (data) ->
          console.log "dataFilter updated", data
          
      controller = this
      @diagram.on "selection_change", (dom, data)->
        console.log data
        $('#prop-window').window('open')
        method_desc = new MethodDesc data.data.method_desc
        grid_data = 
          rows:[
            {name:"Class Name", value:method_desc.owner, group:"Method Info"},
            {name:"Method Name", value:method_desc.method, group:"Method Info"},
            {name:"a", value:"b", group:"Method Arguments", editor:"text"},
            {name:"a", value:"b", group:"Method Arguments", editor:"text"}
          ]
        $('#prop-grid').propertygrid
            data: grid_data
            showGroup: true
            scrollbarSize: 0
        $('#prop-grid').propertygrid('appendRow', data.data);


    start: ->
      that = this

      dbQuery {msg_type: "method_enter", method_desc:{$regex: "^samples"}},
        (data)->
          console.log data 
          me = that.diagram.addActor("Me")
          method_desc = new MethodDesc(data[0]["method_desc"])
          invokee = that.diagram.addActor(method_desc.owner)
          
          #enter point
          method_name = method_desc.method
                    
          invoker_lifeline = invokee.addLifeline(method_name, data[0])
          s = that.diagram.addSignal(me, invoker_lifeline, invokee, null, method_name, data[0])          
          
          that.launch(invokee, s.toLifeline)
 
          that.draw()
    
    #collect the invocation information of a lifeline      
    launch: (invoker, lifeline) ->
      that = this
      dbQuery 
        parent_invocation_id: lifeline.data.invocation_id,
        msg_type: "method_invoke" 
        (data)->
          data.sort (a, b)->
            a["invocation_id"] - b["invocation_id"]
          #for each method invocatio from invoker
          this_controller = that
          for invoc_data in data
                      
            method_desc = new MethodDesc(invoc_data["method_desc"])
            invokee = that.diagram.addActor(method_desc.owner)
            method_name = method_desc.method
            

            s = that.diagram.addSignal(invoker, lifeline, invokee, null, method_name, invoc_data)
            
            s.toLifeline.data.invocation_id = s.toLifeline.data.invocation_id + 1 #IMPROVE ME
            that.launch invokee, s.toLifeline
          that.draw()  
          

    draw: ->
      @diagram.drawSVG(@container)

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
