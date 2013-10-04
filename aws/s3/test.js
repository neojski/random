var AWS = require('aws-sdk');
var fs = require('fs');

// load credentials from aws.json like
// { "accessKeyId": "akid", "secretAccessKey": "secret", "region": "us-east-1" }
AWS.config.loadFromPath(process.env.HOME + '/aws.json');

var s3 = new AWS.S3();

function put(){
  var body = fs.readFileSync('longcat.jpeg');
  s3.putObject({Bucket: 'tomasz-test', Key: 'longcat.jpeg', Body: body, ContentType: 'image/jpeg'}, function(err, data) {
    if (err) {
      console.log(err);
    } else {
      console.log(data);
    }
  });
}
function get(){
  s3.getObject({Bucket: 'tomasz-test', Key: 'longcat.jpeg'}).createReadStream().pipe(fs.createWriteStream('result.jpeg'));
}

get();
