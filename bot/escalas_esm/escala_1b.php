<?php
session_start();
$email = $_SESSION['email'];
$senha = $_SESSION['senha'];

//echo $email;
//echo $senha;

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>


  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>login1b</title>


</head>
<body>
<p>
<?php
header("Content-Type: text/html; charset=utf-8", true);
include ("../protecao3.php");

$data_escala = date("d/m/Y");



$logar_seguro = $conexao->prepare ("SELECT * from `cadastro_usuario` WHERE `EMAIL_USUARIO4` = :email AND `SENHA_USUARIO5` = :senha");
$logar_seguro ->bindValue (':email',$email);
$logar_seguro ->bindValue (':senha',$senha);
$logar_seguro ->execute();
$contagem = $logar_seguro ->rowCount();

if ($contagem ==0) {echo'<p align="center"><a href="javascript:history.back(1);">Este usuário não foi cadastrado</a></p>';}

else {


$nome_escala_1 = utf8_decode($_POST['nome_escala_1']);
$cpf_escala_2 = $_POST['cpf_escala_2'];
$ffaa_escala_3 = utf8_decode($_POST['ffaa_escala_3']);
$dn_escala_4 = $_POST['dn_escala_4'];
$sexo_biologico_escala_5 = $_POST['sexo_biologico_escala_5'];
$posto_grad_escala_6 = utf8_decode($_POST['posto_grad_escala_6']);

$phq9_item_1 = $_POST['phq9_item_1'];
$phq9_item_2 = $_POST['phq9_item_2'];
$phq9_item_3 = $_POST['phq9_item_3'];
$phq9_item_4 = $_POST['phq9_item_4'];
$phq9_item_5 = $_POST['phq9_item_5'];
$phq9_item_6 = $_POST['phq9_item_6'];
$phq9_item_7 = $_POST['phq9_item_7'];
$phq9_item_8 = $_POST['phq9_item_8'];
$phq9_item_9 = $_POST['phq9_item_9'];
$phq9_item_10 = $_POST['phq9_item_10'];

$auditc_item_1 = $_POST['auditc_item_1'];
$auditc_item_2 = $_POST['auditc_item_2'];
$auditc_item_3 = $_POST['auditc_item_3'];

$dass21_item_1 = $_POST['dass21_item_1'];
$dass21_item_2 = $_POST['dass21_item_2'];
$dass21_item_3 = $_POST['dass21_item_3'];
$dass21_item_4 = $_POST['dass21_item_4'];
$dass21_item_5 = $_POST['dass21_item_5'];
$dass21_item_6 = $_POST['dass21_item_6'];
$dass21_item_7 = $_POST['dass21_item_7'];
$dass21_item_8 = $_POST['dass21_item_8'];
$dass21_item_9 = $_POST['dass21_item_9'];
$dass21_item_10 = $_POST['dass21_item_10'];
$dass21_item_11 = $_POST['dass21_item_11'];
$dass21_item_12 = $_POST['dass21_item_12'];
$dass21_item_13 = $_POST['dass21_item_13'];
$dass21_item_14 = $_POST['dass21_item_14'];
$dass21_item_15 = $_POST['dass21_item_15'];
$dass21_item_16 = $_POST['dass21_item_16'];
$dass21_item_17 = $_POST['dass21_item_17'];
$dass21_item_18 = $_POST['dass21_item_18'];
$dass21_item_19 = $_POST['dass21_item_19'];
$dass21_item_20 = $_POST['dass21_item_20'];
$dass21_item_21 = $_POST['dass21_item_21'];

$brs_item_1 = $_POST['brs_item_1'];
$brs_item_2 = $_POST['brs_item_2'];
$brs_item_3 = $_POST['brs_item_3'];
$brs_item_4 = $_POST['brs_item_4'];
$brs_item_5 = $_POST['brs_item_5'];
$brs_item_6 = $_POST['brs_item_6'];

$ais_item_1 = $_POST['ais_item_1'];
$ais_item_2 = $_POST['ais_item_2'];
$ais_item_3 = $_POST['ais_item_3'];
$ais_item_4 = $_POST['ais_item_4'];
$ais_item_5 = $_POST['ais_item_5'];
$ais_item_6 = $_POST['ais_item_6'];
$ais_item_7 = $_POST['ais_item_7'];
$ais_item_8 = $_POST['ais_item_8'];

$pcl5_item_1 = $_POST['pcl5_item_1'];
$pcl5_item_2 = $_POST['pcl5_item_2'];
$pcl5_item_3 = $_POST['pcl5_item_3'];
$pcl5_item_4 = $_POST['pcl5_item_4'];
$pcl5_item_5 = $_POST['pcl5_item_5'];
$pcl5_item_6 = $_POST['pcl5_item_6'];
$pcl5_item_7 = $_POST['pcl5_item_7'];
$pcl5_item_8 = $_POST['pcl5_item_8'];
$pcl5_item_9 = $_POST['pcl5_item_9'];
$pcl5_item_10 = $_POST['pcl5_item_10'];
$pcl5_item_11 = $_POST['pcl5_item_11'];
$pcl5_item_12 = $_POST['pcl5_item_12'];
$pcl5_item_13 = $_POST['pcl5_item_13'];
$pcl5_item_14 = $_POST['pcl5_item_14'];
$pcl5_item_15 = $_POST['pcl5_item_15'];
$pcl5_item_16 = $_POST['pcl5_item_16'];
$pcl5_item_17 = $_POST['pcl5_item_17'];
$pcl5_item_18 = $_POST['pcl5_item_18'];
$pcl5_item_19 = $_POST['pcl5_item_19'];
$pcl5_item_20 = $_POST['pcl5_item_20'];


//echo $data_escala."<br>";



$inserir = $conexao->prepare ("INSERT INTO `aplica_esm` (`DATA_ESCALA`,`NOME_ESCALA_1`,`CPF_ESCALA_2`,`FFAA_ESCALA_3`,`DN_ESCALA_4`,`SEXO_BIOLOGICO_ESCALA_5`,`POSTO_GRAD_ESCALA_6`,`PHQ9_ITEM_1`,`PHQ9_ITEM_2`,`PHQ9_ITEM_3`,`PHQ9_ITEM_4`,`PHQ9_ITEM_5`,`PHQ9_ITEM_6`,`PHQ9_ITEM_7`,`PHQ9_ITEM_8`,`PHQ9_ITEM_9`,`PHQ9_ITEM_10`,`AUDITC_ITEM_1`,`AUDITC_ITEM_2`,`AUDITC_ITEM_3`,`DASS21_ITEM_1`,`DASS21_ITEM_2`,`DASS21_ITEM_3`,`DASS21_ITEM_4`,`DASS21_ITEM_5`,`DASS21_ITEM_6`,`DASS21_ITEM_7`,`DASS21_ITEM_8`,`DASS21_ITEM_9`,`DASS21_ITEM_10`,`DASS21_ITEM_11`,`DASS21_ITEM_12`,`DASS21_ITEM_13`,`DASS21_ITEM_14`,`DASS21_ITEM_15`,`DASS21_ITEM_16`,`DASS21_ITEM_17`,`DASS21_ITEM_18`,`DASS21_ITEM_19`,`DASS21_ITEM_20`,`DASS21_ITEM_21`,`BRS_ITEM_1`,`BRS_ITEM_2`,`BRS_ITEM_3`,`BRS_ITEM_4`,`BRS_ITEM_5`,`BRS_ITEM_6`,`AIS_ITEM_1`,`AIS_ITEM_2`,`AIS_ITEM_3`,`AIS_ITEM_4`,`AIS_ITEM_5`,`AIS_ITEM_6`,`AIS_ITEM_7`,`AIS_ITEM_8`,`PCL5_ITEM_1`,`PCL5_ITEM_2`,`PCL5_ITEM_3`,`PCL5_ITEM_4`,`PCL5_ITEM_5`,`PCL5_ITEM_6`,`PCL5_ITEM_7`,`PCL5_ITEM_8`,`PCL5_ITEM_9`,`PCL5_ITEM_10`,`PCL5_ITEM_11`,`PCL5_ITEM_12`,`PCL5_ITEM_13`,`PCL5_ITEM_14`,`PCL5_ITEM_15`,`PCL5_ITEM_16`,`PCL5_ITEM_17`,`PCL5_ITEM_18`,`PCL5_ITEM_19`,`PCL5_ITEM_20`) VALUES (:data_escala,:nome_escala_1,:cpf_escala_2,:ffaa_escala_3,:dn_escala_4,:sexo_biologico_escala_5,:posto_grad_escala_6,:phq9_item_1,:phq9_item_2,:phq9_item_3,:phq9_item_4,:phq9_item_5,:phq9_item_6,:phq9_item_7,:phq9_item_8,:phq9_item_9,:phq9_item_10,:auditc_item_1,:auditc_item_2,:auditc_item_3,:dass21_item_1,:dass21_item_2,:dass21_item_3,:dass21_item_4,:dass21_item_5,:dass21_item_6,:dass21_item_7,:dass21_item_8,:dass21_item_9,:dass21_item_10,:dass21_item_11,:dass21_item_12,:dass21_item_13,:dass21_item_14,:dass21_item_15,:dass21_item_16,:dass21_item_17,:dass21_item_18,:dass21_item_19,:dass21_item_20,:dass21_item_21,:brs_item_1,:brs_item_2,:brs_item_3,:brs_item_4,:brs_item_5,:brs_item_6,:ais_item_1,:ais_item_2,:ais_item_3,:ais_item_4,:ais_item_5,:ais_item_6,:ais_item_7,:ais_item_8,:pcl5_item_1,:pcl5_item_2,:pcl5_item_3,:pcl5_item_4,:pcl5_item_5,:pcl5_item_6,:pcl5_item_7,:pcl5_item_8,:pcl5_item_9,:pcl5_item_10,:pcl5_item_11,:pcl5_item_12,:pcl5_item_13,:pcl5_item_14,:pcl5_item_15,:pcl5_item_16,:pcl5_item_17,:pcl5_item_18,:pcl5_item_19,:pcl5_item_20)");


$inserir->bindValue(':data_escala', $data_escala);
$inserir->bindValue(':nome_escala_1', $nome_escala_1);
$inserir->bindValue(':cpf_escala_2', $cpf_escala_2);
$inserir->bindValue(':ffaa_escala_3', $ffaa_escala_3);
$inserir->bindValue(':dn_escala_4', $dn_escala_4);
$inserir->bindValue(':sexo_biologico_escala_5', $sexo_biologico_escala_5);
$inserir->bindValue(':posto_grad_escala_6', $posto_grad_escala_6);

$inserir->bindValue(':phq9_item_1', $phq9_item_1);
$inserir->bindValue(':phq9_item_2', $phq9_item_2);
$inserir->bindValue(':phq9_item_3', $phq9_item_3);
$inserir->bindValue(':phq9_item_4', $phq9_item_4);
$inserir->bindValue(':phq9_item_5', $phq9_item_5);
$inserir->bindValue(':phq9_item_6', $phq9_item_6);
$inserir->bindValue(':phq9_item_7', $phq9_item_7);
$inserir->bindValue(':phq9_item_8', $phq9_item_8);
$inserir->bindValue(':phq9_item_9', $phq9_item_9);
$inserir->bindValue(':phq9_item_10', $phq9_item_10);

$inserir->bindValue(':auditc_item_1', $auditc_item_1);
$inserir->bindValue(':auditc_item_2', $auditc_item_2);
$inserir->bindValue(':auditc_item_3', $auditc_item_3);

$inserir->bindValue(':dass21_item_1', $dass21_item_1);
$inserir->bindValue(':dass21_item_2', $dass21_item_2);
$inserir->bindValue(':dass21_item_3', $dass21_item_3);
$inserir->bindValue(':dass21_item_4', $dass21_item_4);
$inserir->bindValue(':dass21_item_5', $dass21_item_5);
$inserir->bindValue(':dass21_item_6', $dass21_item_6);
$inserir->bindValue(':dass21_item_7', $dass21_item_7);
$inserir->bindValue(':dass21_item_8', $dass21_item_8);
$inserir->bindValue(':dass21_item_9', $dass21_item_9);
$inserir->bindValue(':dass21_item_10', $dass21_item_10);
$inserir->bindValue(':dass21_item_11', $dass21_item_11);
$inserir->bindValue(':dass21_item_12', $dass21_item_12);
$inserir->bindValue(':dass21_item_13', $dass21_item_13);
$inserir->bindValue(':dass21_item_14', $dass21_item_14);
$inserir->bindValue(':dass21_item_15', $dass21_item_15);
$inserir->bindValue(':dass21_item_16', $dass21_item_16);
$inserir->bindValue(':dass21_item_17', $dass21_item_17);
$inserir->bindValue(':dass21_item_18', $dass21_item_18);
$inserir->bindValue(':dass21_item_19', $dass21_item_19);
$inserir->bindValue(':dass21_item_20', $dass21_item_20);
$inserir->bindValue(':dass21_item_21', $dass21_item_21);

$inserir->bindValue(':brs_item_1', $brs_item_1);
$inserir->bindValue(':brs_item_2', $brs_item_2);
$inserir->bindValue(':brs_item_3', $brs_item_3);
$inserir->bindValue(':brs_item_4', $brs_item_4);
$inserir->bindValue(':brs_item_5', $brs_item_5);
$inserir->bindValue(':brs_item_6', $brs_item_6);

$inserir->bindValue(':ais_item_1', $ais_item_1);
$inserir->bindValue(':ais_item_2', $ais_item_2);
$inserir->bindValue(':ais_item_3', $ais_item_3);
$inserir->bindValue(':ais_item_4', $ais_item_4);
$inserir->bindValue(':ais_item_5', $ais_item_5);
$inserir->bindValue(':ais_item_6', $ais_item_6);
$inserir->bindValue(':ais_item_7', $ais_item_7);
$inserir->bindValue(':ais_item_8', $ais_item_8);

$inserir->bindValue(':pcl5_item_1', $pcl5_item_1);
$inserir->bindValue(':pcl5_item_2', $pcl5_item_2);
$inserir->bindValue(':pcl5_item_3', $pcl5_item_3);
$inserir->bindValue(':pcl5_item_4', $pcl5_item_4);
$inserir->bindValue(':pcl5_item_5', $pcl5_item_5);
$inserir->bindValue(':pcl5_item_6', $pcl5_item_6);
$inserir->bindValue(':pcl5_item_7', $pcl5_item_7);
$inserir->bindValue(':pcl5_item_8', $pcl5_item_8);
$inserir->bindValue(':pcl5_item_9', $pcl5_item_9);
$inserir->bindValue(':pcl5_item_10', $pcl5_item_10);
$inserir->bindValue(':pcl5_item_11', $pcl5_item_11);
$inserir->bindValue(':pcl5_item_12', $pcl5_item_12);
$inserir->bindValue(':pcl5_item_13', $pcl5_item_13);
$inserir->bindValue(':pcl5_item_14', $pcl5_item_14);
$inserir->bindValue(':pcl5_item_15', $pcl5_item_15);
$inserir->bindValue(':pcl5_item_16', $pcl5_item_16);
$inserir->bindValue(':pcl5_item_17', $pcl5_item_17);
$inserir->bindValue(':pcl5_item_18', $pcl5_item_18);
$inserir->bindValue(':pcl5_item_19', $pcl5_item_19);
$inserir->bindValue(':pcl5_item_20', $pcl5_item_20);

$inserir->execute();

header("location:escala_1a.php");
}

?></p>

</body></html>