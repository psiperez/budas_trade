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
    <link href="./css/bootstrap.min.css" rel="stylesheet">

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
session_destroy();
include("menu_apresentacao.html");?>

<?php


#$resposta1 = "
#Professionals interested in signing in the system should request the link to fulfill the Register Form sending message to Whatsapp number +5521981288406. ";

$resposta1 = "
Profissionais interessados em usar o MoVALex poderão solicitar mais informações por mensagem no Whatsapp no número +5521981288406. ";



?>
<div class="w-75 p-3" style="position: absolute; left: 10px; top: 104px; text-align: left;">
<p style="position: absolute; font-size:16px; color:blue;">Como usar o MoVALex ?</p><br><br>
<?php echo $resposta1; ?><br><br>


</div>

<!--
<div class="w-100 p-3" style="position: absolute; left: 54px; top: 254px;text-align: justify; ">
<p style="position: absolute; font-size:16px; color:blue;">2) Porque usar o MoVALex ?</p><br><br>
<?php //echo $resposta3; ?>
</div>


<div class="w-100 p-3" style="position: absolute; left: 54px; top: 524px; text-align: justify;">
<p style="position: absolute; font-size:16px; color:blue;">3) Como o MoVALex funciona ?</p><br><br>
<?php //echo $resposta2; ?>
</div>



<div class="w-100 p-3" style="position: absolute; left: 54px; top: 814px;text-align: justify; ">
<p style="position: absolute; font-size:16px; color:blue;">4) Qual é o passo a passo para usar o MoVALex ?</p><br><br>
<?php //echo $resposta4; ?>
</div>


<div style="position: absolute; left: 884px; top: 154px; text-align: justify;width:800px;">
<p style="position: absolute; font-size:16px; color:blue;"><img src="oquee.jpeg"</p><br><br>
</div>

<div style="position: absolute; left: 884px; top: 554px; text-align: justify;width:800px;">
<p style="position: absolute; font-size:16px; color:blue;"><img src="comofunciona.png"</p><br><br>
</div>

<div style="position: absolute; left: 884px; top: 954px; text-align: justify;width:800px;">
<p style="position: absolute; font-size:16px; color:blue;"><img src="passoapasso.png"</p><br><br>
</div>

-->



</body>
</html>