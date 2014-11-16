name := "jbd-virtualization"

version := "1.0"

libraryDependencies ++= Seq(
  // Select Play modules
  //jdbc,      // The JDBC connection pool and the play.api.db API
  //anorm,     // Scala RDBMS Library
  //javaJdbc,  // Java database API
  //javaEbean, // Java Ebean plugin
  //javaJpa,   // Java JPA plugin
  //filters,   // A set of built-in filters
  javaCore,  // The core Java API
  cache,
  //MongoDB support
  "org.reactivemongo" %% "play2-reactivemongo" % "0.10.5.0.akka23",
  // WebJars pull in client-side web libraries
  "org.webjars" %% "webjars-play" % "2.3.0",
  "org.webjars" % "bootstrap" % "3.2.0")
 