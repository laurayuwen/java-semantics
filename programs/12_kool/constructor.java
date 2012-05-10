// Testing new, constructor, method invocation.

class C {
  int i, j;

  void C(int x) {
    i = x;
    j = ++x;
  }

  void add(int d) {
    i = i+d;
    j = j-d;
  }

  void print2() {
    System.out.println(i+ " "+ j);
  }
}

public class main {
  int a, b;
  C o;

  void main(String[] args){
    a = b = 5;
    o = new C(a);
    o.print2();
    o.add(++b);
    o.print2();
    System.out.println("Done!");
  }
}


// 5 6
// 11 0
// Done!