# Router for the entire application
# @Author: Beinan
# @Date:   2014-12-25 17:22:58
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-25 18:14:33
define [
  "jquery"
  "backbone"
  "collections/record_filter_coll"
  "data_controllers/seq_diagram_controller"
  "data_controllers/class_method_filter_controller"
], ($, Backbone, RecordFilterColl, SeqDiagramController, ClassMethodFilterController) ->

  class AppRouter extends Backbone.Router
    initialize: ()->
      @recordFilters = new RecordFilterColl
      #filter the data by class name and method name
      @classMethodFilterController = new ClassMethodFilterController
        record_filters: @recordFilters

      Backbone.history.start()


    routes:
      "":"main"
      "pop_class_method_filter": "pop_class_method_filter" 

    main: ()->
      
      sdc = new SeqDiagramController("#diagram")
      sdc.start()

    pop_class_method_filter: ()->
      @classMethodFilterController.pop()
      this.navigate("") #back to main window  

  return AppRouter

