/* 
* @Author: Beinan
* @Date:   2014-11-08 21:58:27
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-08 22:07:54
*/

package controllers

import play.api.mvc.{Action, Controller}
import play.api.libs.json.Json
import play.api.Routes


object MainController extends Controller {
  
  def index() = Action {
    Ok(views.html.index.render("JBD Management & Virtualization"))
  }

  def getMessage(id: String) = Action {
    Ok(Json.toJson("Ok"))
  }

  
  def javascriptRoutes = Action { implicit request =>
    Ok(Routes.javascriptRouter("jsRoutes")(
      routes.javascript.MainController.getMessage
    )).as(JAVASCRIPT)
  }
}
