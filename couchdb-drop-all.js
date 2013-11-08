var http = require('http');

http.get('http://localhost:5984/_all_dbs', function(res) {
  var json = '';
  res.on('data', function(chunk) {
    json += chunk.toString();
  });
  res.on('end', function() {
    removeAll(JSON.parse(json));
  });
});

function removeAll(all) {
  all.forEach(function(db) {
    console.log('deleting ' + db);
    http.request({method: 'delete', port: 5984, path: '/' + encodeURIComponent(db)}, function(res) {
      console.log(res.statusCode);
    }).end();
  });
}
