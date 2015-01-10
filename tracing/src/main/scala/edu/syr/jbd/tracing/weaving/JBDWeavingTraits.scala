/* 
* @Author: Beinan
* @Date:   2015-01-03 17:07:16
* @Last Modified by:   Beinan
* @Last Modified time: 2015-01-03 17:19:08
*/
package edu.syr.jbd.tracing.weaving

trait JBDWeavingTrait {

  //lock object is also a version counter for the field
  protected val lock_desc = "Ledu/syr/jbd/tracing/JBDLocalValue;"
  protected def lock_field_name(name : String) = "__jbd_lock_" + name

  protected def getter_name = "__get_" + _
  protected def getter_desc = "(J)" + _
  
  protected def setter_name = "__set_" + _
  protected def setter_desc:String => String = "(" + _  + "J)V"
  


}