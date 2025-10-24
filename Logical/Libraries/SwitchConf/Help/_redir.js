function GotoNewLocation() {
 if( newLocation != "" ) {
  window.location.replace( newLocation );
 }
}
var newLocation = "";
if(window.location.hash != "") {
 var exp = /^#(.*)@([0-9]+)$/i;
 exp.exec(window.location.hash);
 if( RegExp.$1 != "" && RegExp.$2 != "" ) {
  newLocation = RegExp.$1 + "#Nav=" + RegExp.$2;
 }
}
if( newLocation == "" ) {
 document.write( "<h1>Redirect - ERROR</h1>" );
 document.write( "<p>Umleitung NICHT möglich, da keine Parameter angegeben wurden!</p>" );
 document.write( "<p>Redirect not possible, because there are no parameters!</p>" );
}
window.setTimeout("GotoNewLocation()",10);