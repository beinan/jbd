package edu.syr.jbd.tracing

object JBDTrace{
  def trace(v: AnyRef):Unit = {
    println("aaaabbbb" + v)
  }
}