#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 21:33:44
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 19:48:21
define [
  "backbone"
  "models/actor"
], (Backbone, Actor) ->

  class FieldVisitor extends Backbone.Model
    initialize:()->
      field_info = @get("field").split('@')
      field_name_type = field_info[1].split(',')
      @class_name = field_info[0]
      @field_name = field_name_type[0]
      @field_type = field_name_type[1]  

    title: ()->
      @get("field") + "(" + @get("value") + ")"


  class Signal extends Backbone.Model
    initialize: ()->
      
    title: ()->
      to_lifeline = @to_lifeline()
      if to_lifeline?
        to_lifeline.get("method_name")
      else if @get("field_visitor")? 
        @get("field_visitor").title()
      else
        "unknown"        
    
    set_field_visitor:(data)->
      field_visitor = new FieldVisitor(data)
      @set("field_visitor", field_visitor)

    to_lifeline: ()->
      Actor.lookup_lifeline(@get("to_id"))
      
    to_actor: ()->
      @to_lifeline.get("actor")

    
  return Signal
