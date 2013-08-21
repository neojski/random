#!/usr/bin/env node
var fs = require('fs');
var argv = process.argv.slice(1);
if (process.argc < 2) return 1;

fs.createReadStream(argv[1]).pipe(process.stdout);
