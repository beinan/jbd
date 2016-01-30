define [
  "jquery"
  "views/panel_view"
  "views/class_method_query_view"  
], ($, PanelView, ClassMethodQueryView) ->
  
  class ClassMethodFilterController
    
    constructor: (options) ->

      @options = options
      @panel = new PanelView
        title: "Select classes"
        class_name: "info"

      
      @panel.hide()
      @options.container.append(@panel.el)
      
      

    show: (jvm_process)->
      @panel.show("fast")   
      controller = this
      $(@panel.body).html("")
      jvm_process.get_class_meta().done (meta)->
        view = new ClassMethodQueryView
          model: jvm_process
          collection: meta
          el: controller.panel.body

      query_btn = $('<input class="btn btn-danger query-button" type="button" value="Visualize">')
      $(@panel.footer).append(query_btn) 
      $(query_btn).on "click", ()->
        jvm_process.load_actors().done ()-> 
          #alert("data loaded")
          window.location.hash = 'visualize/' + jvm_process.id
      #$(@panel.footer).append('<a href="#visualize/' + jvm_process.id + '" class="btn btn-danger">Visualize
      #        </a>')  
                      
            
  return ClassMethodFilterController
