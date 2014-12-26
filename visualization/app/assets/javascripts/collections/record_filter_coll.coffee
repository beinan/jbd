# Backbone collection for RecordFilter
# @Author: Beinan
# @Date:   2014-12-25 17:30:19
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-25 17:50:20

define [
  "backbone"
  "models/record_filter"
], (Backbone, RecordFilter) ->

  class RecordFilterColl extends Backbone.Collection
    
    model: RecordFilter

    initialize: ()->

    

  return RecordFilterColl

