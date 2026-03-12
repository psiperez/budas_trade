# Tutorial: Modelagem Baseada em Agentes com Mesa (Python)

Este tutorial fornece um guia passo a passo para criar sua primeira simulação de Modelagem Baseada em Agentes (ABM) usando a biblioteca **Mesa** em Python.

## O que é Mesa?
Mesa é um framework modular para construir, analisar e visualizar modelos baseados em agentes. Ele permite que você crie simulações onde múltiplos "agentes" interagem entre si em um ambiente seguindo regras específicas.

---

## Passo 0: Instalação

Primeiro, você precisa instalar a biblioteca Mesa e suas dependências para visualização:

```bash
pip install mesa matplotlib networkx
```

---

## Passo 1: Criando o Agente

O Agente é a unidade básica da sua simulação. Cada agente é uma instância de uma classe que herda de `mesa.Agent`.

```python
import mesa

class DinheiroAgente(mesa.Agent):
    """Um agente com uma quantidade fixa de dinheiro."""
    def __init__(self, model):
        super().__init__(model)
        self.wealth = 1  # Cada agente começa com 1 unidade de riqueza

    def step(self):
        # O que o agente faz em cada passo da simulação
        if self.wealth > 0:
            # Escolhe um agente aleatório do modelo
            other_agent = self.model.random.choice(self.model.agents)
            if other_agent is not None:
                other_agent.wealth += 1
                self.wealth -= 1
```

---

## Passo 2: Criando o Modelo

O Modelo gerencia os agentes e o ambiente. Ele herda de `mesa.Model`.

```python
class DinheiroModelo(mesa.Model):
    """Um modelo com alguns agentes trocando dinheiro."""
    def __init__(self, n):
        super().__init__()
        self.num_agents = n

        # Criar agentes
        for i in range(self.num_agents):
            a = DinheiroAgente(self)
            # Os agentes são adicionados automaticamente ao AgentSet do modelo no Mesa 2.0+

    def step(self):
        """Avança o modelo por um passo."""
        # O método step do modelo ativa o step de todos os agentes
        self.agents.shuffle_do("step")
```

---

## Passo 3: Adicionando Espaço (Grid)

Muitas vezes, os agentes precisam se mover em um espaço (grade).

```python
class DinheiroAgenteComEspaco(mesa.Agent):
    def __init__(self, model):
        super().__init__(model)
        self.wealth = 1

    def move(self):
        # Pega as posições vizinhas possíveis
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_position = self.model.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)

    def give_money(self):
        # Dá dinheiro para outros agentes na mesma célula
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        if len(cellmates) > 1:
            other = self.model.random.choice(cellmates)
            if other != self:
                other.wealth += 1
                self.wealth -= 1

    def step(self):
        self.move()
        if self.wealth > 0:
            self.give_money()

class DinheiroModeloComEspaco(mesa.Model):
    def __init__(self, n, width, height):
        super().__init__()
        self.num_agents = n
        self.grid = mesa.space.MultiGrid(width, height, True)

        for i in range(self.num_agents):
            a = DinheiroAgenteComEspaco(self)
            # Adiciona o agente a uma célula aleatória do grid
            x = self.random.randrange(self.grid.width)
            y = self.random.randrange(self.grid.height)
            self.grid.place_agent(a, (x, y))

    def step(self):
        self.agents.shuffle_do("step")
```

---

## Passo 4: Coleta de Dados

Para analisar o que acontece, usamos o `DataCollector`.

```python
def compute_gini(model):
    agent_wealths = [agent.wealth for agent in model.agents]
    x = sorted(agent_wealths)
    n = model.num_agents
    B = sum(xi * (n - i) for i, xi in enumerate(x)) / (n * sum(x))
    return 1 + (1 / n) - 2 * B

# No __init__ do modelo:
# self.datacollector = mesa.DataCollector(
#     model_reporters={"Gini": compute_gini},
#     agent_reporters={"Wealth": "wealth"}
# )

# No step do modelo:
# self.datacollector.collect(self)
```

---

## Exemplo Completo e Funcional

Abaixo está o código completo que você pode copiar e executar em um arquivo `.py`.

```python
import mesa
import matplotlib.pyplot as plt

# 1. Definir o Agente
class DinheiroAgente(mesa.Agent):
    def __init__(self, model):
        super().__init__(model)
        self.wealth = 1

    def step(self):
        if self.wealth > 0:
            other_agent = self.model.random.choice(self.model.agents)
            other_agent.wealth += 1
            self.wealth -= 1

# 2. Definir o Modelo
class DinheiroModelo(mesa.Model):
    def __init__(self, n):
        super().__init__()
        self.num_agents = n
        for i in range(self.num_agents):
            DinheiroAgente(self)

        self.datacollector = mesa.DataCollector(
            agent_reporters={"Wealth": "wealth"}
        )

    def step(self):
        self.datacollector.collect(self)
        self.agents.shuffle_do("step")

# 3. Executar a Simulação
modelo = DinheiroModelo(50)
for i in range(100):
    modelo.step()

# 4. Visualizar os resultados
agent_counts = [a.wealth for a in modelo.agents]
plt.hist(agent_counts, bins=range(max(agent_counts)+1))
plt.title("Distribuição de Riqueza após 100 passos")
plt.xlabel("Riqueza")
plt.ylabel("Número de Agentes")
plt.show()
```

---
Este tutorial cobre o básico. Para mais detalhes sobre visualização interativa no navegador e modelos mais complexos, consulte a [documentação oficial do Mesa](https://mesa.readthedocs.io/).
