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
        padding-top: 70px;
        /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
    }

    </style>


</head><body>
<br>



<div class="w-100 p-3" id=item>

<?php
include("./menu_apresentacao.html");
include("entrada.php");
unset($_SESSION['email'])
?>
<!--
<p style="position: absolute; left: 0px; top: 124px; font-size:36px;">Acesso :

<a class="btn btn-primary" href="./login2a_usuario.php" role="button">Usuário</a><a class="btn btn-danger" href="./login2a_prof.php" role="button">Profissional</a></p>


-->





</div>


</body></html>