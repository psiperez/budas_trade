<?php session_start();
$email = $_SESSION['email'];
$senha = $_SESSION['senha'];
$cpf_usuario3 = $_SESSION['cpf_usuario3'];
$nome_usuario2 =  $_SESSION['nome_usuario2'];

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

/*_______________1a verifica��o (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_usuario WHERE `EMAIL_USUARIO4` = :email AND `SENHA_USUARIO5` = :senha" );
$logar_seguro ->bindValue (':email',$email);
$logar_seguro ->bindValue (':senha',$senha);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

/*_______________if_______________________________*/

if ($contagem==0) {echo'<p align="center"><a href="../login2a_usuario.php">Para continuar, voce deve fazer o login</a></p>';}
else {include("menu_usuario.html");}
?>

<!-- -----------boas vindas-------------- -->
<div style="position: absolute; left: 80px; top: 60px;">

<p>Seja bem-vindo(a),
<?php
echo htmlspecialchars($nome_usuario2, ENT_QUOTES, 'UTF-8').'<br>';
echo 'CPF : '.htmlspecialchars($cpf_usuario3, ENT_QUOTES, 'UTF-8').'<br>';

?>
</div>

<!-- -----------imagem-------------- -->
<div style="position: absolute; left: 20px; top: 80px;">
<?php
include("../imagem/".$cpf_usuario3.".php");
?>
</div>

<!-- -----------tabela com registros-------------- -->

<?php
$registros = $conexao ->prepare ("SELECT atendimentos_diario.ID_ATENDIMENTOS,atendimentos_diario.DATA_HORA,atendimentos_diario.TEXTO,atendimentos_diario.EMAIL from atendimentos_diario inner join cadastro_usuario ON atendimentos_diario.EMAIL LIKE cadastro_usuario.EMAIL_USUARIO4 AND atendimentos_diario.EMAIL like :email order by atendimentos_diario.ID_ATENDIMENTOS desc");
$registros ->bindValue (':email',$email);
$registros ->execute();

echo '<div style="position:absolute; left:20px; top:650px">';
echo "<table align = 'center' border = '3'>";
echo "<tr><td>ID</td><td>DATA</td><td>TEXTO</td></tr>";
while ($linhas = $registros-> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$id_atendimentos = $linhas ['ID_ATENDIMENTOS'];
				$data_hora = $linhas ['DATA_HORA'];
				$texto = $linhas ['TEXTO'];
				$texto_esc = htmlspecialchars($texto, ENT_QUOTES, 'UTF-8');

				echo "<tr>
                <td>".htmlspecialchars($id_atendimentos, ENT_QUOTES, 'UTF-8')."</td>
                <td>".htmlspecialchars($data_hora, ENT_QUOTES, 'UTF-8')."</td>
                <td>$texto_esc</td>
				</tr>";
				};
?>

<br>

</body></html>