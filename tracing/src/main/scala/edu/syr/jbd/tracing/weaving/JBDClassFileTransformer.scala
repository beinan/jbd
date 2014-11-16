package edu.syr.jbd.tracing.weaving

import java.lang.instrument.ClassFileTransformer
import java.security.ProtectionDomain

import org.objectweb.asm._
import org.objectweb.asm.util._

import java.io.PrintWriter;

import edu.syr.jbd.tracing.JBDTrace

class JBDClassFileTransformer extends ClassFileTransformer{

  def transform(loader : ClassLoader, className : String, 
    classBeingRefined: Class[_], 
    protectionDomain: ProtectionDomain,
    classFileBuffer: Array[Byte]):Array[Byte] = {

    JBDTrace.trace(loader)
    //if(className != "HelloWorld")
    if(loader == null || className.startsWith("edu/syr/jbd") 
      || className.startsWith("com/sun/")
      || className.startsWith("sun/"))  //to avoid system classes and jbd classes  
      return classFileBuffer
    println("ClassLoader:" + loader)
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
}

