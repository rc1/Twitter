// Works with node-canvas


function rossC1CtxRenderer( ctx, options ) {

    var daysInHueCycle = (typeof options.daysInHueCycle === 'undefined') ? 40 : options.daysInHueCycle;

    var hue = Math.floor( ((options.day-1)/daysInHueCycle) * 360 );
    var hueStep = (typeof options.hueStep === 'undefined') ? 10 : options.hueStep;
    var nextHue = hue + hueStep;

    var width = options.width || 73;
    var height = options.height || 73;
    var gradient = ctx.createLinearGradient(0,0,73,0);

    var startRGB = hsvToRgb( hue/360, 1, 1 );
    var nextRGB = hsvToRgb( nextHue/360, 1, 1 );

    gradient.addColorStop(0, 'rgba('+Math.floor(startRGB[0])+','+Math.floor(startRGB[1])+','+Math.floor(startRGB[2])+',1)');
    gradient.addColorStop(1, 'rgba('+Math.floor(nextRGB[0])+','+Math.floor(nextRGB[1])+','+Math.floor(nextRGB[2])+',1)');

    ctx.fillStyle = gradient;
    ctx.fillRect( 0, 0, 73, 73 );

    stripe( ctx, width, height, 1, 1 );
}

function stripe( ctx, width, height, thickness, step ) {
    ctx.fillStyle = 'rgba(255,255,255,1.0)';
    for ( var x = 0; x < width; x += step + thickness ) {
        ctx.fillRect( x, 0, thickness, height );
    }
    // for ( var y = 0; y < height; y += step + thickness ) {
    //     ctx.fillRect( 0, y, width, thickness );
    // }
}

module.exports = rossC1CtxRenderer;

/**
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
 */
function hslToRgb(h, s, l){
    var r, g, b;

    if(s == 0){
        r = g = b = l; // achromatic
    }else{
        function hue2rgb(p, q, t){
            if(t < 0) t += 1;
            if(t > 1) t -= 1;
            if(t < 1/6) return p + (q - p) * 6 * t;
            if(t < 1/2) return q;
            if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        }

        var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }

    return [r * 255, g * 255, b * 255];
}

/**
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
 */
function hsvToRgb(h, s, v){
    var r, g, b;

    var i = Math.floor(h * 6);
    var f = h * 6 - i;
    var p = v * (1 - s);
    var q = v * (1 - f * s);
    var t = v * (1 - (1 - f) * s);

    switch(i % 6){
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }

    return [r * 255, g * 255, b * 255];
}
