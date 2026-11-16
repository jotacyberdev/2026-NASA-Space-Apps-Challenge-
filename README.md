# 🚀 Mars: Last Survivor

Um jogo de sobrevivência, exploração e construção de base em visão superior (*top-down*) ambientado na superfície hostil de Marte, desenvolvido na **Godot Engine 4.7** com **GDScript**.

---

## 📖 Sobre o Projeto

Em **Mars: Last Survivor**, você assume o papel de um(a) astronauta isolado(a) no Planeta Vermelho após uma queda durante a reentrada atmosférica. Para sobreviver às condições extremas de Marte, é preciso gerenciar seus recursos vitais, explorar os arredores com auxílio de um rover, construir módulos essenciais da base e consultar registros científicos reais sobre a exploração marciana.

---

## ✨ Funcionalidades Principais

* **Personalização Inicial:** Escolha o nome do(a) astronauta (2 a 16 caracteres), gênero, mascote de companhia (**Laika** ou **Ham**) e o nível de dificuldade (**Fácil**, **Normal** ou **Difícil**).
* **Introdução Narrativa:** Sequência ilustrada de 4 páginas contextualizando o acidente e a chegada ao planeta.
* **Sistema de Sobrevivência Dinâmico:**
  * Relógio interno onde **1 segundo real = 1 minuto no jogo**.
  * Monitoramento contínuo de **Vida, Oxigênio, Energia, Fome e Água**.
  * Dano gradual quando oxigênio, fome ou água chegam a zero, escalonado pela dificuldade selecionada (`0.5x` no Fácil, `1.0x` no Normal e `1.5x` no Difícil).
* **Inventário e Consumo:** Mochila com 24 espaços (pilhas de até 99 unidades), barra de acesso rápido (`[1]` a `[8]`) e uso seguro de ração, água engarrafada e kit médico.
* **Construção de Base:** Erga estruturas essenciais como **Habitat**, **Estufa** e **Mineradora** conforme avança nas etapas de desenvolvimento da colônia.
* **Exploração com Rover:** Eventos de escolha textual para coleta estratégica de peças e metais pela superfície marciana.
* **Diário Científico Integrado:** 6 registros educativos sobre a atmosfera de Marte, experimento MOXIE, água, tempestades de poeira, regolito/percloratos e cultivo espacial, com links diretos para fontes oficiais da **NASA**.
* **Sistema de Salvamento Seguro:** Salvamento manual e *autosave* periódico com backup automático e validação de integridade de dados.

---

## 🎮 Controles

| Tecla / Ação | Função |
| :--- | :--- |
| **`W` `A` `S` `D`** ou **Setas** | Movimentação em 8 direções |
| **`E`** | Interagir com baús, rover e pontos de retorno |
| **`1` a `8`** | Usar itens da barra de acesso rápido (*Hotbar*) |
| **`ESC`** | Fechar janelas e modais |
| **Mouse** | Navegação nos menus, inventário, construção e diário científico |

---

## 🛠️ Tecnologias Utilizadas

* **Engine:** [Godot Engine 4.7](https://godotengine.org) (Renderer Mobile / Pixel-perfect `TEXTURE_FILTER_NEAREST`)
* **Linguagem:** GDScript
* **Resolução Base:** 1920x1080 (`canvas_items` / `expand`)

---

## 🚀 Como Executar o Projeto

1. Clone este repositório:
   ```bash
   git clone https://github.com
   ```
2. Abra a **Godot Engine 4.7**.
3. Na tela inicial do Project Manager, clique em **Importar** e selecione o arquivo `project.godot` na raiz do projeto.
4. Aguarde a importação dos *assets* e pressione **`F5`** para iniciar o jogo pelo Menu Principal (ou **`F6`** para testar a cena atual).

---

## 📁 Estrutura do Projeto

```text
├── assets/          # Sprites de personagens, construções e interface
├── scenes/
│   ├── menus/       # Menu principal e criação de personagem
│   ├── story/       # Introdução narrativa
│   ├── ui/          # HUD e elementos de interface
│   └── world/       # Mapa da base marciana e estruturas
├── scripts/         # Lógica do GameManager, sobrevivência, HUD e entidades
├── GAME_SPEC.md     # Especificações de design e balanceamento
├── PROGRESS.md      # Histórico de desenvolvimento e auditoria técnica
└── project.godot    # Configurações principais do projeto Godot
```

---

## 👥 Créditos

Desenvolvido por:
Joao Pedro 

---

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais/acadêmicos. Consulte o arquivo `LICENSE` (se aplicável) para mais detalhes.
