<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>


  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>login1b</title>


</head>
<body>
<p>
<?php
ob_start();
header("Content-Type: text/html; charset=utf-8", true);
include ("protecao3.php");




/*_______________1a verifica巽達o (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from `cadastro_usuario` WHERE `EMAIL_USUARIO4` = :email AND `SENHA_USUARIO5` = :senha");
$logar_seguro ->bindValue (':email',$email_usuario4);
$logar_seguro ->bindValue (':senha',$senha_usuario5);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

/*_______________if_______________________________*/

if ($contagem !==0) {echo'<p align="center"><a href="javascript:history.back(1);">Este usuário já foi cadastrado</a></p>';}

else {

$data_cadastro_usuario1 = $_POST['data_cadastro_usuario1'];
$nome_usuario2 = $_POST['nome_usuario2'];
$cpf_usuario3 = $_POST['cpf_usuario3'];
$email_usuario4 = $_POST['email_usuario4'];
$senha_usuario5 = $_POST['senha_usuario5'];
$telefone_usuario6 = $_POST['telefone_usuario6'];

echo htmlspecialchars($data_cadastro_usuario1)."<br>";
echo htmlspecialchars($nome_usuario2)."<br>";
echo htmlspecialchars($cpf_usuario3)."<br>";
echo htmlspecialchars($email_usuario4)."<br>";
echo "Senha configurada.<br>";
echo htmlspecialchars($telefone_usuario6)."<br>";

/*
$inserir = $conexao->prepare ("INSERT INTO `cadastro_usuario` (`DATA_CADASTRO_USUARIO1`,`NOME_USUARIO2`,`CPF_USUARIO3`,`EMAIL_USUARIO4`,`SENHA_USUARIO5`,`TELEFONE_USUARIO6`) VALUES (:data_cadastro_usuario1,:nome_usuario2,:cpf_usuario3',:email_usuario4,:senha_usuario5,:telefone_usuario6)");
 */

$inserir = $conexao->prepare ("INSERT INTO cadastro_usuario (DATA_CADASTRO_USUARIO1,NOME_USUARIO2,CPF_USUARIO3,EMAIL_USUARIO4,SENHA_USUARIO5,TELEFONE_USUARIO6) VALUES (:data_cadastro_usuario1,:nome_usuario2,:cpf_usuario3,:email_usuario4,:senha_usuario5,:telefone_usuario6)");

$inserir->bindValue(':data_cadastro_usuario1', $data_cadastro_usuario1);
$inserir->bindValue(':nome_usuario2', $nome_usuario2);
$inserir->bindValue(':cpf_usuario3', $cpf_usuario3);
$inserir->bindValue(':email_usuario4', $email_usuario4);
$inserir->bindValue(':senha_usuario5', $senha_usuario5);
$inserir->bindValue(':telefone_usuario6', $telefone_usuario6);

$inserir->execute();

header("location:apresentacao.php");
exit;


}


?></p>

</body></html>