define [
  "jquery",
  "routes"
], ($, routes) ->

  class GroupByMethod
    @map: ()->
      if(this.method_desc?)
        method_desc_terms = this.method_desc.split('#')
        classname = method_desc_terms[0]
        method = {}
        thread_info = {}
        str_thread_id = this.thread_id + ""
        thread_info[str_thread_id] = 1
        method[method_desc_terms[1]] = {count:1, thread_info:thread_info}
        
        emit(classname, method)
    
    @reduce: (classname, methods)->
      result = {}
      for method in methods
        for method_name, method_info of method
          if(result[method_name]?)             
            result[method_name].count += method_info.count
            for thread_id, count of method_info.thread_info  #merge thread_info
              if(result[method_name].thread_info[thread_id]?)
                result[method_name].thread_info[thread_id] += count
              else
                result[method_name].thread_info[thread_id] = count 
          else
            result[method_name] = method_info
      result
        
    @map_reduce: (success_callback)->
      r = routes.controllers.MainController.mapReduce("trace")
      request = 
        url: r.url,
        type: r.type,
        dataType : 'json',
        contentType : 'application/json; charset=utf-8',
        data: JSON.stringify({map: this.map.toString(), reduce:this.reduce.toString()}),
        success: success_callback

      console.debug("Map Reduce request:", request)  
      $.ajax(request)

  return GroupByMethod

