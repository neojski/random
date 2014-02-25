#include<cstdio>
int main() {
  int n = 100000;
  double* arr = new double (n); // this should have been [n]!
  for (int i = 0; i < n; i++) {
    arr[i] = i;
  }
}
