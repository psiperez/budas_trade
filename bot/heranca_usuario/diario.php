<?php session_start();
$email = $_SESSION['email'];
$senha = $_SESSION['senha'];
$cpf_usuario3 = $_SESSION['cpf_usuario3'];
?>


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
    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
    body {
        padding-top: 70px;
        /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
    }
    </style>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head><body>
<br>

<?php
include ("../protecao3.php");
include("menu_usuario.html") ?>
<div style="position: absolute; left: 10px; top: 54px;">

<form class="form-signin" action="diario_1b.php" method="post">
      <h1 class="h3 mb-3 font-weight-normal">Registro Diário de Pensamentos e Sentimentos</h1>


      <label for="exampleFormControlTextarea1" class="form-label">Escreva seus pensamentos e sentimentos, conforme orientações do profissional. Esse registro é muito importante e poderá ser útil nos atendimentos posteriores</label>
  <textarea class="form-control" name= "diario" id="exampleFormControlTextarea1" rows="10" required autofocus></textarea>


      <button class="btn btn-lg btn-primary btn-block" type="submit">Registrar</button>
      <p class="mt-5 mb-3 text-muted"></p>
</form>
</div>


<br>




</div>

</body></html>