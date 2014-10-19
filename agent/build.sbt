import AssemblyKeys._ 

name := "jbd-agent"

version := "1.0"

packageOptions += 
  Package.ManifestAttributes( "Premain-Class" -> "edu.syr.jbd.JBDAgent" )

libraryDependencies += "com.typesafe" % "config" % "1.2.1"


jarName in assembly := "jbd-agent.jar"

assemblySettings

