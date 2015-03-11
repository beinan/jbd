/* 
* @Author: Beinan
* @Date:   2014-11-09 16:17:40
* @Last Modified by:   Beinan
* @Last Modified time: 2015-01-21 09:25:47
*/

require.config({
  paths: {
    'jquery' : 'libs/jquery-2.1.1',
    'bootstrap' : 'libs/bootstrap',
    'underscore' : 'libs/underscore-min',
    'd3' : 'libs/d3',
    'raphael': 'libs/raphael',
    'backbone': 'libs/backbone',
    'jquery.timer': 'libs/jquery.timer',
    'routes' : "routes"
  },
  shim: {
    bootstrap: {
      deps:["jquery"]
    },
    d3: {
      exports: 'd3'
    },
    seq_diagram:{
      deps: ["raphael", "underscore"], 
      exports: "gram"
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"

    },
    'jquery.timer':{
      deps: ['jquery']
    },
    routes:{
      exports: "jsRoutes"
    }
  }
});


require(["bootstrap","app_router"],
  function(ingore, AppRouter) {
  
  new AppRouter;
  
  //     }
  // }); 
  // var diagram = new Diagram();
  // var a = diagram.addActor("A");
  // var b = diagram.addActor("B");
  // var c = diagram.addActor("C");
  
  // var s = diagram.addSignal(a, 1, 1, b, "Hello");
  // var s = diagram.addSignal(a, 1, 1, a, "back");
  // diagram.addSignal(a, 1, 1, c, "back");
  // diagram.addSignal(c, 1, 1, b, "back");
  // console.log(diagram.actors)
  // // diagram.getActor("C");
  // diagram.drawSVG('diagram');

  // function map() { 
  //   var key = this.jvm_name + "#" + this.thread_id + "#" + this.invocation_id;
  //   var value = {};
  //   value[this.msg_type] = {};
  //   for(var attr in this){
  //     if(attr != "_id" && attr!= "jvm_name" && attr!="thread_id")
  //       value[this.msg_type][attr] = this[attr]
  //   }
  //   emit(key, value);
  // };
  // function reduce(key, values) {
  //   var result = {};
  //   values.forEach(function(msg){
  //     for(var msg_type in msg){
  //       if(msg_type in result) {
  //         if(Array.isArray(result[msg_type]))
  //           result[msg_type].push(msg[msg_type]);
  //         else
  //           result[msg_type] = [result[msg_type], msg[msg_type]];
  //       }else{
  //         result[msg_type] = msg[msg_type];
  //       }
  //     }
  //   });
  //   return result;
  // };

  // var r = jsRoutes.controllers.MainController.mapReduce("trace");
  // $.ajax({
  //     url: r.url,
  //     type: r.type,
  //     dataType : 'json',
  //     contentType : 'application/json; charset=utf-8',
  //     data: JSON.stringify({map:map.toString(), reduce:reduce.toString()}),
  //     success: function(data) {
  //         console.log(data);
  //         var tree = d3.layout.tree()
  //             .sort(null)
  //             .size([size.height, size.width - maxLabelLength*options.fontSize])
  //             .children(function(d)
  //             {
  //                 return (!d.contents || d.contents.length === 0) ? null : d.contents;
  //             });

  //         var nodes = tree.nodes(data);
  //         var links = tree.links(nodes);

  //     }
  // });
});