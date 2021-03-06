import sbt._
import Keys._

object JBDBuild extends Build {
  
  lazy val root = project.in(file(".")).aggregate(agent, examples)

  lazy val agent = project.dependsOn(tracing)
  
  lazy val tracing = project

  lazy val examples = project
}
