# Visão Geral da Estratégia
A estratégia é baseada na análise de um indicador de tendência (ATR Envelope) para determinar momentos de entrada e saída no mercado, gerenciando as posições com stops, take profits, parcializações e trailing stops, visando maximizar lucros e limitar perdas.

## Detalhamento Operacional

### Indicador de Tendência (ATR Envelope):
*   Calcula uma faixa dinâmica ao redor do preço, usando o ATR (Average True Range).
*   Essa faixa é composta por uma linha superior (Smax) e uma inferior (Smin), ajustadas com base na volatilidade e um fator de desvio.
*   A tendência de mercado é identificada com base na relação do preço de fechamento (Close) com essas linhas:
    *   Se o preço ultrapassa Smax, indica tendência de alta (trend=1).
    *   Se o preço cai abaixo de Smin, indica tendência de baixa (trend=-1).
    *   Caso contrário, mantém a tendência anterior.

### Geração de Sinais de Entrada:
Quando há uma mudança de tendência (por exemplo, de baixa para alta ou vice-versa), o sistema:
1.  Fecha posições abertas.
2.  Abre uma nova posição na direção da tendência detectada.
3.  Define o nível de stop loss (SL) baseado na última linha de suporte ou resistência (Smax ou Smin).
4.  Calcula o tamanho da posição (lot_size) proporcional ao risco definido (1% do saldo).

### Gestão das Posições:
Para cada posição aberta, o sistema monitora continuamente:
*   **Stop Loss (SL)**: se atingido, a posição é fechada com prejuízo.
*   **Take Profit (TP)**: se atingido, a posição é fechada com lucro.
*   **Parciais**: realiza parcializações ao atingir 25%, 50% e 75% do lucro potencial, reduzindo o lote e ajustando o SL.
*   **Break-even**: ao atingir um lucro equivalente a uma vez o ATR, ajusta o SL para o preço de entrada, protegendo lucros.
*   **Trailing Stop**: ajusta o SL em direção à direção do movimento para maximizar ganhos.

### Gerenciamento de Risco e Tamanho de Posição:
O tamanho da posição é calculado com base no risco fixo (1%) do saldo total, e na distância do SL.

### Cálculo de Métricas de Performance:
Ao final, calcula-se o lucro líquido total, índice de Sharpe, fator de lucro, retorno esperado (payoff), e o drawdown máximo em percentual.

### Visualização:
Um gráfico mostra a evolução do saldo ao longo das negociações, permitindo avaliar o desempenho dinâmico da estratégia.

## Resumo Operacional
*   **Quando entra**: ao detectar mudança de tendência usando o ATR Envelope, entra comprado ou vendido.
*   **Como gerencia**: com stops, take profits, parcializações, break-even e trailing stops.
*   **Objetivo**: capturar movimentos de tendência, protegendo lucros e limitando perdas.
*   **Resultado esperado**: ganho consistente em mercados de tendência, com gerenciamento ativo de risco.
