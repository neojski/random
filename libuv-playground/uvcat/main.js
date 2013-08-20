#!/usr/bin/env node
// translation of main.c into node.js
var fs = require('fs');
var argv = process.argv.slice(1);
if (process.argc < 2) return 1;

var fd;
var buffer = new Buffer(1);

fs.open(argv[1], 'r', on_open);

function on_open(err, _fd) {
  if (err) {
    console.log('error', err);
    return;
  }
  fd = _fd;
  do_read();
}

function do_read() {
  fs.read(fd, buffer, 0, buffer.length, null, on_read);
}

function on_read(err, bytesRead, buffer) {
  if (err) {
    return console.log(err);
  }
  if (bytesRead === 0) {
    fs.close(fd);
  } else {
    fs.write(1, buffer, 0, bytesRead, null, on_write);
  }
}

function on_write(err, written, buffer) {
  if (err) {
    return console.log(err);
  }
  do_read();
}
