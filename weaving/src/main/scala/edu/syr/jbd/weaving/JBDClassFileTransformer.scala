package edu.syr.jbd.weaving

import java.lang.instrument.ClassFileTransformer

import java.security.ProtectionDomain

class JBDClassFileTransformer extends ClassFileTransformer{

	def transform(loader : ClassLoader, className : String, 
		classBeingRefined: Class[_], 
		protectionDomain: ProtectionDomain,
		classFileBuffer: Array[Byte]):Array[Byte] = {

		println(className)
		classFileBuffer
	}
}