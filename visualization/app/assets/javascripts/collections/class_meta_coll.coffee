# Backbone collection for RecordFilter
# @Author: Beinan
# @Date:   2014-12-25 17:30:19
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 16:32:55

define [
  "backbone"
  "models/class_meta"
], (Backbone, ClassMeta) ->

  class ClassMetaColl extends Backbone.Collection
    
    model: ClassMeta

    initialize: ()->

    

  return ClassMetaColl

