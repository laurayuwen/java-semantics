// Testing simple continue inside while loop with label.
// Label should not affect continue execution.

public class main {

  void main(String[] args) {
    int i=0;
    label_1:
    while (i<10) {
      int j = i;
      i++;
      if (j % 2 != 0) continue;
      System.out.print(j+" ");
    }
    System.out.println("\n"+ "Done!");
  }
}

// 0 2 4 6 8
// Done!