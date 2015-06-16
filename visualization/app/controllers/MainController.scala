/* 
* @Author: Beinan
* @Date:   2014-11-08 21:58:27
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-16 20:07:42
*/

package controllers



import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.functional.syntax._
import play.api.libs.json._
import scala.concurrent.Future

// Reactive Mongo imports
import reactivemongo.api._

import play.api.Logger

// Reactive Mongo plugin, including the JSON-specialized collection
import play.modules.reactivemongo.MongoController
import play.modules.reactivemongo.json.collection.JSONCollection



object MainController extends Controller with MongoController{
  
  def index() = Action {
    Ok(views.html.index.render("JBD Management & Virtualization"))
  }


  def collection: JSONCollection = db.collection[JSONCollection]("trace")
  
  def getMessage(id: String) = Action.async {
    // let's do our query
    val cursor: Cursor[JsObject] = collection.
      // find all people with name `name`
      find(Json.obj()).
      // perform the query and get a cursor of JsObject
      cursor[JsObject]

    // gather all the JsObjects in a list
    val futurePersonsList: Future[List[JsObject]] = cursor.collect[List]()

    // transform the list into a JsArray
    val futurePersonsJsonArray: Future[JsArray] = futurePersonsList.map { persons =>
      Json.arr(persons)
    }

    // everything's ok! Let's reply with the array
    futurePersonsJsonArray.map { persons =>
      Ok(persons)
    }
  }

  import reactivemongo.bson._
  import reactivemongo.core.commands._
  import play.modules.reactivemongo.json.BSONFormats._

  def query() = Action.async{ request =>
      request.body.asJson.map{ json =>
        val futureObjsList: Future[List[JsObject]] = collection.
          find(json).
          cursor[JsObject].
          collect[List]()

        futureObjsList.map { objs =>
          Ok(Json.toJson(objs))
        }        
      }.get
  }

  def mapReduce(coll: String) = Action.async{ request =>
      request.body.asJson.map{ json =>
        val map = (json \ "map").as[String]
        val reduce = (json \ "reduce").as[String]
        val mapReduceCommand = BSONDocument(
          "mapreduce" -> "trace",
          "map" -> BSONString(map),
          "reduce" -> BSONString(reduce),
          "out" -> BSONDocument("inline" -> 1)
        )
        val result = db.command(RawCommand(mapReduceCommand))       
        result.map { result =>
          Ok(Json.toJson(result))
        }
      }.get
  }


  import java.io.FileInputStream
  import com.github.javaparser.JavaParser
  import com.github.javaparser.ast.CompilationUnit
  import _root_.com.jbd.visualization.ast.Ast2JsonParser

  def getSourceCode() = Action{ request =>
      request.body.asJson.map{ json =>
        val class_name = (json \ "class_name").as[String]
        val method_name = (json \ "method_name").as[String]
        Logger.debug(s"Getting source code for $class_name $method_name")
        
        val in = new FileInputStream("/home/bwang19/jbd/tracing/src/test/java/samples/concurrent/Plant.java")

        val cu = JavaParser.parse(in)
        in.close()
        //Logger.debug(cu.toString())
        //val result = db.command(RawCommand(mapReduceCommand))
        //result.map { result =>
        Ok(Ast2JsonParser.ast2json(cu))
        //}
      }.get
  }

  def javascriptRoutes = Action { implicit request =>
    Ok(Routes.javascriptRouter("jsRoutes")(
      routes.javascript.MainController.getMessage,
      routes.javascript.MainController.mapReduce,
      routes.javascript.MainController.query,
      routes.javascript.MainController.getSourceCode
    )).as(JAVASCRIPT)
  }
}
