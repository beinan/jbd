jbd
===

JVM Bug Digger -- A distributed monitoring, tracing and debugging tool

##Build
###Build Java Agent

`>  project agent`

`>  assembly`

##Usage
###Start monitoring
####In command-line

``

###Start visualization tool in sbt

`> project visualization`

`> run`

Then visit http://localhost:9000 


###Interweave and run the tracing samples

`> project tracing`
`> test`