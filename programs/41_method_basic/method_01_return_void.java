/*
01. Simple method test.
  - call a method, no args, return type void, printing a value.
*/

public class method_01_return_void {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    x=1;
    f();
  }

  void f() {
    System.out.println("f()");
  }
}
