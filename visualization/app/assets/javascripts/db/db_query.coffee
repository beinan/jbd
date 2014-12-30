#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2014-12-29 23:04:23
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 23:06:03
define [
  "jquery",
  "routes"
], ($, routes) ->

  dbQuery = (q, callback) ->
    console.log "a mongodb query is sending", q
    qr = jsRoutes.controllers.MainController.query()
    $.ajax
      url: qr.url
      type: qr.type
      dataType: "json"
      contentType: "application/json; charset=utf-8"
      data: JSON.stringify(q)
      success: callback

  return dbQuery