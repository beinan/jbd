#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 21:32:16
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 21:33:31

define [
  "backbone"
  "models/signal"
], (Backbone, Signal) ->

  class SignalColl extends Backbone.Collection
    
    model: Signal

    initialize: ()->

    

  return SignalColl
