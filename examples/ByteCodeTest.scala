object ByteCodeTest{
  def main(args:Array[String]) = {
    val b = true
    val a:Int = try{
        add(2, 2)
      }catch {
        case x:Throwable => 
          throw x
      }
    println(a)
  }

  def add(a: Int, b: Int) = a + b
}