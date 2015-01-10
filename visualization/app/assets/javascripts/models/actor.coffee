# Define the model of an actor (object or static class)
# @Author: Beinan
# @Date:   2014-12-27 17:13:48
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-09 16:12:02


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
      @lifelines.on "add", (lifeline)->
        console.log "a lifeline was added", lifeline
    
    title: ()->
      title = @get("owner")
      if @get("owner_ref")?
        title = "obj:" + title
      title

    add_lifeline: (data)->
      data.actor = this
      @lifelines.add(data)

    @lookup_lifeline:(lifeline_id)->
      Lifeline.lookup_lifeline(lifeline_id)

  return Actor

