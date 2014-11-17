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
          a = that.diagram.addActor("Me")
          invoke_desc = data[0]["method_desc"]
          that.diagram.addActor(invoke_desc.split('#')[0])
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
