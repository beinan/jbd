# Collection of JVM Process
# @Author: Beinan
# @Date:   2015-01-09 23:37:08
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 23:38:14

define [
  "backbone"
  "models/jvm_process"
], (Backbone, JVMProcess) ->

  class JVMProcessColl extends Backbone.Collection
    
    model: JVMProcess

    initialize: ()->

    

  return JVMProcessColl