<!--
// 30.Oct.2003 ruv

// 12.Nov.2003
//  GetElementById, expand   из HTMLTree by rsdn.ru

function allGetElementById(id)
{
    return document.all[id];
}
function evalGetElementById(id)
{
    eval("var e=self."+id+";");
    return e;
}
function execGetElementById(id)
{
    window.execScript("var e=self."+id+";","JavaScript")
    return e;
}
function nullGetElementById(id)
{
    return null;
}
if (document.getElementById){;}
else if(document.all)
{   document.getElementById=allGetElementById;}
else if(eval && self)
{document.getElementById=evalGetElementById;}
else if(window.execScript && self)
{document.getElementById=execGetElementById;}
else
{document.getElementById=nullGetElementById;}


function expand(node){
    var ul=document.getElementById(node);
    img=document.getElementById("img"+node);
    if( ul!=null && ul.className!=null && ul.innerHTML!=null  )
    {
        if(ul.className=="Shown"){
            ul.className="Hidden";
            img.src="/images/plus.gif";
        }else if(ul.className=="Hidden"){
            ul.className="Shown";
            img.src="/images/minus.gif";
        }
    }
    return true;
}

function el_node(el){
  return( el.id.substring(0, el.id.length-2) )
}
function each_menu(f) {  // f( menu_el )
  tempColl = document.all.tags("DIV");
  for (i=0; i<tempColl.length; i++)
   if (tempColl(i).className== "menu_div") {
     // alert( tempColl(i).id )
     f( tempColl(i) )
   }
}
function qshow_state_el( el ) { // показать, если оно текущее
  // alert( el.innerHTML )
  if( el.innerHTML.indexOf(search_key, 0) != -1 ) expand( el_node(el) )
}
search_key= location.pathname

function init_menu() { 
   slash="/"
   if( search_key.length > 3 ){ // если путь не тривиальный 
     i = search_key.indexOf(slash, 2)
     if( i != -1)  search_key = search_key.substring(i, search_key.length)
     each_menu( qshow_state_el )
   }
 // alert( search_key)
}

onload = init_menu

//-->
