class i {
  int f;
  void i(int v) {
    f = v;
  }
  int get() { return f; }
}

class g {
  i o;
  void g(i o) {
    this.o = o;
  }
  int do1() {
    int f = 9;
    return (o.get());
  }
}

public class main {
  void main(String[] args) {
    i t = new i(1);
    g y = new g(t);  // passes an oect
    System.out.print(y.do1());
  }
}
