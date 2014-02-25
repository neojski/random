#include<cstdio>
struct A {
  A () {
    printf("%d\n", getColor());
  }
  virtual int getColor() {
    return 1;
  }
};
struct B : A {
  int getColor () {
    return 2;
  }
};
int main () {
  A a; // 1
  B b; // 1
}

