# Bootstrap panel
# @Author: Beinan
# @Date:   2015-01-13 22:52:31
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:54:26

define [
  "jquery"
  "backbone"
  "d3"
  ], ($, Backbone, d3) ->

  class PanelView extends Backbone.View
    
    className: "panel panel-success"

    initialize: (options)->
      @options = options
      @options.class_name ?= "success" 
      @$el.addClass("panel-#{@options.class_name}")
      if @options.title?
        @$el.append('<div class="panel-heading">' + @options.title + '</div>') 
      @body = $('<div class="panel-body"></div>')
      @$el.append(@body); 

      @footer = $('<div class="panel-footer"></div>')
      @$el.append(@footer); 
     
    show: (options)->
      @$el.show(options)

    hide: (options)->
      @$el.hide(options)

  return PanelView