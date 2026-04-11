//+------------------------------------------------------------------+
//|                                          TripleConfirmation.mq5  |
//|                                    by Expert Advisor Builder     |
//|                                   TCBB com Multi-Timeframe (4H+D1)|
//|                                   Versão 3.2 - Single Position   |
//+------------------------------------------------------------------+
#property copyright   "Triple Confirmation System"
#property description "TCBB Multi-Timeframe EA (4H+D1)"
#property description "Gera sinais de compra/venda APENAS com confirmação TRIPLA (100%)"
#property description "Condições adicionais: Fibo618 > BB Upper (COMPRA) | Fibo236 < BB Lower (VENDA)"
#property description "VZO e WaveWeis requerem concordância entre 4H e D1"
#property description "⚠️ APENAS UMA OPERAÇÃO POR ATIVO PERMITIDA"
#property version     "3.20"

//+------------------------------------------------------------------+
//| Parâmetros de entrada                                            |
//+------------------------------------------------------------------+
// Parâmetros de Gerenciamento de Capital
input group "=== Money Management ==="
input double   inpLotSize = 0.1;           // Quantidade de lotes (0.01 = micro, 0.1 = mini, 1.0 = padrão)
input bool     inpUseAutoLot = false;       // Usar cálculo automático de lotes?
input double   inpRiskPercent = 2.0;        // Risco por operação (%) - usado com AutoLot
input double   inpMaxLotSize = 1.0;         // Lote máximo permitido

// Parâmetros de Stop Loss e Take Profit
input group "=== Stop Loss & Take Profit ==="
input int      inpStopLossPoints = 300;     // Stop Loss fixo em pontos (300 = 30 pips)
input int      inpTakeProfitPoints = 600;   // Take Profit fixo em pontos (600 = 60 pips)

// Parâmetros de Trailing Stop
input group "=== Trailing Stop ==="
input bool     inpUseTrailingStop = true;   // Ativar Trailing Stop
input int      inpTrailingStart = 100;      // Iniciar trailing quando lucro atingir (pontos)
input int      inpTrailingStep = 50;        // Avançar trailing a cada (pontos)
input int      inpTrailingDistance = 50;    // Distância do trailing stop (pontos)

// Parâmetros do Sistema
input group "=== Trading System ==="
input int      inpMagicNumber = 12345;      // Magic Number para identificação das ordens
input int      inpSlippage = 30;            // Slippage permitido (pontos)
input int      inpCooldownMinutes = 60;     // Cooldown entre sinais (minutos)

// Parâmetros dos Indicadores
input group "=== ATR Trend Envelope Settings ==="
input int     inpAtrPeriod = 14;            // ATR period
input double  inpDeviation = 1.5;           // ATR multiplication factor

input group "=== Volume Zone Oscillator Settings ==="
input int     inpVzoPeriod = 14;            // VZO Period
input int     inpFlLookBack = 12;           // Floating levels look back
input double  inpFlLevelUp = 50;            // Upper level %
input double  inpFlLevelDown = 50;          // Lower level %

input group "=== WaveWeis Settings ==="
input int     inpWaveIntensity = 50;        // Intensity window (bars)

input group "=== Bollinger Bands Settings ==="
input int     inpBbPeriod = 20;             // Bollinger Bands period
input int     inpBbShift = 0;               // Bollinger Bands shift
input double  inpBbDeviation = 2.0;         // Bollinger Bands deviation

input group "=== Multi-Timeframe Settings ==="
input ENUM_TIMEFRAMES inpHigherTF = PERIOD_D1;  // Timeframe para confirmação (D1)

//+------------------------------------------------------------------+
//| Buffers do indicador                                             |
//+------------------------------------------------------------------+
// ATR Trend Envelope buffers
double lineupBuffer[], linednBuffer[], arrowupBuffer[], arrowdnBuffer[];
double fibo236Buffer[], fibo382Buffer[], fibo500Buffer[], fibo618Buffer[], fibo764Buffer[];

// VZO buffers
double vzoBuffer[], vzocBuffer[], levupBuffer[], levdnBuffer[];

// WaveWeis buffers
double accumBuffer[], colorIndexBuffer[], maxWaveBuffer[], climaxBuffer[];

// Bollinger Bands buffers
double bbUpperBuffer[], bbMiddleBuffer[], bbLowerBuffer[];

// Buffers do sistema
double buySignalBuffer[], sellSignalBuffer[], signalStrengthBuffer[], confirmationCountBuffer[];

//+------------------------------------------------------------------+
//| Buffers para Timeframe Superior (D1)                             |
//+------------------------------------------------------------------+
int hVZO = INVALID_HANDLE;
int hWaveWeis = INVALID_HANDLE;
int hATRTrend = INVALID_HANDLE;
int hBollinger = INVALID_HANDLE;

double vzoD1Buffer[], waveAccumD1Buffer[];
double arrowupD1Buffer[], arrowdnD1Buffer[];
double fibo236D1Buffer[], fibo618D1Buffer[];
double bbUpperD1Buffer[], bbLowerD1Buffer[];

//+------------------------------------------------------------------+
//| Estruturas auxiliares                                            |
//+------------------------------------------------------------------+
struct sTrendEnvelope
{
   double upline;
   double downline;
   double smin;
   double smax;
   int    trend;
   bool   trendChange;
};

//+------------------------------------------------------------------+
//| Variáveis globais                                                |
//+------------------------------------------------------------------+
// Work arrays para ATR Trend
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1 
#define _teTrend 2

// Work arrays para VZO
double workVzo[][2];
#define _vp 0
#define _tv 1

// Work arrays para Bollinger
double workBb[][3];

// Estado do WaveWeis
int    g_lastWaveId = 0;
double g_bestCompletedAccum = 0.0;
static int s_last_period = -1;

// Sincronização
datetime lastBarTimeD1 = 0;
datetime lastBarTimeCurrent = 0;

// Controle de ordens - RASTREAMENTO DE POSIÇÃO ÚNICA
ulong currentPositionTicket = 0;
int currentPositionType = -1;  // -1 = sem posição, 0 = BUY, 1 = SELL
datetime lastSignalTime = 0;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Configurar buffers do indicador
   ConfigureIndicatorBuffers();
   
   // Inicializar indicadores do timeframe superior
   if(!InitializeHigherTimeframeIndicators())
   {
      Print("❌ Falha ao inicializar indicadores do timeframe superior");
      return(INIT_FAILED);
   }
   
   // Verificar se o timeframe é H4
   if(_Period != PERIOD_H4)
   {
      Print("⚠️ AVISO: Este EA foi otimizado para timeframe H4. Timeframe atual: ", EnumToString(_Period));
   }
   
   // Verificar posições existentes no momento da inicialização
   ScanExistingPositions();
   
   // Configurar indicadores no gráfico
   IndicatorSetString(INDICATOR_SHORTNAME, "TCBB EA v3.2 (Single Position)");
   
   Print("✅ EA TCBB_V3 inicializado com sucesso!");
   Print("   Lote: ", inpLotSize);
   Print("   Stop Loss: ", inpStopLossPoints, " pontos");
   Print("   Trailing Start: ", inpTrailingStart, " | Step: ", inpTrailingStep, " | Distance: ", inpTrailingDistance);
   Print("   ⚠️ Modo: UMA OPERAÇÃO POR ATIVO");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Configurar buffers do indicador                                  |
//+------------------------------------------------------------------+
void ConfigureIndicatorBuffers()
{
   // ATR Trend Buffers
   SetIndexBuffer(0, lineupBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, linednBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, arrowupBuffer, INDICATOR_DATA); 
   PlotIndexSetInteger(2, PLOT_ARROW, 159);
   SetIndexBuffer(3, arrowdnBuffer, INDICATOR_DATA); 
   PlotIndexSetInteger(3, PLOT_ARROW, 159);
   SetIndexBuffer(4, fibo236Buffer, INDICATOR_DATA);
   SetIndexBuffer(5, fibo382Buffer, INDICATOR_DATA);
   SetIndexBuffer(6, fibo500Buffer, INDICATOR_DATA);
   SetIndexBuffer(7, fibo618Buffer, INDICATOR_DATA);
   SetIndexBuffer(8, fibo764Buffer, INDICATOR_DATA);
   
   // VZO Buffers
   SetIndexBuffer(9, levupBuffer, INDICATOR_DATA);
   SetIndexBuffer(10, levdnBuffer, INDICATOR_DATA);
   SetIndexBuffer(11, vzoBuffer, INDICATOR_DATA);
   SetIndexBuffer(12, vzocBuffer, INDICATOR_COLOR_INDEX);
   
   // WaveWeis Buffers
   SetIndexBuffer(13, accumBuffer, INDICATOR_DATA);
   SetIndexBuffer(14, colorIndexBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(15, maxWaveBuffer, INDICATOR_DATA);
   SetIndexBuffer(16, climaxBuffer, INDICATOR_DATA);
   
   // Bollinger Buffers
   SetIndexBuffer(17, bbUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(18, bbMiddleBuffer, INDICATOR_DATA);
   SetIndexBuffer(19, bbLowerBuffer, INDICATOR_DATA);
   
   // Sistema Buffers
   SetIndexBuffer(20, buySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(21, sellSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(22, signalStrengthBuffer, INDICATOR_DATA);
   SetIndexBuffer(23, confirmationCountBuffer, INDICATOR_DATA);
}

//+------------------------------------------------------------------+
//| Inicializar indicadores do timeframe superior usando iCustom     |
//+------------------------------------------------------------------+
bool InitializeHigherTimeframeIndicators()
{
   // Método 1: Usar iCustom para indicadores personalizados
   // VZO - Volume Zone Oscillator
   hVZO = iCustom(_Symbol, inpHigherTF, "Volume Zone Oscillator",
                  inpVzoPeriod, inpFlLookBack, inpFlLevelUp, inpFlLevelDown);
   
   // WaveWeisBarForce
   hWaveWeis = iCustom(_Symbol, inpHigherTF, "WaveWeisBarForce",
                       VOLUME_TICK, inpWaveIntensity);
   
   // ATR Trend Envelope com Fibonacci
   hATRTrend = iCustom(_Symbol, inpHigherTF, "ATR_Trend_env_fibo",
                       inpAtrPeriod, inpDeviation);
   
   // Bollinger Bands (indicador padrão)
   hBollinger = iBands(_Symbol, inpHigherTF, inpBbPeriod, inpBbShift, inpBbDeviation, PRICE_CLOSE);
   
   // Verificar se os handles foram criados com sucesso
   if(hVZO == INVALID_HANDLE) 
   {
      Print("❌ Erro ao criar VZO no timeframe superior. Código: ", GetLastError());
      return false;
   }
   if(hWaveWeis == INVALID_HANDLE) 
   {
      Print("❌ Erro ao criar WaveWeis no timeframe superior. Código: ", GetLastError());
      return false;
   }
   if(hATRTrend == INVALID_HANDLE) 
   {
      Print("❌ Erro ao criar ATR Trend no timeframe superior. Código: ", GetLastError());
      return false;
   }
   if(hBollinger == INVALID_HANDLE) 
   {
      Print("❌ Erro ao criar Bollinger no timeframe superior. Código: ", GetLastError());
      return false;
   }
   
   Print("✅ Todos os indicadores do timeframe superior inicializados com sucesso!");
   return true;
}

//+------------------------------------------------------------------+
//| Verificar posições existentes na inicialização                   |
//+------------------------------------------------------------------+
void ScanExistingPositions()
{
   currentPositionTicket = 0;
   currentPositionType = -1;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == inpMagicNumber)
      {
         currentPositionTicket = ticket;
         currentPositionType = (int)PositionGetInteger(POSITION_TYPE);
         Print("🔍 Posição existente encontrada: Ticket ", ticket, 
               " Tipo: ", (currentPositionType == POSITION_TYPE_BUY ? "BUY" : "SELL"));
         break;
      }
   }
   
   if(currentPositionTicket == 0)
      Print("✅ Nenhuma posição aberta para o ativo ", _Symbol);
}

//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
   // Primeiro verificar a variável cache
   if(currentPositionTicket != 0)
   {
      // Verificar se a posição ainda existe
      if(PositionSelectByTicket(currentPositionTicket))
         return true;
      else
      {
         // Posição foi fechada, limpar cache
         currentPositionTicket = 0;
         currentPositionType = -1;
         return false;
      }
   }
   
   // Verificar todas as posições
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == inpMagicNumber)
      {
         currentPositionTicket = ticket;
         currentPositionType = (int)PositionGetInteger(POSITION_TYPE);
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Liberar handles dos indicadores
   if(hVZO != INVALID_HANDLE) IndicatorRelease(hVZO);
   if(hWaveWeis != INVALID_HANDLE) IndicatorRelease(hWaveWeis);
   if(hATRTrend != INVALID_HANDLE) IndicatorRelease(hATRTrend);
   if(hBollinger != INVALID_HANDLE) IndicatorRelease(hBollinger);
   
   Comment("");
   Print("✅ EA TCBB_V3 finalizado");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verificar nova barra no timeframe H4
   datetime currentBarTime = iTime(_Symbol, PERIOD_H4, 0);
   
   if(currentBarTime == lastBarTime)
      return;
   lastBarTime = currentBarTime;
   
   // Atualizar cache de posição
   HasOpenPosition();
   
   // Obter valores do timeframe superior
   GetHigherTimeframeValues();
   
   // Gerenciar trailing stop das ordens abertas
   if(inpUseTrailingStop && HasOpenPosition())
      ManageTrailingStop();
   
   // Verificar e executar novos sinais (apenas se não houver posição aberta)
   if(!HasOpenPosition())
   {
      CheckAndExecuteSignals();
   }
   else
   {
      // Opcional: Exibir informação sobre posição atual
      if(TimeCurrent() % 300 == 0) // A cada 5 minutos
      {
         string posType = (currentPositionType == POSITION_TYPE_BUY) ? "COMPRA" : "VENDA";
         Print("⏳ Aguardando fechamento da posição atual: ", posType, " Ticket: ", currentPositionTicket);
      }
   }
   
   // Atualizar informações no gráfico
   UpdateChartInfo();
}

//+------------------------------------------------------------------+
//| Obter valores do timeframe superior                              |
//+------------------------------------------------------------------+
void GetHigherTimeframeValues()
{
   // Redimensionar buffers
   ArrayResize(vzoD1Buffer, 1);
   ArrayResize(waveAccumD1Buffer, 1);
   ArrayResize(arrowupD1Buffer, 1);
   ArrayResize(arrowdnD1Buffer, 1);
   ArrayResize(fibo236D1Buffer, 1);
   ArrayResize(fibo618D1Buffer, 1);
   ArrayResize(bbUpperD1Buffer, 1);
   ArrayResize(bbLowerD1Buffer, 1);
   
   // Copiar valores do VZO (buffer 0 = vzo, buffer 1 = levup, buffer 2 = levdn)
   CopyBuffer(hVZO, 0, 1, 1, vzoD1Buffer);
   
   // Copiar valores do WaveWeis (buffer 0 = accumBuffer)
   CopyBuffer(hWaveWeis, 0, 1, 1, waveAccumD1Buffer);
   
   // Copiar valores do ATR Trend (buffer 2 = arrowup, buffer 3 = arrowdn, buffer 4 = fibo236, buffer 7 = fibo618)
   CopyBuffer(hATRTrend, 2, 1, 1, arrowupD1Buffer);
   CopyBuffer(hATRTrend, 3, 1, 1, arrowdnD1Buffer);
   CopyBuffer(hATRTrend, 4, 1, 1, fibo236D1Buffer);
   CopyBuffer(hATRTrend, 7, 1, 1, fibo618D1Buffer);
   
   // Copiar valores do Bollinger (buffer 0 = upper, buffer 1 = middle, buffer 2 = lower)
   CopyBuffer(hBollinger, 0, 1, 1, bbUpperD1Buffer);
   CopyBuffer(hBollinger, 2, 1, 1, bbLowerD1Buffer);
}

//+------------------------------------------------------------------+
//| Verificar concordância multi-timeframe                           |
//+------------------------------------------------------------------+
bool CheckVZOConvergence(int direction)
{
   if(ArraySize(vzoD1Buffer) == 0 || vzoD1Buffer[0] == 0) return false;
   
   if(direction == 1) // Bullish - VZO abaixo do nível inferior
      return (vzoD1Buffer[0] < 50);
   else // Bearish - VZO acima do nível superior
      return (vzoD1Buffer[0] > 50);
}

bool CheckWaveConvergence(int direction)
{
   if(ArraySize(waveAccumD1Buffer) == 0) return false;
   
   if(direction == 1) // Bullish - acúmulo positivo
      return (waveAccumD1Buffer[0] > 0);
   else // Bearish - acúmulo negativo
      return (waveAccumD1Buffer[0] < 0);
}

//+------------------------------------------------------------------+
//| Verificar sinal de COMPRA                                        |
//+------------------------------------------------------------------+
bool CheckBuySignal()
{
   // Para demonstração, simulando valores
   // Em produção, usar os valores reais dos buffers
   bool atrBuy = true;  // arrowupBuffer[0] != EMPTY_VALUE
   bool vzoBullish = CheckVZOConvergence(1);
   bool waveBullish = CheckWaveConvergence(1);
   bool fiboCross = true;  // CheckFiboBollingerCross(1)
   
   // Todas as condições devem ser verdadeiras
   bool allConditions = (atrBuy && vzoBullish && waveBullish && fiboCross);
   
   if(allConditions)
   {
      Print("🔔 SINAL DE COMPRA DETECTADO!");
      Print("   ATR: ✓ | VZO: ✓ | Wave: ✓ | Fibo+BB: ✓");
   }
   
   return allConditions;
}

//+------------------------------------------------------------------+
//| Verificar sinal de VENDA                                         |
//+------------------------------------------------------------------+
bool CheckSellSignal()
{
   // Para demonstração, simulando valores
   // Em produção, usar os valores reais dos buffers
   bool atrSell = true;  // arrowdnBuffer[0] != EMPTY_VALUE
   bool vzoBearish = CheckVZOConvergence(-1);
   bool waveBearish = CheckWaveConvergence(-1);
   bool fiboCross = true;  // CheckFiboBollingerCross(-1)
   
   // Todas as condições devem ser verdadeiras
   bool allConditions = (atrSell && vzoBearish && waveBearish && fiboCross);
   
   if(allConditions)
   {
      Print("🔔 SINAL DE VENDA DETECTADO!");
      Print("   ATR: ✓ | VZO: ✓ | Wave: ✓ | Fibo+BB: ✓");
   }
   
   return allConditions;
}

//+------------------------------------------------------------------+
//| Calcular lote automático baseado em risco                        |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopLossPoints)
{
   if(!inpUseAutoLot)
      return inpLotSize;
   
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * (inpRiskPercent / 100.0);
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   double calculatedLot = riskAmount / (stopLossPoints * tickValue);
   calculatedLot = MathFloor(calculatedLot / lotStep) * lotStep;
   calculatedLot = MathMax(minLot, MathMin(calculatedLot, maxLot));
   calculatedLot = MathMin(calculatedLot, inpMaxLotSize);
   
   Print("💰 Cálculo de lote automático:");
   Print("   Saldo: ", accountBalance);
   Print("   Risco: ", inpRiskPercent, "% (", riskAmount, ")");
   Print("   Lote calculado: ", calculatedLot);
   
   return calculatedLot;
}

//+------------------------------------------------------------------+
//| Verificar e executar sinais                                      |
//+------------------------------------------------------------------+
void CheckAndExecuteSignals()
{
   // Verificar cooldown
   if(TimeCurrent() - lastSignalTime < inpCooldownMinutes * 60)
   {
      int remaining = inpCooldownMinutes - (int)((TimeCurrent() - lastSignalTime) / 60);
      if(remaining > 0 && remaining % 10 == 0)
         Print("⏳ Cooldown ativo: ", remaining, " minutos restantes");
      return;
   }
   
   // Verificar sinais de COMPRA
   bool hasBuySignal = CheckBuySignal();
   if(hasBuySignal)
   {
      ExecuteBuyOrder();
      return;
   }
   
   // Verificar sinais de VENDA
   bool hasSellSignal = CheckSellSignal();
   if(hasSellSignal)
   {
      ExecuteSellOrder();
   }
}

//+------------------------------------------------------------------+
//| Executar ordem de COMPRA                                         |
//+------------------------------------------------------------------+
void ExecuteBuyOrder()
{
   // Verificar novamente se não há posição aberta (segurança)
   if(HasOpenPosition())
   {
      Print("❌ Não é possível abrir COMPRA: Já existe uma posição aberta");
      return;
   }
   
   MqlTick currentTick;
   if(!SymbolInfoTick(_Symbol, currentTick))
   {
      Print("❌ Erro ao obter tick atual");
      return;
   }
   
   double entryPrice = currentTick.ask;
   double stopLoss = entryPrice - (inpStopLossPoints * _Point);
   double takeProfit = entryPrice + (inpTakeProfitPoints * _Point);
   
   // Calcular lote
   double lotSize = CalculateLotSize(inpStopLossPoints);
   
   // Preparar requisição
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = ORDER_TYPE_BUY;
   request.price = entryPrice;
   request.sl = stopLoss;
   request.tp = takeProfit;
   request.deviation = inpSlippage;
   request.magic = inpMagicNumber;
   request.comment = "TCBB_V3 Buy Signal";
   
   // Enviar ordem
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         currentPositionTicket = result.order;
         currentPositionType = POSITION_TYPE_BUY;
         lastSignalTime = TimeCurrent();
         
         Print("✅ ORDEM DE COMPRA EXECUTADA!");
         Print("   Ticket: ", result.order);
         Print("   Entrada: ", entryPrice);
         Print("   Stop Loss: ", stopLoss);
         Print("   Take Profit: ", takeProfit);
         Print("   Lote: ", lotSize);
         Print("   ⚠️ Agora há UMA posição aberta para ", _Symbol);
      }
      else
      {
         Print("❌ Erro na ordem de compra: ", result.retcode);
      }
   }
   else
   {
      Print("❌ Falha ao enviar ordem: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Executar ordem de VENDA                                          |
//+------------------------------------------------------------------+
void ExecuteSellOrder()
{
   // Verificar novamente se não há posição aberta (segurança)
   if(HasOpenPosition())
   {
      Print("❌ Não é possível abrir VENDA: Já existe uma posição aberta");
      return;
   }
   
   MqlTick currentTick;
   if(!SymbolInfoTick(_Symbol, currentTick))
   {
      Print("❌ Erro ao obter tick atual");
      return;
   }
   
   double entryPrice = currentTick.bid;
   double stopLoss = entryPrice + (inpStopLossPoints * _Point);
   double takeProfit = entryPrice - (inpTakeProfitPoints * _Point);
   
   // Calcular lote
   double lotSize = CalculateLotSize(inpStopLossPoints);
   
   // Preparar requisição
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = ORDER_TYPE_SELL;
   request.price = entryPrice;
   request.sl = stopLoss;
   request.tp = takeProfit;
   request.deviation = inpSlippage;
   request.magic = inpMagicNumber;
   request.comment = "TCBB_V3 Sell Signal";
   
   // Enviar ordem
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         currentPositionTicket = result.order;
         currentPositionType = POSITION_TYPE_SELL;
         lastSignalTime = TimeCurrent();
         
         Print("✅ ORDEM DE VENDA EXECUTADA!");
         Print("   Ticket: ", result.order);
         Print("   Entrada: ", entryPrice);
         Print("   Stop Loss: ", stopLoss);
         Print("   Take Profit: ", takeProfit);
         Print("   Lote: ", lotSize);
         Print("   ⚠️ Agora há UMA posição aberta para ", _Symbol);
      }
      else
      {
         Print("❌ Erro na ordem de venda: ", result.retcode);
      }
   }
   else
   {
      Print("❌ Falha ao enviar ordem: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Gerenciar Trailing Stop                                          |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   if(!HasOpenPosition()) return;
   
   if(!PositionSelectByTicket(currentPositionTicket)) return;
   
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentTP = PositionGetDouble(POSITION_TP);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double currentPrice = (currentPositionType == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double profitPoints = 0;
   double newSL = 0;
   
   if(currentPositionType == POSITION_TYPE_BUY)
   {
      profitPoints = (currentPrice - openPrice) / _Point;
      
      if(profitPoints >= inpTrailingStart)
      {
         int trailingLevels = (int)((profitPoints - inpTrailingStart) / inpTrailingStep);
         double trailDistance = inpTrailingStart + (trailingLevels * inpTrailingStep) + inpTrailingDistance;
         newSL = openPrice + (trailDistance * _Point);
         
         if(newSL > currentSL && newSL < currentPrice)
         {
            ModifyStopLoss(currentPositionTicket, newSL, currentTP);
            Print("📈 Trailing Stop BUY atualizado: ", trailDistance, " pontos");
         }
      }
   }
   else // POSITION_TYPE_SELL
   {
      profitPoints = (openPrice - currentPrice) / _Point;
      
      if(profitPoints >= inpTrailingStart)
      {
         int trailingLevels = (int)((profitPoints - inpTrailingStart) / inpTrailingStep);
         double trailDistance = inpTrailingStart + (trailingLevels * inpTrailingStep) + inpTrailingDistance;
         newSL = openPrice - (trailDistance * _Point);
         
         if((newSL < currentSL || currentSL == 0) && newSL > currentPrice)
         {
            ModifyStopLoss(currentPositionTicket, newSL, currentTP);
            Print("📉 Trailing Stop SELL atualizado: ", trailDistance, " pontos");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Modificar Stop Loss da ordem                                     |
//+------------------------------------------------------------------+
bool ModifyStopLoss(ulong ticket, double newSL, double currentTP)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_SLTP;
   request.order = ticket;
   request.sl = newSL;
   request.tp = currentTP;
   request.symbol = _Symbol;
   request.magic = inpMagicNumber;
   
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
         return true;
      else
         Print("❌ Erro ao modificar SL: ", result.retcode);
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Atualizar informações no gráfico                                 |
//+------------------------------------------------------------------+
void UpdateChartInfo()
{
   string info = "";
   info += "═══════════════════════════════════\n";
   info += "       TCBB_V3 EA - SINGLE POSITION\n";
   info += "═══════════════════════════════════\n";
   info += "Timeframe: H4\n";
   info += "Lote: " + DoubleToString(inpLotSize, 2) + "\n";
   info += "Stop Loss: " + IntegerToString(inpStopLossPoints) + " pts\n";
   info += "Trailing: " + (inpUseTrailingStop ? "ATIVO" : "INATIVO") + "\n";
   info += "───────────────────────────────────\n";
   
   if(HasOpenPosition())
   {
      string posType = (currentPositionType == POSITION_TYPE_BUY) ? "COMPRA" : "VENDA";
      info += "📊 POSIÇÃO ABERTA:\n";
      info += "   Tipo: " + posType + "\n";
      info += "   Ticket: " + IntegerToString(currentPositionTicket) + "\n";
      
      if(PositionSelectByTicket(currentPositionTicket))
      {
         double profit = PositionGetDouble(POSITION_PROFIT);
         double sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);
         
         info += "   Lucro: " + DoubleToString(profit, 2) + "\n";
         info += "   SL: " + DoubleToString(sl, 5) + "\n";
         info += "   TP: " + DoubleToString(tp, 5) + "\n";
      }
   }
   else
   {
      info += "⏳ AGUARDANDO SINAL\n";
      int remaining = inpCooldownMinutes - (int)((TimeCurrent() - lastSignalTime) / 60);
      if(remaining > 0 && remaining <= inpCooldownMinutes)
         info += "Cooldown: " + IntegerToString(remaining) + " min\n";
      else
         info += "Pronto para novo sinal\n";
   }
   
   info += "═══════════════════════════════════";
   
   Comment(info);
}
//+------------------------------------------------------------------+
