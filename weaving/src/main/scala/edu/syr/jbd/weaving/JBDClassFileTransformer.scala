package edu.syr.jbd.weaving

import java.lang.instrument.ClassFileTransformer
import java.security.ProtectionDomain

import org.objectweb.asm._
import org.objectweb.asm.util.CheckClassAdapter


class JBDClassFileTransformer extends ClassFileTransformer{

  def transform(loader : ClassLoader, className : String, 
    classBeingRefined: Class[_], 
    protectionDomain: ProtectionDomain,
    classFileBuffer: Array[Byte]):Array[Byte] = {

    if(className != "HelloWorld")
      return classFileBuffer
    
    val normalizedClassName = className.replaceAll("/", "\\.");
    println(normalizedClassName)

    val classReader = new ClassReader(classFileBuffer)
    val classWriter = new ClassWriter(ClassWriter.COMPUTE_FRAMES)
    val classVisitor = new TraceClassAdapter(classWriter)
    classReader.accept(new CheckClassAdapter(classVisitor), ClassReader.EXPAND_FRAMES)
    return classWriter.toByteArray
  }
}

class TraceClassAdapter(cv: ClassVisitor) extends ClassVisitor(Opcodes.ASM4, cv) with Opcodes {
  override def visit(version: Int, access: Int, name: String, signature: String, superName: String, interfaces: Array[String]) {
    owner = name
    println("class-visited:" + name)
    super.visit(version, access, name, signature, superName, interfaces)
  }
  override def visitMethod(access: Int, name: String, desc: String, signature: String, exceptions: Array[String]): MethodVisitor = {
    println("method-visited:" + name)
    val mv: MethodVisitor = cv.visitMethod(access, name, desc, signature, exceptions)
    return if (mv == null) null else new TraceMethodAdapter(api, mv, owner, access, name, desc)
    return mv
  }
  private var owner: String = null
}


