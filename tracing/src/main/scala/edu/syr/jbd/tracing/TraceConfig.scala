/* 
* @Author: troya
* @Date:   2014-11-06 15:01:02
* @Last Modified by:   troya
* @Last Modified time: 2014-11-06 15:12:21
*/


package edu.syr.jbd.tracing

import reactivemongo.bson._
import reactivemongo.api._
    
import edu.syr.jbd.tracing.mongo.MongoDB


object TraceConfig{
  import scala.concurrent.Await
  import scala.concurrent.duration._
  lazy val default:ConfigDoc = Await.result(ConfigDoc.load_default, 2000 millis)  

}

case class ConfigDoc(
  symbol: String,
  includedClasses: List[String],
  excludedClasses: List[String]
  )



object ConfigDoc{
  import scala.concurrent.ExecutionContext.Implicits.global
  def load_default = MongoDB.coll("config")
  .find(BSONDocument("symbol" -> "default"))
  .one[ConfigDoc](ConfigDocReader,scala.concurrent.ExecutionContext.Implicits.global).map{ //IMPROVE ME!!!  
    case Some(item) => item
    case _ => ConfigDoc("default", Nil, Nil)
  }


  implicit object ConfigDocWriter extends BSONDocumentWriter[ConfigDoc] {
    def write(doc: ConfigDoc): BSONDocument = BSONDocument(
      "symbol" -> doc.symbol,
      "includedClasses" -> doc.includedClasses,
      "excludedClasses" -> doc.excludedClasses)
  }

  implicit object ConfigDocReader extends BSONDocumentReader[ConfigDoc] {
    def read(doc: BSONDocument): ConfigDoc = ConfigDoc(
      doc.getAs[String]("symbol").get,
      doc.getAs[List[String]]("includedClasses").toList.flatten,
      doc.getAs[List[String]]("excludedClasses").toList.flatten)
  } 
}


