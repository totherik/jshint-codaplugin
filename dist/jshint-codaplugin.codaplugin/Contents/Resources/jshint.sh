#!/usr/bin/env node


var JSHINT = require('./jshint.js').JSHINT,
	fs = require('fs');

function readSTDIN(callback) {
	var stdin = process.stdin,
		body = [];

	stdin.resume();
	stdin.setEncoding('utf8');

	stdin.on('data', function(chunk) {
		body.push(chunk);
	});

	stdin.on('end', function(chunk) {
		callback(body.join('\n'));
	});
}


readSTDIN(function(body) {
    var ok = JSHINT(body),
		i = null,
		error = null,
		errorType = null,
		nextError = null,
		errorCount = null,
		WARN = 'WARNING',
		ERROR = 'ERROR';

    if (!ok) {
        errorCount = JSHINT.errors.length;
        for (i = 0; i < errorCount; i += 1) {
            error = JSHINT.errors[i];
            errorType = WARN;
            nextError = i < errorCount ? JSHINT.errors[i+1] : null;
            if (error && error.reason && error.reason.match(/^Stopping/) === null) {
                // If jslint stops next, this was an actual error
                if (nextError && nextError.reason && nextError.reason.match(/^Stopping/) !== null) {
                    errorType = ERROR;
                }
                console.log([error.line, error.character, errorType, error.reason].join(":"));
            }
        }
    }
	process.exit(0);
});