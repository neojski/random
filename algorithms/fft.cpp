#include<vector>
#include<iostream>
#include<complex>

using namespace std;

typedef complex<double> C;
typedef string bignum;
double pi = 3.1415926535897;

// assume that p has 2^n elements
// w(x) = w_0(x^2) + w_1(x^2) * x
vector<C> fft(const vector<C>& p, bool inv = false){
  int n = p.size();
  if(n == 1){
    return p;
  }
  vector<C> w0, w1;
  for(int i = 0; i < n; i++){
    w0.push_back(p[i++]);
    w1.push_back(p[i]);
  }
  vector<C> r0 = fft(w0, inv);
  vector<C> r1 = fft(w1, inv);
  vector<C> res;
  C e = exp(C(0,1) * (pi / n) * (inv ? 2.0 : -2.0));
  C c = 1;
  for(int i = 0; i < n; i++){
    // w(e^(2 pi i * i):
    res.push_back(r0[i%(n/2)] + r1[i%(n/2)] * c);
    c *= e;
  }
  return res;
}

vector<C> bignumToPoly(const bignum& a){
  vector<C> poly;
  for(int i = 0; i < a.size(); i++){
    poly.push_back(a[a.size()-1-i] - '0');
  }
  return poly;
}

inline int intRe(const C& x){
  return round(real(x));
}

void mul(const bignum& a0, const bignum& b0){
  vector<C> a = bignumToPoly(a0);
  vector<C> b = bignumToPoly(b0);

  int j = max(a.size(), b.size());
  int n = 1;
  while(n < j){
    n <<= 1;
  }
  n *= 2; // result is this long

  for(int i = a.size(); i < n; i++){
    a.push_back(0);
  }
  for(int i = b.size(); i < n; i++){
    b.push_back(0);
  }

  vector<C> x = fft(a);
  vector<C> y = fft(b);

  vector<C> res;
  for(int i = 0; i < n; i++){
    res.push_back(x[i] * y[i]);
  }
  res = fft(res, true);

  // we need to move carry to next digit
  vector<int> intRes;
  for(int i = 0; i < n; i++){
    intRes.push_back(intRe(res[i] * (1.0 / n)));
  }
  for(int i = 0; i < n-1; i++){
    intRes[i+1] += intRes[i] / 10;
    intRes[i] %= 10;
  }
  bool flag = false;
  for(int i = n-1; i >= 0; i--){
    if(intRes[i] != 0){
      flag = true;
    }
    if(flag){
      cout << intRes[i];
    }
  }
  if(!flag){
    cout << 0;
  }
}

int main(){
  bignum a = "7703739845";
  bignum b = "13801630823237866";

  mul(a, b);
}
