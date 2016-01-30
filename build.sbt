name := "jbd"

version := "1.0"

scalaVersion := "2.10.5"


packAutoSettings

lazy val root = project.in(file(".")).aggregate(agent, examples)

lazy val agent = project.dependsOn(tracing)
  
lazy val tracing = project

lazy val examples = project

lazy val visualization = project.dependsOn(tracing).enablePlugins(PlayScala)

