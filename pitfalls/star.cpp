#include<cstdio>
struct Shape {
  int name;
};
struct Point : Shape {
  int x, y;
};

void list (Shape* shapes, int n) {
  for (int i = 0; i < n; i++) {
    printf("%d\n", shapes[i].name);
  }
}

int main () {
  Point points[10];
  for (int i = 0; i < 10; i++) {
    points[i].name = i;
  }
  list(points+1, 9); // skip first
  // sizeof(Point) != sizeof(Shape)
}
