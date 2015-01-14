# Define the model of an actor (object or static class)
# @Author: Beinan
# @Date:   2014-12-27 17:13:48
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 22:24:53


define [
  "backbone"
], (Backbone) ->

  class Lifeline extends Backbone.Model
    @lifeline_dict: {}  
    
    initialize:()->
      Lifeline.lifeline_dict[this.id] = this
    
    @lookup_lifeline: (lifeline_id) ->
      @lifeline_dict[lifeline_id]

  class LifelineColl extends Backbone.Collection
    model: Lifeline

  class Actor extends Backbone.Model
    initialize: ()->
      @lifelines = new LifelineColl
      @thread_dict = {}

    title: ()->
      title = @get("owner")
      if @get("owner_ref")?
        title = "obj:" + title
      title

    add_lifeline: (data)->
      data.actor = this
      @thread_dict[data.thread_id] = true
      return @lifelines.add(data)

    get_thread_ids: ()->
      thread_ids = []
      for thread_id, value of @thread_dict
        thread_ids.push thread_id
      return thread_ids

    @lookup_lifeline:(lifeline_id)->
      Lifeline.lookup_lifeline(lifeline_id)

      

  return Actor

