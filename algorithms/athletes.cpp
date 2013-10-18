#include<iostream>
#include<algorithm>

/*
http://acm.mipt.ru/judge/problems.pl?problem=004:
Every athlete is characterized by his mass mi (in kg) and strength si(in kg).

You are to find the maximum number of athletes that can form a tower standing one upon another.

An athlete can hold a tower of athlets with total mass equal to his strength or less than his strength.

Input contains the number of athletes n and their parameters:

n
m1 s1
m2 s2
...
mn  sn

If mi > mj then si > sj, but athletes with equal masses can be of different strength.

Number of athletes n < 100000. Masses and strengths are positive integers less than 2000000.

SOLUTION:
it's easy to notice that you have to sort athletes by rank = s+m (check that if you have two athletes and that with bigger rank is higher then we can swap them. So sort athletes. Then start from the athlete with smallest rank and add athletes below him. If athlete can't hold the whole stack we can throw him away.
*/

using namespace std;

const int MAX = 100000;

struct athlete{
  int m;
  int s;
  bool operator<(const athlete& A) const {
    return s+m < A.s+A.m;
  }
};

athlete A[MAX];

int main(){
  int n; cin >> n;
  for(int i = 0; i < n; i++){
    cin >> A[i].m >> A[i].s;
  }
  sort(A, A+n);

  int count = 1;
  int last = 0; // last chosen athlete
  int totalMass = A[last].m;
  for(int i = 1; i < n; i++){
    if(A[i].s >= totalMass){
      last = i;
      totalMass += A[i].m;
      count++;
    }
  }

  cout << count;
}
