# Router for the entire application
# @Author: Beinan
# @Date:   2014-12-25 17:22:58
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 17:23:00
define [
  "jquery"
  "backbone"
  "collections/record_filter_coll"
  "collections/actor_coll"
  "collections/signal_coll"  
  "data_controllers/seq_diagram_controller"
  "data_controllers/class_method_filter_controller"
  "data_controllers/signal_filter_controller"
  "data_controllers/reasoning_graph_controller"  
], ($, Backbone, RecordFilterColl, ActorColl, SignalColl, SeqDiagramController, 
  ClassMethodFilterController, SignalFilterController, ReasoningGraphController) ->

  class AppRouter extends Backbone.Router
    initialize: ()->
      @recordFilters = new RecordFilterColl
      @actors = new ActorColl()
      @signals = new SignalColl()
      
      #filter the data by class name and method name
      @classMethodFilterController = new ClassMethodFilterController
        record_filters: @recordFilters


      #signal filter
      @signalFilterController = new SignalFilterController
        record_filters: @record_filters
        signals : @signals

      #control the seq diagram
      @seqDiagramController = new SeqDiagramController
        record_filters: @recordFilters
        actors: @actors
        signals: @signals
        container: "#diagram"

      @reasoningController = new ReasoningGraphController
        signals: @signals


      Backbone.history.start()


    routes:
      "":"main"
      "pop_class_method_filter": "pop_class_method_filter"
      "pop_signal_filter": "pop_signal_filter" 
      "pop_reasoning": "pop_reasoning"

    main: ()->      
      #@seqDiagramController.start()

    pop_class_method_filter: ()->
      @classMethodFilterController.pop()
      this.navigate("") #back to main window  

    pop_signal_filter: ()->
      @signalFilterController.pop()
      this.navigate("") #back to main window  

    pop_reasoning: ()->
      @reasoningController.pop()
      this.navigate("") #back to main window  



  return AppRouter

