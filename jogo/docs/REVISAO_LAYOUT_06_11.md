# Revisão de layout e acabamento — 06/11/2026

Implementada no projeto original, com Godot 4.7.2.stable.official.ed1daf0bf. Esta entrega é uma candidata para avaliação manual, não uma aprovação humana de diversão ou aparência.

## Mudanças por fase

| Fase | Design e resultado | Preservado |
|---|---|---|
| 1 — Trilha | Portões de carvalho, ferragens verdes e base com musgo. Ao abrir, ficam apenas os postes. Removidos cadeados sobrepostos ao desenho. | Layout, medidas físicas, puzzles, ponte, checkpoint e conclusão. |
| 2 — Reino Gelado | Bloco usado como degrau e contrapeso. Cake atravessa o túnel e libera a manivela somente com peso na placa. Veio no gelo liga visualmente placa e interruptor. | Ponte, manivelas, patamar final, recuperação e controles. |
| 3 — Caverna | Ilhas em alturas diferentes e confirmação final em dois níveis. A sequência volta a três símbolos conforme o SGDD: círculo, triângulo, quadrado. O desafio aumenta no espaço, não na memorização. | Painel musical, terminal, energia, checkpoint e saída conjunta. |
| 4 — Oficina | Dois cotovelos com quatro orientações, um no piso e outro no patamar superior. Finn prepara o circuito; BMO conecta. Tubos visíveis correspondem às posições corretas. | Transporte do bloco, terminal de transporte, placa, portas e física do bloco. |
| 5 — Torre | No final, o feixe inferior de Cake sobe por um relé fixo e compartilha o espelho superior com o segundo feixe. Ajustar somente uma personagem não resolve os dois receptores. | Túneis, primeiros circuitos, capacidades, checkpoint e saída. |
| 6 — Portal | Placas embutidas em pedra e bronze, com depressão do piso e luzes laterais visíveis durante o uso. A diferenciação inclui relevo e marcas, não apenas cor. | Layout, trocas de dupla, puzzles, portal, cristal e celebração. |

As fundações das regiões 2–5 reutilizam as texturas nativas, com gelo estriado, rocha estratificada e alvenaria de juntas desencontradas. O acabamento segue as colunas reais e não preenche visualmente os vãos. Não houve troca dos pacotes de arte nem mudança de resolução global.

## Mapas e responsabilidades

2: bloco/contrapeso (Fionna) → túnel/interruptor (Cake) → primeira manivela → checkpoint → relevo de gelo → ponte de Cake/passagem permanente → cristal/saída.

3: balcão musical (Marceline) → pista de três símbolos → terminal (BMO) → ilhas elevadas/energia → dueto em duas alturas → cristal/saída.

4: carregar bloco (Finn) + operar transporte (BMO) → placa/porta → checkpoint → cotovelo inferior + superior (Finn) → ligar energia (BMO) → cristal/saída.

5: primeiro espelho → túnel/galeria cooperativa → checkpoint → desvio inferior de Cake + espelho superior de Marceline alimentando dois receptores → cristal/saída.

## Problemas encontrados e corrigidos nesta rodada

- A placa nova da Fase 2 detectava a borda do bloco inicial. Foi movida para X=408, sem exigir posicionamento exato; inicia vazia e depende de empurrão real.
- A ligação visual do contrapeso ficava atrás do terreno. Agora ocupa uma camada local acima do chão, sem colisão.
- A primeira versão do patamar da oficina buscava um nome de colisor não definido. A referência foi corrigida; os percursos foram repetidos sem erro de script.
- A automação antiga tentava caminhar através da lateral do novo balcão da caverna. O percurso de teste agora usa um salto real, mantendo a colisão visível e as mesmas condições de conclusão.
- Fixtures antigas de teste pressupunham duas orientações de circuito e receptores independentes. Foram atualizadas para a geometria nova, preservando os testes de recusa e segurança.

## Validação executada

- Percursos completos das seis fases, com renderização D3D12, em 1280×720 e 1920×1080, papéis padrão e invertidos. Comandos de movimento/interação foram usados; não houve reposicionamento ou injeção de solução nesses percursos.
- Nas rotas das Fases 1–5, as verificações confirmaram conclusão sem recuperação por queda; a Fase 6 percorreu as três duplas até a celebração.
- Casos isolados separados: saída sem cristal/sem parceira, recuperação e checkpoint, peso ausente, circuito errado, cancelamento de energia, exclusão de BMO da rotação física, sequência incorreta e nova tentativa, duas áreas sobrepostas artificialmente, receptores parciais, ciclos de reflexão e reinício.
- Inspeção das capturas reais: portão fechado/aberto, placas, fundações, ilhas, circuito, feixes e encerramento em 1920×1080. Os registros finais selecionados não contêm erros/avisos de console nem verificações reprovadas.
- HUD, interlúdios e diálogos foram preservados. Personagens, controles, duração das habilidades e configuração global do projeto não foram editados.

As fixtures isoladas podem preparar posições/estados para testar defeitos; não são apresentadas como travessias. O áudio foi executado com driver Dummy, portanto não houve avaliação auditiva. Não houve sessão com duas pessoas, teste em outro computador ou nova exportação. Conforto, clareza sem conhecimento prévio e gosto visual ainda precisam da avaliação do usuário.

## Arte nova e recursos reaproveitados

Novo PNG de execução: `Assets/03_Objects_and_Puzzles/local_finish/forest_gate_oak.png`, 124×104, filtro Nearest. Os PNGs originais permanecem intactos. Usado o skill imagegen com ferramenta integrada; fonte grande guardada somente fora do jogo. Recorte por alfa e redução Nearest feitos uma vez, offline, pelo Godot.

Brief da geração: portão frontal de carvalho para a trilha da casa na árvore; tábuas quentes, postes com musgo, ferragens verdes e pequeno puxador; contorno escuro, blocos de pixel definidos, fundo transparente e sem cenário. Referências: portão original e captura real da Fase 1. A imagem resultante foi recortada e inspecionada dentro do jogo.

Placas e cotovelos reutilizam desenho nativo e alojamentos existentes. As fundações usam `tiles/fill.png` dos quatro pacotes regionais. Não há geração de imagens por quadro, dependência nova ou download externo de assets.

## Como testar

Abrir `project.godot`; executar pelo seletor ou abrir `level_1.tscn` até `level_6.tscn` e usar F6. Alternar o papel na propriedade da raiz: `finn_player_id` na Fase 1, `cake_player_id` na Fase 2 e `lead_player_id` nas demais, conforme já existente.

P1: A/D, Espaço/W, E, Q. P2: setas laterais, Cima, Enter, Shift direito. Ajuda opcional no jogo. F2 reinicia.

- [ ] Fase 1: observar portão fechado e aberto, sem alteração do percurso.
- [ ] Fase 2: tentar o interruptor sem peso; empurrar o bloco sobre a placa, atravessar o túnel e liberar a manivela.
- [ ] Fase 3: ler três símbolos, atravessar as ilhas e reunir a dupla nas placas de alturas diferentes.
- [ ] Fase 4: girar os dois cotovelos até conectar o caminho visível e ligar com BMO; testar Esc antes da conclusão.
- [ ] Fase 5: observar como o espelho elevado influencia os dois feixes; concluir e sair em dupla.
- [ ] Fase 6: comparar placas livres, pressionadas e conquistadas, inclusive com personagem ou objeto em cima.

## Segurança e arquivos

Backup externo completo, anterior às alterações: `C:/Users/Ryzen/Documents/ChatGPT/SGDD/work/layout-cooperativo-2026-11-05/backup` (sem cache/Git). Evidências e scripts auxiliares ficam na pasta irmã `layout-cooperativo-2026-11-05`, fora dos recursos jogáveis. Nenhum arquivo foi apagado.

Arquivos de execução alterados/adicionados nesta rodada:

- `Assets/03_Objects_and_Puzzles/local_finish/forest_gate_oak.png`
- `level_1.tscn`
- `level_6.tscn`
- `scripts/levels/level_2.gd`
- `scripts/levels/level_3.gd`
- `scripts/levels/level_5.gd`
- `scripts/puzzles/workshop_connections.gd`
- `scripts/scenery/forest_gate_finish.gd`
- `scripts/scenery/habitat_finish.gd`
- `scripts/scenery/local_mechanism_finish.gd`
- `scripts/scenery/regional_composition.gd`
- `scripts/scenery/regional_layout.gd`
- `scripts/scenery/sanctuary_plate_finish.gd`
- `scripts/scenery/stage_scenery.gd`

Metadados `.uid` e `.import` novos acompanham os recursos; caches, fonte grande, capturas e backups não são enviados ao repositório. Publicação na branch autorizada `codex/revisao-qualidade-fases-1-6`; hashes e resultado dos pushes são informados na entrega.
