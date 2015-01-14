# Router for the entire application
# @Author: Beinan
# @Date:   2014-12-25 17:22:58
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 14:55:27
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
], ($, Backbone, JVMProcessColl, ActorColl, SignalColl, 
  JVMProcessFilterController, SeqDiagramController, 
  ClassMethodFilterController, SignalFilterController, 
  FieldFilterController, ReasoningGraphController) ->

  class AppRouter extends Backbone.Router
    initialize: ()->
      @jvm_processes = new JVMProcessColl
      @actors = new ActorColl()
      @signals = new SignalColl()
      
      @processFilterController = new JVMProcessFilterController
        jvm_processes : @jvm_processes
        container: "#process_filter_tree"

      #filter the data by class name and method name
      @classMethodFilterController = new ClassMethodFilterController
        container: "#classes_db_query_dialog"


      #signal filter
      @fieldFilterController = new FieldFilterController
        jvm_processes : @jvm_processes
        container: "#field_filter_panel"

      #control the seq diagram
      @seqDiagramController = new SeqDiagramController
        jvm_processes : @jvm_processes
        container: "#diagram"

      @reasoningController = new ReasoningGraphController
        jvm_processes : @jvm_processes
        container: "#reasoning_graph_panel"



      Backbone.history.start()


    routes:
      "":"main"
      "show_process_filter": "show_process_filter"
      "query_classes/:jvm_id": "pop_class_method_filter"
      "show_field_filter": "show_field_filter" 
      "show_reasoning_graph": "show_reasoning_graph"
      "draw_seq_diagram" : "draw_seq_diagram"

    main: ()->
      #@seqDiagramController.start()

    show_process_filter: ()->
      $('#process_filter_panel').toggleClass("hidden")
      $('#show_process_filter_btn').toggleClass("active")      
      this.navigate("") #back to main window  

    pop_class_method_filter: (jvm_id)->
      @classMethodFilterController.pop(@jvm_processes.get(jvm_id))        
      this.navigate("") #back to main window  

    show_field_filter: ()->
      $('#field_filter_panel').toggleClass("hidden")
      $('#show_field_filter_btn').toggleClass("active")      
      @fieldFilterController.show()
      this.navigate("") #back to main window  

    show_reasoning_graph: ()->
      $('#reasoning_graph_panel').toggleClass("hidden")
      $('#show_reasoning_graph_btn').toggleClass("active")      
      @reasoningController.show()
      this.navigate("") #back to main window  

    draw_seq_diagram: ()->
      @seqDiagramController.draw()

  return AppRouter

