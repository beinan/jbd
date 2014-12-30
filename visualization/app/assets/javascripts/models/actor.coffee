# Define the model of an actor (object or static class)
# @Author: Beinan
# @Date:   2014-12-27 17:13:48
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-29 18:04:15


define [
  "backbone"
], (Backbone) ->

  class Lifeline extends Backbone.Model
    initialize:()->
    
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
      Actor.lifeline_dict[data.id] = this
      @lifelines.add(data)

    @lifeline_dict: {}  
    @lookup_actor_by_lifeline_id:(lifeline_id)->
      @lifeline_dict[lifeline_id]

  return Actor

