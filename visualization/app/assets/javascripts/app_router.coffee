# Router for the entire application
# @Author: Beinan
# @Date:   2014-12-25 17:22:58
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 20:54:42
define [
  "jquery"
  "backbone"
  "collections/record_filter_coll"
  "data_controllers/seq_diagram_controller"
  "data_controllers/class_method_filter_controller"
  "data_controllers/signal_filter_controller"  
], ($, Backbone, RecordFilterColl, SeqDiagramController, 
  ClassMethodFilterController, SignalFilterController) ->

  class AppRouter extends Backbone.Router
    initialize: ()->
      @recordFilters = new RecordFilterColl
      #filter the data by class name and method name
      @classMethodFilterController = new ClassMethodFilterController
        record_filters: @recordFilters

      #signal filter
      @signalFilterController = new SignalFilterController
        record_filters: @record_filters

      #control the seq diagram
      @seqDiagramController = new SeqDiagramController
        record_filters: @recordFilters
        container: "#diagram"

      Backbone.history.start()


    routes:
      "":"main"
      "pop_class_method_filter": "pop_class_method_filter"
      "pop_signal_filter": "pop_signal_filter" 

    main: ()->      
      #@seqDiagramController.start()

    pop_class_method_filter: ()->
      @classMethodFilterController.pop()
      this.navigate("") #back to main window  

    pop_signal_filter: ()->
      @signalFilterController.pop()
      this.navigate("") #back to main window  



  return AppRouter

