<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>login</title>

    <!-- Bootstrap Core CSS -->
    <link href="./css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
    body {
        padding-top: 0px;
        /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
    }
    </style>



</head><body>
<br>

<?php
session_start();
session_destroy();
include("menu_apresentacao.html");?>
<div style="position: absolute; left: 25%; top: 204px; ">

<form class="form-signin" action="login2b_usuario.php" method="post">
      <h1 class="h3 mb-3 font-weight-normal">Acesso de Usuários</h1>

      <label for="inputEmail" class="sr-only">Email</label>
      <input type="email" name= "email" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>

      <label for="inputPassword" class="sr-only">Password</label>
      <input type="password" name="senha" id="inputPassword" class="form-control" placeholder="Password" required>

      <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      <p class="mt-5 mb-3 text-muted"></p>
    </form>

</div>

</body></html>