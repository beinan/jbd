import AssemblyKeys._ 

name := "jbd-agent"

version := "1.0"

packageOptions += 
  Package.ManifestAttributes( "Premain-Class" -> "edu.syr.jbd.JBDAgent" )




jarName in assembly := "jbd-agent.jar"

assemblySettings

