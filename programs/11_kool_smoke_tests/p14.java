class a {
  int x;
  void a() {
    x=7;
  }
  int m0() {
    return x;
  }
}

class b extends a {
  boolean x ;
  void b() {
    super.a();
    x=true;
  }
  int m1() {
    return super.x;
  }
  int m2() {
    a o = this;
    return o.x;            // implicit casting
    // the field x is the one in the type a of o, that is, 7
  }
  int m3() {
    return ((a) this).x;  // explicit casting
    //"cast object to class" casts "object" to "class"
  }
  int m4() {
    return aux1(this);
  }
  int aux1(a o) {   // implicit casting, again
    return o.x;
  }
  boolean m5() {
    return aux2(this);
  }
  boolean aux2(a o) {       // implicit casting, again
    return ((b) o).x;     // but then explicit casting back to b
  }
}

public class main {
  void main(String[] args) {
    b o = new b();
    if (o.m5()) System.out.print(""+o.m0()+ o.m1()+ o.m2()+ o.m3()+ o.m4());
    else System.out.println("m5 not returning true");
  }
}
