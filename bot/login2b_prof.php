<?php session_start();

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


/*_______________1a verifica巽達o (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_prof WHERE EMAIL_PROF4 = :email AND SENHA_PROF5 = :senha");
$logar_seguro ->bindValue (':email',$email);
$logar_seguro ->bindValue (':senha',$senha);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

/*_______________if_______________________________*/

if (strlen ($senha)<1) {echo'<p align="center">Digite a sua senha<br><a href="javascript:history.back(1);">Tente novamente</a></p>';}
elseif ($contagem == 0) {echo'<p align="center"><a href="javascript:history.back(1);">Este profissional ainda n達o foi cadastrado</a></p>';}
else {
    while ($linhas = $logar_seguro -> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];

				$nome_prof2 = $linhas['NOME_PROF2'];
				$email_prof4 = $linhas['EMAIL_PROF4'];

        //$emissario = $linhas ['EMISSARIO'];
        $_SESSION['NOME_PROF2'] = $nome_prof2;
        $_SESSION['EMAIL_PROF4'] = $email_prof4;



                }
    header("location:heranca_profissional/index_prof.php");
    }
//echo $nome_prof2. " - ".$email_prof4;


//elseif ($contagem == 0) {echo'<p align="center"><a href="javascript:history.back(1);">Este profissional ainda n達o foi cadastrado</a></p>';}
//else {header("location:heranca_usuario/index_negociador.php");}
//Pode ser usado um Javascrip para substituiro header ---- else {echo "<script>location.href='index_negociador.php';</script>"; }


/*_______________VERIFICAR EMISSARIO_______________________________*/



?></p>

</body></html>