<?php session_start();
$nome_prof2 = $_SESSION['NOME_PROF2'];
$email_prof4 = $_SESSION['EMAIL_PROF4'];
$nome_usuario2 = $_SESSION['NOME_USUARIO2'];
$cpf_usuario3 = $_SESSION['CPF_USUARIO3'];
$email_usuario4 = $_SESSION['EMAIL_USUARIO4'];

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
<p>
<?php
//header("Content-Type: text/html; charset=ISO-8859-1", true);
include ("../protecao3.php");
include("menu_prof.html");

$cpf_usuario3_consulta = $_POST['cpf_usuario3_consulta'];
$_SESSION['CPF_USUARIO3'] = $cpf_usuario3_consulta;

/*
echo $nome_prof2."<br>";
echo $email_prof4."<br>";
echo $nome_usuario2."<br>";
echo $cpf_usuario3."<br>";
echo $email_usuario4."<br>";
echo $cpf_usuario3_consulta."<br>";
*/



/*_______________1a verifica巽達o (logar_seguro)_______________________________*/

$logar_seguro = $conexao->prepare ("SELECT * from cadastro_prof inner join cadastro_usuario on cadastro_usuario.CPF_USUARIO3 = :cpf_usuario3_consulta
AND cadastro_usuario.PROF_USUARIO7 = :email and cadastro_prof.EMAIL_PROF4 = cadastro_usuario.PROF_USUARIO7");
$logar_seguro ->bindValue (':email',$email_prof4);
$logar_seguro ->bindValue (':cpf_usuario3_consulta',$cpf_usuario3_consulta);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();


/*_______________if________________$cpf_usuario3_consulta_______________*/

if ($contagem==0) {echo'<p align="center"><a href="login2a.php">Voce não tem acesso a esse paciente</a></p>';}
else {
    echo "<div style=\"position: absolute; left: 30px; top: 60px;\">";
    echo "<p>Seja bem-vindo(a), Psic. " .$nome_prof2. "</p>";
    echo "<p>O Usuário selecionado foi :" .$cpf_usuario3_consulta."</p>";
    echo "</div>";
    echo "<div style=\"position: absolute; left: 200px; top: 80px;\">";
    $safe_cpf = preg_replace('/[^a-zA-Z0-9]/', '', $cpf_usuario3_consulta);
    $img_file = "../imagem/".$safe_cpf.".php";
    if (file_exists($img_file)) {
        include($img_file);
    } else {
        echo "Imagem não encontrada.";
    }
    echo "<div style=\"position: absolute; left:80px; top: 150px;\">";
    $registros = $conexao ->prepare ("SELECT atendimentos_diario.ID_ATENDIMENTOS,atendimentos_diario.DATA_HORA,atendimentos_diario.TEXTO,atendimentos_diario.EMAIL from atendimentos_diario inner join cadastro_usuario ON atendimentos_diario.EMAIL LIKE cadastro_usuario.EMAIL_USUARIO4 AND atendimentos_diario.CPF like :cpf ");
    $registros ->bindValue (':cpf',$cpf_usuario3_consulta);
    $registros ->execute();

    echo '<div style="position:absolute; left:20px; top:550px">';
    echo "<table align = 'center' border = '3' width='500px'>";
    echo "<tr><td>ID</td><td>DATA</td><td>TEXTO</td></tr>";
    while ($linhas = $registros-> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$id_atendimentos = $linhas ['ID_ATENDIMENTOS'];
				$data_hora = $linhas ['DATA_HORA'];
				$texto = $linhas ['TEXTO'];
				$texto_utf8 = utf8_encode($texto);

				echo "<tr>
                <td>".htmlspecialchars($id_atendimentos)."</td>
                <td>".htmlspecialchars($data_hora)."</td>
                <td>".htmlspecialchars($texto)."</td>
				</tr>";
				};
    // header("location:index_prof.php"); // Removido para evitar erro de headers


}

?>

<!--
<div style="position: absolute; left: 30px; top: 60px;">
<p>Seja bem-vindo(a), Psic. <?php echo $nome_prof2;?></p>
<p>O Usuário selecionado foi :  <?php echo $cpf_usuario3_consulta ;?></p>
</div>
-->

<!--
<div style="position: absolute; left: 200px; top: 80px;">
-->

<?php

#include("../imagem/".$cpf_usuario3_consulta.".php");

?>
<!--
</div>
-->


<!--
<div style="position: absolute; left:80px; top: 150px;">
-->


<?php
/*
$registros = $conexao ->prepare ("SELECT atendimentos_diario.ID_ATENDIMENTOS,atendimentos_diario.DATA_HORA,atendimentos_diario.TEXTO,atendimentos_diario.EMAIL from atendimentos_diario inner join cadastro_usuario ON atendimentos_diario.EMAIL LIKE cadastro_usuario.EMAIL_USUARIO4 AND atendimentos_diario.CPF like :cpf ");
$registros ->bindValue (':cpf',$cpf_usuario3_consulta);
$registros ->execute();

echo '<div style="position:absolute; left:20px; top:550px">';
echo "<table align = 'center' border = '3' width='500px'>";
echo "<tr><td>ID</td><td>DATA</td><td>TEXTO</td></tr>";
while ($linhas = $registros-> fetch(PDO::FETCH_ASSOC))
				{
				//$n = $linhas [''];
				$id_atendimentos = $linhas ['ID_ATENDIMENTOS'];
				$data_hora = $linhas ['DATA_HORA'];
				$texto = $linhas ['TEXTO'];
				$texto_utf8 = utf8_encode($texto);

				echo "<tr>
                <td>$id_atendimentos</td>
                <td>$data_hora</td>
                <td>$texto_utf8</td>
				</tr>";
				};

*/
?>

<!--
</div>
-->


</body></html>