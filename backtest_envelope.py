import yfinance as yf
import pandas as pd
import numpy as np

def calculate_backtest():
    # 1. Download Data
    # Period: 2025-03-14 to 2026-03-15
    data = yf.download('GC=F', start='2025-03-14', end='2026-03-16', interval='1h')
    if data.empty:
        return "No data found."

    # Pre-process
    df = data.copy()
    df.columns = [col[0] if isinstance(col, tuple) else col for col in df.columns]

    # 2. Indicator Implementation (ATR Trend Envelope)
    inpAtrPeriod = 14
    inpDeviation = 1.5

    df['TR'] = 0.0
    for i in range(1, len(df)):
        df.loc[df.index[i], 'TR'] = max(df.iloc[i]['High'], df.iloc[i-1]['Close']) - min(df.iloc[i]['Low'], df.iloc[i-1]['Close'])

    df['ATR'] = df['TR'].rolling(window=inpAtrPeriod).mean()

    # State variables
    s_min = np.zeros(len(df))
    s_max = np.zeros(len(df))
    trend = np.zeros(len(df))

    for i in range(1, len(df)):
        atr = df.iloc[i]['ATR']
        if pd.isna(atr):
            continue

        dev = atr * inpDeviation
        val_h = df.iloc[i]['High']
        val_l = df.iloc[i]['Low']
        val_c = df.iloc[i]['Close']

        s_max[i] = val_h + dev
        s_min[i] = val_l - dev

        prev_trend = trend[i-1]
        prev_s_max = s_max[i-1]
        prev_s_min = s_min[i-1]

        # Trend detection
        if val_c > prev_s_max and prev_s_max > 0:
            trend[i] = 1
        elif val_c < prev_s_min and prev_s_min > 0:
            trend[i] = -1
        else:
            trend[i] = prev_trend

        # Trailing Support/Resistance
        if trend[i] > 0 and s_min[i] < prev_s_min:
            s_min[i] = prev_s_min
        if trend[i] < 0 and s_max[i] > prev_s_max:
            s_max[i] = prev_s_max

    df['Smin'] = s_min
    df['Smax'] = s_max
    df['Trend'] = trend

    # 3. Strategy Simulation
    balance = 100000.0 # Initial Balance
    risk_percent = 0.01
    rr_ratio = 2.5
    be_trigger_atr = 1.0
    trailing_multiplier = 1.5

    positions = [] # List of active positions
    history = []   # List of closed trades (profits)

    for i in range(2, len(df)):
        # Check Trend Change
        if df.iloc[i]['Trend'] != df.iloc[i-1]['Trend'] and df.iloc[i-1]['Trend'] != 0:
            # Trend changed!
            # Close existing positions first
            for p in positions:
                p['status'] = 'closed'
                p['exit_price'] = df.iloc[i]['Open']
                history.append((p['exit_price'] - p['entry_price']) * p['direction'] * p['lot_size'] * 100)
            positions = []

            # Open new position
            direction = df.iloc[i]['Trend']
            entry_price = df.iloc[i]['Open']

            # SL: Previous trend level
            # If changed to UP (1), SL is prev Smax (resistance)
            # If changed to DOWN (-1), SL is prev Smin (support)
            if direction == 1:
                sl = df.iloc[i-1]['Smax']
            else:
                sl = df.iloc[i-1]['Smin']

            if sl == 0: continue # Skip if no level available

            dist = abs(entry_price - sl)
            if dist == 0: continue

            tp = entry_price + dist * rr_ratio * direction

            # Risk Management: Lot Size
            risk_money = balance * risk_percent
            lot_size = risk_money / (dist * 100) # Gold pip value approx $100 per full lot

            positions.append({
                'entry_price': entry_price,
                'sl': sl,
                'tp': tp,
                'initial_sl': sl,
                'direction': direction,
                'lot_size': lot_size,
                'initial_vol': lot_size,
                'current_vol': lot_size,
                'be_protected': False,
                'p25': False, 'p50': False, 'p75': False,
                'status': 'open'
            })

        # Manage Positions
        high = df.iloc[i]['High']
        low = df.iloc[i]['Low']
        close = df.iloc[i]['Close']
        atr = df.iloc[i]['ATR']

        for p in positions[:]:
            if p['status'] != 'open': continue

            # 1. Stop Loss Hit?
            sl_hit = (p['direction'] == 1 and low <= p['sl']) or (p['direction'] == -1 and high >= p['sl'])
            if sl_hit:
                history.append((p['sl'] - p['entry_price']) * p['direction'] * p['current_vol'] * 100)
                p['status'] = 'closed'
                positions.remove(p)
                continue

            # 2. Take Profit Hit?
            tp_hit = (p['direction'] == 1 and high >= p['tp']) or (p['direction'] == -1 and low <= p['tp'])
            if tp_hit:
                history.append((p['tp'] - p['entry_price']) * p['direction'] * p['current_vol'] * 100)
                p['status'] = 'closed'
                positions.remove(p)
                continue

            # 3. Partial Stages (25, 50, 75%)
            total_dist = abs(p['tp'] - p['entry_price'])
            current_profit = (close - p['entry_price']) * p['direction']
            progress = current_profit / total_dist if total_dist > 0 else 0

            # Stage 1: 25% progress -> Close 25% of initial
            if progress >= 0.25 and not p['p25']:
                close_lot = p['initial_vol'] * 0.25
                history.append((close - p['entry_price']) * p['direction'] * close_lot * 100)
                p['current_vol'] -= close_lot
                p['p25'] = True
                p['sl'] = p['entry_price'] # Lock BE

            # Stage 2: 50% progress -> Close 25% more (total 50%)
            elif progress >= 0.50 and not p['p50']:
                close_lot = p['initial_vol'] * 0.25
                history.append((close - p['entry_price']) * p['direction'] * close_lot * 100)
                p['current_vol'] -= close_lot
                p['p50'] = True

            # Stage 3: 75% progress -> Close 25% more (total 75%)
            elif progress >= 0.75 and not p['p75']:
                close_lot = p['initial_vol'] * 0.25
                history.append((close - p['entry_price']) * p['direction'] * close_lot * 100)
                p['current_vol'] -= close_lot
                p['p75'] = True

            # 4. Break-even (ATR based)
            if not p['be_protected'] and current_profit >= atr * be_trigger_atr:
                p['sl'] = p['entry_price']
                p['be_protected'] = True

            # 5. Trailing Stop (ATR based)
            if p['direction'] == 1:
                new_sl = bid_sim = close - atr * trailing_multiplier
                if new_sl > p['sl']: p['sl'] = new_sl
            else:
                new_sl = ask_sim = close + atr * trailing_multiplier
                if new_sl < p['sl']: p['sl'] = new_sl

    # 4. Metrics Calculation
    if not history:
        return "No trades executed."

    history = np.array(history)
    net_profit = np.sum(history)
    wins = history[history > 0]
    losses = history[history <= 0]

    profit_factor = abs(np.sum(wins) / np.sum(losses)) if len(losses) > 0 else np.inf

    # Sharpe Ratio (daily approximation)
    avg_return = np.mean(history)
    std_return = np.std(history)
    sharpe = (avg_return / std_return) * np.sqrt(252) if std_return > 0 else 0

    payoff = net_profit / len(history)

    print(f"Lucro Líquido Total: {net_profit:.2f} USD")
    print(f"Fator de Lucro: {profit_factor:.2f}")
    print(f"Índice Sharpe: {sharpe:.2f}")
    print(f"Retorno Esperado (Payoff): {payoff:.2f} USD")
    print(f"Total de Negociações (incluindo parciais): {len(history)}")

calculate_backtest()
