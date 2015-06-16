define [
  "jquery",
  "routes"
], ($, routes) ->

  get_source_code = (class_name, method_name, callback) ->
    console.log "geting source of " + class_name + "///" + method_name
    qr = jsRoutes.controllers.MainController.getSourceCode()
    q =
      class_name: class_name
      method_name: method_name
      
    $.ajax
      url: qr.url
      type: qr.type
      dataType: "json"
      contentType: "application/json; charset=utf-8"
      data: JSON.stringify(q)
      success: callback

  return get_source_code


