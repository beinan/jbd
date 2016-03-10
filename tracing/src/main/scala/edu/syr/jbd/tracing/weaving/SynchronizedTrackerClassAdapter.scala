/* 
* @Author: Beinan
* @Date:   2014-11-08 16:07:14
* @Last Modified by:   Beinan
* @Last Modified time: 2015-01-03 17:35:28
*/

package edu.syr.jbd.tracing.weaving

import org.objectweb.asm._
import org.objectweb.asm.util._
import org.objectweb.asm.commons.AdviceAdapter


class SynchronizedFieldTrackerClassAdapter(cv: ClassVisitor) extends ClassVisitor(Opcodes.ASM4, cv) 
  with Opcodes with JBDWeavingTrait{
  
  private var owner: String = null
  private var locks: List[String] = Nil

  override def visit(version: Int, access: Int, name: String, signature: String, superName: String, interfaces: Array[String]) {
    owner = name
    println("class-visited:" + name)
    super.visit(version, access, name, signature, superName, interfaces)
  }

  override def visitMethod(access: Int, name: String, desc: String, 
    signature: String, exceptions: Array[String]): MethodVisitor = {
    println("method-visited:" + name)
    val mv: MethodVisitor = cv.visitMethod(access, name, desc, signature, exceptions)
    
    if (mv!=null && !name.equals("<clinit>")) 
      return new FieldTrackingMethodAdapter(api, mv, owner, access, name, desc, locks)
    else{
      println("skip method"+name)
      return mv
    }
  }

  /**
   * Generate getter and setter
   */
  override def visitField(access:Int, name:String, desc:String,
            signature:String, value:Object):FieldVisitor = {
    if((access & Opcodes.ACC_STATIC) == 0 && !owner.startsWith("java")){ //only for non-static field so far.

      //create lock field    
      cv.visitField(access, lock_field_name(name), lock_desc, null, null);
      locks = lock_field_name(name)::locks //add lock field name to locks list, which will be used in constructor to initialize the value

      //create getter
      generateGetter(access, name, desc, signature)

      //create setter
      generateSetter(access, name, desc, signature)
    }

    return cv.visitField(access, name, desc, signature, value)
  }
  
  private def generateGetter(access:Int, name:String, desc:String,
            signature: String) {
    
    val mv: MethodVisitor = cv.visitMethod(access, getter_name(name), getter_desc(desc) , signature, Array())
    new FieldGetterAdapter(api, mv, owner, access, name, desc).generate()    
  }

  private def generateSetter(access:Int, name:String, desc:String,
            signature:String) {
    val f_type =  Type.getType(desc) //field type

    val mv: MethodVisitor = cv.visitMethod(access, setter_name(name), setter_desc(desc), signature, Array())
    new FieldSetterAdapter(api, mv, owner, access, name, desc).generate()    
    
  }

  /**
   * 1. Weaving the constructor to initialize the locks
   * 2. Translate putfield, getfield to getter and setter method
   */
  class FieldTrackingMethodAdapter(api : Int, mv : MethodVisitor, owner: String,
    access : Int, name : String, desc : String, locks: List[String]) 
      extends AdviceAdapter(api, mv, access, name, desc) with Opcodes {
    
    /**
     * initialize the locks in every constructor of the class
     */
    override def onMethodEnter() {
    
      //the name of constructors should be <init>
      if("<init>".equals(name)){ //is constructor
        locks.foreach{
          lock_field_name=>
            println(lock_field_name)
            mv.visitVarInsn(Opcodes.ALOAD, 0)  //load "this" for putfield
            mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDLocalValue",
              "instance", "()Ledu/syr/jbd/tracing/JBDLocalValue;")
            mv.visitFieldInsn(Opcodes.PUTFIELD, owner, lock_field_name, 
              "Ledu/syr/jbd/tracing/JBDLocalValue;")

        }
      }
    }
      
  } 

  class FieldGetterAdapter(api : Int, mv : MethodVisitor, owner: String,
    access : Int, name : String, desc : String) 
    extends AdviceAdapter(api, mv, access, getter_name(name), getter_desc(desc)) with Opcodes {

    def generate(){
      val f_type = Type.getType(desc)
      mv.visitCode()
      //get lock
      mv.visitVarInsn(Opcodes.ALOAD, 0)    //load "this" for getfield if "lock"
      mv.visitFieldInsn(Opcodes.GETFIELD, owner, lock_field_name(name), lock_desc)
      mv.visitInsn(Opcodes.DUP) // dup for tracing
      mv.visitInsn(Opcodes.MONITORENTER)


      //get value
      mv.visitVarInsn(Opcodes.ALOAD, 0)
      mv.visitFieldInsn(Opcodes.GETFIELD, owner, name, desc)
      
      //tracing
      if(f_type.getSize() == 2){
        mv.visitInsn(Opcodes.DUP2_X1) // dup for tracing -- lock, field_value ->  field_value, lock, field_value
      }else{
        mv.visitInsn(Opcodes.DUP_X1)
      }
      if(f_type.getSort() <= 8){ //primitive type, do boxing
        box(f_type)
      }      
      mv.visitVarInsn(Opcodes.ALOAD, 0)  //load obj ref of the owner
      push(owner + "@" + name + "," + desc)   
      mv.visitVarInsn(Opcodes.LLOAD, 1)  //load parent invocation id
      mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
          "traceFieldGetter", "("+ lock_desc+"Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/String;J)V")//long, int, object
      
      //release lock
      mv.visitVarInsn(Opcodes.ALOAD, 0)    
      mv.visitFieldInsn(Opcodes.GETFIELD, owner, lock_field_name(name), lock_desc)
      mv.visitInsn(Opcodes.MONITOREXIT)
    
      //return
      mv.visitInsn(f_type.getOpcode(Opcodes.IRETURN))
      mv.visitMaxs(0, 0)
      mv.visitEnd()
    }

  }

  class FieldSetterAdapter(api : Int, mv : MethodVisitor, owner: String,
    access : Int, name : String, desc : String) 
    extends AdviceAdapter(api, mv, access, getter_name(name), getter_desc(desc)) with Opcodes {

    def generate(){
      val f_type = Type.getType(desc)
      mv.visitCode()
      //get lock
      mv.visitVarInsn(Opcodes.ALOAD, 0)    //load "this" for getfield if "lock"
      mv.visitFieldInsn(Opcodes.GETFIELD, owner, lock_field_name(name), lock_desc)
      mv.visitInsn(Opcodes.DUP) // dup for tracing
      mv.visitInsn(Opcodes.MONITORENTER)

    
      //set value
      mv.visitVarInsn(Opcodes.ALOAD, 0)
      mv.visitVarInsn(f_type.getOpcode(Opcodes.ILOAD), 1)
      mv.visitFieldInsn(Opcodes.PUTFIELD, owner, name, desc)
      

      //tracing
      mv.visitVarInsn(f_type.getOpcode(Opcodes.ILOAD), 1) //load the value again      
      if(f_type.getSort() <= 8){ //primitive type, do boxing
        box(f_type)
      }
      mv.visitVarInsn(Opcodes.ALOAD, 0)  //load obj ref of the owner      
      push(owner + "@" + name + "," + desc)   
      //load parent invocation id, which is the second parameter
      //the first parameter is the new field value, so 1 + f_type.getSize() can get the proper postion of p_v_i
      mv.visitVarInsn(Opcodes.LLOAD, 1 + f_type.getSize())  
      mv.visitMethodInsn(Opcodes.INVOKESTATIC, "edu/syr/jbd/tracing/JBDTrace", 
          "traceFieldSetter", 
          "("+ lock_desc+"Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/String;J)V")
   
      //release lock
      mv.visitVarInsn(Opcodes.ALOAD, 0)    
      mv.visitFieldInsn(Opcodes.GETFIELD, owner, lock_field_name(name), lock_desc)
      mv.visitInsn(Opcodes.MONITOREXIT)
    
      //return
      mv.visitInsn(Opcodes.RETURN)      
      mv.visitMaxs(0, 0)
      mv.visitEnd()
    }

  } 
}





