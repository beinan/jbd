/* 
* @Author: Beinan
* @Date:   2014-11-09 16:17:40
* @Last Modified by:   Beinan
* @Last Modified time: 2014-12-25 16:58:04
*/

require.config({
  paths: {
    'jquery' : 'libs/jquery-2.1.1',
    'easyui' : 'libs/jquery.easyui.min',
    'underscore' : 'libs/underscore-min',
    'd3' : 'libs/d3',
    'raphael': 'libs/raphael',
    'backbone': 'libs/backbone',
    'routes' : "routes"
  },
  shim: {
    d3: {
      exports: 'd3'
    },
    easyui: {
      deps: ['jquery']
    },
    seq_diagram:{
      deps: ["raphael", "underscore"], 
      exports: "gram"
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"

    },
    routes:{
      exports: "jsRoutes"
    }
  }
});


require(["easyui", "app_router"],
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