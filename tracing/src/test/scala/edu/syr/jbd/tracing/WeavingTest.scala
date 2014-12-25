/* 
* @Author: troya
* @Date:   2014-11-06 15:38:26
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-22 16:38:36
*/

package edu.syr.jbd.tracing

import edu.syr.jbd.tracing.weaving._

import org.specs2.mutable._

import java.lang.reflect.{InvocationTargetException, Method}


class WeavingTest extends Specification{

  "The executor" should {
      "invoke main function" in {
        Executor.exec
        true
      }
      
    }

  
}

object Executor{
  def exec = {
    val loader = new ControlledClassLoader(Executor.getClass.getClassLoader)
    val clazz: Class[_] = loader.loadClass("samples.concurrent.Plant")
    val method: Method = clazz.getMethod("main", classOf[Array[String]])
    val params: Array[String] = null
    val startExecTime: Long = System.currentTimeMillis
    method.invoke(null, params.asInstanceOf[AnyRef])
              
  }
}

class ControlledClassLoader(parent: ClassLoader) extends ClassLoader(parent) {
  import scala.io._
  override def loadClass(name: String, resolve: Boolean): Class[_] = this.synchronized{
    if (name.startsWith("java.lang") || name.startsWith("java.io") || name.startsWith("edu.syr.jbd.tracing")) 
      return super.loadClass(name, resolve)

    System.err.println("Class weaving:" + name)
    val resource: String = name.replace('.', '/') + ".class"
    val is = getResourceAsStream(resource)
    val byteArray = Source.fromInputStream(is, "ISO-8859-1").toArray.map(_.toByte)
    val tf = new JBDClassFileTransformer()
    val transformedBytes = tf.transform(this, name, null, null, byteArray)
    return defineClass(name, transformedBytes, 0, transformedBytes.length)
  }
}



