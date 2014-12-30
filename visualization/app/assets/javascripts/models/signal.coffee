#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 21:33:44
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 21:35:07
efine [
  "backbone"
], (Backbone) ->

  class Signal extends Backbone.Model
    initialize: ()->
      
    title: ()->
      title = @get("to_id")
      
    
  return Signal
