#include<string>
#include<iostream>
#include<vector>

using namespace std;

vector<int> getrow(const string& a, const string& b){
  vector<int> v(a.size()+1, 0);
  int prev;
  for(int i = 1; i <= b.size(); i++){
    prev = 0;
    for(int j = 1; j <= a.size(); j++){
      int tmp = v[j];
      v[j] = max(v[j], max(v[j-1], a[j-1] == b[i-1] ? prev + 1 : 0));
      prev = tmp;
    }
  }
  return v;
}
string rev(const string& a){
  return string(a.rbegin(), a.rend());
}
// here we should have had references
string lcs(string a, string b){
  if(a.size() > b.size()) swap(a,b);
  if(a.size() > 1){
    int c = b.size()/2;
    vector<int> v1 = getrow(a, b.substr(0, c));
    vector<int> v2 = getrow(rev(a), rev(b.substr(c, b.size()-c)));

    int max = 0;
    int j;
    for(int i = 0; i < v1.size(); i++){
      int sum = v1[i] + v2[v2.size() - 1 - i];
      if(sum >= max){
        max = sum;
        j = i;
      }
    }
    return lcs(a.substr(0, j), b.substr(0, c)) +
      lcs(a.substr(j, a.size() - j), b.substr(c, b.size() - c));
  }else{
    if(b.find(a) != string::npos){
      return a;
    }
    return "";
  }
}

int main() {
  int z; cin >> z;
  while(z--){
    string a, b;
    cin >> a >> b;
    string res = lcs(a, b);
    cout << res.size() << endl << res << endl;
  }
  return 0;
}
