<!--
// раскрытие текущего 'меню'

function _expand_curr_menu(){
 ss = onload
 window.alert( "okkk:" + ss )

 s_key = "plugins/"
 s = location.href.toLowerCase()
 i0 = s.indexOf(s_key)+s_key.length;
 i1=i0;
 for(i=i0; i<s.length; i++){ if( s.charAt(i) == '/'){ i1=i; break ;}}
 s = s.substring(i0, i1);
 if( s.indexOf ("trafc") != -1 ) { expandIt('trafc'); }

 ss = onload
 window.alert( ss )
}

// onload = onload + " ; expand_curr_menu() " 

// onload = "expand_curr_menu()" 

// ss = onload ; window.alert( ss ) ;

//-->
