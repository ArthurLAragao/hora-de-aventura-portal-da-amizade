# Revisão de design e identidade — 05/11/2026

## Direção e limite desta versão

Revisão implementada sobre a base existente em Godot 4.7.2, preservando os personagens, controles, pontes e recuperação. A direção passa a aceitar um pouco mais de desafio de leitura e deslocamento. Não houve validação humana de diversão, dificuldade ou qualidade comercial desta rodada.

O critério foi reforçar intenção, participação e identidade, sem aumentar punição ou exigir precisão de um pixel. As Fases 1 e 4 já têm boas combinações de objeto e parceiro: mantiveram os puzzles. O desafio foi ampliado localmente nas Fases 2, 3, 5 e 6, sem reescrever os seis layouts.

## Leitura de cada fase e intervenção

| Fase | Diagnóstico e decisão | Implementado | Como avaliar |
|---|---|---|---|
| 1 — Casa na Árvore | O tronco com dois usos e a separação das rotas já sustentam a cooperação. A abertura precisa continuar contrastando com as fases finais. | Escoras, juntas de madeira e ligação visual sob a rota do tronco. Arte, vegetação e percurso anteriores preservados. | Jake mantém o encaixe enquanto Finn move o tronco; observar se a ligação comunica a alteração do caminho sem texto. |
| 2 — Reino Gelado | A crista era composta por dois patamares, com pouca variação após aprender o primeiro. | Crista com três alturas (superfícies Y487, Y455 e Y423). O ponto mais alto exige outro salto após pousar. Arcos de aqueduto congelado e acabamentos no túnel conectam bosque e reencontro. | Repetir com ambas as personagens e voltar pelo caminho. O vão e a formação de Cake mantêm suas medidas. |
| 3 — Caverna Musical | Uma sequência contendo cada símbolo uma vez pode ser resolvida enumerando as três opções. | Pista e terminal usam círculo, triângulo, quadrado, círculo. Ressonadores de pedra e ligação sob o piso reforçam a música como tema. | Ler a ordem, errar, cancelar e repetir. Marceline continua móvel durante o painel de BMO. A pista permanece visível; não é memória punitiva. |
| 4 — Oficina Doce | Transporte, peso e circuito já dão funções diferentes à dupla. Acrescentar uma ação arbitrária não melhora essa combinação. | Estruturas de oficina em plano distante, suportes no trilho e ligação de estado na fundação. Puzzle, circuito, transporte e portas preservados. | Conferir leitura da carga, chegada da plataforma e conexão; os pilares devem ficar atrás dos mecanismos móveis. |
| 5 — Torre dos Espelhos | O primeiro espelho era alcançável pelo chão, e o panorama deixava uma área cinza na câmera. | Balcão de 96×18 em X288/Y452, com apoio de mão única. Espelho em (360,394), receptor em (360,274), emissor em (260,394), alcance inicial de 54. Fundo cobre 2208×648 mantendo proporção; perfil local 1152×648. Contrafortes e fundação dão unidade à galeria. | Interação do piso inferior deve falhar; saltar ao balcão deve permitir o ajuste. Conferir margem direita do cenário e reunião após os circuitos. |
| 6 — Portal da Amizade | O encerramento deve recombinar o que foi aprendido, com o núcleo ainda dominando a composição. | Sequência final e pista passam a triângulo, círculo, quadrado, triângulo. Pilares distantes emolduram o santuário e juntas luminosas refletem os três reparos existentes. | Concluir três duplas, observar as luzes, confirmar em conjunto, coletar e celebrar. Não foi criado um segundo estado de progresso. |

## Mapas laterais resumidos

1. Início → tronco/placa → ponte Jake/alavanca → acampamento → tronco como degrau / rota elevada de Jake → encaixe conjunto → cristal → saída.
2. Bloco/degrau → túnel Cake/interruptor → manivela Fionna/passagem → checkpoint → crista em três alturas → ponte Cake/manivela → terraço do cristal → saída.
3. Balcão musical → pista de quatro símbolos → checkpoint → terminal BMO → ilhas de eco/energia → duas placas → cristal → saída.
4. Carga → transporte BMO → peso/placa → checkpoint → condutores Finn/conexão BMO → cristal → saída.
5. Balcão/primeiro reflexo → túnel inferior Cake + ajuste elevado Marceline → checkpoint → dois receptores → cristal → saída.
6. Estrutura Finn/Jake → reunião → túnel/manivela Fionna/Cake → reunião → pista/terminal Marceline/BMO → confirmação conjunta → cristal → celebração.

## Técnica e preservação

- `scripts/scenery/level_identity.gd`: acabamento local nas seis cenas. Arquitetura distante em camada separada; fundações e indicadores desenhados sobre terreno. Sem colisões decorativas, controles ou dependências novas.
- A arquitetura é desenhada pelo Godot em coordenadas inteiras e paleta local. Não foram substituídos PNGs, sprites de personagens ou pacotes de arte.
- O fundo da Torre usa escala uniforme; o perfil de janela anterior é restaurado ao sair. `project.godot` mantém as configurações encontradas do usuário, incluindo a referência global 1920×1080.
- `scripts/ui/friendship_story.gd`: incluída a correção anterior do erro real após coleta. Fases 3–5 consultam o estado persistente da saída, pois o nó do cristal pode ser removido ao terminar seu som.
- Demais controladores compartilhados, pontes, túneis, habilidades, menus e telas não foram reescritos.
- Backup completo anterior fora do jogo: `D:/TEMP/revisao-design-2026-11-03/backup`.

## Validação e evidências

Percursos de início a fim nas seis fases com papéis padrão e invertidos foram executados por entradas, sem reposicionamento para concluir. Casos de erro usam preparação isolada, explicitamente distinta de travessia.

Foram exercitados: ponte com parceiro apoiado e no ar; quedas e checkpoints; cancelamentos; troca de dupla; sequências erradas/corretas de quatro posições; circuito e transporte; receptores e ciclos; cristal e saída conjunta; menu e orientações. Testes antigos de três símbolos foram atualizados para as novas pistas, mantendo verificações de erro e nova tentativa.

Teste dedicado remove o cristal após emitir sua coleta nas Fases 3, 4 e 5 e consulta os diálogos posteriormente. O estado permanece verdadeiro e não ocorre acesso a objeto nulo.

Renderização nativa D3D12 e inspeção de capturas de três enquadramentos de cada fase. As capturas de composição posicionam a câmera para inspeção; não são prova de percurso. A Torre foi conferida em janelas 1280×720 e 1920×1080; a suíte de telas cobre também 800×450 e 1024×768. Áudio foi desativado no QA.

Evidências pesadas ficam fora do jogo, em `D:/TEMP/revisao-design-2026-11-03/final-images`. Houve interrupções de captura quando o compositor deixou de entregar frames em segundo plano; a captura final usa renderização forçada do Godot. Isso não altera o jogo.

## Avaliação manual pendente

1. Abrir pelo menu com F5; F6 abre cada cena diretamente.
2. Jogar a crista da Fase 2 com ambas as personagens; verificar se o salto adicional é confortável.
3. Resolver a pista da Fase 3 com outra pessoa, incluindo erro e nova tentativa.
4. Na Torre, tentar operar do chão, usar o balcão e conferir fundo, feixes e mecanismos nas margens.
5. Concluir a Fase 6 e verificar se a nova sequência final é legível e se as três luzes permanecem coerentes.
6. Rever o erro de coleta: deixar terminar o som e continuar jogando nas Fases 3–5.

Continuam pendentes: sessão com duas pessoas reais, medição de tempo/espera por personagem, conforto com o público e áudio em dispositivo real. Esta rodada não exporta executável nem refaz ZIP. O resultado é uma revisão incremental para avaliação, não uma certificação de qualidade comercial ou ausência universal de bugs.
