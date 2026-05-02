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
    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
    body {
        padding-top: 70px;
        /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
    }
    </style>

</head><body>
<br>

<?php include("./menu_escalas.html") ?>
<div style="position: absolute; left: 20px; top: 104px;width:100%;">

<form class="form-signin" action="escala_1b.php" method="post">
      <h1 class="h3 mb-3 font-weight-normal">Inventários para Rastreio</h1><br><Br>


<div class="mb-3">
   <label for="inputNome" class="form-label">A - Nome do Usuário</label>
      <input type="text" name= "nome_escala_1" id="inputNome" class="form-control" placeholder="Nome do Usuário" required autofocus>
</div><br>

<div class="mb-3">
   <label for="inputCpf" class="form-label">B - CPF do Usuário</label>
      <input type="text" name= "cpf_escala_2" id="inputCpf" class="form-control" placeholder="Insira somente os algarismo do CPF. Ex:  012345678934" required autofocus>
</div><br>


<div class="form-check">
  <label class="form-check-label" for="flexRadioDefault1">C - Força Armada</label><br>
  <input class="form-check-input" type="radio" name="ffaa_escala_3" id="flexRadioDefault1" value="Marinha do Brasil" required><label class="form-check-label" for="flexRadioDefault1">Marinha do Brasil</label>
  <input class="form-check-input" type="radio" name="ffaa_escala_3" id="flexRadioDefault1" value="Exército Brasileiro"><label class="form-check-label" for="flexRadioDefault1">Exército Brasileiro</label>
  <input class="form-check-input" type="radio" name="ffaa_escala_3" id="flexRadioDefault1" value="Força Aérea Brasileira"><label class="form-check-label" for="flexRadioDefault1">Força Aérea Brasileira</label>
</div><br>

<div class="mb-3">
    <label for="inputData" class="form-label">D - Data de Nascimento</label>
      <div class="input-group date" data-date-format="dd/mm/yyyy">
          <input  type="text" name= "dn_escala_4" class="form-control" placeholder="dd/mm/yyyy" required>
            <div class="input-group-addon" >
                <span class="glyphicon glyphicon-th"></span>
            </div>
      </div>
</div><br>


<div class="form-check">
  <label class="form-check-label" for="flexRadioDefault1">E - Sexo Biológico</label><br>
  <input class="form-check-input" type="radio" name="sexo_biologico_escala_5" id="flexRadioDefault1" value="Masculino" required><label class="form-check-label" for="flexRadioDefault1">Masculino</label>
  <input class="form-check-input" type="radio" name="sexo_biologico_escala_5" id="flexRadioDefault1" value="Feminino"><label class="form-check-label" for="flexRadioDefault1">Feminino</label>
</div><br>


<div class="form-check">
  <label class="form-check-label" for="flexRadioDefault1">F - Posto ou Graduação</label><br>
  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Almirante de Esquadra / General de Exército / Tenente-Brigadeiro" required><label class="form-check-label" for="flexRadioDefault1">Almirante de Esquadra / General de Exército / Tenente-Brigadeiro</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Vice-Almirante / General de Divisão / Major-Brigadeiro" required><label class="form-check-label" for="flexRadioDefault1">Vice-Almirante / General de Divisão / Major-Brigadeiro</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Contra-Almirante / General de Brigada / Brigadeiro do Ar" required><label class="form-check-label" for="flexRadioDefault1">Contra-Almirante / General de Brigada / Brigadeiro do Ar</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Capitão de Mar e Guerra / Coronel" required><label class="form-check-label" for="flexRadioDefault1">Capitão de Mar e Guerra / Coronel</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Capitão-de-Fragata / Tenente-Coronel" required><label class="form-check-label" for="flexRadioDefault1">Capitão-de-Fragata / Tenente-Coronel</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Capitão-de-Corveta / Major" required><label class="form-check-label" for="flexRadioDefault1">Capitão-de-Corveta / Major</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Capitão-Tenente / Capitão" required><label class="form-check-label" for="flexRadioDefault1">Capitão-Tenente / Capitão</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Primeiro-Tenente" required><label class="form-check-label" for="flexRadioDefault1">Primeiro-Tenente</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Segundo-Tenente" required><label class="form-check-label" for="flexRadioDefault1">Segundo-Tenente</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Guarda-Marinha / Aspirante" required><label class="form-check-label" for="flexRadioDefault1">Guarda-Marinha / Aspirante</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Suboficial / Subtenente" required><label class="form-check-label" for="flexRadioDefault1">Suboficial / Subtenente</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Primeiro-Sargento" required><label class="form-check-label" for="flexRadioDefault1">Primeiro-Sargento</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Segundo-Sargento" required><label class="form-check-label" for="flexRadioDefault1">Segundo-Sargento</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Terceiro-Sargento" required><label class="form-check-label" for="flexRadioDefault1">Terceiro-Sargento</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="Cabo" required><label class="form-check-label" for="flexRadioDefault1">Cabo</label><br>

  <input class="form-check-input" type="radio" name="posto_grad_escala_6" id="flexRadioDefault1" value="" required><label class="form-check-label" for="flexRadioDefault1">Marinheiro / Soldado</label><br>
</div><br><br>


<div class="form-check">
<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">PHQ-9</label><br>
<div style="background-color:silver;" class="container-fluid">Durante as últimas 2 semanas, com que freqüência você foi incomodado/a por qualquer um dos problemas abaixo?<Br>

</div>

<table class="table">
  <thead>
    <tr>
      <th scope="col">Item</th>
      <th scope="col">Nenhuma vez</th>
      <th scope="col">Vários dias</th>
      <th scope="col">Mais da metade dos dias</th>
      <th scope="col">Quase todos os dias</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1. Pouco interesse ou pouco prazer em fazer as coisas</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_1" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_1" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_1" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">2. Se sentir “para baixo”, deprimido/a ou sem perspectiva	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_2" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_2" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_2" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">3. Dificuldade para pegar no sono ou permanecer dormindo, ou dormir mais do que de costume	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_3" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_3" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_3" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">4. Se sentir cansado/a ou com pouca energia	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_4" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_4" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_4" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_4" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">5. Falta de apetite ou comendo demais	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_5" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_5" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_5" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_5" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">6. Se sentir mal consigo mesmo/a — ou achar que você é um fracasso ou que decepcionou sua família ou você mesmo/a	0	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_6" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_6" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_6" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_6" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">7. Dificuldade para se concentrar nas coisas, como ler o jornal ou ver televisão	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_7" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_7" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_7" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_7" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">8. Lentidão para se movimentar ou falar, a ponto das outras pessoas perceberem? Ou o oposto – estar tão agitado/a ou irrequieto/a que você fica andando de um lado para o outro muito mais do que de costume	</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_8" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_8" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_8" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_8" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">9. Pensar em se ferir de alguma maneira ou que seria melhor estar morto/a</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_9" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_9" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_9" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_9" id="flexRadioDefault1" value="3"></td>

    </tr>

    <thead>
    <tr>

      <th scope="col"></th>
      <th scope="col">Nenhuma dificuldade</th>
      <th scope="col">Alguma dificuldade</th>
      <th scope="col">Muita dificuldade</th>
      <th scope="col">Extrema dificuldade</th>
      <th scope="col">Sem resposta</th>
    </tr>
  </thead>

  <tr>
      <th scope="row">Se você assinalou qualquer um dos problemas acima, indique o grau de dificuldade que os mesmos lhe causaram para realizar seu trabalho, tomar conta das coisas em casa ou para se relacionar com as pessoas?</th>
      <td><input class="form-check-input" type="radio" name="phq9_item_10" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_10" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_10" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_10" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="phq9_item_10" id="flexRadioDefault1" value="0"></td>
    </tr>

  </tbody>
</table>


<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">AUDIT-C</label>
<div style="background-color:silver;" class="container-fluid">Por favor, Responda as perguntas abaixo :</div>

<table class="table">
  <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Nunca</th>
      <th scope="col">Mensalmente ou menos</th>
      <th scope="col">2 a 4 vezes por mês</th>
      <th scope="col">2 a 3 vezes por semana</th>
      <th scope="col">4 ou mais vezes por semana</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1. Com que frequência você toma bebidas com álcool ?</th>
      <td><input class="form-check-input" type="radio" name="auditc_item_1" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_1" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_1" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_1" id="flexRadioDefault1" value="4"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">1 ou 2</th>
      <th scope="col">3 a 4</th>
      <th scope="col">5 a 6</th>
      <th scope="col">7 a 9</th>
      <th scope="col">10 ou mais</th>
    </tr>
  </thead>


    <tr>
      <th scope="row">2. Quantas bebidas padrão contendo álcool você toma em um dia típico</th>
      <td><input class="form-check-input" type="radio" name="auditc_item_2" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_2" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_2" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_2" id="flexRadioDefault1" value="4"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Diariamente ou quase diariamente</th>
      <th scope="col">Semanalmente</th>
      <th scope="col">Mensalmente</th>
      <th scope="col">Menor do que mensalmente</th>
      <th scope="col">Nunca</th>
    </tr>
  </thead>


    <tr>
      <th scope="row">3. Com que frequência você toma seis ou mais drinques em uma ocasião ?</th>
      <td><input class="form-check-input" type="radio" name="auditc_item_3" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_3" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_3" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="auditc_item_3" id="flexRadioDefault1" value="4"></td>
    </tr>
    </table>



<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">DASS-21</label>
<div style="background-color:silver;" class="container-fluid">Por favor, leia cuidadosamente cada uma das afirmações abaixo e circule o número apropriado 0,1,2 ou 3 que indique o quanto ela se aplicou a você durante a última semana, conforme a indicação a seguir:</div>

<table class="table">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Não se aplicou de maneira alguma</th>
      <th scope="col">Aplicou-se em algum grau, ou por pouco de tempo</th>
      <th scope="col">Aplicou-se em um grau considerável, ou por uma boa parte do tempo</th>
      <th scope="col">Aplicou-se muito, ou na maioria do tempo</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1. Achei difícil me acalmar</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_1" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_1" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_1" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">2. Senti minha boca seca</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_2" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_2" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_2" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">3. Não consegui vivenciar nenhum sentimento positivo</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_3" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_3" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_3" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">4. Tive dificuldade em respirar em alguns momentos (ex. respiração ofegante, falta de ar, sem ter feito nenhum esforço físico)</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_4" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_4" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_4" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_4" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">5. Achei difícil ter iniciativa para fazer as coisas</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_5" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_5" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_5" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_5" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">6. Tive a tendência de reagir de forma exagerada às situações</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_6" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_6" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_6" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_6" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">7. Senti tremores (ex. nas mãos)</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_7" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_7" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_7" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_7" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">8. Senti que estava sempre nervoso</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_8" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_8" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_8" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_8" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">9. Preocupei-me com situações em que eu pudesse entrar em pânico e parecesse ridículo (a)	</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_9" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_9" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_9" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_9" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">10. Senti que não tinha nada a desejar</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_10" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_10" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_10" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_10" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">11. Senti-me agitado</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_11" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_11" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_11" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_11" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">12. Achei difícil relaxar</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_12" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_12" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_12" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_12" id="flexRadioDefault1" value="3"></td>
    </tr>

    <tr>
      <th scope="row">13. Senti-me depressivo (a) e sem ânimo</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_13" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_13" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_13" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_13" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">14. Fui intolerante com as coisas que me impediam de continuar o que eu estava fazendo</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_14" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_14" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_14" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_14" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">15. Senti que ia entrar em pânico	</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_15" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_15" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_15" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_15" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">16. Não consegui me entusiasmar com nada</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_16" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_16" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_16" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_16" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">17. Senti que não tinha valor como pessoa</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_17" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_17" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_17" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_17" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">18. Senti que estava um pouco emotivo/sensível demais</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_18" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_18" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_18" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_18" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">19. Sabia que meu coração estava alterado mesmo não tendo feito nenhum esforço físico (ex. aumento da frequência cardíaca, disritmia cardíaca)</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_19" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_19" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_19" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_19" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">20. Senti medo sem motivo</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_20" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_20" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_20" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_20" id="flexRadioDefault1" value="3"></td>
    </tr>
    <tr>
      <th scope="row">21. Senti que a vida não tinha sentido</th>
      <td><input class="form-check-input" type="radio" name="dass21_item_21" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_21" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_21" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="dass21_item_21" id="flexRadioDefault1" value="3"></td>
    </tr>

  </tbody>
</table>

<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">BRS</label>
<div style="background-color:silver;" class="container-fluid">Por favor, Responda as perguntas abaixo :</div>

<table class="table">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Discordo Fortemente</th>
      <th scope="col">Discordo</th>
      <th scope="col">Neutro</th>
      <th scope="col">Concordo</th>
      <th scope="col">Concordo Fortemente</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <th scope="row">1. Costumo me recuperar rapidamente após tempos difíceis</th>
      <td><input class="form-check-input" type="radio" name="brs_item_1" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_1" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_1" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_1" id="flexRadioDefault1" value="5"></td>
    </tr>
    <tr>
      <th scope="row">2. Tenho dificuldades em superar eventos estressantes</th>
      <td><input class="form-check-input" type="radio" name="brs_item_2" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_2" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_2" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_2" id="flexRadioDefault1" value="5"></td>
    </tr>
    <tr>
      <th scope="row">3. Não demoro muito para me recuperar de um evento estressante</th>
      <td><input class="form-check-input" type="radio" name="brs_item_3" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_3" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_3" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_3" id="flexRadioDefault1" value="5"></td>
    </tr>
    <tr>
      <th scope="row">4. É difícil para mim reagir quando algo ruim acontece</th>
      <td><input class="form-check-input" type="radio" name="brs_item_4" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_4" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_4" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_4" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_4" id="flexRadioDefault1" value="5"></td>
    </tr>
    <tr>
      <th scope="row">5. Eu costumo passar por momentos difíceis com poucos problemas</th>
      <td><input class="form-check-input" type="radio" name="brs_item_5" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_5" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_5" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_5" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_5" id="flexRadioDefault1" value="5"></td>
    </tr>
    <tr>
      <th scope="row">6. Costumo levar muito tempo para superar os contratempos da minha vida</th>
      <td><input class="form-check-input" type="radio" name="brs_item_6" id="flexRadioDefault1" value="1" required></td>
      <td><input class="form-check-input" type="radio" name="brs_item_6" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_6" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_6" id="flexRadioDefault1" value="4"></td>
      <td><input class="form-check-input" type="radio" name="brs_item_6" id="flexRadioDefault1" value="5"></td>
    </tr>
      </tbody>
</table>

<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">AIS</label>
<div style="background-color:silver;" class="container-fluid">Por favor, Responda as perguntas abaixo :</div>

<table class="table">
  <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Sem problemas</th>
      <th scope="col">Levemente após</th>
      <th scope="col">Acentuadamente após</th>
      <th scope="col">Muito após ou não adormece</th>

    </tr>
  </thead>

  <tbody>
    <tr>
      <th scope="row">1. Indução do sono (tempo que demora a adormecer depois de apagar as luzes)</th>
      <td><input class="form-check-input" type="radio" name="ais_item_1" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_1" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_1" id="flexRadioDefault1" value="3"></td>

    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Sem problemas</th>
      <th scope="col">Pequeno problema</th>
      <th scope="col">Problema considerável</th>
      <th scope="col">Sério problema ou não adormece</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">2. Acordar durante a noite</th>
      <td><input class="form-check-input" type="radio" name="ais_item_2" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_2" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_2" id="flexRadioDefault1" value="3"></td>

    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Não desperta antes do desejado</th>
      <th scope="col">Desperta um pouco antes do desejado</th>
      <th scope="col">Desperta acentuadamente antes</th>
      <th scope="col">Desperta muito antes ou não adormece</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">3. Despertar antes do desejado</th>
      <td><input class="form-check-input" type="radio" name="ais_item_3" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_3" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_3" id="flexRadioDefault1" value="3"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Suficiente</th>
      <th scope="col">Levemente insuficiente</th>
      <th scope="col">Acentuadamente insuficiente</th>
      <th scope="col">Muito insuficiente ou não adormece</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">4. Total da duração do sono</th>
      <td><input class="form-check-input" type="radio" name="ais_item_4" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_4" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_4" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_4" id="flexRadioDefault1" value="3"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Satisfatória</th>
      <th scope="col">Levemente insatisfatória</th>
      <th scope="col">Acentuadamente insatisfatória</th>
      <th scope="col">Muito insatisfatória ou não adormeceu</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">5. Qualidade geral do sono (não importa por quanto tempo dormiu)</th>
      <td><input class="form-check-input" type="radio" name="ais_item_5" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_5" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_5" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_5" id="flexRadioDefault1" value="3"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Normal</th>
      <th scope="col">Levemente reduzida</th>
      <th scope="col">Acentuadamente reduzida</th>
      <th scope="col">Muito reduzida</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">6. Sensação de bem-estar durante o dia</th>
      <td><input class="form-check-input" type="radio" name="ais_item_6" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_6" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_6" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_6" id="flexRadioDefault1" value="3"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Normal</th>
      <th scope="col">Levemente reduzido</th>
      <th scope="col">Acentuadamente reduzido</th>
      <th scope="col">Muito reduzido</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">7. Funcionamento (físico e mental) durante o dia</th>
      <td><input class="form-check-input" type="radio" name="ais_item_7" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_7" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_7" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_7" id="flexRadioDefault1" value="3"></td>
    </tr>

    <thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">Nenhuma</th>
      <th scope="col">Leve</th>
      <th scope="col">Considerável</th>
      <th scope="col">Intensa</th>

    </tr>
  </thead>

    <tr>
      <th scope="row">8. Sonolência durante o dia</th>
      <td><input class="form-check-input" type="radio" name="ais_item_8" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="ais_item_8" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_8" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="ais_item_8" id="flexRadioDefault1" value="3"></td>
    </tr>

    </tbody>
</table>

<label for="exampleFormControlTextarea1" class="form-label" style="color:red;">PCL-5</label>
<div style="background-color:silver;" class="container-fluid">Abaixo há uma lista de problemas que as pessoas as vezes apresentam em resposta a situações muito estressantes. Por favor, leia cada problema atentamente e indique o quanto você tem sido incomodado por ele no mês passado, de acordo com a legenda abaixo :</div>

<table class="table">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">De jeito nenhum</th>
      <th scope="col">Pouco incomodado</th>
      <th scope="col">Moderadamente incomodado</th>
      <th scope="col">Muito incomodado</th>
      <th scope="col">Extremamente incomodado</th>

    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">1. Memórias repetidas, perturbadoras e indesejadas do experiência estressante </th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_1" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_1" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_1" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_1" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_1" id="flexRadioDefault1" value="4"></td>
    </tr>

    <tr>
      <th scope="row">2. Sonhos perturbadores e repetidos da experiência estressante </th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_2" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_2" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_2" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_2" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_2" id="flexRadioDefault1" value="4"></td>
    </tr>

    <tr>
      <th scope="row">3. De repente, sentir ou agir como se a experiência estressante fosse realmente acontecendo de novo (como se você estivesse realmente lá atrás revivendo isso)</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_3" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_3" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_3" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_3" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_3" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">4. Sentir-se muito chateado quando algo te lembra de uma experiência estressante</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_4" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_4" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_4" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_4" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_4" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">5. Ter fortes reações físicas quando algo lembra você da experiência estressante (por exemplo, coração palpitação, dificuldade para respirar, suor)</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_5" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_5" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_5" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_5" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_5" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">6. Evita memórias, pensamentos ou sentimentos relacionados ao experiência estressante</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_6" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_6" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_6" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_6" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_6" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">7. Evita lembranças externas da experiência estressante (por exemplo, pessoas, lugares, conversas, atividades, objetos ou situações)</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_7" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_7" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_7" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_7" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_7" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">8. Dificuldade em lembrar partes importantes do estressante experiência</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_8" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_8" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_8" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_8" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_8" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">9. Ter fortes crenças negativas sobre si mesmo, outras pessoas, ou o mundo (por exemplo, tendo pensamentos como: eu sou ruim, há algo seriamente errado comigo, ninguém é confiável, o mundo é completamente perigoso) </th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_9" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_9" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_9" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_9" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_9" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">10. Culpar a si mesmo ou a outra pessoa pelo estresse experiência ou o que aconteceu depois dela</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_10" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_10" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_10" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_10" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_10" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">11. Ter fortes sentimentos negativos, como medo, horror, raiva, culpa ou vergonha</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_11" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_11" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_11" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_11" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_11" id="flexRadioDefault1" value="4"></td>
    </tr>

    <tr>
      <th scope="row">12. Perda de interesse por atividades que antes gostava </th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_12" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_12" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_12" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_12" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_12" id="flexRadioDefault1" value="4"></td>
    </tr>

    <tr>
      <th scope="row">13. Sente-se distante ou isolado das outras pessoas</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_13" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_13" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_13" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_13" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_13" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">14. Dificuldade em experimentar sentimentos positivos (por exemplo, ser incapaz de sentir felicidade ou ter sentimentos amorosos pelas pessoas perto de você)</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_14" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_14" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_14" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_14" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_14" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">15. Comportamento irritável, explosões de raiva ou comportamento agressivo</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_15" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_15" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_15" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_15" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_15" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">16. Correr muitos riscos ou fazer coisas que podem causar ferir</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_16" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_16" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_16" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_16" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_16" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">17. Estar “superalerta” ou vigilante ou em guarda</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_17" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_17" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_17" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_17" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_17" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">18. Sentir-se nervoso ou facilmente assustado</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_18" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_18" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_18" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_18" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_18" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">19. Tem dificuldade de concentração</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_19" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_19" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_19" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_19" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_19" id="flexRadioDefault1" value="4"></td>
    </tr>
    <tr>
      <th scope="row">20. Dificuldade em adormecer ou manter o sono</th>
      <td><input class="form-check-input" type="radio" name="pcl5_item_20" id="flexRadioDefault1" value="0" required></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_20" id="flexRadioDefault1" value="1"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_20" id="flexRadioDefault1" value="2"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_20" id="flexRadioDefault1" value="3"></td>
      <td><input class="form-check-input" type="radio" name="pcl5_item_20" id="flexRadioDefault1" value="4"></td>
    </tr>


  </tbody>
</table>

</div>


      <button class="btn btn-lg btn-primary btn-block" type="submit">Enviar respostas</button>
      <p class="mt-5 mb-3 text-muted"></p>
    </form>


<br>

</div>
 <!-- Plugin pro Datapicker novo -->
    <script src='https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.6.1/js/bootstrap-datepicker.min.js'></script>
    <script>
     $('.input-group.date').datepicker({format: "dd/mm/yyyy"});
    </script>


</body></html>