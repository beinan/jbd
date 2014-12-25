/* 
* @Author: Beinan
* @Date:   2014-11-22 16:35:36
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-22 18:11:56
*/
package samples.concurrent;

public class Plant {
    public static final int THREAD_COUNT = 3;
    public static final int[][] WORKER_PATTERN= {
      {1,1,1},{3,0,0},{0,0,3},{0,3,0},
      {0,1,2},{0,2,1},{1,0,2},{1,2,0},{2,1,0},{2,0,1},
    };

    public static void main(String[] args) throws Throwable{
      Thread partWorkers[] = new Thread[THREAD_COUNT];
      Thread productWorkers[] = new Thread[THREAD_COUNT];      
      Buffer buff = new Buffer(6,5,4);
      for(int i = 0; i < THREAD_COUNT; i++){
        partWorkers[i] = new Thread(new PartWorker(buff));
        partWorkers[i].start();
        productWorkers[i] = new Thread(new ProductWorker(buff));
        productWorkers[i].start();        
      }
      
      for(int i = 0; i < THREAD_COUNT; i++){
        partWorkers[i].join();        
        productWorkers[i].join();
      }
          

    }
}

class Buffer{
  
  int a, b, c;
  int aCapacity, bCapacity, cCapacity;
  
  Buffer(int aCapacity, int bCapacity, int cCapacity){
    this.aCapacity = aCapacity;
    this.bCapacity = bCapacity;
    this.cCapacity = cCapacity;
  }

  public synchronized void placeRequest(int a, int b, int c) throws InterruptedException{
    System.out.println("Place Request:" + a + b + c);
    while(a + this.a > aCapacity || b + this.b > bCapacity || c + this.c > cCapacity)
      this.wait();
    this.a +=a; this.b+=b; this.c+=c;
    this.notifyAll();
  }   
  
  public synchronized void pickUpRequest(int a, int b, int c) throws InterruptedException{
    System.out.println("Pick-up Request:" + a + b + c);
    while(a > this.a || b > this.b || c > this.c){
      int partialA = Math.min(a, this.a);
      int partialB = Math.min(b, this.b);
      int partialC = Math.min(c, this.c); 
      partialPickUp(partialA, partialB, partialC);
      a -= partialA; b -= partialB; c -= partialC;
      this.wait();
    }
    this.a -= a; this.b -= b; this.c -= c; //pick up
    this.notifyAll();
  }

  private void partialPickUp(int a, int b, int c){
    this.a -= a; this.b -= b; this.c -= c;
  }
}

class PartWorker implements Runnable{
  Buffer buff;
  public PartWorker(Buffer buff){
    this.buff = buff;
  }
  public void run(){
    for(int i = 0; i < 10; i++){
      int pattern[] = Plant.WORKER_PATTERN[(int)(Math.random() * 10)];
      try{
        buff.placeRequest(pattern[0], pattern[1], pattern[2]);
      }catch(InterruptedException ex){
        throw new RuntimeException(ex);
      }
    }
  }
}


class ProductWorker implements Runnable{
  Buffer buff;
  public ProductWorker(Buffer buff){
    this.buff = buff;
  }
  public void run(){
    for(int i = 0; i < 10; i++){
      int pattern[] = Plant.WORKER_PATTERN[(int)(Math.random() * 6 + 4)];
      try{
        buff.pickUpRequest(pattern[0], pattern[1], pattern[2]);
      }catch(InterruptedException ex){
        throw new RuntimeException(ex);
      }
    }
  }
}