<html>
<body>
<h2>Не задан пароль интерфейса управления!</h2>
Вы пытаетесь войти с именем: <b>{PHP_AUTH_USER}</b>
паролем: <b>{PHP_AUTH_PW}</b><p>
Чтобы такой логин заработал, нужно в Eserv3.ini поставить:<br>
<pre>
[HTTP]
AdminUser={PHP_AUTH_USER}
AdminPass={PHP_AUTH_PW MD5}
</pre>

</body>
</html>
