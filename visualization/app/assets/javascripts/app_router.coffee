# Router for the entire application
# @Author: Beinan
# @Date:   2014-12-25 17:22:58
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:56:32
define [
  "jquery"
  "backbone"
  "collections/jvm_process_coll"
  "collections/actor_coll"
  "collections/signal_coll"  
  "data_controllers/jvm_process_filter_controller"
  "data_controllers/seq_diagram_controller"
  "data_controllers/class_method_filter_controller"
  "data_controllers/signal_filter_controller"
  "data_controllers/field_filter_controller"
  "data_controllers/reasoning_graph_controller"
  "data_controllers/replay_controller"  
], ($, Backbone, JVMProcessColl, ActorColl, SignalColl, 
  JVMProcessFilterController, SeqDiagramController, 
  ClassMethodFilterController, SignalFilterController, 
  FieldFilterController, ReasoningGraphController, ReplayController) ->

  class AppRouter extends Backbone.Router
    initialize: ()->
      @jvm_processes = new JVMProcessColl
      @container = $('#main-container')
      @processFilterController = new JVMProcessFilterController
        jvm_processes : @jvm_processes
        container: @container

      #filter the data by class name and method name
      @classMethodFilterController = new ClassMethodFilterController
        container: @container


      # #signal filter
      # @fieldFilterController = new FieldFilterController
      #   jvm_processes : @jvm_processes
      #   container: "#field_filter_panel"

      #control the seq diagram
      @seqDiagramController = new SeqDiagramController
        #jvm_processes : @jvm_processes
        container: @container

      @reasoningController = new ReasoningGraphController
        container: @container

      @replayController = new ReplayController
        container: @container

      Backbone.history.start()


    routes:
      "":"main"
      "query_classes/:jvm_id": "show_class_method_filter"
      "show_field_filter": "show_field_filter" 
      "reasoning/:jvm_id": "show_reasoning_graph"
      "visualize/:jvm_id" : "draw_seq_diagram"
      "replay/:jvm_id" : "replay"

    main: ()->
      @processFilterController.show()
      #@seqDiagramController.start()

    

    show_class_method_filter: (jvm_id)->
      @classMethodFilterController.show(@jvm_processes.get(jvm_id))        
      this.navigate("") #back to main window  

    show_field_filter: ()->
      $('#field_filter_panel').toggleClass("hidden")
      $('#show_field_filter_btn').toggleClass("active")      
      @fieldFilterController.show()
      this.navigate("") #back to main window  

    show_reasoning_graph: (jvm_id)->
      
      @reasoningController.show(@jvm_processes.get(jvm_id))
      this.navigate("") #back to main window  

    draw_seq_diagram: (jvm_id)->
      @seqDiagramController.show(@jvm_processes.get(jvm_id))
      this.navigate("") #back to main window  

    replay: (jvm_id)->
      @replayController.show(@jvm_processes.get(jvm_id))
      this.navigate("") #back to main window  


  return AppRouter

