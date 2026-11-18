# Telas e instruções — item de 05/11

Implementado em 03/11/2026 no projeto otimizado atual, Godot 4.7.2. O cronograma fornecido pede **tela inicial, orientações e tela de encerramento conectadas ao jogo**. A adaptação a janelas diferentes foi solicitada pelo usuário. Este documento não presume exigência de exportação, pacote ZIP novo ou controle físico para esse item.

## O que está integrado

| Item | Implementação | Evidência |
|---|---|---|
| Tela inicial | Arte e logo existentes preservados; Jogar, Como jogar, estado real de som e foco por teclado. | `Assets/04_Interface/Godot/main_menu.tscn`, `screen_controller.gd` |
| Seleção | Seis fases com nome e dupla; início de foco na primeira fase; retorno ao menu. | `phase_select.tscn`, `scripts/ui/phase_select.gd` |
| Orientações | Três páginas: Em dupla, Controles e Amigos, com comandos reais e retratos existentes. | `Assets/04_Interface/Godot/instructions.tscn`, `scripts/ui/instructions_screen.gd` |
| Orientações dentro do jogo | F1 ou botão Controles abre a mesma orientação, identifica P1/P2 e conserva a fase atual. | `scripts/ui/game_screens.gd` |
| Conclusão intermediária | Fases 1–5 oferecem Próxima fase, Repetir, Fases e Menu após a condição original de conclusão. | `GameScreens/ScreenLayer/Result` |
| Encerramento final | Celebração existente com os seis personagens, enquadramento proporcional e retorno à seleção ou menu. | `scripts/ui/friendship_ending.gd` |

## Fluxo de telas

```text
Tela inicial ─ Jogar ─ Seleção ─ Fase escolhida
     │                   │          │
     └ Como jogar        └ Menu     ├ F1 / Controles ─ Orientações ─ Voltar ao jogo
           │                        │
           └ Menu / Escolher fase    └ Conclusão em dupla
                                         │
                     Fases 1–5: Próxima fase / Repetir / Fases / Menu
                     Fase 6: Celebração ─ Seleção de fases / Menu
```

Próxima fase é uma escolha explícita e avança 1 → 2 → 3 → 4 → 5 → 6. Não há carregamento automático que pule fases nem acesso a uma Fase 7. O seletor mantém acesso independente às seis fases, inclusive pelo editor com F6.

## Orientações e preservação de estado

As instruções permanecem opcionais; não voltaram as dicas flutuantes, ordens ou faixas de tutorial sobre os cenários. Os diálogos aprovados permanecem.

Ao abrir a ajuda dentro da fase, a simulação pausa para leitura. Posições, desafios resolvidos, cristal, interações e estados da dupla permanecem. A conversa é temporariamente retirada da frente das orientações e restaurada ao voltar. Nenhum personagem é teleportado ou recriado para consultar a ajuda.

Esc/F1 ou Voltar ao jogo fecha a leitura; o sistema espera soltar as teclas dos jogadores antes de retomar para evitar saltos ou confirmações acidentais. F2 durante as orientações reinicia pelo mecanismo original da fase e preserva os papéis. Não é possível interromper uma recuperação ou uma troca de dupla com a abertura da ajuda.

A operação do terminal de BMO continua sendo local: só BMO fica bloqueado enquanto usa seu painel. A pausa global ocorre apenas quando alguém abre voluntariamente a tela de orientações. Ao fechar essa tela, o terminal pode continuar aberto e não recebe um símbolo indevido.

Repetir reinicia a fase, e escolher Menu/Fases deixa a execução atual. Não foi criado save persistente. A continuação transfere somente o papel dos jogadores para a dupla seguinte; não transfere estados temporários nem inventa coleta global de cristais. Na Fase 2, a propriedade de Cake é o complemento do papel principal, e essa diferença é tratada explicitamente.

## Responsividade e leitura

- Resolução global e câmera do projeto preservadas.
- Composições das telas usam escala uniforme e centralização, mantendo proporções das imagens. As margens das telas de menu usam a paleta escura existente.
- Validado em janelas de 800×450, 1024×768, 1280×720 e 1920×1080. Formatos diferentes de 16:9 podem usar margens para preservar a proporção.
- Textos de orientação são editáveis, em fonte NotoSans existente; retratos e fundos usam assets originais. O PNG antigo de instruções foi preservado, sem ser usado para apresentar comandos desatualizados.
- Botões têm foco visível por teclado. O estado de som reflete o barramento Master e permanece coerente ao retornar ao menu no mesmo processo.
- O mínimo de 800×450 foi verificado quanto ao enquadramento. Para leitura mais confortável, prefira 1152×648 ou maior; a legibilidade para crianças ainda precisa de avaliação humana.

## Testes e evidências

O QA de telas (`verify_screens`) exercitou navegação com teclas reais de GUI, alternância de som, páginas, enquadramento, ausência de corte nos espaços reservados, abertura/fechamento da ajuda nas seis fases com P1/P2 invertidos, retorno com tecla segurada, F2 durante leitura, terminal aberto e pontes de Jake/Cake com parceiro apoiado.

Os finais preparados nos testes de componente servem para conferir botões e enquadramento; não são apresentados como resolução normal dos puzzles. Os percursos completos de cada fase foram executados separadamente pelas suítes de jornada, sem reposicionamento para concluir. Regressões de recuperação, desafios, diálogos, apresentação limpa e menu também foram executadas.

Capturas reais foram inspecionadas para menu, seletor, três páginas, ajuda na fase, conclusão e celebração em mais de uma proporção. Foram corrigidos antes da entrega: espaço insuficiente para texto, largura mínima indevida antes da quebra de linha e callbacks de redimensionamento durante a saída de cena.

Áudio foi desativado no QA: o botão de som foi verificado pelo estado do barramento, não por audição. Não houve teste com duas pessoas reais/crianças, build exportado, controle físico ou outro computador. Esta rodada é candidata à avaliação manual; não equivale à aprovação humana nem à conclusão de todas as etapas futuras da disciplina.

## Arquivos e manutenção

- `scripts/ui/menu_layout.gd`: componentes visuais locais, foco e ajuste proporcional.
- `scripts/ui/instructions_screen.gd`: conteúdo das três páginas; uso independente e incorporado na fase.
- `scripts/ui/game_screens.gd`: ajuda contextual ao papel, retorno seguro, conclusão e navegação.
- `screen_controller.gd`: menu existente e estado real de som.
- `phase_select.gd`: nomes, duplas e foco inicial.
- `friendship_ending.gd`: celebração preservada com redimensionamento e teclado.
- `clean_phase_presentation.gd`: apenas acrescentada a permissão das novas telas opcionais, mantendo os tutoriais externos ocultos.
- Cada `level_1.tscn` a `level_6.tscn` recebeu somente o nó/recurso GameScreens; terreno, instâncias e propriedades anteriores foram comparados ao backup.

Não foram alterados scripts de personagens, controles, pontes, checkpoints, puzzles, layouts, tilesets ou PNGs. Testes e capturas permanecem fora do projeto jogável. Não foi refeito ZIP, exportado executável ou enviado material à professora.

## Checklist para apresentação

1. Abrir `project.godot` e usar F5. Navegar por Jogar e Como jogar.
2. Mostrar Em dupla, Controles e Amigos. Redimensionar a janela e conferir o enquadramento.
3. Escolher uma fase. Abrir F1, observar os personagens atuais e voltar à mesma posição.
4. Concluir normalmente em dupla; testar Próxima fase ou Repetir.
5. Na Fase 6, concluir os setores e mostrar a celebração e o retorno ao menu.
6. Conferir manualmente tamanho de texto, clique e leitura na máquina da apresentação.
