<?php
session_start();
ob_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>


  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>login1b</title>


</head><body oncontextmenu="returnfalse" onselectstart="return false" ondragstart="return false">
<p>
<?php
//header("Content-Type: text/html; charset=ISO-8859-1", true);
include ("protecao3.php");



$email = $_POST['email'];
$senha = $_POST['senha'];

$_SESSION['email'] = $email;
$_SESSION['senha'] = $senha;
echo $_SESSION['email'].''.$_SESSION['senha'];


/*_______________1a verificação (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_usuario WHERE `EMAIL_USUARIO4` = :email AND `SENHA_USUARIO5` = :senha");
$logar_seguro ->bindValue (':email',$email);
$logar_seguro ->bindValue (':senha',$senha);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

/*_______________if_______________________________*/

if (strlen ($senha)<1) {echo'<p align="center">Digite a sua senha<br><a href="javascript:history.back(1);">Tente novamente</a></p>';}

elseif ($contagem == 0) {echo'<p align="center"><a href="javascript:history.back(1);">Este usu&aacute;rio ainda n&atilde;o foi cadastrado</a></p>';}

else {
    while ($linhas = $logar_seguro -> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$id_usuario_1 = $linhas ['ID_USUARIO_1'];
				$data_cadastro_usuario1 = $linhas ['DATA_CADASTRO_USUARIO1'];
				$nome_usuario2 = $linhas ['NOME_USUARIO2'];
				$cpf_usuario3 = $linhas ['CPF_USUARIO3'];
				$email_usuario4 = $linhas ['EMAIL_USUARIO4'];
				$senha_usuario5 = $linhas ['SENHA_USUARIO5'];
				$telefone_usuario6 = $linhas ['TELEFONE_USUARIO6'];

        //$emissario = $linhas ['EMISSARIO'];
        $_SESSION['cpf_usuario3'] = $cpf_usuario3;
        $_SESSION['nome_usuario2'] = $nome_usuario2;



                }
    header("location:heranca_usuario/index_negociador.php");
    exit;
    }




//elseif ($contagem == 0) {echo'<p align="center"><a href="javascript:history.back(1);">Este profissional ainda não foi cadastrado</a></p>';}
//else {header("location:heranca_usuario/index_negociador.php");}
//Pode ser usado um Javascrip para substituiro header ---- else {echo "<script>location.href='index_negociador.php';</script>"; }


/*

else {
$verifica_emissario = $conexao->prepare ("SELECT * FROM cadastro_usuario cadastro_usuario.CPF_USUARIO3 LIKE '$cpf'
AND cadastro_usuario.EMAIL_USUARIO4 LIKE '$email' ");
$verifica_emissario ->execute();

//echo '<div style="position:absolute; left:0px; top:50px">';
//echo "<table align = 'center' border = '3'>";
//echo "<tr><td>ID</td><td>DATA</td><td>NOME</td><td>CPF</td><td>EMAIL</td><td>SENHA</td><td>TELEFONE</td><td>EMISSARIO</td></tr>";

while ($linhas = $verifica_emissario -> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$id_usuario_1 = $linhas ['ID_USUARIO_1'];
				$data_cadastro_usuario1 = $linhas ['DATA_CADASTRO_USUARIO1'];
				$nome_usuario2 = $linhas ['NOME_USUARIO2'];
				$cpf_usuario3 = $linhas ['CPF_USUARIO3'];
				$email_usuario4 = $linhas ['EMAIL_USUARIO4'];
				$senha_usuario5 = $linhas ['SENHA_USUARIO5'];
				$telefone_usuario6 = $linhas ['TELEFONE_USUARIO6'];

        //$emissario = $linhas ['EMISSARIO'];
        $_SESSION['cpf_usuario3'] = $cpf_usuario3;



        echo "<tr>
        <td>$id_usuario_1</td>
        <td>$data_cadastro_usuario1</td>
        <td>$nome_usuario2</td>
        <td>$cpf_usuario3</td>
        <td>$email_usuario4</td>
        <td>$senha_usuario5</td>
        <td>$telefone_usuario6</td>
        <td>$emissario</td>
				</tr>";


				}
	header("location:heranca_usuario/index_negociador.php");}


*/



?></p>

</body></html>