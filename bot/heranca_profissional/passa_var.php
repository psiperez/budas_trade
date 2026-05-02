<?php
session_start();
$email_usuario4 = $_SESSION['EMAIL_USUARIO4'];
$cpf_usuario3 = $_SESSION['cpf_usuario3'];
$nome_usuario2 =  $_SESSION['nome_usuario2'];
$cpf_usuario3_consulta = $_SESSION['cpf_usuario3_consulta'];

//echo $emissario. "-" . $email;

$para1 = $email_usuario4;
$para2 = $cpf_usuario3_consulta;

echo $para1. "-" . $para2;

#$localidade = $emissario.'.html';
#$localidade = $emissario.'.php';

# na pasta usuario, a localidade é index_negociador.php;
$localidade = 'ce_1b.php';

//$localidade = 'recebe_var4.html';
#$localidade = $emissario.'.png';
#$localidade = 'modelo_grafico_simples2.html';

//ordem para execução
//$r = "/bin/python3  recebe_var.py '$para1' '$para2' ";
//exec($r);


$output = passthru("/opt/alt/python311/bin/python3 recebe_diario.py ".escapeshellarg($para1)." ".escapeshellarg($para2));

header('Location:'.$localidade);
?>