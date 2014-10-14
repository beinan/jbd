name := "jbd"

version := "1.0"

scalaVersion := "2.10.3"

packageOptions += 
  Package.ManifestAttributes( "Premain-Class" -> "Hi" )

libraryDependencies += "org.ow2.asm" % "asm" % "5.0.3"

packAutoSettings