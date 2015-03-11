#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 21:33:44
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 20:26:35
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
      @get("msg_type").split("_")[1] + " " + @field_name + "(" + @get("value") + ")"
  
  class MethodInvocation extends Backbone.Model
    initialize:()->
      method_info = @get("method_desc").split('#')
      method_name_type = method_info[1].split(')')
      @class_name = method_info[0]
      @method_name = method_name_type[0] + ")"
      @method_type = method_name_type[1]  

    title: ()->
      "invoke " + @method_name
  

  class Signal extends Backbone.Model
    initialize: ()->
          
    title: ()->
      to_lifeline = @to_lifeline()
      if to_lifeline?
        to_lifeline.get("method_name")
      else if @get("field_visitor")? 
        @get("field_visitor").title()
      else if @get("method_invocation")?
        @get("method_invocation").title()
      else
        "unknown"        
    
    set_field_visitor:(data)->
      field_visitor = new FieldVisitor(data)
      @set("field_visitor", field_visitor)

    set_method_invocation: (data) ->
      method_invocation = new MethodInvocation data
      @set("method_invocation", method_invocation)

    to_lifeline: ()->
      Actor.lookup_lifeline(@get("to_id"))
      
    to_actor: ()->
      to_lifeline = @to_lifeline()
      if to_lifeline?
        to_lifeline.get("actor")
      else
        null
    from_lifeline: ()->
      Actor.lookup_lifeline(@get("from_id"))
      
    from_actor: ()->
      from_lifeline = @from_lifeline()
      if from_lifeline?
        from_lifeline.get("actor")
      else
        null


  return Signal
