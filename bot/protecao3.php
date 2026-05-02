<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head>

  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>protecao3</title>



  <!--
<link rel="stylesheet" href="menu_saipm2.css" type="text/css">
<style type="text/css">._css3m{display:none}</style>
-->

  <!-- End css3menu.com HEAD section -->
</head><body><br>

<?php /*_______________conecta_pdo com banco de dados_________________________*/
include ("conecta_pdo.php");

/*_______________protecao.php ADDSLASHES (DEPRECATED - use Prepared Statements) _________________________*/
// foreach ($_POST as $indice =>$value) {$_POST[$indice] = addslashes($_POST[$indice]);}

/*_______________protecao2.php EVITAR STRING____________________
$phpself = $_SERVER['PHP_SELF'];
if(!empty($_SERVER['QUERY_STRING'])) {
$IncEvil = $phpself .= "?" . $_SERVER['QUERY_STRING'];
}
if(preg_match("/http|cmd|www|ftp|.dat|.txt|.gif|wget|from|select|update|insert|
delete|where|drop table|show tables|#|\*|--|\\\\/", $IncEvil)) {
echo "<font face=verdana color=ff0000><b>$IncEvil</b> <br>Esta pagina
invalida!<br>";
echo "Voce sera redirecionado para a pagina principal.</font>";
echo "<meta http-equiv=\"refresh\" content=\"3; URL=index_saipm.php\">";
exit;
}
_____*/


?>

</body></html>