   <!--

  document.onmouseover = doDocumentOnMouseOver ;
  document.onmouseout = doDocumentOnMouseOut ;

  function doDocumentOnMouseOver() {
    var eSrc = window.event.srcElement ;
    if (eSrc.className == "item") {
      window.event.srcElement.className = "highlight";
    }
  }

  function doDocumentOnMouseOut() {
    var eSrc = window.event.srcElement ;
    if (eSrc.className == "highlight") {
      window.event.srcElement.className = "item";
    }
  }


var bV=parseInt(navigator.appVersion);
NS4=(document.layers) ? true : false;
IE4=((document.all)&&(bV>=4))?true:false;
ver4 = (NS4 || IE4) ? true : false;

function expandIt(){return}
function expandAll(){return}
//-->
