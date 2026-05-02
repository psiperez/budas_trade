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

/*
$resposta1 = "

The system scope is monitoring the emotional status through lexical analyses. This system is a tool to help psychologists in duty to keep track of mental conditions of their remote clients  in a proactive, ethicaly and  objective way, what represents by itself an enlargerment of their assistance efficacy."."<br><br>"."

The system uses artificial intelligence resources without recurring to any external provider, and outputs a graphical plot for lexical valencies used to describe the inner thoughts monologue and their parallels feelings."."<br><br>"."

MoVALex, as said above, do not dispense the regular and personal professional specialized assistance. In emergencies cases, as, for example, psychotics acutes crisis,drugs abstinence, rage episodes or suicidal ideation, should be adopted all the recommend mental first-aid measures."."<br><br>"." ";

*/


$resposta1 = "

O MoVALex é um sistema informatizado que tem por finalidade realizar o acompanhamento do estado afetivo por meio da análise léxica. O sistema é uma ferramenta para auxiliar os profissionais de saúde mental na tarefa de acompanhamento remoto do estado emocional de seus pacientes de um forma proativa, ética e objetiva, o que amplia a eficácia da assistência prestada. "."<br><br>"."

O sistema usa um algoritmo de inteligência artificial, sem recorrer a hospedagem em outro servidor externo ao próprio sistema, e produz gráficos com as valências afetivas das palavras utilizadas para a descrição de seus pensamentos automáticos, ou seja, dos seus monólogos mentais e dos sentimentos que lhes correspondem. "."<br><br>"."

Como dito acima, MoVALex não dispensa a assistência especializada, pessoal e regular. Seu uso não é recomendado em casos de emergências em saúde mental, como, por exemplo, episódios psicóticos agudos, abstinência de drogas, explosões de agressividade ou ideações/tentativas de suicídio. Nestes casos agudos e graves, as condutas recomendadas para o pronto-atendimento devem ser adotadas."."<br><br>"."  ";



$resposta2 = "O sistema funciona hospedado em um servidor com acesso a internet para recepção dos dados, os quais ficam arquivados no banco de dados deste servidor que hospeda o MoVALex."."<br><br>"."

O profissional de saúde mental realiza o login no sistema e, a partir de uma interface amigável, carrega os dados relativos aos usuários que estão sob seu acompanhamento. O profissional somente tem acesso aos usuários que estão sob os seus cuidados. O gráfico é gerado pela inteligência artificial a cada vez que o usuário faz um registro no seu diário de pensamentos."."<br><br>"."

Ao analisar o conteúdo das frases registradas pelos seus pacientes e a evolução dos dados quantitativos produzidos pela inteligência artificial, o profissional pode filtrar os casos por sua gravidade e urgência, a fim de providenciar a melhor forma de ação preventiva ou  intervenção."."<br><br>"."  ";

$resposta3 = "

O maior benefício que o MoVALex agrega a assistência em saúde mental é permitir o acompanhamento psicológico à distância de indivíduos ou grupos de forma regular, sistemática e objetiva, sendo, portanto, uma ferramenta complementar à teleconsulta. "."<br><br>"."

Além deste benefício, existem outras vantagens :"."<br>
<ul>
<li>Ampliação do universo de pessoas atendidas por um profissional;</li>
<li>Aumento do foco do atendimento psicológico a partir do conteúdo registrado;</li>
<li>Manutenção de registros escritos descritivos de características psicológicas de usuários; e</li>
<li>Criação de indicadores objetivos para avaliação da eficiência da assistência oferecida </li>
</ul>"."<br>";

$resposta4 = "


Os passos a serem seguidos dependerão do tipo de acesso: USUARIO ou PROFISSIONAL"."<br><br><b>"."Passo a passo para acesso de USUÁRIO :". "</b><br>

<ul>
<li>Ter acesso a internet;</li>
<li>Fazer o download da rede social Telegram para o seu celular ou computador;</li>

<li>Acessar o ChatBot Ouvidor no Telegram (https://t.me/ouvidor1_bot);</li>

<li>Ler e seguir as instruções do ChatBot para registro de mensagens;</li>
<li>Acessar o MoVALex (https://psiperez.net/bot/cadastra_usuario_1a.php) para se cadastrar como Novo Usário;</li>
<li>Após o cadastro aceito, acessar o MoVALex (https://psiperez.net/bot/apresentacao.php) como usuário por meio de email e senha cadastrada ;</li>
<li>Clicar em Escalas da ESM e responder ao questionário ;</li>
<li>Clicar em Obter registros ;</li>
<li>Clicar em Atualizar o gráfico .</li>

</ul>"."<br><b>"."Passo a passo para acesso de PROFISSIONAL :". "</b><br>

<ul>
<li>Ter acesso a internet;</li>
<li>Acessar o MoVALex para entrar em contato (https://psiperez.net/bot/contato.php);</li>
<li>Após a realização do contato, o profissional poderá ser cadastrado na plataforma para acessá-la como profissional;</li>
<li>Após o cadastramento aceito, acessar o MoVALex (https://psiperez.net/bot/apresentacao.php) como profissional por meio de email e senha cadastrada;</li>
<li>Preencher o campo emissário do formulário de consulta, a partir dos usuários que lhe estiverem atribuídos;</li>
<li>Clicar em Obter registros no menu superior;</li>
<li>Clicar em Atualizar o gráfico no menu superior.</li>
</ul>";

$resposta5 = '<ul>
<li><a href="Computer-based personality judgments are more accurate than those made by humans.pdf">Computer-based personality judgments are more accurate than those made by humans</a></li>
<li><a href="Quantifying Mental Health Signals in Twitter.pdf">Quantifying Mental Health Signals in Twitter</a></li>
<li><a href="VADER- A Parsimonious Rule-based Model for Sentiment Analysis of Social Media Text.pdf">VADER- A Parsimonious Rule-based Model for Sentiment Analysis of Social Media Text</a></li>
<li><a href="https://medium.com/@mystery0116/nlp-how-does-nltk-vader-calculate-sentiment-6c32d0f5046b">Como o VADER calcula sentimentos </a></li>
<li><a href="https://en.wikipedia.org/wiki/James_W._Pennebaker">James W Pennebaker</a></li>
<li><a href="writing about emotinal experience.pdf">Writing about emotinal experience</a></li>
<li><a href="Health Complaints, Stress, and Distress- Exploring the Central Role of Negative Affectivity.pdf">Health Complaints, Stress, and Distress- Exploring the Central Role of Negative Affectivity </a></li>
<li><a href="Forming a Story- The Health Benefits of Narrative.pdf">Forming a Story- The Health Benefits of Narrative</a></li>
<li><a href="https://www.youtube.com/watch?v=SsTzXB8M8fg&list=PLNddSR_IzYHxec0rP5C8vWylOraeI2tAQ&index=3">Expressive writing can help your mental health, with James Pennebaker, PhD</a></li>
</ul>';

?>
<div class="w-75 p-3" style="position: absolute; left: 10px; top: 104px; text-align: left;">
<p style="position: absolute; font-size:16px; color:blue;">1) O que é o MoVALex ?</p><br><br>
<?php echo $resposta1; ?><br><br>

<p style="position: absolute; font-size:16px; color:blue;">2) Porque usar o MoVALex ?</p><br><br>
<?php echo $resposta3; ?><br><br>

<p style="position: absolute; font-size:16px; color:blue;">3) Como o MoVALex funciona ?</p><br><br>
<?php echo $resposta2; ?><br><br>

<p style="position: absolute; font-size:16px; color:blue;">4) Para saber mais Psicologia, Informática e Saúde Mental :</p><br><br>
<?php echo $resposta5; ?><br><br>

<!--
<p style="position: absolute; font-size:16px; color:blue;">4) Qual é o passo a passo para usar o MoVALex ?</p><br><br>

-->


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