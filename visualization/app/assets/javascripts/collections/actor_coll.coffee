# Backbone collection for Actor
# @Author: Beinan
# @Date:   2014-12-27 17:15:36
# @Last Modified by:   Beinan
# @Last Modified time: 2014-12-27 17:35:06

define [
  "backbone"
  "models/actor"
], (Backbone, Actor) ->

  class ActorColl extends Backbone.Collection
    
    model: Actor

    initialize: ()->

    

  return ActorColl

