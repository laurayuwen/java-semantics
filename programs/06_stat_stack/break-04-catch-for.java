// Testing break inside try/catch inside for. Try./catch should not affect
// break behavior, even if both interact with the same stack.

public class main {

  void main(String[] args) {
    int i;
    for(i=0; i<10; i++) {
      try {
        if (i >= 5) break;
      } catch(int ex) {
        System.out.print("never reached");
      }
      System.out.print(i+" ");
    }
    System.out.println("\n"+ "final i = "+ i);
    System.out.println("Done!");
  }
}

// 0 1 2 3 4
// final i = 5
// Done!