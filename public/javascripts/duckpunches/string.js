// Prototype methods for Javascripts String object.


// http://snipplr.com/view/699/stringrepeat/
String.prototype.repeat = function( num ) {
  for( var i = 0, buf = ""; i < num; i++ ) buf += this;
  return buf;
}

// http://snipplr.com/view/709/stringcenter-rjust-ljust/
String.prototype.rjust = function( width, padding ) {
  padding = padding || " ";
  padding = padding.substr( 0, 1 );
  if( this.length < width )
    return padding.repeat( width - this.length ) + this;
  else
    return this;
}
