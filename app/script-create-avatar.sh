#!/usr/bin/env node

// # Modules
var OAuth = require( 'oauth' );
var https = require( 'https' );
var renderer = require( './libs/rossc1-ctx-renderer' );
var Canvas = require( 'canvas' );
var fs = require('fs');
var util = require('util');
// All the options `save` to save all the images to a disk 
var optimist = require('optimist')
    .usage( 'Usage: $0' )
    .alias( 'm', 'make-all' )
    .alias( 'd', 'dir' )
    .alias( 'u', 'upload' ) 
    .alias( 'w', 'write' )
    .alias( 'k', 'consumer-key' ) 
    .alias( 's', 'consumer-secret' ) 
    .alias( 'a', 'access-token' ) 
    .alias( 't', 'access-token-secret' ) 
    .describe( 'u', 'Upload the image to twitter' )
    .describe( 'w', 'Write the image to avatar.png' )
    .describe( 'm', 'Make all (365 days) images to a dir' )
    .describe( 'd', 'Folder for making all images to' );
var argv = optimist.argv; 
if ( !argv.w && !argv.u && !argv.a ) {
    optimist.showHelp();
    return;
}
if ( argv.u && !( argv.k && argv.s && argv.a && argv.t ) ) {
    console.error( "Error: Twitter oauth details missing!\n" );
    optimist.showHelp();
    return;
}

// # Main

// Create them all if nessicary

if ( argv.m ) {
    for ( var i=1; i <= 365; i++ ) {
        // Create the canvas
        var canvas = new Canvas( 73, 73 );  
        var ctx = canvas.getContext( '2d' );
        renderer( ctx, {  day : i, width : 73, height : 73 } );
        saveCanvasToDisk( canvas, ''+i );
    }
}

// Create the canvas
var canvas = new Canvas( 48, 48 );  
var ctx = canvas.getContext( '2d' );

// Style it based on the day
var day = getCurrentDay();
renderer( ctx, {  day : day, width : 48, height : 48 } );

if ( argv.write ) {
    saveCanvasToDisk( canvas, 'avatar' );
}
if ( argv.upload ) {

    canvas.toBuffer( function( err, buf ) {

        if ( err ) {
            console.error( 'Failed to get buffer from canavs', err );
            return;
        }

        var oauth = new OAuth.OAuth(
            'https://api.twitter.com/oauth/request_token',
            'https://api.twitter.com/oauth/access_token',
            argv.k, argv.s,
            '1.0', null, 'HMAC-SHA1');

        var crlf = "\r\n";
        var boundary = '---------------------------10102754414578508781458777923';

        var separator = '--' + boundary;
        var footer = crlf + separator + '--' + crlf;

        var contents = separator + crlf
            + 'Content-Disposition: file; name="image";' +  crlf
            + 'Content-Type: image/png' +  crlf
            + crlf;

        var multipartBody = Buffer.concat( [ new Buffer(contents), buf, new Buffer(footer) ] );

        var hostname = 'api.twitter.com';
        var authorization = oauth.authHeader(
            'https://api.twitter.com/1.1/account/update_profile_image.json',
            argv.a, argv.t, 'POST');

        var headers = {
            'Authorization': authorization,
            'Content-Type': 'multipart/form-data; boundary=' + boundary,
            'Host': hostname,
            'Content-Length': multipartBody.length,
            'Connection': 'Keep-Alive'
        };

        var options = {
            host: hostname,
            port: 443,
            path: '/1.1/account/update_profile_image.json',
            method: 'POST',
            headers: headers
        };

        var request = https.request(options);     
        request.write(multipartBody);
        request.end();

        request.on('error', function (err) {
            console.log('Error: Something is wrong.\n'+JSON.stringify(err)+'\n');
        });

        request.on('response', function (response) {            
            response.setEncoding('utf8');            
            response.on('data', function (chunk) {
                console.log(chunk.toString());
            });
            response.on('end', function () {
                console.log(response.statusCode +'\n');
            });
        });    
    });
}

// # Utils
function getCurrentDay() {
    var now = new Date();
    var start = new Date(now.getFullYear(), 0, 0);
    var diff = now - start;
    var oneDay = 1000 * 60 * 60 * 24;
    var day = diff / oneDay;
    return day;
}

function saveCanvasToDisk( canvas, filename ) {
    var out = fs.createWriteStream( (argv.d || __dirname) + '/' + filename + '.png' );
    var stream = canvas.pngStream();
    stream.on( 'data', function ( chunk ) {
        out.write( chunk );
    });
    stream.on( 'end', function () {
        console.log( 'saved %s.png', filename );
    });
}