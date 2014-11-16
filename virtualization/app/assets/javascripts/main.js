/* 
* @Author: Beinan
* @Date:   2014-11-09 16:17:40
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-15 20:23:08
*/

require.config({
  paths: {
    'jquery' : 'libs/jquery-2.1.1',
    'underscore' : 'libs/underscore-min',
    'd3' : 'libs/d3',
    'raphael': 'libs/raphael',
    'seq_diagram': 'libs/sequence-diagram'
  },
  shim: {
    d3: {
      exports: 'd3'
    },
    seq_diagram:{
      deps: ["raphael", "underscore"], 
      exports: "Diagram"
    }
  }
});


require(["jquery", "d3", "raphael", "seq_diagram"],function($, d3, Raphael, ignore) {
  console.log(d3.version); 
  var diagram = Diagram.parse("A->B: Does something");
  diagram.getActor("C");
  diagram.drawSVG('diagram');

  function map() { 
    var key = this.jvm_name + "#" + this.thread_id + "#" + this.invocation_id;
    var value = {};
    value[this.msg_type] = {};
    for(var attr in this){
      if(attr != "_id" && attr!= "jvm_name" && attr!="thread_id")
        value[this.msg_type][attr] = this[attr]
    }
    emit(key, value);
  };
  function reduce(key, values) {
    var result = {};
    values.forEach(function(msg){
      for(var msg_type in msg){
        if(msg_type in result) {
          if(Array.isArray(result[msg_type]))
            result[msg_type].push(msg[msg_type]);
          else
            result[msg_type] = [result[msg_type], msg[msg_type]];
        }else{
          result[msg_type] = msg[msg_type];
        }
      }
    });
    return result;
  };

  var r = jsRoutes.controllers.MainController.mapReduce("trace");
  $.ajax({
      url: r.url,
      type: r.type,
      dataType : 'json',
      contentType : 'application/json; charset=utf-8',
      data: JSON.stringify({map:map.toString(), reduce:reduce.toString()}),
      success: function(data) {
          console.log(data);
          var tree = d3.layout.tree()
              .sort(null)
              .size([size.height, size.width - maxLabelLength*options.fontSize])
              .children(function(d)
              {
                  return (!d.contents || d.contents.length === 0) ? null : d.contents;
              });

          var nodes = tree.nodes(data);
          var links = tree.links(nodes);

      }
  });
});