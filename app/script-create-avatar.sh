#!/usr/bin/env node

// # Modules
var Twit = require( 'twit' );
var renderer = require( './libs/rossc1-ctx-renderer' );
var Canvas = require( 'canvas' );
var fs = require('fs');
var util = require('util');
// All the options `save` to save all the images to a disk 
var optimist = require('optimist')
    .usage( 'Usage: $0' )
    .alias( 'u', 'upload' ) 
    .alias( 'w', 'write' )
    .alias( 'k', 'consumer-key' ) 
    .alias( 's', 'consumer-secret' ) 
    .alias( 'a', 'access-token' ) 
    .alias( 't', 'access-token-secret' ) 
    .describe( 'u', 'Upload the image to twitter' )
    .describe( 'w', 'Write the image to avatar.png' );
var argv = optimist.argv; 
if ( !argv.w && !argv.u ) {
    optimist.showHelp();
    return;
}
if ( argv.u && !( argv.k && argv.s && argv.a && argv.t ) ) {
    console.error( "Error: Twitter oauth details missing!\n" );
    optimist.showHelp();
    return;
}

// # Main

// Create the canvas
var canvas = new Canvas( 73, 73 );  
var ctx = canvas.getContext( '2d' );

// Style it based on the day
var day = getCurrentDay();

renderer( ctx, {  day : day } );

if ( argv.write ) {
    saveCanavsToDisk( canvas, 'avatar' );
}
if ( argv.upload ) {

    // Set the twitter access details
    var twit = new Twit({
        consumer_key :         argv.k,
        consumer_secret :      argv.s,
        access_token :         argv.a,
        access_token_secret :  argv.t
    });

    // Convert the canvas into base64 image
    canvas.toBuffer( function( err, buf ) {

        if ( err ) {
            console.error( 'Failed to get buffer from canavs', err );
            return;
        }

        twit.post( 'account/update_profile_image', {
            image : buf.toString('base64')
        }, function (err, reply) { 
            if ( err ) {
                console.error( 'Failed to post image' );
                console.log( util.inspect( err, { showHidden: false, depth: null, colors: true } ) );
                console.log( util.inspect( reply, { showHidden: false, depth: null, colors: true } ) );
                return;
            }
            console.log( 'updated image' );
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

function saveCanavsToDisk( canvas, filename ) {
    var out = fs.createWriteStream( __dirname + '/' + filename + '.png' );
    var stream = canvas.pngStream();
    stream.on( 'data', function ( chunk ) {
        out.write( chunk );
    });
    stream.on( 'end', function () {
        console.log( 'saved %s.png', filename );
    });
}