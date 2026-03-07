[ANALISE_TECNICA.md](https://github.com/user-attachments/files/25815349/ANALISE_TECNICA.md)
# Análise Técnica: mar2_agressivo.mq5

## 1. Resumo da Estratégia
O Expert Advisor (EA) **MAR1_AGRESSIVO_PRO** é um robô de rompimento (breakout) que opera baseado em volatilidade e tendência.

- **Filtro de Tendência**: Utiliza uma Média Móvel Exponencial (EMA) de 200 períodos. Só compra se o preço estiver acima da EMA e só vende se estiver abaixo.
- **Entrada**: Baseada no rompimento da máxima (`iHighest`) ou mínima (`iLowest`) dos últimos $N$ períodos (padrão 20 barras), com um buffer adicional.
- **Filtro de Volatilidade**: Utiliza o ATR (Average True Range) para garantir que o mercado tenha movimento suficiente antes de abrir ordens. O ATR atual deve ser pelo menos 70% da sua média móvel de 50 períodos e maior que um valor mínimo absoluto.
- **Gestão de Risco**: Lote dinâmico baseado no percentual de risco da conta (RiskPercent) e na distância do Stop Loss.

## 2. Mecanismos de Saída
- **Stop Loss (SL)**: Baseado em um multiplicador do ATR.
- **Take Profit (TP)**: Baseado em uma relação Risco:Retorno (RR_Ratio), padrão 2.5x o risco.
- **Break-even**: Move o Stop Loss para o preço de entrada quando o preço atinge um gatilho baseado no ATR.
- **Trailing Stop**: Utiliza um Trailing ATR para proteger lucros conforme o preço se move a favor.

## 3. Avaliação Técnica e Pontos Críticos

### Bugs e Problemas Identificados
1. **Redundância no Break-even (Crítico)**: No loop `ManagePosition`, a função `trade.PositionModify` é chamada em **todos os ticks** assim que a condição de Break-even é atingida, pois não há uma verificação se o SL já está posicionado no preço de entrada. Isso pode gerar erros de "Trade is disabled" ou sobrecarga de requisições ao servidor da corretora.
2. **Input Não Utilizado**: O parâmetro `MaxConsecutiveLoss` está declarado, mas não é utilizado em nenhuma parte da lógica para bloquear novas operações após perdas seguidas.
3. **Falta de Normalização de Preços**: As funções de envio de ordens e modificação de posição não utilizam `NormalizeDouble` para ajustar os preços ao número de dígitos do símbolo (`_Digits`). Isso pode causar falhas no envio de ordens em alguns ativos.
4. **Persistência do Drawdown**: O cálculo do `PeakEquity` é feito em memória. Se o MT5 for reiniciado, o `PeakEquity` é resetado para o patrimônio atual, o que "limpa" o histórico de drawdown acumulado.

### Pontos Positivos
- Uso correto da biblioteca padrão `CTrade`.
- Gestão eficiente de handles de indicadores no `OnInit` e `OnDeinit`.
- Filtro de volatilidade robusto, comparando o ATR atual com sua própria média histórica.

## 4. Sugestões de Melhoria
1. **Otimização do Loop de Gestão**: Adicionar uma verificação simples: `if(sl == open) continue;` antes de aplicar o Break-even.
2. **Implementação do MaxConsecutiveLoss**: Criar um contador global de perdas consecutivas que seja resetado após um lucro e impeça novas entradas se o limite for atingido.
3. **Persistência de Dados**: Utilizar `GlobalVariableSet` para salvar o `PeakEquity`, permitindo que o robô mantenha o cálculo de drawdown correto mesmo após reinicializações.
4. **Filtro de Horário**: Como é uma estratégia de rompimento, adicionar filtros de horário (ex: evitar abertura de mercado ou notícias de alto impacto) poderia reduzir falsos rompimentos.

---
**Conclusão**: O código é bem estruturado e segue boas práticas de MQL5 institucional, mas necessita de ajustes finos na parte de execução (normalização e redução de chamadas redundantes) para ser considerado pronto para produção em conta real.
