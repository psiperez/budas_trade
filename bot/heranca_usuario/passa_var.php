<?php
session_start();
$email = $_SESSION['email'];
$senha = $_SESSION['senha'];
$cpf_usuario3 = $_SESSION['cpf_usuario3'];
$nome_usuario2 =  $_SESSION['nome_usuario2'];

//echo $emissario. "-" . $email;

$para1 = $email;
$para2 = $cpf_usuario3;

echo $para1. "-" . $para2;

#$localidade = $emissario.'.html';
#$localidade = $emissario.'.php';
$localidade = 'index_negociador.php';
//$localidade = 'recebe_var4.html';
#$localidade = $emissario.'.png';
#$localidade = 'modelo_grafico_simples2.html';

//ordem para execução
//$r = "/bin/python3  recebe_var.py '$para1' '$para2' ";
//exec($r);

// $r = "/opt/alt/python311/bin/python3  atividade_fisica_consulta_grafico.py '$cpf_bfp'  ";
//exec($r);

//$output = passthru("/bin/python3 recebe_diario.py ".escapeshellarg($para1)." ".escapeshellarg($para2));

$output = passthru("/opt/alt/python311/bin/python3 recebe_diario.py ".escapeshellarg($para1)." ".escapeshellarg($para2));

header('Location:'.$localidade);
?>