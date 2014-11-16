/* 
* @Author: troya
* @Date:   2014-11-06 17:19:37
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-14 21:29:11
*/
package edu.syr.jbd.tracing.weaving

import org.objectweb.asm._
import org.objectweb.asm.commons.AdviceAdapter

/**
 * Tacking method invocation
 * @type {[type]}
 */
class MethodInvocationTrackerClassAdapter(cv: ClassVisitor) extends ClassVisitor(Opcodes.ASM4, cv) with Opcodes {
  
  private var owner: String = null
  private var locks: List[String] = Nil

  override def visit(version: Int, access: Int, name: String, signature: String, superName: String, interfaces: Array[String]) {
    owner = name
    println("class-visited:" + name)
    super.visit(version, access, name, signature, superName, interfaces)
  }

  override def visitMethod(access: Int, name: String, desc: String, signature: String, exceptions: Array[String]): MethodVisitor = {
    println("method-visited:" + name)
    val mv: MethodVisitor = cv.visitMethod(access, name, desc, signature, exceptions)
    return if (mv == null) null else new TraceMethodAdapter(api, mv, owner, access, name, desc)
  }
}


class TraceMethodAdapter(api : Int, mv : MethodVisitor, owner: String,
  access : Int, name : String, desc : String) 
    extends AdviceAdapter(api, mv, access, name, desc) with Opcodes {

  lazy val is_static = (access & Opcodes.ACC_STATIC) != 0
  
  val method_key = owner + "#" + name + desc
  
  var local_var_invoc_id : Int = -1
  /**
   * tracing method invocation with the values of parameters
   */
  override def onMethodEnter() {
    val types = Type.getArgumentTypes(desc)
    val off = if(is_static) 0 else 1  //local var 0 is "this" for non-static method
    local_var_invoc_id = newLocal(Type.LONG_TYPE)

    push(method_key) 
    
    //traceMethodEnter will return an invocation id
    mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
      "traceMethodEnter", "(Ljava/lang/String;)J")
    dup2()  //dup invocation id
    mv.visitVarInsn(Opcodes.LSTORE, local_var_invoc_id) //store to local var for further usage
    types.foldLeft[Int](off){ //trace each argument of the current method invocation
      (pos:Int, a_type:Type) =>
        println(pos) 
        dup2() //for invocation id
        push(method_key)
        push(pos) //for argument seq
        //val a_type = types(i) //each argument type
        val opcode = a_type.getOpcode(Opcodes.ILOAD)      
        
        mv.visitVarInsn(opcode, pos)
        
        if(a_type.getSort() <= 8){ //primitive type, do boxing
          box(a_type)
        }

        mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
        "traceMethodArgument", "(JLjava/lang/String;ILjava/lang/Object;)V")//long, int, object
        
        pos + a_type.getSize()  //for double & long, size will be 2
    }
    pop2() //eat the invocation_id

  }

  /**
   * Tracing the return value of a method invocation
   *
   */
  override def visitMethodInsn(opcode : Int, owner : String, 
    name : String, desc : String,  itf : Boolean){
    val invokee_method_key = owner + "#" + name + desc
    
    if(name != "<init>" && this.name != "<init>"){ //for the case of invoke super constructor in the constructor 

      push(invokee_method_key) 
      //load invocation_id of the invoker (actuall it's the parent of this returned method invocation)
      mv.visitVarInsn(Opcodes.LLOAD, local_var_invoc_id)
      mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
        "traceMethodInvocation", "(Ljava/lang/String;J)V")
    }
    
    super.visitMethodInsn(opcode, owner, name, desc, itf)
    
    val returnType = Type.getReturnType(desc)
    if (returnType != Type.VOID_TYPE) {
      if (returnType.getSize() == 2) {
        dup2()
      }else{
        dup()
      }

      if(returnType.getSort() <= 8){ //primitive type, do boxing
        box(returnType)
      }
      push(invokee_method_key) 
      //load invocation_id of the invoker (actuall it's the parent of this returned method invocation)
      mv.visitVarInsn(Opcodes.LLOAD, local_var_invoc_id)
      mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
        "traceReturnValue", "(Ljava/lang/Object;Ljava/lang/String;J)V")
    }
  }
  

  
  
}

