# Source code view for replay purpose
# @Author: Beinan
# @Date:   2015-01-13 22:52:31
# @Last Modified by:   Beinan
# @Last Modified time: 2015-01-13 22:54:26

define [
  "jquery"
  "backbone"
  "d3"
  "db/source_code"
  "db/db_query"
  ], ($, Backbone, d3, get_source_code, dbQuery) ->

  class SourceCodeView extends Backbone.View
    
    
    initialize: (options)->
      console.log "source code view is initializing..."
      
    show: (lifeline)->
      class_name = lifeline.get("actor").get("owner")
      method_name = lifeline.get("method_name")
      view = @
      view.current_lifeline = lifeline
      view.current_method_name = method_name
      get_source_code class_name, method_name, (code_data)->
        console.debug "code ast", code_data
        [..., simple_class_name] = class_name.split("/")
        console.log "simple class name", simple_class_name
        type_selected = (type for type in code_data.types when type.name is simple_class_name)
        d3.select(view.el).html("").append("div").attr("class", "code_section")
          .selectAll(".code_type").data(type_selected).enter().append("div")
          .attr
            "class": "code_type"
          .call view.show_type.bind(view)
    show_type: (selection)->
      view = @
      selection.html("")
      selection.append("p").text (d)->d.name
      selection
        .selectAll(".code_member")
        .data( (d) -> (method for method in d.members when method.name is view.current_method_name.split("(")[0]) ).enter().append("div")
        .attr
          "class": "code_member"
        .call view.show_member.bind(view)

      #selection..text (d)->d.name
    
    show_member: (selection)->
      view = @
      draw_method_params = (span, params) ->
        console.log "drawing params", params, view.current_lifeline
        view.current_lifeline.params (param_values)->
          console.log "params", params, param_values
          for p,i in params
            p_span = span.append("span")
            p_span.append("span").text(p.type)
            p_span.append("span").text(p.id)
            p_span.append("span").attr("class", "code_value").text("= " + param_values[i+1]) #the index of param_values is starting from 1
        
      sig_line = selection.append("p")
      sig_line.append("span").text (d)-> d.name + "("
      params_span = sig_line.append("span")
      draw_method_params(params_span, params_span.datum().parameters)
      sig_line.append("span").text "){"

      dbQuery
        parent_invocation_id: view.current_lifeline.get("invocation_id")
        thread_id: view.current_lifeline.get("thread_id")
        msg_type: {"$regex": "^field_"}  #field_setter or field_getter
        , (data) ->
          console.log "Field accessing information for source code view", data
          view.current_field_acc = data
          selection.append("div").datum((d)->d.body)
            .call view.show_code_body.bind(view)
      
          selection.append("p").text "}"

    show_code_body: (selection)->
      view = @
      console.log "body-data", selection.datum()
      selection.attr
        "class":"code_body"

      for stmt in selection.datum().stmts
        selection.append("div").datum(stmt).call view.show_code_stmt.bind(view) 
        
    show_code_stmt: (selection)->
      console.log "drawing code statement", selection.datum()
      stmt = selection.datum()
      view = @
      selection.attr
          "class":"code_stmt"
      if stmt.node_type is "WhileStmt"
        while_head = selection.append("p")
        while_head.append("span").text("while(")
        while_head.append("span").text(stmt.condition.code)
        while_head.append("span").text("){")
        if stmt.body.stmts?
          #code block,  that means more than one statement in the blcck
          while_body = selection.append("div").datum(stmt.body).call view.show_code_body.bind(view)
        else
          #single statement
          while_body = selection.append("div").attr("class", "code_body").text (d)->d.body.expression.code
        selection.append("p").text "}"
      else if stmt.node_type is "ExpressionStmt"
        selection.text stmt.expression.code
        if stmt.expression? and stmt.expression.node_type is "AssignExpr" and stmt.expression.target.pos?
          expr = stmt.expression
          is_match = (acc_item) ->
            is_setter = acc_item.msg_type is "field_setter"
            is_pos_matched = acc_item.line_number <= expr.target.pos.end_line and acc_item.line_number >= expr.target.pos.begin_line
            field_name = acc_item.field.split("@")[1].split(",")[0]
              
            is_name_matched = field_name is expr.target.field_name
            return is_setter and is_pos_matched and is_name_matched
              
          matched_item = acc_item for acc_item in view.current_field_acc when is_match(acc_item) 
          if !matched_item?
            selection.append("span").attr("class", "code_warning").text "Not Reached"
          else
            dbQuery
              field: matched_item.field
              owner_ref: matched_item.owner_ref
              version: matched_item.version - 1
              jvm_name: matched_item.jvm_name
              , (previous_version) ->
                console.log "field setter data", previous_version, matched_item
                if previous_version? and previous_version[0]?
                  selection.append("span").attr("class" , "code_value").text previous_version[0].value
                  selection.append("span").text "->"
                selection.append("span").attr("class" , "code_value").text matched_item.value
        
      else
        selection.text (d)->d.code
         
  return SourceCodeView
