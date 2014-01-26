#define REP(x,n) for(int x=0;x<n;x++)
#define ALL REP(i,2) REP(j,2) REP(k,2)

const int DELAY = 10;
int cube[2][2][2];

int cols[2][2] = {{8, 9}, {10, 11}};
int rows[2] = {6, 7};

void clear() {
  ALL cube[i][j][k] = 0;
}

void setup() {
  REP(i,2) pinMode(rows[i], OUTPUT);
  REP(i,2) REP(j,2) pinMode(cols[i][j], OUTPUT);
}

void randomIn(int time) {
  int count = 8;
  while(count > 0){
    int x = random(2);
    int y = random(2);
    int z = random(2);
    if(cube[y][x][z]==0){
      cube[y][x][z]=1;
      count--;
      show(time);
    }
  }
}

void layerSpiral(int i, int time) {
  REP(j,2) {
    cube[i][0][j] = 1;
    show(time);
    clear();
  }
  REP(j,2) {
    cube[i][1][1-j] = 1;
    show(time);
    clear();
  }
}

void layer(int i, int time) {
  REP(j,2) REP(k,2) cube[i][j][k] = 1;
  show(time);
  clear();
}

void loop() {
  const int t = 100;
  
  REP(x,4)
  REP(l,2){
    layer(l, 500);
  }
  
  REP(x,3) ALL {
    cube[i][j][k] = 1;
    show(t);
    clear();
  }
  
  REP(x,3){
    randomIn(t);
    clear();
  }

  REP(i,3){
    REP(l,2){
      REP(x,3) layerSpiral(l, t);
    }
  }
}

void show(int time){
  REP(t,time/DELAY/2){
    REP(i,2){
      digitalWrite(rows[i], LOW);
      REP(j,2) REP(k,2){
        digitalWrite(cols[j][k], cube[i][j][k] ? HIGH : LOW);
      }
      delay(DELAY);
      digitalWrite(rows[i], HIGH);
    }
  }
}
