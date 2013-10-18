#include<iostream>
#include<vector>

/* http://acm.mipt.ru/judge/problems.pl?problem=010
 * SOLUTION: turbo-matching */

using namespace std;

vector<int> G[2008];
int M[2008];
bool V[2008];
int N, K, C;

bool path(int x){
  if(V[x]) return false;
  V[x] = true;

  for(int i = 0; i < G[x].size(); i++){
    int y = G[x][i];
    if(!M[y] || path(M[y])){
      M[x] = y;
      M[y] = x;
      return true;
    }
  }
  return false;
}

int pathset(){
  for(int i = 1; i <= N+K; i++){
    V[i] = 0;
  }
  bool change = false;
  for(int i = 1; i <= N+K; i++){
    if(!M[i]){
      change = change || path(i);
    }
  }
  return change;
}

int main(){
  cin >> N >> K >> C;

  while(C--){
    int i, j; cin >> i >> j;
    j += N;
    G[i].push_back(j);
    G[j].push_back(i);
  }

  int count = 0;
  while(pathset());

  for(int i = 1; i <= N; i++){
    if(M[i]) count++;
  }

  cout << count << endl;
  for(int i = 1; i <= N; i++){
    if(M[i]){
      cout << i << " " << M[i]-N << endl;
    }
  }
}
