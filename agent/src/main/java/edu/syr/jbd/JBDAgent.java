package edu.syr.jbd;

import java.lang.instrument.Instrumentation;

import com.typesafe.config.*;

import edu.syr.jbd.tracing.weaving.JBDClassFileTransformer;

public class JBDAgent{

	public static void premain(String arg, Instrumentation ins){
		System.out.println("JBD Agent starts.");

    

		ins.addTransformer(new JBDClassFileTransformer());
	}

	public static void main(String[] args){
		Config conf = ConfigFactory.load();
    System.out.println(conf.getInt("abb"));
	}
} 