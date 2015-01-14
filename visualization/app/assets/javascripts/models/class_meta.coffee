# CoffeeScript
# @Author: Beinan
# @Date:   2014-12-25 17:27:28
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-10 21:13:10

define [
  "backbone"
], (Backbone) ->

  class ClassMeta extends Backbone.Model
    initialize: ()->
  
    #generate an array of mongodb query object for the classes and method selected 
    mongo_query_objs: (msg_type)->
      queries = []
      if(@get("checked"))
        method_desc_cri = 
          "$regex": "^" + @id
        queries.push
          method_desc: method_desc_cri
          msg_type: msg_type
        return queries  #class query will cover every method
      
      for method, info of @get("value")
        if info.checked
          queries.push 
            method_desc: @id + "#" + method
            msg_type: msg_type
      queries    

  return ClassMeta

