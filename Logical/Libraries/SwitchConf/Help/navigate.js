/*
--------------------------------------------------------------------------------
 Versions-Information:
--------------------------------------------------------------------------------
  $HeadURL:$
  $LastChangedDate:$
  $LastChangedRevision:$
-------------------------------------------------------------------------------- 
*/

function CheckPar() {
 if(window.location.hash != "") {
  var exp = /#nav=([0-9]*)/i;
  exp.exec(window.location.hash);
  var ShowId = RegExp.$1
  if(ShowId != "") {
   ShowNav("NavBottom_" + ShowId);
   ShowNav("NavList_"   + ShowId);
  }
  if( ShowId != "" ) {
   var xLocation = window.location.href;
   xLocation = xLocation.replace(/#nav=[0-9]+/i,"");
   if( xLocation.search(/#/) > 0 ) {
    var xAnchor = xLocation.replace(/^.*(#.*)/,"$1");
    window.location.href = xAnchor;
   }
  }
 } else {
  ShowID = GetShowID();
  if( ShowId > -1 ) {
   ShowNav("NavBottom_" + ShowId);
   ShowNav("NavList_"   + ShowId);
  }
 }
}

function ShowNav( id ) {
 var element = document.getElementById(id);
 if( element != null ) {
  element.style.display = "";
 }
}

function GetShowID() {
 var div_id, id_match, i, m;
 var div_tags = document.all.tags("div");
 for( i = 0; i < div_tags.length; i++ ) {
  div_id = div_tags[i].id;
  id_match = div_id.match( /^(NavBottom_|NavList_)([0-9]+)$/ );
  if( id_match ) {
   for( m = 0; m < id_match.length; m++ ) {
    return id_match[m].replace( /(NavBottom_|NavList_)/, "");
   }
  }
 }
 return -1;
}

CheckPar();