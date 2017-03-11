#include<vector>
#include<cstdio>
#include<cassert>
#include<unistd.h>
#include<cstdlib>

// #include "LedControl.h"
// #include <ArduinoSTL.h>

using namespace std;

const int pinX = 0;
const int pinY = 1;
const int pinZ = 2;
const int INF = 10000;

// DATA IN, CLK, CS, num of devices
LedControl lc = LedControl(12,11,10,2);
void setup() {
  Serial.begin(9600);
  
  for (int d = 0; d < 2; d++) {
    lc.shutdown(d, false);
    lc.setIntensity(d, 1);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        lc.setLed(0, i, j, false);
      }
    }
  }
}

struct Point {
  int x;
  int y;
  Point(int x, int y) : x(x), y(y) {}

  Point translate(Point p) {
    return Point(x + p.x, y + p.y);
  }

  void print() {
    printf("x: %d, y: %d\n", x, y);
  }

  int dot(Point p) {
    return p.x * x + p.y * y;
  }
};

 struct Dir {
  int dir;
  Dir(int dir) : dir(dir) {}

  static vector<Point> points;

  Point getPoint(int dir) {
    return points[dir % points.size()];
  }

  Point getPoint() {
    return points[dir % points.size()];
  }

  static Dir getFromVector(float x, float y) {
    int maxI = 0;
    int maxV = -INF;
    for (int i = 0; i < 8; i++) {
      float dot = x * points[i].x + y * points[i].y;
      if (dot > maxV) {
        maxI = i;
      }
    }
    return maxI;
  }

  vector<Point> neighbours() {
    vector<Point> res;
    res.push_back(getPoint(dir));
    Point left = getPoint(dir - 1);
    Point right = getPoint(dir + 1);
    if (rand() % 2) {
      res.push_back(left);
      res.push_back(right);
    } else {
      res.push_back(right);
      res.push_back(left);
    }
    return res;
  }
};

vector<Point> Dir::points = {
    Point(1, 0),
    Point(1, 1),
    Point(0, 1),
    Point(-1, 1),
    Point(-1, 0),
    Point(-1, -1),
    Point(0, -1),
    Point(1, -1)};

struct Matrix {
  static const int size = 8;
  bool V[size][size];

  void checkPoint(Point p) {
    if (!valid(p)) {
      printf ("%s", "Invalid point");
    }
  }

  void set(Point p, bool state) {
    checkPoint(p);
    V[p.x][p.y] = state;
  }

  bool get(Point p) {
    checkPoint(p);
    return V[p.x][p.y];
  }

  Matrix() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        set(Point(i, j), false);
      }
    }
  }

  void print() {
    for (int i = 0; i < size; i++) {
      printf("-");
    }
    printf("\n");

    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        int c = V[i][size - 1 - j] ? 'o' : ' ';
        printf("%c", c);
      }
      printf("\n");
    }
  }

  void display() {
    for (int j = 0; j < 8; j++) {
      for (int i = 0; i < 8; i++) {
        lc.setLed(0, i, 8 - 1 - j, V[i][j]);
      }
    }
  }

  bool valid(Point p) {
    return p.x >= 0 && p.x < size && p.y >= 0 && p.y < size;
  }

  bool movePoint(Dir d, Point p) {
    vector<Point> neighbours = d.neighbours();
    for (int i = 0; i < neighbours.size(); i++) {
      Point next = p.translate(neighbours[i]);
      if (!valid(next)) continue;
      if (!V[next.x][next.y]) { // valid and movable
        set(next, true);
        set(p, false);
        return true;
      }
    }
    return false;
  }


  vector<Point> order(Dir d) {
    vector<Point> res;
    for (int r = -16; r < 16; r++) {
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          Point p(i, j);
          if (p.dot(d.getPoint()) == -r) {
            res.push_back(p);
          }
        }
      }
    }
    return res;
  }

  void moveAll(Dir d) {
    vector<Point> points = order(d);
    for (int i = 0; i < points.size(); i++) {
      Point p = points[i];
      if (get(p)) {
        movePoint(d, p);
      }
    }
  }
};

Dir readDir() {
  const int xpin = 0;                  // x-axis of the accelerometer
  const int ypin = 1;                  // y-axis
  const int zpin = 2;                  // z-axis (only on 3-axis models)
  
  int x = analogRead(xpin);
  int y = analogRead(ypin);
  int z = analogRead(zpin);
 
  float zero_G = 512.0; //ADC is 0~1023  the zero g output equal to Vs/2
                        //ADXL335 power supply by Vs 3.3V
  float scale = 102.3;  //ADXL335330 Sensitivity is 330mv/g
                         //330 * 1024/3.3/1000 

  // normalize (magic constants)
  int x2 = ((float)x - 331.5)/65*9.8;
  int y2 = ((float)y - 329.5)/68.5*9.8;
  int z2 = ((float)z - 340)/68*9.8;

  return Dir::getFromVector(x2, y2);
}

void loop() {
  Matrix m;

  Dir d;
  for (int i = 0; i < 10000; i++) {
    if (i % 10 == 0) {
      m.set(Point(3, 7), true);
    }

    d = readDir();

    m.display();
    m.moveAll(d);

    delay(10);
  }
}
