# CoffeeScript
# @Author: Beinan
# @Date:   2014-12-25 17:27:28
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 23:12:43

define [
  "backbone"
], (Backbone) ->

  class RecordFilter extends Backbone.Model
    initialize: ()->
  
    #generate a mongodb query object  
    mongo_query_obj(msg_type): ->
      if(@get("type") is "class")
        method_desc_cri = 
          "$regex": "^" + @get("id")
      else
        method_desc_cri = @get("id")

      query_obj = 
        method_desc: method_desc_cri
        msg_type: msg_type

      query_obj
  return RecordFilter

