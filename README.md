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

---
**Conclusão**: O código é bem estruturado e segue boas práticas de MQL5 institucional, mas necessita de ajustes finos na parte de execução (normalização e redução de chamadas redundantes) para ser considerado pronto para produção em conta real.
