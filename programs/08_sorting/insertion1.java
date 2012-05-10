// This program should execute correctly

public class main {
	int[] x;

	void init(int n) {
		x = new int[n];
		for (int i = 0; i<n; x[i] = n - i + 100, i++) {}
	}

	void printAll(int n) {
    String s = "";
		for (int i = 0, xi; i<n; i++) {
      xi = x[i];
      s = s + " " + xi;
		}
    System.out.print(s);
	}

	void main(String[] args) {
		int n=30;
		init(n);
		System.out.print("The original sequence is");
		printAll(n);
		System.out.print("\n"+ "Sorting the array using insertion sort ... ");
		for (int i = 0; i<n; i++) {
			int j = i - 1, v = x[i];
			while (j >= 0 && x[j] > v) {
				x[j + 1] = x[j];
				j = j - 1;
			}
			x[j+1] = v;
		}
		System.out.print("Sort completed."+ "\n"+ "The sorted sequence is");
		printAll(n);
		System.out.print("\n");
    System.out.println("Done!");
	}
}