// # Config
var port = process.env.PORT;
// # Custom
var renderer = require( './libs/rossc1-ctx-renderer' );
// # Core
var util = require( 'util' );
// # Express
var express = require( 'express' );
var jadeMiddleware = require( './libs/jade-middleware' );
var lessMiddleware = require( 'less-middleware' );
var routeCache = require( 'route-cache' );
// ## Server
var app = express();
app.use( app.router );
app.use( jadeMiddleware({
	src : './public',
	jadeOptions : {
		pretty: true
	}
}));
app.use( lessMiddleware( {
	debug : false,
	src : './public',
}) );
app.use( express.static( './public' ) );
app.use( express.directory( './public' ) );
// # Canvas
var Canvas = require( 'canvas' );

// Error
app.use(function(err, req, res, next) {
	console.log( util.inspect( err, { showHidden: false, depth: null, colors: true } ) );
    //do logging and user-friendly error message display
    res.send(500, { status:500, message: 'internal error', type:'internal', error:err });
});

app.get( '/day/:day.png', routeCache.cacheSeconds( 60 * 60 * 60 * 60  ), function ( req, res ) {
    var canvas = new Canvas( 73, 73 ); 	
    var ctx = canvas.getContext( '2d' );
    renderer( ctx, { 
	day: req.params.day
    });
    res.set( 'Content-Type', 'image/png' ); 
    // canvas.createPNGStream().pipe( res );
    
    canvas.toBuffer( function( err, buf ) {
         res.send( buf );
    });
});

// ## Server
app.listen( port );
console.log( 'App listening on port %d', port );


// @todo:
// * add jade middleware
// * add less middleware
// * add leafletjs
// * add create main.js
// * add jade file for exmaple
