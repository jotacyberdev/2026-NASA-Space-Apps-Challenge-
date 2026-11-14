# Progresso do projeto

## Fase A - Fundação

Status: concluída

### Implementado

- Estrutura inicial do projeto Godot.
- Cena do mapa marciano com terreno e espaço para estruturas.
- Personagem astronauta com movimento em oito direções.
- Colisões com bordas e obstáculos.
- Câmera acompanhando a personagem.
- Cenário provisório com silhuetas de estruturas e elementos de visual marciano.

## Fase B - Interface e experiência inicial

Status: implementada no código, mas não validada em runtime porque o executável do Godot não foi detectado no ambiente atual.

### Implementado

- Tela inicial com opções de Novo Jogo, Carregar Jogo, Configurações, Créditos e Sair.
- Criação da astronauta com nome, gênero, mascote e dificuldade.
- Validação de nome com limite entre 2 e 16 caracteres.
- Introdução da história com quatro páginas e botão de pular.
- HUD inicial com retrato, atributos, objetivo, dia, sol e horário.
- Integração do HUD ao cenário de gameplay.
- Autoload de estado do jogo para manter dados da partida em fase inicial.

### Arquivos criados

- scenes/menus/main_menu.tscn
- scenes/menus/character_creation.tscn
- scenes/story/introduction.tscn
- scenes/ui/hud.tscn
- scripts/game_manager.gd
- scripts/menus/main_menu.gd
- scripts/menus/character_creation.gd
- scripts/story/introduction.gd
- scripts/ui/hud.gd

### Arquivos alterados

- project.godot
- scenes/world/mars_base.tscn

### Validação real realizada

- Projeto encontrado no diretório do workspace.
- [project.godot](project.godot) está presente.
- Não foi localizado nenhum executável do Godot 4.7.2 em: Program Files, Program Files (x86), AppData/Local/Programs ou no PATH do Windows.
- Sem a instalação do Godot, não é possível abrir o projeto, importar recursos, validar cenas, verificar sintaxe GDScript nem executar a demo.

### Próximo passo necessário

- Instalar o Godot 4.7.2 em um caminho padrão do Windows ou informar o caminho existente do executável.
- Depois disso, abrir o projeto pelo arquivo [project.godot](project.godot) e validar a execução real.

## Fase C - Sobrevivência

Status: implementada em código; ainda sem validação de runtime no Godot.

### Implementado até agora

- Relógio de jogo avança um minuto por segundo real durante a cena do mapa.
- Oxigênio, energia, fome e água diminuem gradualmente.
- Oxigênio, fome ou água em zero causam dano gradual à vida.
- A dificuldade ajusta consumo e dano: fácil 0,5x, normal 1x e difícil 1,5x.
- O HUD recebe sinal de alteração do estado da partida e atualiza os valores.
- Os atributos continuam limitados entre 0 e 100.

### Pendente

- Validar scripts, cenas e execução no Godot 4.7.2.
- Testar passagem de hora/dia e os efeitos de cada dificuldade em runtime.
- Balancear os valores de consumo após teste jogável.

## Demo jogável - Tutorial do Dia 1

Status: implementada em código; aguardando teste ponta a ponta no Godot 4.7.2.

### Implementado

- Nova partida limpa os dados anteriores depois que o perfil é confirmado; nome, gênero, mascote e dificuldade são salvos.
- Introdução completa ou pulada leva ao mapa e registra a opção escolhida.
- Carregar Jogo restaura o salvamento, incluindo atributos, mochila, etapa do tutorial, estruturas, horário e posição.
- Salvamento manual no HUD e autosalvamento periódico durante a partida.
- Baú inicial com metal, polímero, sementes, ração, água e kit médico.
- Mochila de 24 espaços, pilhas limitadas, barra rápida e consumo seguro de ração, água e kit médico.
- Habitat, estufa e mineradora nível 1 construíveis somente na etapa correta e com materiais suficientes.
- Interação com rover, exploração por duas escolhas textuais, recompensa única e retorno caminhando ao acampamento.
- Tutorial concluído ao construir a mineradora; construções concluídas ficam visualmente destacadas no mapa.
- Retrato placeholder muda conforme o gênero selecionado.
- Diário científico com seis entradas, categorias e fontes oficiais da NASA: atmosfera, MOXIE, água, tempestades de poeira, regolito/percloratos e cultivo em microgravidade.
- Botões do HUD para mochila, construção, mapa, diário e configurações/salvamento.

### Verificações feitas

- O VS Code não reportou diagnósticos nos scripts GDScript e cenas alterados.
- Isso não equivale a importar ou executar cenas no motor Godot.
- Não foi possível confirmar os executáveis Godot 4.7.2 nesta sessão: os comandos de terminal disponíveis ficaram em estado de continuação e não retornaram caminho nem versão.
- Portanto, nenhum dos testes de gameplay abaixo está declarado como executado.

### Testes de runtime pendentes

- Novo jogo, escolhas de personagem, introdução e entrada no mapa.
- Coleta do baú, contagens da mochila e uso/ausência de itens na barra rápida.
- Construção do habitat e estufa, exploração, recompensa única, retorno e construção da mineradora.
- Conclusão do tutorial, salvamento, encerramento e carregamento da partida.

### Como executar

1. Abra `project.godot` com o editor Godot 4.7.2.
2. Aguarde a importação dos recursos.
3. Pressione F6 para testar a cena atual ou F5 para iniciar pelo menu e jogar o percurso completo.
4. No mapa, mova-se com WASD ou setas e pressione E quando o aviso de interação aparecer. Use o menu Construção para erguer estruturas.

### Como exportar para Windows

1. No Godot, abra **Project > Export** e crie um preset **Windows Desktop**.
2. Se o editor solicitar, instale os export templates da mesma versão 4.7.2.
3. Escolha um caminho de saída, por exemplo `build/MarsLastSurvivor.exe`, e exporte o projeto.

Nenhum executável foi gerado nesta sessão. O caminho dos binários Godot e a validação ponta a ponta continuam pendentes.

## Auditoria técnica de entrega

Data: 2026-11-14

### Problemas encontrados e corrigidos

- `can_add_items()` estava declarado dentro de `add_item()`; foi movido ao escopo principal do GameManager.
- Adição de lote agora valida IDs, quantidades, pilhas e espaços livres antes de qualquer mutação. Baú e recompensa usam a operação validada sem distribuição parcial.
- Remoção verifica a quantidade total antes de alterar slots; construção desconta os materiais após validar integralmente receita, ordem e estado da estrutura.
- `mark_tutorial_complete()` redundante foi removido; construir a mineradora é a única rota para o estado final.
- Salvamento passou a escrever em temporário, preservar backup apenas de arquivo válido e validar todos os campos antes de alterar o estado durante o carregamento. O backup pode ser usado se o arquivo principal estiver inválido.
- `mars_base.tscn` agora tem uma única atribuição `script` no nó raiz e contagem de recursos coerente.
- Retorno ao acampamento deixou de avançar automaticamente; o jogador precisa se aproximar e pressionar E.
- Modais bloqueiam movimento, atalhos, cliques em controles ao fundo e pausam o relógio de sobrevivência.
- O HUD cria os 24 slots do inventário; consumíveis não são gastos se o atributo correspondente já estiver cheio.
- A indentação de `introduction.gd` foi padronizada em tabs.
- Créditos incluem os cinco integrantes solicitados, sem atribuição de cargos.

### Sistemas preservados e aprimorados

- Mapa, personagem, colisões, câmera e movimento existentes foram mantidos.
- O ciclo do tutorial, receitas, escolha cuidadosa/rápida, recompensa única, retorno manual e construção final continuam no GameManager existente.
- HUD, diário científico, sinais e autosalvamento foram mantidos e integrados às validações.

### Verificações efetivamente realizadas

- Diagnósticos disponíveis no VS Code: nenhum erro reportado nos scripts e cenas consultados.
- Referências `res://` examinadas: caminhos de cenas/scripts apontam para arquivos presentes no projeto.
- Referências de métodos revisadas: não há chamadas para `mark_tutorial_complete()`; a cena do mapa referencia o script raiz uma única vez.
- A montagem do inventário foi revisada no código e contém um botão por cada um dos 24 espaços.
- O usuário informou que validou manualmente o tutorial. Os resultados individuais por teste não foram detalhados nesta documentação.

### Limite da validação desta sessão

- Não foi possível confirmar o caminho nem a versão do executável Godot nesta sessão. O terminal PowerShell disponível permaneceu preso em continuação multilinha/erro do PSReadLine; por isso não consegui executar a importação headless nem abrir o editor.
- A validação manual do fluxo foi reportada pelo usuário; não foi reproduzida nem observada diretamente por esta sessão.
- Não há registro individual sobre save corrompido, inventário cheio, extremos de atributos ou balanceamento de dificuldade.

### Pendências conhecidas

- Confirmar/importar com Godot 4.7.2 nesta máquina e resolver quaisquer erros que só o parser/runtime do motor revelar.
- Registrar separadamente resultados de save corrompido, inventário cheio, backup e extremos de atributos, caso esses testes façam parte do aceite.
- Confirmar o conteúdo e os links científicos em execução; nenhum registro do diário é obrigatório para concluir o tutorial.
- Ajustar balanceamento e layout visual se a validação manual tiver encontrado problemas.

### Execução e exportação

- Abrir `project.godot` no Godot 4.7.2, aguardar a importação e pressionar F5 para iniciar pelo menu.
- Para exportar: criar um preset **Windows Desktop** em **Project > Export**, garantir os templates correspondentes à versão do editor e exportar o executável. Esta sessão não gerou um `.exe`.


## Atualização da Identidade Visual e Telas (Novembro 2026)

- **Identidade Visual Quente:** Aplicada a paleta marrom-terroso e laranja-âmbar (`WarmSciFiTheme`) ao HUD, barras de atalho, atalhos rápidos, títulos, descrições, modais (Inventário, Fabricação, Construção, Missões, Diário) e ao Radar/Mapa marciano.
- **Tela de Criação de Personagem:** Refatorados estilos dos botões de seleção, campo de texto (LineEdit) e painéis para a identidade visual aquecida.
- **Tela de Introdução:** Ilustrações vetoriais, céu, estação e elementos ajustados para paleta quente e cinemática alinhada ao tema do jogo.
- **Polimento e Estabilidade:** Verificadas todas as referências de nós e chamadas de método nos scripts `mars_base.gd`, `mars_radar.gd`, `hud.gd` e `character_creation.gd`, garantindo ausência de referências nulas no Godot 4.x.
