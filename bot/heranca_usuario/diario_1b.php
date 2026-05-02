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

</head><body>
<br>

<?php
include ("../protecao3.php");
include("menu_usuario.html") ;
/*_____________________________obter data do sistema ___*/
$data_sistema = date('Y-m-d');
$data_sistema2 = date("d/m/Y",strtotime($data_sistema));

/*_____________________________obter dados enviados ___*/
$diario = utf8_decode($_POST['diario']);

/*_______________1a verifica巽達o (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_usuario WHERE `EMAIL_USUARIO4` = :email AND `SENHA_USUARIO5` = :senha");
$logar_seguro ->bindValue (':email',$email);
$logar_seguro ->bindValue (':senha',$senha);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();


/*_______________if___________window.location = "diario.php";____________________*/

if (strlen ($senha)<1) {echo'<p align="center">Digite a sua senha<br><a href="javascript:history.back(1);">Tente novamente</a></p>';}

elseif ($contagem == 0) {echo'<p align="center"><a href="javascript:history.back(1);">Este profissional ainda nao foi cadastrado</a></p>';}


else {

$inserir = $conexao->prepare ("INSERT INTO atendimentos_diario (DATA_HORA, CPF, EMAIL,TEXTO) VALUES (:data_sistema,:cpf,:email,:texto)");

$inserir->bindValue(':data_sistema', $data_sistema2);
$inserir->bindValue(':cpf', $cpf_usuario3);
$inserir->bindValue(':email', $email);
$inserir->bindValue(':texto', $diario);


$inserir->execute();


}

?>
<script>
window.location = "passa_var.php";
</script>