package edu.syr.jbd.tracing.mongo

object MongoDB{
	import reactivemongo.api._
    import scala.concurrent.ExecutionContext.Implicits.global


    // gets an instance of the driver
    // (creates an actor system)
    val driver = new MongoDriver
    val db_address = sys.env.getOrElse("DB_PORT_27017_TCP_ADDR", "localhost");
    val db_port = sys.env.getOrElse("DB_PORT_27017_TCP_PORT", "27017");

    val connection = driver.connection(List(db_address + ":" + db_port))

    // Gets a reference to the database "plugin"
    val db = connection("jbd")

    def coll(coll_name: String) = db(coll_name)

    def test = {
    	import reactivemongo.bson._
        import scala.util.{Success, Failure}

    	val document = BSONDocument(
          "symbol" -> "default",  
		    "includeClasses" -> List(""),
          "excludedClasses" -> List("com.sun.","sun.")
          )

    	val future = coll("config").insert(document)
    	future.onComplete {
		  case Failure(e) => throw e
		  case Success(lastError) => {
		    println("successfully inserted document with lastError = " + lastError)
            connection.close()
		  }
		}
        
    }
 }

