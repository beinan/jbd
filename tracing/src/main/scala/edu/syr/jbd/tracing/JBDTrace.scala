package edu.syr.jbd.tracing

object JBDTrace{
  val local = new JBDLocal
  def traceMethodEnter(owner: String, name:String, desc:String):Long = {
    println(owner + name + desc + "----method entered")
    local.get.count
  }

  def traceMethodArgument(invocation_id:Long, arg_seq:Int,arg_val: AnyRef) {
    //traceMethodEnter(null,null,null)
    println(arg_val)

  }
  def traceReturnValue(return_val: AnyRef, owner: String, name:String, desc:String){
    println(owner + name + desc + return_val)
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
  def count = {
    counter = counter + 1
    counter
  }
}