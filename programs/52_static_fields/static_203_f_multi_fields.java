/*
Two static and two instance fields in the same class, all accessed unqualified.
*/

public class static_203_f_multi_fields {
  public static void main(String[] args) {
    A a = new A(1,2,3,4);
    a.printFields();
    System.out.println("Done!");
  }
}

class A {
  private int q;
  private static int p,r;
  private int s;

  A(int p, int q, int r, int s) {
    A.p = p;
    this.q = q;
    A.r = r;
    this.s = s;
  }

  void printFields() {
    System.out.println(p + " " + q + " " + r + " " + s);
  }
}
