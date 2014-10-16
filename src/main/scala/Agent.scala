
import java.lang.instrument.Instrumentation

object Hi {
  def premain(arg:String, inst: Instrumentation) = {println("agent!")}	
  def main(args: Array[String]) = println("You should use jbd as a java-agent")
}