<?php
session_start();
$nome_prof2 = $_SESSION['NOME_PROF2'];
$email_prof4 = $_SESSION['EMAIL_PROF4'];

?>

 <!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>index</title>

    <!-- Bootstrap Core CSS -->
    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
    body {
        padding-top: 70px;
        /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
    }
    </style>



</head>
<body>
<?php
include ("../protecao3.php");
//echo $email_prof4;


/*_______________1a verifica��o (logar_seguro)______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_prof WHERE EMAIL_PROF4 = :email");
$logar_seguro ->bindValue (':email',$email_prof4);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

if ($contagem==0) {echo'<p align="center"><a href="login2a.php">Para continuar, voce deve fazer o login</a></p>';}
else {include("./menu_apresentacao_prof.html");}


?>




<div style="position: absolute; left: 30px; top: 60px;"><p>Seja bem-vindo(a), Psic.  <?php echo htmlspecialchars($nome_prof2);?></p></div>

<div style="position: absolute; left: 130px; top: 100px;">


<form class="form-signin" action="ce_1b.php" method="post">
      <h1 class="h3 mb-3 font-weight-normal">Consulta de Usuários</h1>

      <label for="inputEmail" class="sr-only"> CPF do Usuário</label>
      <input type="text" name= "cpf_usuario3_consulta" id="inputCpf" class="form-control" placeholder="cpf do usuário" required autofocus>

      <button class="btn btn-lg btn-primary btn-block" type="submit">Consulta</button>
      <p class="mt-5 mb-3 text-muted"></p>
</form>




</div>

<div style="position: absolute; left: 10px; top: 250px;">


<?php


$verifica_prof = $conexao->prepare ("SELECT cadastro_usuario.NOME_USUARIO2,cadastro_usuario.CPF_USUARIO3, cadastro_usuario.EMAIL_USUARIO4,cadastro_prof.NOME_PROF2 FROM cadastro_usuario INNER JOIN cadastro_prof ON cadastro_prof.EMAIL_PROF4 = cadastro_usuario.PROF_USUARIO7 AND cadastro_prof.EMAIL_PROF4 = :email ");

$verifica_prof ->bindValue(':email', $email_prof4);
$verifica_prof ->execute();

echo '<div style="position:absolute; left:0px; top:50px">';
echo "<table align = 'center' border = '3' width='190%'>";
echo "<tr><td>NOME DO USUARIO</td><td>CPF DO USUARIO</td></tr>";

while ($linhas = $verifica_prof -> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$nome_usuario2 = utf8_encode($linhas ['NOME_USUARIO2']);
				$_SESSION['NOME_USUARIO2'] = $nome_usuario2;

				$cpf_usuario3 = utf8_encode($linhas ['CPF_USUARIO3']);
				$_SESSION['CPF_USUARIO3'] = $cpf_usuario3;

				$email_usuario4 = $linhas ['EMAIL_USUARIO4'];
				$_SESSION['EMAIL_USUARIO4'] = $email_usuario4;

				$nome_prof2 = $linhas ['NOME_PROF2'];


        echo "<tr>
        <td>".htmlspecialchars($nome_usuario2)."</td>
        <td>".htmlspecialchars($cpf_usuario3)."</td>

				</tr>";
		//<td>$email_usuario4</td>

				}

?>

</p>




</div>





<br>

</body></html>