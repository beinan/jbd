#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: Beinan
# @Date:   2015-01-11 15:09:20
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-11 19:33:40

define [
  "backbone"
], (Backbones) ->

  class SingalDepGraph
    constructor:(signals, @field_filter)->
      @signals = signals
      @field_filter = field_filter
      @nodes = []
      @links = []

      @nodes_by_thread = {}  #node dict for each thread
      @nodes_by_field = {}  #node dict for each field

      @generate_nodes()
      @generate_links()

    top_sort:()->
      result = [] #sort result
      
      node_wrapers = {} #sorting data structure
      for node in @nodes 
        node_wrapers[node.id] = #initialize the data stucture of each node
          node : node
          to : [] #the nodes that has an edge from this node
          visit: 0 #not visited
      for link in @links
        node_wrapers[link.source.id].to.push node_wrapers[link.target.id]

      #visit function for top sort
      visit = (node)->
        if node.visit is 1 #has a temporary mark
           throw "Found a circle"
        if node.visit == 0
          node.visit = 1 #mark n temporarily
          for to_node in node.to
            visit to_node
          node.visit = 2 #mark n permanently
          result.push node.node


      for node_id, node of node_wrapers
        if(node.visit == 0)
          visit(node)
      return result

    generate_nodes: ()->
      for node in @signals #each signal is a node in the graph
        if(node.get("field_visitor")?) #it is field visitor
          class_name = node.get("field_visitor").class_name
          field_name =  node.get("field_visitor").field_name  
          if(@field_filter[class_name][field_name].checked)
            @nodes.push node
            @nodes_by_thread[node.get("thread_id")] ?= []
            @nodes_by_thread[node.get("thread_id")].push node                   

            version = node.get("field_visitor").get("version")

            @nodes_by_field[class_name + field_name] ?= []
            @nodes_by_field[class_name + field_name][version] ?= {}
            msg_type = node.get("field_visitor").get("msg_type")
            if msg_type is "field_getter"
              @nodes_by_field[class_name + field_name][version]["getter"] ?= []
              @nodes_by_field[class_name + field_name][version]["getter"].push node                     
            else
              @nodes_by_field[class_name + field_name][version]["setter"] = node

        else
          @nodes.push node
          @nodes_by_thread[node.get("thread_id")] ?= []
          @nodes_by_thread[node.get("thread_id")].push node                   

    generate_links: ()->
      #generate @links
      for thread_id, nodes_of_thread of @nodes_by_thread
        nodes_of_thread.sort (a, b)->
          a.get("invocation_id") - b.get("invocation_id")
        for node, i in nodes_of_thread
          if i != 0 #ignore the first node
            @links.push
              source: nodes_of_thread[i]
              target: nodes_of_thread[i - 1]
              type: 'thread-seq'  
      for field_id, nodes_of_field of @nodes_by_field
        for data, version in nodes_of_field
          if data?
            for getter in data["getter"]
              if(data["setter"]?)
                @links.push
                  source: getter
                  target: data["setter"]  
                  type: "read-after-write"
            if(nodes_of_field[version]? and nodes_of_field[version]["setter"]? and nodes_of_field[version - 1]? and nodes_of_field[version - 1]["setter"]?)

              @links.push
                source: nodes_of_field[version]["setter"]
                target: nodes_of_field[version - 1]["setter"]  
                type: "write-after-write"
           

  return SingalDepGraph