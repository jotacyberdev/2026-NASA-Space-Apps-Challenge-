# Mars: Last Survivor

## Fase A - Fundação

Este projeto foi iniciado para cumprir a primeira fase obrigatória do tutorial do jogo.

### Objetivos desta fase

- Criar a cena do mapa marciano.
- Criar a cena da astronauta.
- Implementar movimentação em oito direções.
- Garantir colisões com paredes e obstáculos.
- Manter a câmera seguindo a astronauta.
- Conter um cenário provisório com espaço para futuro desenvolvimento das estruturas.

### Diretrizes aplicadas

- Projeto em Godot 4 com GDScript.
- Cenário top-down em visão superior.
- Personagem com movimentação básica e colisão.
- Câmara seguindo o jogador.
- Ambiente marciano com terreno, rochas, barreiras e silhuetas de estruturas.

### Estado atual

A estrutura funcional básica do jogo está pronta para expansão na fase B.

## Fase B - Interface e experiência inicial

A Fase B implementa o menu inicial, a criação da astronauta, a introdução da história e o HUD integrado ao mapa de Marte. O estado da partida é mantido pelo autoload `GameManager`.

## Fase C - Sobrevivência

### Objetivos

- Avançar o relógio de jogo enquanto a partida está no mapa.
- Consumir oxigênio, energia, fome e água gradualmente.
- Aplicar dano à vida quando oxigênio, fome ou água chegarem a zero.
- Ajustar a intensidade do consumo pela dificuldade selecionada.
- Atualizar o HUD sempre que o estado da partida mudar.

### Regras iniciais

- Um segundo real equivale a um minuto no jogo.
- No modo normal, por hora de jogo, oxigênio diminui 5 pontos, energia 3, fome 2 e água 3,5.
- No modo fácil, o consumo e o dano de sobrevivência são reduzidos pela metade; no difícil, aumentam em 50%.
- Oxigênio zerado causa 4 pontos de dano por hora; fome zerada causa 1,5; água zerada causa 2.
- Todos os atributos permanecem limitados ao intervalo de 0 a 100.
- O relógio e o consumo só avançam na cena do mapa.

Estes valores são parâmetros iniciais de balanceamento e devem ser ajustados após testes de gameplay.

## Demo jogável - Tutorial do Dia 1

### Percurso

1. Recolher os suprimentos no baú ao lado do ponto inicial.
2. Construir o Habitat nível 1.
3. Construir a Estufa nível 1.
4. Interagir com o rover e escolher uma abordagem de exploração.
5. Receber peças e metal uma única vez e retornar à área central do acampamento.
6. Construir a Mineradora nível 1 e concluir o tutorial.

### Regras de inventário e construção

- A mochila possui 24 espaços com pilhas limitadas a 99 unidades.
- Os materiais são removidos somente depois de validar a receita completa.
- A ordem de construção é controlada pelo estado do tutorial.
- A recompensa da exploração não pode ser reclamada duas vezes.
- Ração, água engarrafada e kit médico só podem ser consumidos quando presentes na mochila.
- O progresso, inventário, atributos, posição e etapa do tutorial são gravados no arquivo de salvamento.

### Diário científico

O diário integrado ao HUD inclui registros curtos de atmosfera, MOXIE, água, tempestades de poeira, regolito/percloratos e cultivo espacial. Cada registro exibe categoria e link para uma página oficial da NASA.
