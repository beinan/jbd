define [
  "jquery"
  "d3"
  "raphael"
  "seq_diagram/diagram"
], ($, d3, Raphael, Diagram) ->
  
  dbQuery = (q, callback) ->

    qr = jsRoutes.controllers.MainController.query()
    $.ajax
      url: qr.url
      type: qr.type
      dataType: "json"
      contentType: "application/json; charset=utf-8"
      data: JSON.stringify(q)
      success: callback

  class SeqDiagramController
    
    diagram:undefined

    constructor: (container)->
      @diagram = new Diagram()
      @container = container

    start: ->
      that = this
      dbQuery 
        msg_type: "method_enter", 
        (data)->
          console.log data
          me = that.diagram.addActor("Me")
          invoke_desc = data[0]["method_desc"]
          invokee = that.diagram.addActor(invoke_desc.split('#')[0])
          
          #enter point
          method_name = invoke_desc.split('#')[1].split('(')[0] + "()"
                    
          s = that.diagram.addSignal(me, 1, 2, invokee, method_name)          
          method_lifeline = invokee.addLifeline(method_name)
          method_lifeline.addSignal(s)


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
