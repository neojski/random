#include<cmath>
class Point {
  public:
    Point(double x = 0, double y = 0) {}
};

int main () {
  double a, r, x, y;
  Point p = (x + r * cos(a), y + r * sin(a));
  // compiles but should have been either:
  // Point p(X, Y);
  // or
  // Point p = Point(X, Y);
  // Right now it becomes: Point(Y)
  // explicit would have helped
}
