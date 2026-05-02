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



</head>
<body>
  <?php
session_destroy();
include("./menu_apresentacao.html");?>
<div style="position: absolute; left: 10px; top: 64px;">


<form class="form-signin" action="cadastra_usuario_1b.php" method="post">
      <h1 class="h3 mb-3 font-weight-normal">New Users Register</h1><br>


<div class="mb-3">
    <label for="inputData" class="form-label">Register date</label>
      <div class="input-group date" data-date-format="dd/mm/yyyy">
          <input  type="text" name= "data_cadastro_usuario1" class="form-control" placeholder="dd/mm/yyyy" required>
            <div class="input-group-addon" >
                <span class="glyphicon glyphicon-th"></span>
            </div>
      </div><br>
</div>

<div class="mb-3">
  <label for="formGroupExampleInput2" class="form-label">User name</label>
  <input type="text" name= "nome_usuario2" class="form-control" id="formGroupExampleInput2" placeholder="Name Complete" required autofocu><br>
</div>

<div class="mb-3">
  <label for="formGroupExampleInput2" class="form-label">Id number (For Brazilians, please input CPF number)</label>
  <input type="text" name= "cpf_usuario3" class="form-control" id="formGroupExampleInput2" placeholder="Only algarism. Ex : 99999999999" required autofocu><br>
</div>

<div class="mb-3">
  <label for="inputEmail" class="form-label">User email</label>
      <input type="email" name= "email_usuario4" id="inputEmail" class="form-control" placeholder="email address" required autofocus><br>

</div>

<div class="mb-3">
  <label for="inputPassword" class="form-label">User password</label>
      <input type="password" name= "senha_usuario5" id="inputPassword" class="form-control" placeholder="Password to access the application" required autofocu><br>

</div>

<div class="mb-3">
  <label for="formGroupExampleInput2" class="form-label">User telephone</label>
  <input type="text" name= "telefone_usuario6" class="form-control" id="formGroupExampleInput2" placeholder="Only algarism with code area and country. Example: 011123456789" required autofocu><br>
</div>





      <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      <p class="mt-5 mb-3 text-muted"></p>
    </form>


<br>
</div>
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <!-- Plugin pro Datapicker novo -->
    <script src='https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.6.1/js/bootstrap-datepicker.min.js'></script>
    <script>
     $('.input-group.date').datepicker({format: "dd/mm/yyyy"});
    </script>
</body>
</html>