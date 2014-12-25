/* 
* @Author: Beinan
* @Date:   2014-11-18 21:28:24
* @Last Modified by:   Beinan
* @Last Modified time: 2014-11-19 14:49:40
*/
package samples;

public class QuickSort {
    public static void main(String[] args) {
      int[] a = { 4, 3, 7, 11, 2, 6, 5 };
      quick_sort(a, 0, 6);
      for(int v : a){
        System.out.print(v);
        System.out.print(" "); 
      }

    }

    public static void quick_sort(int[] v1, int b, int e) {
      if (b == e) return;
      int l = b, u = e;
      int pivot = v1[l];
      int temp;
      for (int k = b + 1; k <= e; k++)
      {
        if (v1[l+1] < pivot) { v1[l] = v1[l+1]; l++; }
        else { temp = v1[u]; v1[u] = v1[l+1]; v1[l+1] = temp; u--; }
      }
      v1[l] = pivot;
      if ((l - b > 1)) quick_sort(v1, b, l - 1);
      if ((e - u >1)) quick_sort(v1, u + 1, e);
      return;
    }
}