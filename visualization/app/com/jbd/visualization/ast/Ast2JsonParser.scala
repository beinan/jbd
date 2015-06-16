package com.jbd.visualization.ast


import com.github.javaparser.ast._
import com.github.javaparser.ast.body._
import com.github.javaparser.ast.expr._
import com.github.javaparser.ast.stmt._
import play.api.libs.json._

import scala.collection.JavaConversions._

object Ast2JsonParser{

  def ast2json(node: Node):JsValue = node match {
    case cu: CompilationUnit => cu2json(cu) 
    case c_i: ClassOrInterfaceDeclaration => class2json(c_i)
    case m: MethodDeclaration => method2json(m)
    case name: NameExpr => Json.toJson(name.toString())
    case p: Parameter => Json.obj("type"->p.getType().toString, "id"->p.getId().toString())
    case block:BlockStmt => Json.obj("stmts" -> block.getStmts().map(ast2json(_)))
    case while_stmt: WhileStmt => Json.obj("node_type"->"WhileStmt", 
      "condition" -> ast2json(while_stmt.getCondition()),
      "body" -> ast2json(while_stmt.getBody())
      )
    case expr_stmt: ExpressionStmt => Json.obj("node_type" -> "ExpressionStmt","expression" -> ast2json(expr_stmt.getExpression()))
    case assign_expr:AssignExpr => Json.obj("node_type" -> "AssignExpr", 
      "code" -> assign_expr.toString(),
      "target" -> ast2json(assign_expr.getTarget())  
    )
    case field_acc_expr: FieldAccessExpr => Json.obj("node_type" -> "FieldAccessExpr",
      "code" -> field_acc_expr.toString(),
      "field_name" -> field_acc_expr.getField(),
      "scope" -> field_acc_expr.getScope().toString(),
      "pos" -> pos(field_acc_expr)
    )
    case node => Json.obj("node_type" -> node.getClass.getName, "code" ->node.toString())
  }

  def pos(node: Node) = Json.obj(
    "begin_line" -> node.getBeginLine(),
    "end_line" -> node.getEndLine(),
    "begin_column" -> node.getBeginColumn(),
    "end_column" -> node.getEndColumn()
  )
  def cu2json(cu: CompilationUnit) = {
    //convert each types(class, interface and etc..)
    Json.obj("package" -> ast2json(cu.getPackage().getName()), 
      "types" -> cu.getTypes().map(ast2json(_)))
  }

  def class2json(c: ClassOrInterfaceDeclaration) = {
    //todo: get extends and implements
    Json.obj(
      "is_interface" -> c.isInterface(),
      "name" -> c.getName(),
      "members" -> c.getMembers().map(ast2json(_))
    )
  }
  
  def method2json(m : MethodDeclaration) = {
    Json.obj(
      "type" -> "method",
      "modifiers" -> m.getModifiers,
      "type" -> ast2json(m.getType),
      "name" -> m.getName,
      "parameters" -> m.getParameters().map(ast2json(_)),
      "body" -> ast2json(m.getBody())
    )
  }

}
