var express = require('express');
var app = express();

app.use(express.cookieParser());
app.use(express.session({secret: '1234567890QWERTY'}));

app.get('/:id', function(req, res) {
    var id = req.params.id;
    if(!req.session.pages) {
        req.session.pages = [];
        req.session.count = 0;
    }
    req.session.pages.push(id);
    req.session.count++;

    var data = '<html>' + req.session.pages.reduce(function(prev, page){
        return prev + '<li><a href="/' + page + '">' + page + '</a></li>';
    }, '') + '<span>' + req.session.count + '</span></html>';
    res.end(data);
});

app.listen(process.env.PORT || 1234);
