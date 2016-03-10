/* 
* @Author: Beinan
* @Date:   2014-11-06 21:25:10
* @Last Modified by:   Beinan
* @Last Modified time: 2015-01-03 17:26:28
*/
package edu.syr.jbd.tracing

import java.lang.management._

import reactivemongo.bson._
    
import edu.syr.jbd.tracing.mongo.MongoDB
import edu.syr.jbd.tracing.mongo.JBDExecContext


object JBDTrace{
  val local = new JBDLocal
  val jvm_name = sys.env.getOrElse("jvm_id", ManagementFactory.getRuntimeMXBean().getName());

  implicit val ec = JBDExecContext.ec

  def traceStaticMethodEnter(method_desc:String):Long = {
    val invocation_id = local.get.count
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "invocation_id" -> invocation_id,
      "method_desc" -> method_desc,
      "msg_type" -> "method_enter",     
      "line_number" -> local.get.line_number,
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    try{
      MongoDB.coll("trace").insert(doc)
    }catch{
      case _ =>  //do nothing, work around for Random confict problem
    }
    return invocation_id
  }
  
  def traceNonStaticMethodEnter(method_desc:String, owner_ref:Object):Long = {
    val invocation_id = local.get.count
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "invocation_id" -> invocation_id,
      "method_desc" -> method_desc,
      "msg_type" -> "method_enter",
      "owner_ref" -> System.identityHashCode(owner_ref),
      "line_number" -> local.get.line_number,
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   
   
    return invocation_id 
  }

  def traceMethodArgument(invocation_id:Long, method_desc:String, arg_seq:Int,arg_val: AnyRef) {
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "invocation_id" -> invocation_id,
      "value" -> String.valueOf(arg_val),
      "arg_seq" -> arg_seq,
      "method_desc" -> method_desc,
      "msg_type" -> "method_argument",
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   


  }

  def traceMethodInvocation(method_desc: String, parent_invocation_id:Long):Long = {
    val invocation_id = local.get.count    
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "invocation_id" -> invocation_id,
      "parent_invocation_id" -> parent_invocation_id,
      "method_desc" -> method_desc,
      "msg_type" -> "method_invoke",
      "line_number" -> local.get.line_number,
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   
    return invocation_id
  }

  def traceReturnValue(return_val: AnyRef, method_desc: String, parent_invocation_id:Long, invokee_id:Long){
    val invocation_id = local.get.count    
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "invocation_id" -> invocation_id,
      "parent_invocation_id" -> parent_invocation_id,
      "invokee_id" -> invokee_id,
      "value" -> String.valueOf(return_val),
      "method_desc" -> method_desc,
      "msg_type" -> "method_return",
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   
  }

  def traceFieldGetter(counter:JBDLocalValue, value: AnyRef, 
    owner_ref: AnyRef, field:String, parent_inv_id: Long){
    val invocation_id = local.get.count
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "value" -> String.valueOf(value),
      "invocation_id" -> invocation_id,
      "parent_invocation_id" -> parent_inv_id,
      "version" -> counter.get,
      "field" -> field,
      "owner_ref" -> System.identityHashCode(owner_ref),
      "msg_type" -> "field_getter",
      "line_number" -> local.get.line_number,
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   
  }

  def traceFieldSetter(counter:JBDLocalValue, value: AnyRef, 
    owner_ref: AnyRef, field:String, parent_inv_id: Long){
    val invocation_id = local.get.count
    val doc = BSONDocument(
      "jvm_name" -> jvm_name,
      "thread_id" -> Thread.currentThread().getId(),
      "value" -> String.valueOf(value),
      "invocation_id" -> invocation_id,
      "parent_invocation_id" -> parent_inv_id,
      "version" -> counter.count,
      "field" -> field,
      "owner_ref" -> System.identityHashCode(owner_ref),
      "msg_type" -> "field_setter",      
      "line_number" -> local.get.line_number,
      "created_datetime" -> BSONDateTime(System.currentTimeMillis))
    
    MongoDB.coll("trace").insert(doc)   
  }

  def traceLineNumber(line_number: Int) = {
    local.get.line_number = line_number
  }

  val array_counter = scala.collection.mutable.Map[AnyRef, Int]()
  
  def traceArrayRead(a:Array[Int], index:Int, parent_inv_id:Long):Int = {
    println("array read:"+index)
    val invocation_id = local.get.count
     
    a.synchronized{
      val value = a(index)
      val version = array_counter.getOrElse(a, 0)
      val doc = BSONDocument(
        "jvm_name" -> jvm_name,
        "thread_id" -> Thread.currentThread().getId(),
        "value" -> String.valueOf(value),
        "invocation_id" -> invocation_id,
        "parent_invocation_id" -> parent_inv_id,
        "version" -> version,
        "owner_ref" -> System.identityHashCode(a),
        "index" -> index,
        "msg_type" -> "array_getter",
        "line_number" -> local.get.line_number,
        "created_datetime" -> BSONDateTime(System.currentTimeMillis))

      MongoDB.coll("trace").insert(doc)
      return a(index)
    }
  }

  def traceArrayWrite(a:Array[Int], index:Int, value:Int, parent_inv_id:Long) {
    println("array write:"+index +" value:"+value)
    val invocation_id = local.get.count
   
    a.synchronized{
      a(index) = value
      val version = array_counter.getOrElse(a, 0)
      array_counter(a) = version + 1
      array_counter
      val doc = BSONDocument(
        "jvm_name" -> jvm_name,
        "thread_id" -> Thread.currentThread().getId(),
        "value" -> String.valueOf(value),
        "invocation_id" -> invocation_id,
        "parent_invocation_id" -> parent_inv_id,
        "version" -> String.valueOf(version + 1),
        "owner_ref" -> System.identityHashCode(a),
        "index" -> index,
        "msg_type" -> "array_setter",
        "line_number" -> local.get.line_number,
        "created_datetime" -> BSONDateTime(System.currentTimeMillis))

      MongoDB.coll("trace").insert(doc)
    }
    
  }

  def trace(v: AnyRef):Unit = {
    //println("aaaabbbb" + v)
  }
}

class JBDLocal extends ThreadLocal[JBDLocalValue]{
  override def initialValue = new JBDLocalValue
}

class JBDLocalValue{
  var counter:Long = 0
  var line_number:Int = 0
  def count = {
    counter = counter + 1
    counter
  }
  def get = counter
  def change_line_number(line:Int) = {
    line_number = line
  }

}

object JBDLocalValue{
  def instance = new JBDLocalValue
}

