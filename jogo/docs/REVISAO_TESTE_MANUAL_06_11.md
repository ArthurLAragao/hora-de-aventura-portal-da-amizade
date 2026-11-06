# Revisão após teste manual — 06/11/2026

Projeto original, Godot 4.7.2.stable.official.ed1daf0bf. A Fase 1 foi aprovada manualmente pelo usuário nesta conversa; seu cenário, portão, controles e puzzles foram preservados. A última referência ambígua à “fase 5 aprovada” foi esclarecida pelo usuário como Fase 6. O cenário e a lógica da Fase 6 permanecem intactos; sua tela de vitória recebeu a melhoria adicional solicitada.

## Correções implementadas

| Relato | Causa confirmada | Correção e evidência |
|---|---|---|
| Como jogar com texto excessivo | Cartões continham parágrafos e listas longas de comandos. | Diagramas P1/P2 com teclas em relevo, retratos, ações de uma palavra e exemplos visuais de cristal/passagem/saída. Três abas e retorno ao jogo preservados. Conferidas em 800×450, 1024×768, 1280×720 e 1920×1080. |
| Vãos do Reino Gelado ignoravam mecanismos | Os dois vãos tinham apenas 64 unidades. | Agora medem 192: X=736–928 e X=1504–1696. Manivela inicial passa a X=696 e a posterior a X=1736. Passarelas permanentes cobrem o apoio efetivamente desenhado, sem chão invisível. Tentativas de salto de Fionna e Cake, incluindo margem após sair da borda, não atravessaram. |
| Ponte de Cake precisava acompanhar o vão maior | O apoio original tinha alcance de 125 unidades. | Export `extra_length=96` somente na âncora gelada. Centro próprio repetido, extremidades preservadas, apoio e dependência aérea aumentados na mesma medida. Zero continua sendo o padrão dos demais usos. Travessia normal, soltura no ar, manivela e reunião da dupla passaram em P1/P2. |
| Atalhos na Caverna Musical | Vãos curtos e portões de 64 unidades permitiam ignorar o percurso. | Abertura inicial de 96 unidades e galeria de 256 com ilhas; os portões visíveis ganharam 256 de altura, conservando apoio no chão e arte nativa por ladrilhamento. Flutuar/saltar não supera os portões fechados. Percurso completo continua acessível às duas personagens. |
| Placas genéricas na caverna e oficina | Sprite compartilhado sem material próprio do ambiente. | Placas locais com pedra violeta/cristais e biscoito/cobre. Área física e regra de detecção preservadas. Tampas abaixam e laterais continuam visíveis; conquista mantém a luz. |
| Montes quadrados no fundo da caverna | Formações eram desenhadas por retângulos empilhados. | Novo sprite de rochas facetadas, paleta índigo/violeta e pequenos cristais. Retiradas as formas abstratas sobrepostas; apoios e colisões jogáveis não foram criados na decoração. |
| Oficina confusa e saturada | Fundo muito vivo mais tubos, colunas retangulares e várias camadas decorativas sobrepostas. | Redução localizada da saturação/contraste da pintura, retirada das colunas e tubos redundantes, agrupamentos menores e prioridade aos mecanismos em primeiro plano. Nenhuma filtragem global foi alterada. |
| Mais desafio no circuito da oficina | Duas peças permitiam ignorar os antigos patamares de serviço. | Terceiro cotovelo em X=1216,Y=308. Os patamares de serviço conduzem até ele; Finn alinha três peças e BMO conecta. Os apoios de serviço são atravessáveis por baixo, impedindo que bloqueiem o caminho térreo. Transporte do bloco preservado. |
| Portões da torre pareciam retângulos | Portões eram linhas e retângulos sem sprite de material. | Novo portão de pedra lavanda, bronze e cristais. Abertura conserva postes e arco; colisão original continua sendo controlada por CoopGate. |
| Reflexão pelo verso / imagem não correspondia | Cálculo refletia raios de ambos os lados; sprite não indicava a face considerada. | Cada espelho tem uma normal frontal; o verso interrompe o feixe. Aresta clara marca a superfície usada pelo cálculo. Feixes recebem contorno e núcleo claro. A galeria continua combinando Cake e Marceline; o final usa duas rotas legíveis e fisicamente consistentes, sem exceção oculta para atravessar receptores. |
| Vitória pouco organizada | Encerramento tinha poucos elementos animados e hierarquia visual fraca. | Entrada escalonada dos seis amigos, animações existentes e pequenos saltos de comemoração, emblema com seis cristais acendendo, confetes discretos, mensagem breve e botões estáveis. Nenhum personagem é controlável na celebração. A tecla da última ação não confirma automaticamente a próxima tela. |

## Testes e inspeção

- Rotas completas das Fases 2, 3, 4, 5 e 6, padrão/invertido, com renderização em 1280×720 e 1920×1080. Rotas não usam teleporte nem concessão de estado; coleta e conclusão exigem o percurso real. A regressão completa da Fase 1 também foi executada em 1280×720.
- Casos isolados separados: salto nos dois vãos de gelo com Fionna/Cake, tentativa de flutuar sobre portão fechado, verso de espelho, orientações erradas, receptor parcial, ciclos de reflexão, pressão de placa, terceira conexão, entradas concorrentes, cancelamento, reinício, recuperação e preservação de progresso.
- A ajuda abriu/fechou pelo fluxo do menu e durante as seis fases. Foram conferidos foco de teclado, ausência de movimento durante ajuda e retomada sem controle preso.
- A vitória e os botões foram inspecionados nos quatro tamanhos de janela acima. O GIF foi capturado após concluir a Fase 6 pelo percurso normal, incluindo a última ação e a animação de vitória. Não é uma montagem.
- Os relatórios finais selecionados não registraram falhas, erros de script ou avisos de console. As falhas intermediárias foram corrigidas: configuração da extensão da âncora precisava vir depois do script na cena; plataformas de serviço sólidas bloqueavam a passagem por baixo; rodapé da nova moldura precisava permanecer fora da abertura física.

Inspeção visual não equivale à aprovação humana de conforto. Não houve teste com duas pessoas, avaliação auditiva (driver Dummy), teste em outra máquina nem nova exportação. A área física dos vãos e o circuito da oficina mudaram e merecem nova avaliação manual. A Fase 1 continua aprovada na versão que foi preservada; esta aprovação não é estendida às mudanças novas.

## Arte e proveniência

Ferramenta integrada imagegen, sem download externo. Fontes grandes ficam fora do projeto. Originais preservados. Recorte transparente e redução Nearest são realizados offline uma única vez, sem processar imagens durante o jogo.

- `manual_review/cave_rocks.png`: 128×104. Brief: formação rochosa irregular para a caverna musical, índigo/violeta com reflexos turquesa, pequenos cristais, contornos e agrupamentos de pixels, fundo transparente. Referência: captura real da caverna.
- `manual_review/tower_gate.png`: 88×268. Brief: portão estreito e alto da torre, pilares de pedra lavanda, bronze envelhecido, incrustações de espelho e grade vazada; estilo pixel art compatível com captura real da torre.
- `manual_review/cave_leaf_256.png` e `cave_frame_256.png`: variantes por repetição de faixas centrais da arte nativa. Sem deformar pixels ou sobrescrever a textura original.
- Placas, teclas e emblema usam desenho nativo no estilo da interface. Nenhum plugin ou dependência nova foi instalado.

## Conferência manual

1. Abrir Como jogar pelo menu e por F1: comparar teclas, retratos e retorno ao jogo.
2. Fase 2: tentar pular os vãos, resolver a primeira manivela e atravessar com a ponte de Cake; soltar a habilidade enquanto Fionna está sobre ela/no ar.
3. Fase 3: observar as placas, as rochas e a abertura dos portões; completar símbolos, energia e reunião em duas alturas.
4. Fase 4: conferir leitura do cenário, carregar o bloco, alcançar o terceiro encaixe e ligar os três cotovelos com BMO.
5. Fase 5: testar as orientações dos espelhos, observar qual face recebe a luz e concluir ambos os receptores.
6. Concluir a Fase 6: observar animação, seis amigos, emblema e navegação pelos botões. Esc retorna ao menu.

P1: A/D, Espaço/W, E, Q. P2: setas, Cima, Enter, Shift direito. F2 reinicia. Cenas `level_1.tscn` a `level_6.tscn` podem ser abertas pelo editor e executadas com F6.

## Backup, arquivos e publicação

Backup externo anterior: `C:/Users/Ryzen/Documents/ChatGPT/SGDD/work/revisao-manual-2026-11-06/backup`, sem cache/Git. Evidências, GIF e scripts auxiliares ficam nessa mesma pasta de trabalho, fora de `res://`. Nenhum asset original foi apagado.

Arquivos alterados/adicionados nesta rodada:

- `Assets/02_Environments/manual_review/cave_frame_256.png`
- `Assets/02_Environments/manual_review/cave_leaf_256.png`
- `Assets/02_Environments/manual_review/cave_rocks.png`
- `Assets/02_Environments/manual_review/tower_gate.png`
- `docs/REVISAO_TESTE_MANUAL_06_11.md`
- `level_2.tscn`
- `level_3.tscn`
- `scripts/bridges/cake_bridge.gd`
- `scripts/bridges/cake_bridge_visual.gd`
- `scripts/levels/level_2.gd`
- `scripts/levels/level_5.gd`
- `scripts/puzzles/ice_passage.gd`
- `scripts/puzzles/workshop_connections.gd`
- `scripts/scenery/habitat_finish.gd`
- `scripts/scenery/region_scenery.gd`
- `scripts/scenery/regional_composition.gd`
- `scripts/scenery/regional_gate_finish.gd`
- `scripts/scenery/regional_layout.gd`
- `scripts/scenery/regional_plate.gd`
- `scripts/ui/friendship_ending.gd`
- `scripts/ui/instructions_screen.gd`

Publicação somente na branch `codex/revisao-qualidade-fases-1-6`. Testes ficam em `development/qa`, fora da pasta jogável. Caches, backups, capturas pesadas e fontes grandes não entram no Git.
