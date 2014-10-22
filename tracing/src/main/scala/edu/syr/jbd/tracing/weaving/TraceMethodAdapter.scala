package edu.syr.jbd.tracing.weaving

import org.objectweb.asm._
import org.objectweb.asm.commons.AdviceAdapter

class TraceMethodAdapter(api : Int, mv : MethodVisitor, owner: String,
  access : Int, name : String, desc : String) 
  extends AdviceAdapter(api, mv, access, name, desc) with Opcodes {
  

  override def visitMethodInsn(opcode : Int, owner : String, 
    name : String, desc : String,  itf : Boolean){
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
        super.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", "trace", "(Ljava/lang/Object;)V")
    }
  }

}

