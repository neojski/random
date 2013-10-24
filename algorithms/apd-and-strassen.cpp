#include<vector>
#include<iostream>
#include<stdexcept>

using namespace std;

#define REP(x,n) for(int x=0; x<(n); ++x)
#define PB push_back
class matrix{
  int n;
  vector<vector<int> > d;
public:
  enum init{one, zero};
  matrix(int n, init val = zero) : n(n) {
    d = vector<vector<int> >(n, vector<int>(n, 0));
    if (val == one) {
      REP(i,n) d[i][i] = 1;
    }
  }
  matrix(const matrix& m) : n(m.n), d(m.d) {}
  int size() const {
    return n;
  }
  vector<int>& operator[](int i){
    return d[i];
  }
  const vector<int>& operator[](int i) const {
    return d[i];
  }
  int& operator()(int i, int j) {
    return d[i][j];
  }
  const int& operator()(int i, int j) const {
    return d[i][j];
  }
  matrix& operator+=(const matrix& r){
    REP(i,n) REP(j,n) d[i][j] += r[i][j];
    return *this;
  }
  matrix& operator-=(const matrix& r){
    REP(i,n) REP(j,n) d[i][j] -= r[i][j];
    return *this;
  }
  friend matrix operator*(const matrix&, const matrix&);
  friend ostream& operator<<(ostream &out, const matrix& m);
};
matrix operator*(const int c, const matrix& m){
  int n = m.size();
  matrix res(m);
  REP(i,n) REP(j,n) res[i][j] *= c;
  return res;
}
matrix operator+(matrix l, const matrix& r){
  l += r;
  return l;
}
matrix operator-(matrix l, const matrix& r){
  l -= r;
  return l;
}
ostream& operator<<(ostream &out, const matrix& m){
  REP(i,m.size()){
    REP(j,m.size()){
      out << m[i][j] << " ";
    }
    out << endl;
  }
  return out;
}

// strassen multiplication
matrix getBlock(const matrix& m, int r, int c){
  int n = m.size()/2;
  matrix res(n);
  int offsetR = n*r;
  int offsetC = n*c;
  for(int i = 0; i < n; i++){
    for(int j = 0; j < n; j++){
      res[i][j] = m[offsetR+i][offsetC+j];
    }
  }
  return res;
}
void putBlock(matrix& m, const matrix& b, int r, int c){
  int n = b.size();
  int offsetR = n*r;
  int offsetC = n*c;
  REP(i,n) REP(j,n) m[i+offsetR][j+offsetC] = b[i][j];
}

// interesting fact:
// ikj loop order is much more preformant that ijk!
matrix multiply(const matrix& a, const matrix& b){
  if(a.size() != b.size()){
    throw out_of_range("sizes differ");
  }
  int n = a.size();
  matrix res(n);
  REP(i,n) REP(k,n) REP(j,n)
    res[i][j] += a[i][k] * b[k][j];
  return res;
}
matrix strassen(const matrix& a, const matrix& b){
  if(a.size() <= 64){
    return multiply(a,b);
  }

  matrix a11 = getBlock(a, 0, 0);
  matrix a12 = getBlock(a, 0, 1);
  matrix a21 = getBlock(a, 1, 0);
  matrix a22 = getBlock(a, 1, 1);

  matrix b11 = getBlock(b, 0, 0);
  matrix b12 = getBlock(b, 0, 1);
  matrix b21 = getBlock(b, 1, 0);
  matrix b22 = getBlock(b, 1, 1);

  matrix m1 = strassen(a11+a22, b11+b22);
  matrix m2 = strassen(a21+a22, b11);
  matrix m3 = strassen(a11, b12-b22);
  matrix m4 = strassen(a22, b21-b11);
  matrix m5 = strassen(a11+a12, b22);
  matrix m6 = strassen(a21-a11, b11+b12);
  matrix m7 = strassen(a12-a22, b21+b22);

  matrix c11 = (m1+m4)-(m5+m7);
  matrix c12 = m3+m5;
  matrix c21 = m2+m4;
  matrix c22 = (m1-m2)+(m3+m6);

  matrix res(a.size());
  putBlock(res, c11, 0, 0);
  putBlock(res, c12, 0, 1);
  putBlock(res, c21, 1, 0);
  putBlock(res, c22, 1, 1);
  return res;
}
matrix prepstrassen(const matrix& a, const matrix& b){
  int n = a.size();
  int s = 1;
  while(s < n) s <<= 1;

  matrix A(s);
  matrix B(s);
  putBlock(A, a, 0, 0);
  putBlock(B, b, 0, 0);

  matrix Res = strassen(A, B);
  matrix res(n);

  REP(i,n) REP(j,n) res[i][j] = Res[i][j];

  return res;
}
matrix operator*(const matrix& a, const matrix& b){
  return prepstrassen(a,b);
}


// All Pairs Distances
matrix APD(matrix A){
  int n = A.size();
  matrix Z = A * A;
  matrix Ap(n);
  REP(i,n) REP(j,n) Ap[i][j] = (i != j) && (A[i][j] > 0 || Z[i][j] > 0);

  bool end = true;
  REP(i,n) REP(j,n) if(i != j && Ap[i][j] != 1){ end = false; break; }
  if(end) return 2 * Ap - A;

  matrix Dp = APD(Ap);
  matrix S = A * Dp;

  matrix D(n);
  REP(i,n){
    REP(j,n){
      D[i][j] = 2 * Dp[i][j];
      if(S[i][j] < Dp[i][j] * Z[i][i]){
        --D[i][j];
      }
    }
  }
  return D;
}
int main(){
  int n; cin >> n;
  matrix A(n);
  REP(i,n) REP(j,n) cin >> A[i][j];

  cout << APD(A);
  //cout << A * A;
  //cout << prepstrassen(A, A);
}
