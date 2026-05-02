# Relatório de Vulnerabilidades e Sugestões de Melhoria

Este documento detalha as vulnerabilidades de segurança e áreas de melhoria identificadas no código do projeto.

## 1. Vulnerabilidades Corrigidas

### 1.1 Injeção de Comando (Command Injection)
**Status: CORRIGIDO**
**Arquivos:**
- `bot/heranca_usuario/passa_var.php`
- `bot/heranca_profissional/passa_var.php`

**Correção:** Implementado o uso de `escapeshellarg()` para todos os parâmetros passados via linha de comando.

---

### 1.2 Credenciais Expostas (Hardcoded Credentials)
**Status: CORRIGIDO**
**Arquivos:**
- `bot/conecta_pdo.php`
- `bot/heranca_usuario/recebe_diario.py`
- `bot/heranca_profissional/recebe_diario.py`

**Correção:** As credenciais foram movidas para `db_config.php` e `db_config.py`, que agora utilizam variáveis de ambiente com fallbacks de placeholders. Criado `.env.example`.

---

### 1.3 Cross-Site Scripting (XSS)
**Status: CORRIGIDO**
**Arquivos:**
- `bot/heranca_usuario/index_negociador.php`
- `bot/heranca_usuario/recebe_diario.py`
- `bot/heranca_profissional/ce_1b.php`

**Correção:** Implementado `htmlspecialchars()` na exibição de dados vindos do banco de dados ou de entradas de usuários.

---

### 1.4 Local File Inclusion (LFI)
**Status: CORRIGIDO**
**Arquivos:**
- `bot/heranca_profissional/ce_1b.php`
- `bot/heranca_profissional/ce_1b_mod.php`

**Correção:** Adicionada validação de entrada e sanitização (regex) antes de incluir arquivos dinamicamente.

---

### 1.5 Uso Inadequado de `addslashes`
**Arquivo:** `bot/protecao3.php`

**Descrição:**
O uso de `addslashes()` global em `$_POST` é uma prática obsoleta e insuficiente para prevenir injeção de SQL em todos os cenários. O ideal é o uso exclusivo de prepared statements (que já são usados em alguns lugares com PDO).

---

## 2. Sugestões de Melhoria e Boas Práticas

### 2.1 Arquitetura e Estrutura
- **Configuração Centralizada:** Mover credenciais para variáveis de ambiente ou um arquivo de configuração fora da raiz pública do servidor.
- **Modularização do Python:** O script Python faz muitas coisas ao mesmo tempo (DB, tradução, análise de sentimento, geração de gráficos e arquivos). Seria melhor separar essas responsabilidades.
- **Tratamento de Erros:** O script Python não possui blocos `try-except`, o que pode causar erros 500 ou quebras silenciosas no PHP caso a tradução ou o banco falhem.

### 2.2 Desempenho e Confiabilidade
- **Tradução:** A biblioteca `googletrans` é uma implementação não oficial que faz web scraping do Google Translate e pode falhar devido a limites de taxa (rate limit). Recomenda-se o uso de APIs oficiais (Google Cloud Translation, DeepL) ou processamento local (NLTK/Spacy com modelos PT).
- **Geração de Arquivos:** O script gera arquivos `.php` e `.html` para cada usuário. Isso é ineficiente e difícil de manter. O ideal seria que o PHP lesse os dados (ou a imagem) e renderizasse o template dinamicamente.

### 2.3 Interface e UX
- Uso de bibliotecas de frontend mais modernas. O Bootstrap 3 está datado.
- Melhorar a validação de formulários no lado do cliente e do servidor.
