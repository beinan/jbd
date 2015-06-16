
define [
  "jquery"
  "backbone"
  "d3"
  ], ($, Backbone, d3) ->

  class TabView extends Backbone.View
    
    #className: "panel panel-success"

    initialize: (options)->
      @options = options
       

      @$el.attr
        "role": "tabpanel"
      tab_nav = d3.select(@el).append("ul").attr
        "role":"tablist"
        "class":"nav nav-tabs"
      tab_nav.selectAll("li").data(@options.tab_keys).enter().append("li")
        .attr("role","presentation")
        .append("a").attr 
          "id": (k) -> "tab_nav_" + k
          "role":"tab"
          "data-toggle":"tab"
          "aria-control": (k) -> k
          "href": (k) -> "#tab_" + k
        .text (tab_key)->tab_key
      tab_content = d3.select(@el).append("div").attr
        "class": "tab-content"
      tab_content.selectAll("div").data(@options.tab_keys).enter().append("div")
        .attr
          role: "tabpanel"
          class: (k, i) -> if i is 0 then "tab-pane active" else "tab-pane"
          id: (k)->"tab_" + k
        .text (k) -> k
        
      @show(@options.tab_keys[0])
       
    show: (key)->
      @$el.find("#tab_nav_" + key).tab("show")

    get_tab_body: (key)->
      @$el.find("#tab_" + key).get(0)
      
    hide: (options)->
      @$el.hide(options)

  return TabView
