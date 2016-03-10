package edu.syr.jbd.tracing.weaving

import java.lang.instrument.ClassFileTransformer
import java.security.ProtectionDomain

import org.objectweb.asm._
import org.objectweb.asm.util._

import java.io.PrintWriter;

import edu.syr.jbd.tracing._

class JBDClassFileTransformer extends ClassFileTransformer{

  def transform(loader : ClassLoader, className : String, 
    classBeingRefined: Class[_], 
    protectionDomain: ProtectionDomain,
    classFileBuffer: Array[Byte]):Array[Byte] = {

    JBDTrace.trace(loader)
    val value = new JBDLocalValue
    //println("loading:" + className);
    if(filter(className))
      return classFileBuffer
    //println("ClassLoader:" + loader)
    val normalizedClassName = className.replaceAll("/", "\\.");
    println(normalizedClassName)

    val classReader = new ClassReader(classFileBuffer)
    val classWriter = new ClassWriter(ClassWriter.COMPUTE_FRAMES | ClassWriter.COMPUTE_MAXS)
    val field_tracker = new SynchronizedFieldTrackerClassAdapter(classWriter)
    val method_tracker = new MethodInvocationTrackerClassAdapter(field_tracker)
    classReader.accept(method_tracker, ClassReader.SKIP_FRAMES)

    val result = classWriter.toByteArray
    
    if(true){
      val cr = new ClassReader(result);
      val printWriter = new PrintWriter(System.out);
      val traceClassVisitor = new TraceClassVisitor(printWriter);
      
      cr.accept(traceClassVisitor, ClassReader.SKIP_DEBUG);
    }
    
    return result
  }
  
  def filter(className:String):Boolean = {
    //if(className.equals("java/util/Random") || className.equals("java/lang/Math"))
      //return false

    if(className.startsWith("edu/syr/jbd")
      || className.startsWith("jdk")
      || (className.startsWith("java"))
      || className.startsWith("com/sun/")
      || className.startsWith("sun")
      || className.startsWith("scala")      
      || className.startsWith("reactivemongo")
      || className.startsWith("org/apache/logging")
      || className.startsWith("com/typesafe/config/")
      || className.startsWith("akka")
      || className.startsWith("org/jboss")
      || className.startsWith("sun/"))  //to avoid system classes and jbd classes  
      return true
    return false
  }

}

