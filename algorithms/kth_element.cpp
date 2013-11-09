#include<iostream>
#include<vector>
#include<cmath>
#include<algorithm>
#include<cstdlib>

using namespace std;

typedef vector<int> vi;
typedef vi::iterator vit;

// Median probabilistic algorithm with expected number
// of comparisons 2n
int median(vit A, vit A_end) {
  int n = A_end - A;

  while (true) {
    int sampleSize = pow(n, 0.75);
    vector<int> sample;
    for (int i = 0; i < sampleSize; i++) {
      sample.push_back(A[rand()%n]);
    }
    sort(sample.begin(), sample.end());

    int d = sample[max(sampleSize/2 - (int)sqrt(n), 0)];
    int u = sample[min(sampleSize/2 + (int)sqrt(n), sampleSize-1)];

    int dn = 0; int un = 0;
    vector<int> C;
    for (int i = 0; i < n; i++) {
      if(A[i] < d) {
        dn++;
      } else if(A[i] > u) {
        un++;
      } else {
        C.push_back(A[i]);
      }
    }
    if (dn > n/2) continue;
    if (un > n/2) continue;
    if(C.size() > 4*sampleSize) continue;

    sort(C.begin(), C.end());
    return C[n/2 - dn];
  }
}

int kth(vit A, vit A_end, int l) {
  int p = median(A, A_end); // pivot
  int j = 0; int k = 0; // [0,j) <, [j,k) =, [k,i) >, [i, n) whatever
  int n = A_end - A;
  for (int i = 0; i < n; i++) {
    if (A[i] <= p) {
      swap(A[i], A[k++]);
      if (A[k-1] < p) {
        swap(A[k-1], A[j++]);
      }
    }
  }
  if (l < j) {
    return kth(A, A+j, l);
  }
  if (l < k) {
    return p;
  }
  return kth(A+k, A_end, l-k);
}

int kth_naive(vit A, vit A_end, int l) {
  sort(A, A_end);
  return A[l];
}

int main() {
  srand(time(NULL));
  int z; cin >> z;
  while (z--) {
    int n, k; cin >> n >> k;
    vector<int> A(n);
    for (int i = 0; i < n; i++) {
      cin >> A[i];
    }
    cout << kth(A.begin(), A.end(), k) << endl;
  }
}
