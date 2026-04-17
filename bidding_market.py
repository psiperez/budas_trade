import mesa

"""
Modelo de Mercados de Licitação (Bidding Markets)
Inspirado no modelo Bidding Market da biblioteca do NetLogo.

Este modelo simula um mercado simples onde compradores e vendedores interagem
para negociar bens. Os preços se ajustam dinamicamente com base no sucesso
ou falha das transações.
"""

class Vendedor(mesa.Agent):
    """
    Representa um vendedor no mercado.
    Possui um preço de venda (asking price) e um inventário de produtos.
    """
    def __init__(self, model, preco_inicial, inventario):
        super().__init__(model)
        self.preco = preco_inicial
        self.inventario = inventario
        self.vendeu_nesta_rodada = False

    def ajustar_preco(self):
        """
        Ajusta o preço para a próxima rodada.
        Se vendeu, tenta aumentar o lucro subindo o preço.
        Se não vendeu, baixa o preço para atrair compradores.
        """
        if self.vendeu_nesta_rodada:
            self.preco += 0.02  # Aumenta o preço se houve venda
        else:
            # Diminui o preço se não houve venda, mantendo um mínimo de 0.01
            self.preco = max(0.01, self.preco - 0.02)

        # Reseta o status para a próxima rodada
        self.vendeu_nesta_rodada = False

class Comprador(mesa.Agent):
    """
    Representa um comprador no mercado.
    Possui uma expectativa de preço máximo e uma quantidade de dinheiro (riqueza).
    """
    def __init__(self, model, expectativa_inicial, riqueza):
        super().__init__(model)
        self.expectativa = expectativa_inicial
        self.riqueza = riqueza
        self.comprou_nesta_rodada = False

    def ajustar_expectativa(self):
        """
        Ajusta a expectativa de preço.
        Se comprou, tenta pagar menos na próxima vez (baixa expectativa).
        Se não conseguiu comprar, aceita pagar mais (sobe expectativa).
        """
        if self.comprou_nesta_rodada:
            self.expectativa = max(0.01, self.expectativa - 0.02)
        else:
            self.expectativa += 0.02

        # Reseta o status para a próxima rodada
        self.comprou_nesta_rodada = False

class MercadoModelo(mesa.Model):
    """
    O modelo que gerencia os agentes e a simulação do mercado.
    """
    def __init__(self, n_vendedores, n_compradores):
        super().__init__()
        self.num_vendedores = n_vendedores
        self.num_compradores = n_compradores

        # Criar vendedores com preços e estoques aleatórios
        for i in range(self.num_vendedores):
            Vendedor(self,
                     preco_inicial=self.random.uniform(0.5, 1.5),
                     inventario=self.random.randint(10, 20))

        # Criar compradores com expectativas e riquezas aleatórias
        for i in range(self.num_compradores):
            Comprador(self,
                      expectativa_inicial=self.random.uniform(0.5, 1.5),
                      riqueza=self.random.uniform(50, 100))

        # Coletor de dados para analisar o mercado
        self.datacollector = mesa.DataCollector(
            model_reporters={
                "Preco_Medio_Venda": lambda m: sum([a.preco for a in m.agents if isinstance(a, Vendedor)]) / m.num_vendedores,
                "Expectativa_Media": lambda m: sum([a.expectativa for a in m.agents if isinstance(a, Comprador)]) / m.num_compradores
            }
        )

    def step(self):
        """
        Executa um passo da simulação.
        """
        # 1. Coletar dados do estado atual
        self.datacollector.collect(self)

        # 2. Obter listas de agentes
        vendedores = [a for a in self.agents if isinstance(a, Vendedor)]
        compradores = [a for a in self.agents if isinstance(a, Comprador)]

        # 3. Embaralhar para garantir interações aleatórias (como no NetLogo)
        self.random.shuffle(vendedores)
        self.random.shuffle(compradores)

        # 4. Tentar realizar transações pareando compradores e vendedores
        # Usamos zip para criar pares. Se as listas tiverem tamanhos diferentes,
        # o zip para na menor.
        for comprador, vendedor in zip(compradores, vendedores):
            # Condições para venda:
            # - Vendedor tem estoque
            # - Comprador tem dinheiro suficiente para o preço do vendedor
            # - Preço do vendedor está dentro da expectativa do comprador
            if (vendedor.inventario > 0 and
                comprador.riqueza >= vendedor.preco and
                vendedor.preco <= comprador.expectativa):

                # Realizar transação
                comprador.riqueza -= vendedor.preco
                vendedor.inventario -= 1
                vendedor.vendeu_nesta_rodada = True
                comprador.comprou_nesta_rodada = True

        # 5. Todos os agentes ajustam seus comportamentos para a próxima rodada
        for agente in self.agents:
            if isinstance(agente, Vendedor):
                agente.ajustar_preco()
            elif isinstance(agente, Comprador):
                agente.ajustar_expectativa()

# Exemplo de execução
if __name__ == "__main__":
    # Cria o mercado com 10 vendedores e 10 compradores
    modelo = MercadoModelo(10, 10)

    print("Iniciando Simulação de Mercado...")
    print(f"{'Rodada':<10} | {'Preço Médio':<15} | {'Exp. Média':<15}")
    print("-" * 45)

    for i in range(50):
        modelo.step()
        dados = modelo.datacollector.get_model_vars_dataframe()
        preco = dados["Preco_Medio_Venda"].iloc[-1]
        exp = dados["Expectativa_Media"].iloc[-1]
        if i % 5 == 0:
            print(f"{i:<10} | {preco:<15.2f} | {exp:<15.2f}")

    print("-" * 45)
    print("Simulação concluída.")
