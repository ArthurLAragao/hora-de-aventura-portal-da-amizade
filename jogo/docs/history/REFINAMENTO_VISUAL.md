# Refinamento visual — Fases 1 e 6

Godot 4.7.2 mantido. Candidata para avaliação visual do usuário; sem nova aprovação manual presumida.

## Implementação

| Elemento | Mudança | Verificação |
|---|---|---|
| Placas | Bases de madeira na trilha e pedra/metal no santuário; emblemas elevados removidos. Placa de peso tem ressalto que desce; reunião é rebaixada com marcas no pavimento. Extremidades continuam aparentes sob personagem/tronco. | Capturas antes/durante/depois, recuperação e reinício. Áreas e autorização inalteradas. |
| Portal | Estrutura e PNG externo preservados. Espiral de intensidade moderada desenhada em células locais, recortada na abertura e coberta pela moldura. O recorte foi refinado após a inspeção revelar uma fresta. | Portal ativo inspecionado ampliado e na câmera real; clipe renderizado durante o percurso normal. |
| Progresso | Três luzes físicas nos encaixes, apagadas/acesas com abertura luminosa e breve realce. Nenhuma miniatura. | Usa somente `repaired`; recuperação mantém os estados, reinício apaga. Clip de acendimento usa estados controlados, identificado como tal. |
| Túnel | Canal contínuo escuro atrás de Cake, teto e cantos conectados ao material do terreno. Marcadores isolados ocultados apenas nesta fase. | Cake atravessa, recua e sai no percurso por controles; permanece legível sob o teto. |
| Ilhas | As três superfícies elevadas de Marceline ganham espessura, bordas e base rochosa. As margens principais recebem relevo inferior menos repetitivo. | Topos e colisores originais; pistas, movimento e saltos preservados. |
| Composição | Emblemas removidos, mecanismos do setor anterior ocultados quando deixam de participar, rótulos redundantes retirados. Contrapeso ocultado apenas na celebração sem atores controláveis. | Trocas, terminal, cristal e encerramento verificados. |
| Ambiente F1 | Brisa lenta e defasada em 13 plantas e 3 árvores, com o ponto de apoio imóvel. | Shader local apenas em decoração; capturas sequenciais e clipe. Sem áudio necessário. |

## Decisões espaciais e limites

Não foi ampliada a largura física do mapa (1376 unidades), nem alterada a resolução de referência (1152×648). O respiro foi obtido por hierarquia visual, menos sobreposições e volume abaixo dos apoios. Não afirmamos ter criado uma fase fisicamente maior. A distribuição dos puzzles e as distâncias de ação continuam iguais; uma ampliação que redistribua esses conjuntos deverá ser avaliada separadamente se o usuário ainda considerar o espaço insuficiente.

O acabamento de ilhas se concentra nas três plataformas elevadas. As duas margens contínuas mantêm suas superfícies, limites e profundidade física, sem novos buracos. Os volumes inferiores das pequenas ilhas são decoração; não acrescentam superfícies de apoio.

Nenhum colisor, âncora, spawn, checkpoint, limite de câmera, duração de habilidade, entrada ou regra de progressão mudou. Nenhum PNG foi substituído ou gerado nesta rodada. Foram usados desenhos locais do CanvasItem, um shader decorativo e recortes dos tiles existentes. Os arquivos raster originais permanecem intactos.

## Validação

- Fases 1 e 6 percorridas por entradas do Input Map, com papéis padrão e invertidos, em 1152×648 e 1280×720. Sem teleporte ou manipulação de estado como prova de travessia.
- Ponte, túnel, recuo, manivela, terminal, trocas de dupla, cristal único e conclusão normal.
- Casos isolados de recuperação, checkpoint, reinício, cancelamento, parceiro no ar durante a ponte, saída sem cristal/dupla e sequência incorreta. Esses cenários preparados não são apresentados como percurso normal.
- Estados das placas e das luzes, incluindo recuperação e reinício, conferidos por renderização e inspeção das capturas.
- Fase 2: regressão existente executada, sem modificar arquivos ou design da fase.
- Ajuda opcional e destinos dos botões finais: verificações dos handlers; não equivalem a clique humano em outro computador.
- Execuções finais sem erros de runtime registrados. Durante a implementação houve uma declaração de polígono incompatível e uma faixa estreita que não triangulava; ambas foram corrigidas e as execuções repetidas.

Automação não aprova conforto ou aparência humana. Áudio não foi ouvido (driver Dummy), não houve exportação, teste em outro computador, medição comparativa de desempenho nem sessão com duas pessoas. Os GIFs são trechos recortados e ampliados de frames reais; o retorno ao primeiro quadro do GIF é um corte de gravação, não uma falha de loop no jogo.

## Arquivos

Alterados: `journey_plate.gd`, `portal_sanctuary.gd`, `stage_scenery.gd`, `level_6.gd`, `README.md`.

Adicionados: `sanctuary_masonry.gd`, `foliage_breeze.gdshader`, `tests/qa_visual_refinement.gd`, `tests/qa_visual_states.gd`, este relatório e seus UIDs quando emitidos pelo Godot. Capturas publicadas em `docs/refino-visual`, fora dos recursos de jogo.

`pressure_plate.gd`, controladores de personagens/pontes, cenas e assets da Fase 2, menu, câmera e configurações globais não foram alterados.

## Como avaliar

Abra `level_1.tscn` ou `level_6.tscn` e execute com F6. Na raiz, `finn_player_id` (F1) / `primary_player_id` (F6) alterna o papel principal.

- P1: A/D, Espaço/W, E, Q. P2: setas, cima, Enter, Shift direito.
- Placas são automáticas, sem tecla; observe o ressalto e as bordas com personagem em cima.
- Confira túnel por ambos os lados e Cake sob o teto.
- Veja as luzes acenderem por setor e persistirem após queda; F2 reinicia tudo.
- Observe o portal ativo e a celebração; F1 abre a ajuda opcional.
- Observe a folhagem alguns segundos sem movimentar personagens.

## Evidências

[Comparações e GIFs](../docs/refino-visual/) e `resultados.json` documentam os comportamentos. As capturas anteriores da Fase 6 foram feitas no original antes desta edição; as da Fase 1 vieram da entrega imediatamente anterior, cujas fontes foram conferidas contra o estado inicial desta rodada.

Branch autorizada: `codex/revisao-qualidade-fases-1-6`. Publicação em blocos; hashes/resultados apresentados na entrega. Main preservada.
