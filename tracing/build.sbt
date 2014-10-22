name := "jbd-tracing"

version := "1.0"

resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies += "org.reactivemongo" %% "reactivemongo" % "0.10.5.0.akka23"

libraryDependencies += "org.ow2.asm" % "asm" % "5.0.3"

libraryDependencies += "org.ow2.asm" % "asm-analysis" % "5.0.3"

libraryDependencies += "org.ow2.asm" % "asm-util" % "5.0.3"

libraryDependencies += "org.ow2.asm" % "asm-commons" % "5.0.3"

libraryDependencies += "com.typesafe" % "config" % "1.2.1"