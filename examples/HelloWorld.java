
public class HelloWorld{
	public static void main(String[] args){
    
    int c = add(4,5);
    try{
      System.out.println("Hello World!1");
    }catch(Exception x){
      throw x;
    }

    try{
      System.out.println("Hello World!2");
      try{
        System.out.println("Hello World!3");
      }catch(Exception x){
        throw x;
      }
    }catch(Exception x){
      throw x;
    }

    
		
	}

  public static int add(int a, int b) {
    return a + b;
  }
}