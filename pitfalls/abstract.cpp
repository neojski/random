class Shape {
  virtual void reset () = 0;
  void init () {
    reset();
  }

  public:
  Shape () {
    init();
  }
};
class Point : Shape {
  double _x, _y;
  virtual void reset () {
    _x = _y = 0;
  }
};

int main () {
  Point p;
}
