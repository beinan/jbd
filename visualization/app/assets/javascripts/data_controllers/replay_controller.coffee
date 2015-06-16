# Replay controller
# @Author: Beinan
# @Date:   2015-01-13 22:36:40
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:55:18

define [
  "jquery"
  "backbone"
  "views/panel_view"
  "views/tab_view"
  "views/replay_view"  
  "jquery.timer"
], ($, Backbone, PanelView, TabView, ReplayView, timer) ->
  
  class ReplayFieldModel extends Backbone.Model
    initialize:()->

  

  class ReplayFieldModelColl extends Backbone.Collection
    model: ReplayFieldModel
    initialize:()->

  class ReplayController
    
    constructor: (options)->
      @options = options
      controller = this
      @timer = $.timer ()->
        pos = controller.replay_process_bar.get("pos")
        controller.replay_process_bar.set("pos", pos + controller.process_inc)
        for field_model in controller.fields.models
          p = pos
          while(p>=0)
            if(field_model.value_history[p]?)
              field_model.set("value", field_model.value_history[p])
              break;
            p--
          
      ,500,false
    
    
      
    generate_field_models: (jvm)->
      field_filter = jvm.get_field_tree_filter()
      field_models = new ReplayFieldModelColl
      for signal, i in jvm.sorted_signals
        if (signal.get("field_visitor")?)
          class_name = signal.get("field_visitor").class_name
          field_name =  signal.get("field_visitor").field_name  
          if (field_filter[class_name][field_name].checked)
            owner_ref = signal.get("field_visitor").get("onwer_ref")
            field_id = owner_ref + class_name + "." + field_name
            field_model = field_models.add  
              id: field_id
              class_name: class_name
              field_name: field_name
              owner_ref: owner_ref
            field_model.value_history ?= []
            field_model.value_history[i] = signal.get("field_visitor").get("value")
            
      return field_models

    show: (jvm)->
      
      @panel = new PanelView
        title: "Replay:" + jvm.id 
        class_name: "danger"
      @options.container.append(@panel.el)
      @panel.$el.css
        position: "fixed"
        top:0
      @fields = @generate_field_models(jvm)
      @replay_process_bar = jvm.replay_process_model
      @replay_process_bar.set
        total: jvm.signals.length
        pos: 0
      
      @view = new ReplayView
        model: @replay_process_bar
        collection: @fields
        el : @panel.body
      
      controller = this
      backward_btn = $("""
          <button type="button" class="btn btn-default" aria-label="Left Align">
            <span class="glyphicon glyphicon-backward" aria-hidden="true"></span>
          </button>
        """)
      $(@panel.footer).append(backward_btn)  
      $(backward_btn).on "click", ()->
        controller.process_inc = -5
        if !controller.timer.isActive
          controller.timer.play()

      play_btn = $("""
          <button type="button" class="btn btn-default" aria-label="Left Align">
            <span class="glyphicon glyphicon-play" aria-hidden="true"></span>
          </button>
        """)
      $(@panel.footer).append(play_btn) 
      $(play_btn).on "click", ()->
        controller.process_inc = 1
        if !controller.timer.isActive
          controller.timer.play()
        

      pause_btn = $("""
          <button type="button" class="btn btn-default" aria-label="Left Align">
            <span class="glyphicon glyphicon-pause" aria-hidden="true"></span>
          </button>
        """)
      $(@panel.footer).append(pause_btn) 
      $(pause_btn).on "click", ()->
        controller.process_inc = 0
        if !controller.timer.isActive
          controller.timer.play()

      forward_btn = $("""
          <button type="button" class="btn btn-default" aria-label="Left Align">
            <span class="glyphicon glyphicon-forward" aria-hidden="true"></span>
          </button>
        """)

      $(@panel.footer).append(forward_btn)  

      $(forward_btn).on "click", ()->
        controller.process_inc = 5
        if !controller.timer.isActive
          controller.timer.play()

      stop_btn = $("""
          <button type="button" class="btn btn-default" aria-label="Left Align">
            <span class="glyphicon glyphicon-stop" aria-hidden="true"></span>
          </button>
        """)
      $(@panel.footer).append(stop_btn) 
      $(stop_btn).on "click", ()->
        controller.timer.stop()
        controller.panel.remove()
      
            
  return ReplayController
