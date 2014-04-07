var request = require('request');


function wielokat(n, maxK){

  var z = 0;
  for (var k = .01; k < maxK; k+=.03){
    for(var i = 0; i < n; i++) {
      var str = '<?xml version="1.0"?> <newpath userId="' + (++z) + '">';
      str += '<point x="' + ((1-k)/2+k*(Math.cos(2*Math.PI*(i/n))+1)/2) + '" y="' + ((1-k)/2+k*((Math.sin( 2*Math.PI * (i/n))+1)/2)) + '"/>';
      ++i;
      str += '<point x="' + ((1-k)/2+k*(Math.cos(2*Math.PI*(i/n))+1)/2) + '" y="' + ((1-k)/2+k*((Math.sin( 2*Math.PI * (i/n))+1)/2)) + '"/>';
      str += '</newpath>';
      --i;

      request.post({
        headers: {'content-type' :'application/xml'},
        url: 'http://grzegorzgutowski.staff.tcs.uj.edu.pl/board/newpath/',
        body: str
      }, function (error, response, body) {
        console.log(error);
        console.log(body);
      });
    }
  }

}

wielokat(3, 1);
wielokat(6, .3);
