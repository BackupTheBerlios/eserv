<!--
isExpanded = false;

function getIndex(el) {
    ind = null;
    for (i=0; i<document.layers.length; i++) {
        whichEl = document.layers[i];
        if (whichEl.id == el) {
            ind = i;
            break;
        }
    }
    return ind;
}

function arrange() {
    nextY = document.layers[firstInd].pageY + document.layers[firstInd].document.height;
    for (i=firstInd+1; i<document.layers.length; i++) {
        whichEl = document.layers[i];
        if (whichEl.visibility != "hide") {
            whichEl.pageY = nextY;
            nextY += whichEl.document.height;
        }
    }
}

function existEl(el){
    if (NS4) {
        for (i=0; i<document.layers.length; i++) {
            whichEl = document.layers[i];
            if (whichEl.id.indexOf(el) == 0) return true ;
        }
        return false;
    }
    else {
        tempColl = document.all.tags("DIV");
        for (i=0; i<tempColl.length; i++) {
            if (tempColl(i).id.indexOf(el) == 0) return -1 ;
            // alert( tempColl(i).link[0].href );
        }
        return 0;
    }
}

function AsPluginName(s) {
 s1 = ""
 for(i=0; i<s.length; i++){ 
   if( s.charAt(i) == '/' || s.charAt(i) == '-' ){
   s1=s1+'_' }  else {  s1=s1+s.charAt(i) }
 }
 return s1
}
function expand_curr_menu(){
 s_key = "conf/"
 s_key_l1 = "/ru"
 s_key_l2 = "/en"
 //s =location.href
 s=location.pathname 
 i0 = s.indexOf(s_key)
 if(i0 == -1) return
 i0=i0+s_key.length
 i1 = s.indexOf(s_key_l1)
 if( i1 == -1) i1 = s.indexOf(s_key_l2)
 if( i1 == -1) i1 = s.length
 s = s.substring(i0, i1)
 if ( s.length < 3 ) s='conf_'
 s = AsPluginName( s )
// window.alert("menu_item="+s)
 if ( existEl(s) ) expandIt(s)
}

function initIt(){
    if (NS4) {
        for (i=0; i<document.layers.length; i++) {
            whichEl = document.layers[i];
            if (whichEl.id.indexOf("Child") != -1) whichEl.visibility = "hide";
        }
        arrange();
    }
    else {
        tempColl = document.all.tags("DIV");
        for (i=0; i<tempColl.length; i++) {
            if (tempColl(i).className == "child") tempColl(i).style.display = "none";
        }
    }
   expand_curr_menu()
   // alert('http-qqq');
}

function expandIt(el) {
    if (!ver4) return;
    if (IE4) {expandIE(el)} else {expandNS(el)}
}

function expandIE(el) { 
    whichEl = eval(el + "Child");

        // Modified Tobias Ratschiller 01-01-99:
        // event.srcElement obviously only works when clicking directly
        // on the image. Changed that to use the images's ID instead (so
        // you've to provide a valid ID!).

    //whichIm = event.srcElement;
        whichIm = eval(el+"Img");

    if (whichEl.style.display == "none") {
        whichEl.style.display = "block";
        whichIm.src = "/images/minus.gif";      
    }
    else {
        whichEl.style.display = "none";
        whichIm.src = "/images/plus.gif";
    }
    window.event.cancelBubble = true ;
}

function expandNS(el) {
    whichEl = eval("document." + el + "Child");
    whichIm = eval("document." + el + "Parent.document.images['imEx']");
    if (whichEl.visibility == "hide") {
        whichEl.visibility = "show";
        whichIm.src = "/images/minus.gif";
    }
    else {
        whichEl.visibility = "hide";
        whichIm.src = "/images/plus.gif";
    }
    arrange();
}

function showAll() {
    for (i=firstInd; i<document.layers.length; i++) {
        whichEl = document.layers[i];
        whichEl.visibility = "show";
    }
}

function expandAll(isBot) {
    newSrc = (isExpanded) ? "/images/plus.gif" : "/images/minus.gif";

    if (NS4) {
        // TR-02-01-99: Don't need that
        // document.images["imEx"].src = newSrc;
        for (i=firstInd; i<document.layers.length; i++) {
            whichEl = document.layers[i];
            if (whichEl.id.indexOf("Parent") != -1) {
                whichEl.document.images["imEx"].src = newSrc;
            }
            if (whichEl.id.indexOf("Child") != -1) {
                whichEl.visibility = (isExpanded) ? "hide" : "show";
            }
        }

        arrange();
        if (isBot && isExpanded) scrollTo(0,document.layers[firstInd].pageY);
    }
    else {
        divColl = document.all.tags("DIV");
        for (i=0; i<divColl.length; i++) {
            if (divColl(i).className == "child") {
                divColl(i).style.display = (isExpanded) ? "none" : "block";
            }
        }
        imColl = document.images.item("imEx");
        for (i=0; i<imColl.length; i++) {
            imColl(i).src = newSrc;
        }
    }

    isExpanded = !isExpanded;
}

onload = initIt ;
// alert(onload);

//-->
