#include<vector>
template<typename T>
struct Array {
  Array (int size) {}
  T& operator[] (int) {}
  Array<T>& operator= (const Array<T>&) {}
};
int main () {
  Array<int> a(10);
  a[0] = 0;
  a[1] = 1;
  a[2] = 2;
  a = 3; // this compiles!
  a[3] = 3;
}
