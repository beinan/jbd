name := "jbd-agent"

version := "1.0"

packageOptions += 
  Package.ManifestAttributes( "Premain-Class" -> "edu.syr.jbd.JBDAgent" )




jarName in assembly := "jbd-agent.jar"



assemblyShadeRules in assembly := Seq(
      ShadeRule.rename("org.objectweb.**" -> "shadeio.@1").inAll
)
