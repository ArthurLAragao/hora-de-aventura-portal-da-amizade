# Roteiro de apresentação

## Antes da aula

Abra `project.godot` no Godot 4.7.2. Aguarde a importação normal. O projeto não precisa dos testes ou arquivos de autoria para executar. O ZIP fonte deve ser extraído inteiro; não execute de dentro do ZIP.

## Abas úteis no Godot

1. `Assets/04_Interface/Godot/main_menu.tscn`: F5 demonstra o fluxo inicial.
2. `level_1.tscn`: abertura cooperativa com Finn e Jake.
3. `level_2.tscn`: Fionna e Cake, túnel e passagem.
4. `level_3.tscn`: Marceline e BMO, comunicação por símbolos.
5. `level_4.tscn`: Finn e BMO, transporte e circuito.
6. `level_6.tscn`: três duplas sucessivas e encerramento.

Use F6 para executar a aba de cena atual. F8 para interromper a execução antes de trocar a demonstração. Não apresente uma posição de teste como um percurso concluído.

## Código para mostrar, se solicitado

- `scripts/characters/player.gd`: movimento compartilhado e separação entre personagem/jogador/capacidade.
- `scripts/bridges/jake_bridge.gd`: estados e segurança da ponte.
- `mechanisms/bmo_terminal.gd`: painel e bloqueio apenas do operador.
- `scripts/levels/level_6.gd`: trocas de dupla e preservação do progresso.

Todas as funções mantidas possuem comentários em português. Consulte `CODIGO.md` para encontrar uma função sem procurar em dezenas de arquivos.

## Demonstração curta

Mostre o menu e escolha uma fase. Explique que os dois jogadores usam o mesmo computador. Demonstre uma ação em que cada parceiro contribui, um mecanismo com feedback e uma recuperação segura. Na Fase 6, mostre a troca de dupla e, quando houver tempo para o percurso, a celebração.

Não é necessário abrir todas as funções durante a apresentação. Deixe a documentação disponível e priorize o jogo funcionando.

## Falar com precisão

Há cinco fases integradas e a Fase 5 permanece pendente. Foram realizados testes automatizados de percurso e inspeção de capturas reais; isso não equivale a validar exportação, outros computadores ou todos os cenários possíveis. A otimização reduziu o material dentro do projeto e o trabalho de preparação de recursos, sem alterar os puzzles.
