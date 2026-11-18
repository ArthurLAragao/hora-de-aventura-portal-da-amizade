# Campanha e apresentação final — 17/11/2026

Projeto original: `C:/Users/Ryzen/Documents/Codex/2026-10-22/quero-que-voc-me-ajude-a/outputs/adventure-time-phase1-corrigida`. Godot **4.7.2.stable.official.ed1daf0bf**, preservado.

O usuário confirmou todas as seis fases na campanha. Uma aventura nova começa somente com a Fase 1; cada conclusão conjunta libera o destino seguinte. As mudanças desta rodada aguardam avaliação manual do usuário. O jogo continua ensinando cooperação; a dificuldade dos percursos não foi aumentada.

## O que mudou

| Área | Implementação |
|---|---|
| Como jogar | Teclado completo de 104 teclas, bloco numérico, setas, funções e modificadores. P1 destacado em verde e P2 em dourado. Pressionar ou clicar dá relevo à tecla; segurar mantém o destaque e a caminhada; soltar devolve o boneco à animação de repouso. Não injeta comandos na fase pausada. Dupla/Amigos e Escolher fase foram retirados. Há somente o botão contextual de retorno: menu na tela independente, jogo na ajuda embutida. |
| Seleção | Cartões ilustrados com o background de cada região, detalhes ambientais discretos, cadeados e confirmação de fases concluídas. Desbloqueio é verificado no botão e no callback, impedindo abrir uma fase bloqueada pela interface. |
| Progresso | Cristais coletados e fases concluídas são estados separados. A coleta sozinha não libera o próximo destino. Save local JSON com escrita temporária e troca de arquivo; dados são lidos em cache, sem leitura de disco por quadro. Nova aventura solicita confirmação antes de limpar. |
| HUD | Relicário com seis encaixes coloridos preenchidos, facetas, realce e pulso ao receber cristal; acompanha o save real. Retratos continuam seguindo P1/P2 durante trocas de dupla. Não foi criada barra de vida fictícia. |
| Diálogos | Cartão inferior central com o personagem que fala e o retrato do parceiro. Introduções reforçam por que recuperar cristais e como a dupla ajuda a restaurar o mundo. Tab avança e F3 relê; a fala também avança automaticamente. Recuperação, terminal e troca de dupla continuam tendo prioridade. |
| Ambientes | Sombras de contato para personagens no chão, nuvens discretas nas áreas externas e pequenos movimentos ambientais por região. Sem colisões novas, alteração de gravidade, filtro global ou novos obstáculos. |
| Alavanca da Fase 1 | Variante local em madeira, cobre e contorno nítido, com estado acionado visível. A arte original e a Area2D da interação foram preservadas. O ajuste trata a densidade/acabamento da representação, sem mover o mecanismo. |
| Epílogo | Após concluir a Fase 6, a última dupla chega ao monumento. Cada cristal é colocado por E/Enter próximo de sua base, preservando o papel de jogador. As seis bases usam árvore, gelo, tubos musicais, engrenagens, espelho e arco. Cristais giram e brilham; as três luzes do portal aprovado acendem progressivamente. O sexto depósito gera restauração, diálogo e celebração. |
| Vitória | Fundo do santuário, seis personagens com frames originais, entrada escalonada, pequenas comemorações, emblema completo, confetes discretos e um botão Voltar ao menu. A tecla da última ação não confirma automaticamente o botão. |

## Fluxo de campanha

Menu → destinos → Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5 → Fase 6 → Monumento dos seis cristais → celebração → menu.

As passagens entre fases continuam usando os interlúdios existentes. O epílogo é `monument_finale.tscn`, e não uma Fase 7. Abrir uma fase pelo editor continua sendo uma possibilidade de desenvolvimento; concluir F6 isoladamente não libera as fases anteriores nem inventa cinco cristais no save. Para a cerimônia completa é necessário ter os seis cristais da campanha.

## Save e reinício

- Arquivo: `user://friendship_campaign_v1.json` (Windows: `%APPDATA%/Godot/app_userdata/Adventure Time/`). Não contém dados pessoais ou credenciais.
- Fechar o jogo preserva fases e cristais. F2 reinicia a fase atual e preserva o progresso da campanha. Uma queda mantém as regras de checkpoint já existentes.
- Nova aventura, no seletor, pede confirmação e limpa os cristais/desbloqueios. É a opção adequada para começar uma nova sessão de apresentação.
- Não há gravação dentro de Assets, do repositório ou do cache `.godot`.

## Validação real e limites

- Percursos completos das seis fases por entradas simuladas, papéis padrão e invertidos, com renderização em 1280×720. Não foram usados teleporte ou concessão de estado para atravessar os puzzles desses percursos.
- Fases 1 e 6/epílogo também executadas com ambos os papéis em 1920×1080. O epílogo foi concluído caminhando até as bases e alternando os jogadores nas interações.
- Para testar F6 isoladamente, a fixture declara os cinco cristais anteriores como pré-condição. Isso não é apresentado como prova de uma campanha inteira jogada numa única sessão. A progressão entre destinos foi testada separadamente pelo menu e pelos eventos reais de conclusão/coleta.
- Teclado, destinos, HUD, conversa inferior, monumento e botão de vitória conferidos em 800×450, 1024×768, 1280×720 e 1920×1080. Capturas foram inspecionadas, incluindo a correspondência entre teclas e respostas, preenchimento do relicário e cobertura do fundo.
- Testados: save novo, recarga do arquivo, coleta sem conclusão, conclusão repetida, fase fora de ordem, callback bloqueado, retorno da ajuda por Esc, ausência de pausa residual, tecla segurada/solta, clique, Shift direito, cinco depósitos sem vitória, sexto depósito, repetição idempotente, retorno ao menu, checkpoint, recuperação, terminal, cancelamento e troca de duplas.
- As regressões narrativas e de interlúdio confirmaram a troca de retratos, releitura, prioridade do terminal e transferência de P1/P2 sem perda de cristais.
- Os relatórios finais selecionados não contêm erros ou avisos de console nem verificações reprovadas. Problemas intermediários corrigidos incluem coordenadas de viewport nas verificações, persistência do destaque de tecla, teclado numérico, enquadramento local do monumento e repetição do terreno sem deformação.

Não foram avaliados áudio (driver Dummy), uma sessão com duas pessoas, controle físico ESP32, outra máquina ou um novo executável exportado. Não foi criado ZIP novo. Clareza para crianças, conforto e gosto visual ainda dependem da avaliação presencial; automação não comprova diversão nem qualidade comercial.

## Evidências

Pasta externa: `C:/Users/Ryzen/Documents/ChatGPT/SGDD/work/campanha-final-2026-11-17/`.

- `teclado-interativo.gif`: resposta a teclas enviadas pela entrada do Godot na ajuda embutida.
- `cerimonia-percurso-real.gif`: caminhadas e depósitos no epílogo após o percurso da Fase 6. Não é montagem. O teste isolado de F6 usa a pré-condição explícita dos cinco cristais anteriores.
- `tests/verify_campaign_ui/`: teclado, cartões e conversa inferior.
- `tests/verify_presentation_finish/`: relicário 6/6 e telas nas quatro resoluções; os estados de apresentação desse teste são preparados e não comprovam percurso.
- `tests/verify_journey_6/`: depósitos e vitória obtidos pelo percurso normal dessa fase/epílogo.
- `final/`: composição atual das seis fases, com câmera reposicionada somente para inspeção visual; não é evidência de travessia.

## Arte, preservação e colaboração

A tentativa de gerar uma nova ilustração da celebração pela ferramenta integrada imagegen foi rejeitada pela ferramenta. Nenhuma imagem desse pedido foi integrada. O encerramento foi construído com os sprites originais, poses existentes e o portal aprovado. Os novos detalhes de interface e monumentos são desenhos nativos; não houve download externo, deformação dos personagens, plugin ou dependência nova.

Layouts, colisões e scripts dos personagens, pontes e mecanismos existentes foram preservados. A única mudança na lógica da Fase 6 é o encaminhamento após a conclusão para o epílogo e o registro do cristal conquistado. O portal do epílogo reutiliza `portal_sanctuary.gd` sem modificar esse recurso compartilhado. `project.godot` permaneceu idêntico ao backup do original.

O remoto continha 12 commits mais recentes, incluindo a integração ESP32 da equipe. A cópia de publicação foi atualizada por fast-forward até `9e46859`; esses commits, firmware e configuração remota foram preservados. Esta rodada não transplanta a integração de hardware para o original local que não a continha, nem declara teste físico.

Backup externo anterior às alterações: `C:/Users/Ryzen/Documents/ChatGPT/SGDD/work/campanha-final-2026-11-17/backup`. Arquivos originais não foram apagados. Os saves de QA são isolados na pasta externa de testes; não há progresso artificial liberado para o usuário.

## Checklist antes da apresentação

1. Abrir o projeto original e executar pelo menu (F5). Em Como jogar, segurar A/D e setas, pular com W/Espaço/Cima, experimentar clique e Shift direito; observar destaque e liberação.
2. No seletor, iniciar Nova aventura e confirmar que somente a Fase 1 está liberada. Concluir em dupla e conferir a liberação da Fase 2. Fechar/reabrir para conferir a persistência.
3. Conferir o diálogo inferior, Tab/F3, ajuda F1/Esc e se nenhum texto cobre algo importante nos trechos que você observar.
4. Coletar cristais e observar o encaixe preenchido e o brilho. Conferir os retratos na troca de dupla da Fase 6.
5. Após F6, caminhar até as seis bases e interagir com E/Enter. Observar a restauração, a comemoração e o retorno ao menu.

## Arquivos desta rodada

- `monument_finale.tscn`
- `scripts/content/friendship_lines.gd`
- `scripts/core/campaign_progress.gd`
- `scripts/levels/level_6.gd`
- `scripts/levels/monument_finale.gd`
- `scripts/scenery/forest_lever_skin.gd`
- `scripts/scenery/local_mechanism_finish.gd`
- `scripts/scenery/world_atmosphere.gd`
- `scripts/ui/adventure_hud.gd`
- `scripts/ui/crystal_emblem.gd`
- `scripts/ui/friendship_ending.gd`
- `scripts/ui/friendship_story.gd`
- `scripts/ui/game_screens.gd`
- `scripts/ui/instructions_screen.gd`
- `scripts/ui/phase_select.gd`

Testes portáteis e resultados ficam em `development/`, fora da árvore jogável. Backups, capturas pesadas, cache, saves e credenciais não são enviados. Publicação na branch autorizada `codex/revisao-qualidade-fases-1-6`; hashes e resultado dos pushes constam na entrega.
