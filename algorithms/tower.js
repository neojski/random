function floor(n){
  var f = 0; // current floor
  for(var i = 1;; i++){ // current rectangle size
    for(var j = 0; j < i; j++){
      ++f;
      for(var k = 0; k < i; k++){
        --n;
        if(n === 0){
          return [f, k+1];
        }
      }
    }
  }
}

// sum of squares
// 1 + 4 + 9 + 16 + ...
// n(n+1)(2n+1)/6
function floor2(n){
  var i;
  for(i = 1;; i++){
    if(i * (i+1) * (2*i+1) / 6 >= n){
      break;
    }
  }
  // i zwraca w jakim kwadracie jest n
  var f = i*(i-1)/2;  // 1 + 2 + ... + (i-1) = tyle pięter poniżej kwadratu

  n -= (i-1) * i * (2*i - 1) / 6; // teraz które n jest w swoim kwadracie

  return [f + Math.ceil(n/i), (n-1)%i + 1];
}

for(var i = 1; i < 200000; i++){
  var fast = floor2(i);
}

