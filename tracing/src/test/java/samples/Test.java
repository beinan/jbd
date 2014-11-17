/* 
* @Author: troya
* @Date:   2014-11-06 16:08:43
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-16 22:04:35
*/

package samples;
public class Test {
	public int a;
	public Test b;
	public final Object lock = new Object();

    public static void main(String[] args) {
    	System.out.println(add(5,3));
    	Test t = new Test();
    	
    	
    }

    public static double add(double a, double b){
    	return a + b;
    }

    public void setA(int p){
    	synchronized(b){
    		a = p;
    	}
    }
}