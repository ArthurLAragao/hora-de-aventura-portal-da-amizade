# Guia das funções do jogo

Cada função mantida tem comentário `##` de propósito. Parâmetros, tipos e retorno ficam na assinatura. As responsabilidades de cada componente estão em ARQUITETURA.md.

| Arquivo | Função | Responsabilidade |
|---|---|---|
| `Assets/01_Characters/animation_driver.gd:24` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: prévia reutilizável de animações dos assets. |
| `Assets/01_Characters/animation_driver.gd:30` | `set_character` | Seleciona os SpriteFrames do personagem válido e reinicia sua apresentação visual. |
| `Assets/01_Characters/animation_driver.gd:44` | `_start` | Inicia um clipe existente sem reiniciar a reprodução se ela já estiver correta. |
| `Assets/01_Characters/animation_driver.gd:57` | `clear_action` | Limpa a ação temporária e seus temporizadores. |
| `Assets/01_Characters/animation_driver.gd:64` | `is_movement_locked` | Informa se a ação visual atual exige bloqueio de movimento. |
| `Assets/01_Characters/animation_driver.gd:68` | `set_ability` | Sincroniza o estado visual da habilidade pressionada, incluindo sustentação e retração. |
| `Assets/01_Characters/animation_driver.gd:80` | `play_secondary` | Reproduz a ação secundária correspondente à identidade configurada. |
| `Assets/01_Characters/animation_driver.gd:84` | `play_action` | Inicia uma ação existente e configura o prazo de recuperação de seu clipe. |
| `Assets/01_Characters/animation_driver.gd:98` | `update_motion` | Escolhe locomoção, aterrissagem ou ação a partir de velocidade, apoio e tempo decorrido. |
| `Assets/01_Characters/animation_driver.gd:130` | `_finished` | Converte extensão em sustentação ou encerra a ação e emite sua conclusão. |
| `Assets/04_Interface/Godot/hud.gd:7` | `set_players` | Atualiza os dois retratos com personagens válidos. |
| `Assets/04_Interface/Godot/hud.gd:13` | `set_objective` | Atualiza o texto do objetivo apresentado na interface. |
| `Assets/04_Interface/Godot/hud.gd:17` | `set_crystals` | Preenche os seis indicadores conforme a quantidade de cristais coletados. |
| `Assets/04_Interface/Godot/screen_controller.gd:7` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: telas de interface dos assets. |
| `Assets/04_Interface/Godot/screen_controller.gd:21` | `_on_button_pressed` | Encaminha a ação do botão para seleção, instruções, menu ou som. |
| `Assets/04_Interface/Godot/screen_controller.gd:35` | `_fit` | Centraliza e escala o desenho da interface preservando a proporção 640×360. |
| `Assets/05_Effects/effect_driver.gd:7` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: animação de efeitos dos assets. |
| `Assets/05_Effects/effect_driver.gd:13` | `trigger` | Mostra e reinicia um efeito existente no recurso de animações. |
| `mechanisms/bmo_terminal.gd:37` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: painel de símbolos e conexão de energia. |
| `mechanisms/bmo_terminal.gd:44` | `can_interact` | Verifica alcance, capacidade e disponibilidade para uma interação contextual. |
| `mechanisms/bmo_terminal.gd:48` | `interact` | Inicia a interação local e registra o personagem proprietário. |
| `mechanisms/bmo_terminal.gd:69` | `process_operator_input` | Processa somente as entradas do operador, exigindo soltar a tecla usada para abrir o painel. |
| `mechanisms/bmo_terminal.gd:102` | `cancel` | Cancela a ação corrente e libera as referências/controles pertencentes a este mecanismo. |
| `mechanisms/bmo_terminal.gd:107` | `action_finished` | Recebe sucesso/cancelamento da animação e conclui a operação sem duplicar efeitos. |
| `mechanisms/bmo_terminal.gd:131` | `update_prompt` | Atualiza a indicação contextual com a tecla do jogador e a disponibilidade da ação. |
| `mechanisms/bmo_terminal.gd:139` | `_label` | Cria um rótulo do painel com fonte, tamanho e texto configurados. |
| `mechanisms/bmo_terminal.gd:147` | `_style` | Cria o estilo de fundo/borda usado nos elementos do painel. |
| `mechanisms/bmo_terminal.gd:156` | `_build_panel` | Monta o painel de símbolos com seleção, progresso e instruções do operador. |
| `mechanisms/bmo_terminal.gd:201` | `_refresh_panel` | Atualiza seleção e sequência apresentada no painel. |
| `mechanisms/bmo_terminal.gd:208` | `_exit_tree` | Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: painel de símbolos e conexão de energia. |
| `mechanisms/cake_tunnel.gd:8` | `can_interact` | Verifica alcance, capacidade e disponibilidade para uma interação contextual. |
| `mechanisms/cake_tunnel.gd:12` | `interact` | Inicia a interação local e registra o personagem proprietário. |
| `mechanisms/cake_tunnel.gd:17` | `update_prompt` | Atualiza a indicação contextual com a tecla do jogador e a disponibilidade da ação. |
| `mechanisms/fionna_crank.gd:13` | `can_interact` | Verifica alcance, capacidade e disponibilidade para uma interação contextual. |
| `mechanisms/fionna_crank.gd:17` | `interact` | Inicia a interação local e registra o personagem proprietário. |
| `mechanisms/fionna_crank.gd:30` | `action_finished` | Recebe sucesso/cancelamento da animação e conclui a operação sem duplicar efeitos. |
| `mechanisms/fionna_crank.gd:47` | `cancel` | Cancela a ação corrente e libera as referências/controles pertencentes a este mecanismo. |
| `mechanisms/fionna_crank.gd:52` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: operação cancelável da manivela. |
| `mechanisms/fionna_crank.gd:56` | `update_prompt` | Atualiza a indicação contextual com a tecla do jogador e a disponibilidade da ação. |
| `mechanisms/fionna_crank.gd:66` | `_exit_tree` | Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: operação cancelável da manivela. |
| `mechanisms/fionna_platform.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: extensão permanente da plataforma. |
| `mechanisms/fionna_platform.gd:19` | `extend_passage` | Solicita a extensão permanente até o destino configurado. |
| `mechanisms/fionna_platform.gd:23` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: extensão permanente da plataforma. |
| `mechanisms/music_mechanism.gd:15` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: mecanismo musical autorizado por capacidade. |
| `mechanisms/music_mechanism.gd:21` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: mecanismo musical autorizado por capacidade. |
| `mechanisms/music_mechanism.gd:27` | `activate` | Executa a ativação deste mecanismo e atualiza seu estado. |
| `mechanisms/music_mechanism.gd:41` | `_on_entered` | Registra o personagem que entrou no alcance do mecanismo. Contexto: mecanismo musical autorizado por capacidade. |
| `mechanisms/music_mechanism.gd:47` | `_on_exited` | Remove o personagem que saiu do alcance do mecanismo. Contexto: mecanismo musical autorizado por capacidade. |
| `mechanisms/music_mechanism.gd:52` | `_refresh` | Sincroniza texto e disponibilidade do mecanismo com o estado atual. |
| `scripts/bridges/bridge_approach.gd:12` | `_init` | Inicializa dados locais antes da entrada na árvore. Contexto: aproximação assistida segura até uma âncora. |
| `scripts/bridges/bridge_approach.gd:17` | `path_reason` | Consulta o trajeto até a formação e retorna o motivo que impede a aproximação, ou texto vazio. |
| `scripts/bridges/bridge_approach.gd:43` | `selected` | Resolve a seleção da âncora candidata, evitando alternância instável entre âncoras próximas. |
| `scripts/bridges/bridge_approach.gd:59` | `begin` | Inicia a aproximação solicitada, mantendo uma referência ao personagem que a controla. |
| `scripts/bridges/bridge_approach.gd:74` | `advance` | Avança a aproximação em passos seguros e informa se continua, terminou ou foi interrompida. |
| `scripts/bridges/bridge_approach.gd:112` | `cancel` | Cancela a ação corrente e libera as referências/controles pertencentes a este mecanismo. |
| `scripts/bridges/cake_bridge.gd:27` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: estados e apoio seguro da ponte de Cake. |
| `scripts/bridges/cake_bridge.gd:45` | `offer_position` | Retorna a posição de referência em que a habilidade é oferecida ao jogador. |
| `scripts/bridges/cake_bridge.gd:49` | `accepts_actor` | Verifica a capacidade/identidade aceita por esta âncora, independentemente de P1 ou P2. |
| `scripts/bridges/cake_bridge.gd:53` | `can_request` | Verifica se a solicitação da habilidade é válida antes de iniciar aproximação ou formação. |
| `scripts/bridges/cake_bridge.gd:57` | `request` | Recebe a solicitação do jogador e encaminha aproximação/formação quando as condições permitem. |
| `scripts/bridges/cake_bridge.gd:63` | `can_activate` | Verifica as condições de ativação da habilidade no estado atual. |
| `scripts/bridges/cake_bridge.gd:70` | `activate` | Executa a ativação deste mecanismo e atualiza seu estado. |
| `scripts/bridges/cake_bridge.gd:75` | `_form` | Inicia a formação visual da passagem mantendo o apoio indisponível enquanto incompleta. |
| `scripts/bridges/cake_bridge.gd:98` | `_play` | Seleciona o clipe visual da transformação e configura sua reprodução. |
| `scripts/bridges/cake_bridge.gd:108` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: estados e apoio seguro da ponte de Cake. |
| `scripts/bridges/cake_bridge.gd:160` | `_shrink` | Inicia o recolhimento quando a liberação do apoio é segura. |
| `scripts/bridges/cake_bridge.gd:167` | `_reverse_source` | Reproduz os quadros de extensão em sentido inverso para o recolhimento. |
| `scripts/bridges/cake_bridge.gd:177` | `get_dependents` | Retorna parceiros que ainda dependem da passagem, incluindo a região de risco durante saltos. |
| `scripts/bridges/cake_bridge.gd:192` | `cancel_immediately` | Encerra a habilidade durante recuperação/limpeza e restaura sprite, controles e apoio. |
| `scripts/bridges/cake_bridge.gd:208` | `update_prompt` | Atualiza a indicação contextual com a tecla do jogador e a disponibilidade da ação. |
| `scripts/bridges/cake_bridge.gd:219` | `_exit_tree` | Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: estados e apoio seguro da ponte de Cake. |
| `scripts/bridges/cake_bridge.gd:224` | `request_cancel` | Solicita cancelamento respeitando a presença de parceiros dependentes do apoio. |
| `scripts/bridges/cake_bridge.gd:232` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: estados e apoio seguro da ponte de Cake. |
| `scripts/bridges/cake_bridge_visual.gd:7` | `set_progress` | Define a fração visível da extensão e solicita atualização do desenho. |
| `scripts/bridges/cake_bridge_visual.gd:12` | `has_full_render` | Informa se a representação visual já cobre a passagem completamente. |
| `scripts/bridges/cake_bridge_visual.gd:15` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: desenho progressivo da ponte de Cake. |
| `scripts/bridges/jake_bridge.gd:44` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: estados e apoio seguro da ponte de Jake. |
| `scripts/bridges/jake_bridge.gd:62` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: estados e apoio seguro da ponte de Jake. |
| `scripts/bridges/jake_bridge.gd:139` | `offer_position` | Retorna a posição de referência em que a habilidade é oferecida ao jogador. |
| `scripts/bridges/jake_bridge.gd:143` | `accepts_actor` | Verifica a capacidade/identidade aceita por esta âncora, independentemente de P1 ou P2. |
| `scripts/bridges/jake_bridge.gd:147` | `can_request` | Verifica se a solicitação da habilidade é válida antes de iniciar aproximação ou formação. |
| `scripts/bridges/jake_bridge.gd:151` | `_find_candidate` | Procura o personagem elegível para solicitar esta ponte. |
| `scripts/bridges/jake_bridge.gd:157` | `can_activate` | Verifica as condições de ativação da habilidade no estado atual. |
| `scripts/bridges/jake_bridge.gd:161` | `_can_form` | Verifica se a ponte pode formar apoio sem violar as condições da âncora. |
| `scripts/bridges/jake_bridge.gd:185` | `_begin_bridge` | Inicia a transformação e mantém o personagem imóvel durante a habilidade. |
| `scripts/bridges/jake_bridge.gd:220` | `_play_source` | Reproduz os quadros originais usados na transição da habilidade. |
| `scripts/bridges/jake_bridge.gd:239` | `_start_growth` | Inicia a revelação progressiva do trecho central da ponte. |
| `scripts/bridges/jake_bridge.gd:252` | `_start_shrink` | Inicia o recolhimento visual depois de liberar o apoio com segurança. |
| `scripts/bridges/jake_bridge.gd:263` | `_start_source_retraction` | Prepara o retorno pelos quadros originais da transformação. |
| `scripts/bridges/jake_bridge.gd:275` | `_finish_retraction` | Conclui a retração e restaura a representação normal do personagem. |
| `scripts/bridges/jake_bridge.gd:290` | `_unlock_player` | Libera o bloqueio local mantido pela ponte. |
| `scripts/bridges/jake_bridge.gd:301` | `get_support_rect` | Retorna o retângulo útil de apoio em coordenadas do mundo. |
| `scripts/bridges/jake_bridge.gd:307` | `_shape_rect` | Converte a forma física em retângulo para as consultas de segurança. |
| `scripts/bridges/jake_bridge.gd:320` | `get_dependents` | Retorna parceiros que ainda dependem da passagem, incluindo a região de risco durante saltos. |
| `scripts/bridges/jake_bridge.gd:343` | `_set_support` | Ativa/desativa o apoio físico de acordo com o estado seguro da transformação. |
| `scripts/bridges/jake_bridge.gd:351` | `_set_prompt` | Atualiza o feedback contextual da âncora. |
| `scripts/bridges/jake_bridge.gd:358` | `_on_jake_animation_finished` | Avança a transformação da ponte ao terminar o clipe original de Jake. Contexto: estados e apoio seguro da ponte de Jake. |
| `scripts/bridges/jake_bridge.gd:368` | `_exit_tree` | Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: estados e apoio seguro da ponte de Jake. |
| `scripts/bridges/jake_bridge.gd:374` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: estados e apoio seguro da ponte de Jake. |
| `scripts/bridges/jake_bridge_visual.gd:15` | `configure` | Configura as referências e dimensões necessárias ao componente. |
| `scripts/bridges/jake_bridge_visual.gd:26` | `set_progress` | Define a fração visível da extensão e solicita atualização do desenho. |
| `scripts/bridges/jake_bridge_visual.gd:33` | `has_full_render` | Informa se a representação visual já cobre a passagem completamente. |
| `scripts/bridges/jake_bridge_visual.gd:38` | `get_flat_back_rect` | Retorna a faixa plana do desenho usada para conferir o alinhamento do apoio. |
| `scripts/bridges/jake_bridge_visual.gd:42` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: desenho progressivo da ponte de Jake. |
| `scripts/bridges/journey_bridge_deck.gd:4` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: desenho do tablado permanente. |
| `scripts/bridges/permanent_bridge.gd:8` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: passagem permanente. |
| `scripts/bridges/permanent_bridge.gd:15` | `open_gate` | Abre a passagem pelo estado existente do mecanismo, sem duplicar efeitos. |
| `scripts/characters/bmo_player.gd:8` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: ações locais de terminal e energia de BMO. |
| `scripts/characters/bmo_player.gd:27` | `_start_jump` | Inicia o salto com os valores de movimento configurados e atualiza o estado de animação. |
| `scripts/characters/bmo_player.gd:32` | `_update_animation` | Seleciona a animação apropriada ao movimento, postura ou interação atual. |
| `scripts/characters/bmo_player.gd:45` | `begin_interaction` | Adquire o bloqueio local de movimento para um proprietário e clipe de interação válidos. |
| `scripts/characters/bmo_player.gd:66` | `finish_interaction` | Finaliza a ação do proprietário e devolve o controle, comunicando sucesso ou cancelamento. |
| `scripts/characters/bmo_player.gd:83` | `_on_animation_finished` | Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: ações locais de terminal e energia de BMO. |
| `scripts/characters/bmo_player.gd:89` | `reset_after_recovery` | Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida. |
| `scripts/characters/cake_player.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: rastejo e postura de Cake. |
| `scripts/characters/cake_player.gd:21` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: rastejo e postura de Cake. |
| `scripts/characters/cake_player.gd:44` | `can_stand` | Consulta a geometria acima de Cake antes de restaurar o colisor alto. |
| `scripts/characters/cake_player.gd:56` | `begin_crawl` | Entra na postura baixa autorizada pelo túnel, mantendo o deslocamento controlável. |
| `scripts/characters/cake_player.gd:75` | `request_stand` | Tenta restaurar a postura normal somente se houver espaço livre acima. |
| `scripts/characters/cake_player.gd:89` | `_start_jump` | Inicia o salto com os valores de movimento configurados e atualiza o estado de animação. |
| `scripts/characters/cake_player.gd:97` | `_update_animation` | Seleciona a animação apropriada ao movimento, postura ou interação atual. |
| `scripts/characters/cake_player.gd:107` | `finish_pose` | Finaliza a pose temporária e devolve a personagem à animação de movimento. |
| `scripts/characters/cake_player.gd:118` | `reset_after_recovery` | Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida. |
| `scripts/characters/fionna_player.gd:8` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: empurrão e manivela de Fionna. |
| `scripts/characters/fionna_player.gd:26` | `_start_jump` | Inicia o salto com os valores de movimento configurados e atualiza o estado de animação. |
| `scripts/characters/fionna_player.gd:31` | `_update_animation` | Seleciona a animação apropriada ao movimento, postura ou interação atual. |
| `scripts/characters/fionna_player.gd:46` | `_push_nearby_block` | Procura um bloco elegível para o pedido de empurrão. |
| `scripts/characters/fionna_player.gd:51` | `_try_push_from_walk` | Tenta empurrar a partir do movimento e de um contato físico válido. |
| `scripts/characters/fionna_player.gd:61` | `begin_crank` | Inicia a ação local de manivela e o clipe correspondente. |
| `scripts/characters/fionna_player.gd:79` | `finish_crank` | Finaliza ou cancela a operação da manivela e restaura o movimento. |
| `scripts/characters/fionna_player.gd:95` | `_on_animation_finished` | Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: empurrão e manivela de Fionna. |
| `scripts/characters/fionna_player.gd:100` | `reset_after_recovery` | Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida. |
| `scripts/characters/marceline_player.gd:12` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: flutuação limitada e ação musical de Marceline. |
| `scripts/characters/marceline_player.gd:36` | `_apply_air_gravity` | Aplica a aceleração vertical enquanto o personagem está no ar. |
| `scripts/characters/marceline_player.gd:44` | `_start_jump` | Inicia o salto com os valores de movimento configurados e atualiza o estado de animação. |
| `scripts/characters/marceline_player.gd:52` | `_update_animation` | Seleciona a animação apropriada ao movimento, postura ou interação atual. |
| `scripts/characters/marceline_player.gd:70` | `play_music_interaction` | Inicia o clipe musical sem permitir um bloqueio permanente de controles. |
| `scripts/characters/marceline_player.gd:82` | `_on_animation_finished` | Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: flutuação limitada e ação musical de Marceline. |
| `scripts/characters/marceline_player.gd:88` | `reset_after_recovery` | Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida. |
| `scripts/characters/player.gd:32` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: movimento compartilhado, controles por jogador e animações básicas. |
| `scripts/characters/player.gd:41` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: movimento compartilhado, controles por jogador e animações básicas. |
| `scripts/characters/player.gd:95` | `_apply_air_gravity` | Aplica a aceleração vertical enquanto o personagem está no ar. |
| `scripts/characters/player.gd:99` | `_start_jump` | Inicia o salto com os valores de movimento configurados e atualiza o estado de animação. |
| `scripts/characters/player.gd:107` | `face_direction` | Orienta o sprite horizontalmente sem modificar a identidade ou os controles do jogador. |
| `scripts/characters/player.gd:113` | `has_ability` | Consulta as capacidades do personagem; o número do jogador não concede habilidades. |
| `scripts/characters/player.gd:117` | `_limit_direction_from_partner` | Limita o deslocamento que aumentaria uma separação excessiva da dupla. |
| `scripts/characters/player.gd:129` | `_update_animation` | Seleciona a animação apropriada ao movimento, postura ou interação atual. |
| `scripts/characters/player.gd:154` | `_play_motion_animation` | Troca o clipe de locomoção sem reiniciá-lo desnecessariamente. |
| `scripts/characters/player.gd:164` | `_play_if_available` | Reproduz o clipe solicitado somente quando existe no recurso de animações. |
| `scripts/characters/player.gd:171` | `play_lever_interaction` | Inicia o clipe de alavanca preservando a recuperação posterior do movimento. |
| `scripts/characters/player.gd:180` | `get_animation_duration` | Calcula a duração do clipe a partir dos quadros e da velocidade disponível. |
| `scripts/characters/player.gd:190` | `_on_animation_finished` | Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: movimento compartilhado, controles por jogador e animações básicas. |
| `scripts/characters/player.gd:195` | `_try_push_from_walk` | Tenta empurrar a partir do movimento e de um contato físico válido. |
| `scripts/characters/player.gd:206` | `_push_nearby_block` | Procura um bloco elegível para o pedido de empurrão. |
| `scripts/characters/player.gd:215` | `_request_push` | Encaminha força horizontal ao bloco e registra feedback de empurrão válido. |
| `scripts/characters/player.gd:221` | `_reset_nearby_pushable` | Restaura um objeto próximo elegível sem reiniciar a fase inteira. |
| `scripts/characters/player.gd:228` | `get_interact_action` | Retorna a ação de interação correspondente ao papel P1/P2 atual. |
| `scripts/characters/player.gd:232` | `get_ability_action` | Retorna a ação de habilidade correspondente ao papel P1/P2 atual. |
| `scripts/characters/player.gd:236` | `get_reset_action` | Retorna a ação de restauração local correspondente ao jogador. |
| `scripts/characters/player_2.gd:9` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: habilidade de ponte de Jake sobre a base compartilhada. |
| `scripts/core/journey_build.gd:7` | `label` | Cria e adiciona um rótulo com fonte e contorno padronizados. |
| `scripts/core/journey_build.gd:20` | `sprite` | Cria e adiciona um sprite com filtro Nearest e configuração local. |
| `scripts/core/journey_build.gd:32` | `packed` | Instancia e adiciona uma cena reutilizável na posição solicitada. |
| `scripts/core/journey_build.gd:40` | `actor` | Instancia o personagem solicitado e atribui seu papel de controle. |
| `scripts/core/journey_build.gd:50` | `collider` | Cria uma forma retangular local para o corpo informado. |
| `scripts/core/journey_build.gd:61` | `area` | Cria uma área de detecção de jogadores com tamanho e posição locais. |
| `scripts/core/journey_build.gd:72` | `wall` | Cria uma superfície física estática, sem regras adicionais de puzzle. |
| `scripts/core/journey_build.gd:83` | `plate` | Instancia uma placa com a regra de corpo/capacidade configurada. |
| `scripts/core/journey_build.gd:97` | `log_block` | Instancia o bloco empurrável e configura seu apoio inicial. |
| `scripts/core/journey_build.gd:110` | `gate` | Instancia o portão e alinha sua apresentação à superfície. |
| `scripts/core/journey_build.gd:134` | `tilemap` | Cria o mapa com o TileSet e deslocamento fornecidos. |
| `scripts/core/journey_build.gd:143` | `fill` | Preenche uma faixa de células do mapa; as coordenadas deste método são células, não pixels. |
| `scripts/core/journey_build.gd:148` | `background` | Configura o fundo preservando os recursos do ambiente. |
| `scripts/core/journey_build.gd:156` | `hud` | Instancia a interface comum da jornada. |
| `scripts/core/journey_build.gd:183` | `camera` | Configura a câmera compartilhada para a dupla e os limites da fase. |
| `scripts/core/journey_build.gd:196` | `safe_to_close` | Verifica jogadores/objetos na passagem antes de permitir fechar o portão. |
| `scripts/core/journey_build.gd:206` | `clean_actor` | Limpa a ação temporária do personagem antes de recuperação ou troca de dupla. |
| `scripts/core/journey_build.gd:215` | `controls` | Compõe a descrição das teclas correspondente ao papel atual do personagem. |
| `scripts/core/journey_build.gd:219` | `request_bridge_cancel` | Solicita o encerramento da ponte sem retirar apoio de um parceiro dependente. |
| `scripts/core/journey_build.gd:231` | `poll_bridge_cancel` | Reavalia um cancelamento pendente assim que os parceiros deixam a área de risco. |
| `scripts/core/journey_build.gd:237` | `restore_restart_role` | Recupera o papel de controle preservado pelo reinício da cena. |
| `scripts/core/journey_build.gd:245` | `restart` | Reinicia a cena guardando a configuração P1/P2 selecionada. |
| `scripts/core/journey_build.gd:250` | `bridge_deck` | Instala o desenho de largura completa na passagem permanente. |
| `scripts/core/journey_build.gd:259` | `sound` | Cria um reprodutor com o efeito sonoro disponível. |
| `scripts/core/journey_build.gd:268` | `style_button` | Aplica a aparência comum ao botão sem alterar sua ação. |
| `scripts/core/journey_build.gd:282` | `receiver_texture` | Retorna o recorte do receptor, excluindo pixels fora da região útil. |
| `scripts/core/shared_camera.gd:18` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: câmera compartilhada e limites do cenário. |
| `scripts/core/shared_camera.gd:30` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: câmera compartilhada e limites do cenário. |
| `scripts/levels/imported_phase_runtime.gd:6` | `configure_imported_phase` | Conecta a cena recebida aos controles, conclusão, recuperação e interface existentes. |
| `scripts/levels/imported_phase_runtime.gd:12` | `_cancel_local_actions` | Cancela interações locais antes de recuperar ou reiniciar a dupla. |
| `scripts/levels/imported_phase_runtime.gd:25` | `_on_imported_completion` | Recebe a conclusão da fase integrada e atualiza o encerramento disponível. |
| `scripts/levels/imported_phase_runtime.gd:32` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: integração comum das fases 3 e 4. |
| `scripts/levels/imported_phase_runtime.gd:39` | `_configure_respawn_markers` | Configura marcadores de retorno para os dois personagens ativos. |
| `scripts/levels/imported_phase_runtime.gd:52` | `_grounded_destination` | Calcula um destino cujo colisor se apoia na superfície consultada. |
| `scripts/levels/journey_level_1.gd:32` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: progressão cooperativa da Fase 1. |
| `scripts/levels/journey_level_1.gd:49` | `_build` | Constrói os nós e conexões locais definidos para a fase. |
| `scripts/levels/journey_level_1.gd:132` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: progressão cooperativa da Fase 1. |
| `scripts/levels/journey_level_1.gd:158` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: progressão cooperativa da Fase 1. |
| `scripts/levels/journey_level_1.gd:180` | `_note` | Atualiza a mensagem breve do objetivo ou estado atual. |
| `scripts/levels/journey_level_1.gd:185` | `_prepare_recovery` | Encerra estados temporários antes de reposicionar a dupla com segurança. |
| `scripts/levels/journey_level_1.gd:189` | `_recovered` | Restaura o estado local necessário após a recuperação. |
| `scripts/levels/journey_level_1.gd:193` | `_crystal_collected` | Registra a coleta única do cristal da fase. |
| `scripts/levels/journey_level_1.gd:198` | `_complete` | Executa o encerramento após a condição conjunta ser atendida. |
| `scripts/levels/journey_level_1.gd:220` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: progressão cooperativa da Fase 1. |
| `scripts/levels/level_2.gd:25` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: percurso e mecanismos da Fase 2. |
| `scripts/levels/level_2.gd:48` | `_build_terrain` | Preenche as células e superfícies previstas no percurso existente. |
| `scripts/levels/level_2.gd:66` | `_build_decoration` | Monta os elementos decorativos sem criar colisões adicionais. |
| `scripts/levels/level_2.gd:87` | `_unlock_first` | Libera a primeira etapa após a condição prevista ser cumprida. |
| `scripts/levels/level_2.gd:94` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: percurso e mecanismos da Fase 2. |
| `scripts/levels/level_2.gd:115` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: percurso e mecanismos da Fase 2. |
| `scripts/levels/level_2.gd:128` | `recover_pair` | Recupera os dois personagens preservando o progresso e a dupla correspondente ao setor. |
| `scripts/levels/level_2.gd:139` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: percurso e mecanismos da Fase 2. |
| `scripts/levels/level_2.gd:150` | `_setup_finish` | Conecta cristal e saída às condições de conclusão da fase. |
| `scripts/levels/level_2.gd:170` | `_complete_level` | Finaliza a fase uma única vez após a condição conjunta. |
| `scripts/levels/level_3.gd:15` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: progressão musical da Fase 3. |
| `scripts/levels/level_3.gd:28` | `_build_clue` | Monta a pista visual com símbolos legíveis para o terminal. |
| `scripts/levels/level_3.gd:62` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: progressão musical da Fase 3. |
| `scripts/levels/level_3.gd:88` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: progressão musical da Fase 3. |
| `scripts/levels/level_4.gd:17` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: transporte e energia da Fase 4. |
| `scripts/levels/level_4.gd:27` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: transporte e energia da Fase 4. |
| `scripts/levels/level_4.gd:55` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: transporte e energia da Fase 4. |
| `scripts/levels/level_4.gd:65` | `_setup_workshop` | Conecta transportador, bloco e terminais às referências da oficina. |
| `scripts/levels/level_6.gd:51` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: três setores e troca segura de duplas na Fase 6. |
| `scripts/levels/level_6.gd:71` | `_surface` | Desenha/cria a superfície local solicitada conforme o papel deste componente. |
| `scripts/levels/level_6.gd:84` | `_build` | Constrói os nós e conexões locais definidos para a fase. |
| `scripts/levels/level_6.gd:249` | `_activate_pair` | Instancia a dupla do setor com papéis consistentes, destinos separados e referências atualizadas. |
| `scripts/levels/level_6.gd:278` | `_set_presentation` | Atualiza a visibilidade dos objetos conforme o setor ativo. |
| `scripts/levels/level_6.gd:296` | `_advance_pair` | Executa a transição segura para a próxima dupla preservando setores concluídos. |
| `scripts/levels/level_6.gd:337` | `_repair` | Registra a parte restaurada e atualiza o feedback do portal. |
| `scripts/levels/level_6.gd:356` | `open_gate` | Abre a passagem pelo estado existente do mecanismo, sem duplicar efeitos. |
| `scripts/levels/level_6.gd:361` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: três setores e troca segura de duplas na Fase 6. |
| `scripts/levels/level_6.gd:390` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: três setores e troca segura de duplas na Fase 6. |
| `scripts/levels/level_6.gd:441` | `recover_pair` | Recupera os dois personagens preservando o progresso e a dupla correspondente ao setor. |
| `scripts/levels/level_6.gd:466` | `_crystal_collected` | Registra a coleta única do cristal da fase. |
| `scripts/levels/level_6.gd:471` | `_celebrate` | Inicia o encerramento estável e posiciona os seis personagens na celebração. |
| `scripts/levels/level_6.gd:498` | `_note` | Atualiza a mensagem breve do objetivo ou estado atual. |
| `scripts/levels/level_6.gd:503` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: três setores e troca segura de duplas na Fase 6. |
| `scripts/puzzles/checkpoint.gd:21` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: checkpoint conquistado e destinos de retorno. |
| `scripts/puzzles/checkpoint.gd:29` | `_arm_after_startup` | Arma a detecção após a inicialização para evitar conquistar o checkpoint ao criar a cena. |
| `scripts/puzzles/checkpoint.gd:36` | `set_recovery_in_progress` | Suspende/reabilita a conquista durante a recuperação da dupla. |
| `scripts/puzzles/checkpoint.gd:40` | `get_respawn_positions` | Retorna os dois destinos de recuperação sem conceder ativação do checkpoint. |
| `scripts/puzzles/checkpoint.gd:46` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: checkpoint conquistado e destinos de retorno. |
| `scripts/puzzles/cooperative_exit.gd:15` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: saída conjunta condicionada ao cristal. |
| `scripts/puzzles/cooperative_exit.gd:26` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: saída conjunta condicionada ao cristal. |
| `scripts/puzzles/cooperative_exit.gd:32` | `_on_body_exited` | Remove o corpo que saiu da área e atualiza as condições locais. Contexto: saída conjunta condicionada ao cristal. |
| `scripts/puzzles/cooperative_exit.gd:37` | `_try_complete` | Verifica cristal e presença conjunta antes de emitir a conclusão uma única vez. |
| `scripts/puzzles/cooperative_exit.gd:49` | `_on_crystal_collected` | Registra a coleta para a condição de saída. |
| `scripts/puzzles/crystal.gd:10` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: coleta única do cristal. |
| `scripts/puzzles/crystal.gd:15` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: coleta única do cristal. |
| `scripts/puzzles/fall_zone.gd:25` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: recuperação conjunta após queda. |
| `scripts/puzzles/fall_zone.gd:33` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: recuperação conjunta após queda. |
| `scripts/puzzles/fall_zone.gd:43` | `_respawn_both` | Seleciona destinos seguros e inicia uma única recuperação para a dupla. |
| `scripts/puzzles/fall_zone.gd:82` | `_complete_recovery` | Conclui a recuperação e libera a trava contra chamadas duplicadas. |
| `scripts/puzzles/fall_zone.gd:94` | `_starting_world_positions` | Converte as posições iniciais configuradas em destinos no mundo. |
| `scripts/puzzles/fall_zone.gd:102` | `_body_rect` | Calcula o retângulo físico do corpo na posição consultada. |
| `scripts/puzzles/fall_zone.gd:112` | `_has_floor` | Consulta apoio físico abaixo de uma posição candidata. |
| `scripts/puzzles/fall_zone.gd:123` | `_safe_position` | Avalia um destino com espaço livre e chão seguro. |
| `scripts/puzzles/fall_zone.gd:138` | `_safe_pair_near` | Procura dois destinos separados e seguros próximos da referência. |
| `scripts/puzzles/fall_zone.gd:151` | `_restore_obstructing_unsolved_log` | Restaura o bloco ainda não resolvido quando ele impede uma recuperação segura. |
| `scripts/puzzles/gate.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: sincronização visual/física do portão. |
| `scripts/puzzles/gate.gd:17` | `open_gate` | Abre a passagem pelo estado existente do mecanismo, sem duplicar efeitos. |
| `scripts/puzzles/gate.gd:21` | `_set_open_state` | Sincroniza textura e colisão com o estado aberto/fechado do portão. |
| `scripts/puzzles/imported_phase_checkpoint.gd:6` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: checkpoint das fases integradas. |
| `scripts/puzzles/journey_fall_zone.gd:5` | `_has_floor` | Consulta apoio físico abaixo de uma posição candidata. |
| `scripts/puzzles/journey_music.gd:4` | `can_play` | Verifica alcance, capacidade e estado necessários para a ação musical. |
| `scripts/puzzles/journey_music.gd:13` | `activate` | Executa a ativação deste mecanismo e atualiza seu estado. |
| `scripts/puzzles/journey_music.gd:16` | `_refresh` | Sincroniza texto e disponibilidade do mecanismo com o estado atual. |
| `scripts/puzzles/journey_plate.gd:9` | `_is_accepted` | Filtra o corpo por tipo/capacidade conforme a regra da placa. |
| `scripts/puzzles/journey_plate.gd:13` | `_set_visual` | Sincroniza o desenho da placa com seu estado físico/lógico. |
| `scripts/puzzles/journey_plate.gd:19` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: apresentação das placas da jornada. |
| `scripts/puzzles/journey_plate.gd:23` | `visual_state` | Expõe o estado visual da placa para apresentação e inspeção. |
| `scripts/puzzles/journey_plate.gd:26` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: apresentação das placas da jornada. |
| `scripts/puzzles/journey_terminal.gd:4` | `can_interact` | Verifica alcance, capacidade e disponibilidade para uma interação contextual. |
| `scripts/puzzles/journey_terminal.gd:8` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: terminal de sinal do portal. |
| `scripts/puzzles/lever.gd:16` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: alavanca autorizada por capacidade. |
| `scripts/puzzles/lever.gd:23` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: alavanca autorizada por capacidade. |
| `scripts/puzzles/lever.gd:30` | `activate` | Executa a ativação deste mecanismo e atualiza seu estado. |
| `scripts/puzzles/lever.gd:46` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: alavanca autorizada por capacidade. |
| `scripts/puzzles/lever.gd:52` | `_on_body_exited` | Remove o corpo que saiu da área e atualiza as condições locais. Contexto: alavanca autorizada por capacidade. |
| `scripts/puzzles/lever.gd:57` | `_refresh_prompt` | Recalcula a indicação da interação conforme os jogadores no alcance. |
| `scripts/puzzles/pressure_plate.gd:19` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: detecção dos corpos aceitos na placa. |
| `scripts/puzzles/pressure_plate.gd:26` | `is_active` | Retorna o estado de pressão atual da placa. |
| `scripts/puzzles/pressure_plate.gd:30` | `_on_body_entered` | Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: detecção dos corpos aceitos na placa. |
| `scripts/puzzles/pressure_plate.gd:41` | `_on_body_exited` | Remove o corpo que saiu da área e atualiza as condições locais. Contexto: detecção dos corpos aceitos na placa. |
| `scripts/puzzles/pressure_plate.gd:50` | `_is_accepted` | Filtra o corpo por tipo/capacidade conforme a regra da placa. |
| `scripts/puzzles/pressure_plate.gd:56` | `_set_visual` | Sincroniza o desenho da placa com seu estado físico/lógico. |
| `scripts/puzzles/push_block.gd:17` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: bloco empurrável e restauração local. |
| `scripts/puzzles/push_block.gd:25` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: bloco empurrável e restauração local. |
| `scripts/puzzles/push_block.gd:41` | `push` | Recebe o pedido de empurrão, validando movimento e apoio conforme a configuração. |
| `scripts/puzzles/push_block.gd:48` | `reset_to_start` | Restaura o objeto à origem e limpa a velocidade/estado temporário. |
| `scripts/puzzles/push_block.gd:65` | `play_push_sound` | Reproduz o feedback disponível para um empurrão válido. |
| `scripts/puzzles/push_block.gd:70` | `_supported_after` | Consulta se o deslocamento horizontal proposto ainda terá apoio seguro. |
| `scripts/puzzles/two_player_puzzle.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: confirmação simultânea em duas placas. |
| `scripts/puzzles/two_player_puzzle.gd:18` | `_check_solution` | Combina as condições das placas e libera o resultado quando a cooperação é satisfeita. |
| `scripts/puzzles/workshop_carrier.gd:11` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: transportador de bloco com espera segura. |
| `scripts/puzzles/workshop_carrier.gd:21` | `loaded` | Verifica se o bloco ocupa a região de carga do transportador. |
| `scripts/puzzles/workshop_carrier.gd:24` | `start_route` | Solicita o transporte quando a carga e o estado permitem. |
| `scripts/puzzles/workshop_carrier.gd:28` | `_physics_process` | Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: transportador de bloco com espera segura. |
| `scripts/puzzles/workshop_carrier.gd:50` | `reset_if_clear` | Restaura o transportador somente quando sua área de movimento está livre. |
| `scripts/puzzles/workshop_carrier.gd:57` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: transportador de bloco com espera segura. |
| `scripts/puzzles/workshop_connections.gd:15` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: alinhamento dos dois condutores e apresentação da energia. |
| `scripts/puzzles/workshop_connections.gd:41` | `_sprite` | Cria o sprite local mantendo sua escala nativa e referência de textura. |
| `scripts/puzzles/workshop_connections.gd:47` | `solved` | Retorna se os dois condutores estão na orientação que permite conectar energia. |
| `scripts/puzzles/workshop_connections.gd:50` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: alinhamento dos dois condutores e apresentação da energia. |
| `scripts/puzzles/workshop_connections.gd:62` | `_sync_art` | Atualiza orientação e receptor somente quando o estado visual muda. |
| `scripts/puzzles/workshop_connections.gd:74` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: alinhamento dos dois condutores e apresentação da energia. |
| `scripts/scenery/journey_surface.gd:7` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: desenho das superfícies da jornada. |
| `scripts/scenery/pixel_environment.gd:17` | `texture` | Carrega uma variante nativa já preparada; falha explicitamente se o tamanho não estiver no catálogo. |
| `scripts/scenery/portal_sanctuary.gd:23` | `_init` | Calcula uma única vez as células internas da abertura e os coeficientes fixos da onda. |
| `scripts/scenery/portal_sanctuary.gd:33` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: portal, interior animado e três luzes de reparo. |
| `scripts/scenery/portal_sanctuary.gd:39` | `light_states` | Retorna uma cópia do estado das três luzes, sem permitir modificar o progresso por referência. |
| `scripts/scenery/portal_sanctuary.gd:42` | `_octagon` | Desenha a peça octogonal usada nas luzes do portal. |
| `scripts/scenery/portal_sanctuary.gd:47` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: portal, interior animado e três luzes de reparo. |
| `scripts/scenery/portal_visual_clean.gd:11` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: apresentação visual legada do portal. |
| `scripts/scenery/region_scenery.gd:12` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: apresentação local das fases 2 a 4. |
| `scripts/scenery/region_scenery.gd:27` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: apresentação local das fases 2 a 4. |
| `scripts/scenery/region_scenery.gd:74` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: apresentação local das fases 2 a 4. |
| `scripts/scenery/region_scenery.gd:79` | `_configure_presentation` | Configura orientações locais e ajuda opcional sem alterar o menu principal. |
| `scripts/scenery/region_scenery.gd:104` | `_context` | Atualiza os prompts apenas para o objetivo e mecanismos relevantes ao estado atual. |
| `scripts/scenery/region_scenery.gd:130` | `_add_finish` | Adiciona o componente visual regional e o acabamento dos portões. |
| `scripts/scenery/region_scenery.gd:141` | `_finish_gates` | Percorre a hierarquia e instala uma única apresentação local em cada portão. |
| `scripts/scenery/regional_composition.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: vegetação, suspensões e variação de terreno das regiões. |
| `scripts/scenery/regional_composition.gd:24` | `prop` | Adiciona um recurso decorativo apoiado na superfície indicada. |
| `scripts/scenery/regional_composition.gd:36` | `_ice` | Distribui a decoração do Reino Gelado nos apoios existentes. |
| `scripts/scenery/regional_composition.gd:49` | `_cave` | Distribui a decoração da caverna nos apoios existentes. |
| `scripts/scenery/regional_composition.gd:62` | `_candy` | Distribui a decoração da oficina sem ocultar os mecanismos. |
| `scripts/scenery/regional_composition.gd:72` | `_skin_terrain` | Aplica variantes visuais em cópias locais do TileSet, preservando a geometria configurada. |
| `scripts/scenery/regional_composition.gd:102` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: vegetação, suspensões e variação de terreno das regiões. |
| `scripts/scenery/regional_composition.gd:110` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: vegetação, suspensões e variação de terreno das regiões. |
| `scripts/scenery/regional_gate_finish.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: folha e moldura dos portões regionais. |
| `scripts/scenery/regional_gate_finish.gd:28` | `_sprite` | Cria o sprite local mantendo sua escala nativa e referência de textura. |
| `scripts/scenery/regional_gate_finish.gd:37` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: folha e moldura dos portões regionais. |
| `scripts/scenery/regional_gate_finish.gd:41` | `_sync` | Sincroniza a folha visível com o estado do portão. |
| `scripts/scenery/regional_layout.gd:11` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: plataformas e integração local das regiões. |
| `scripts/scenery/regional_layout.gd:25` | `platform` | Cria a plataforma local e recorta a textura final na largura real do apoio. |
| `scripts/scenery/regional_layout.gd:43` | `_configure` | Conecta os objetos locais e alinha sua apresentação às superfícies existentes. |
| `scripts/scenery/regional_layout.gd:73` | `_check_duet` | Conquista a confirmação quando ambas as placas da dupla estão ativas. |
| `scripts/scenery/regional_layout.gd:80` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: plataformas e integração local das regiões. |
| `scripts/scenery/regional_layout.gd:93` | `_ground_fixture` | Ajusta somente o sprite pela sua região opaca, sem mover o corpo físico. |
| `scripts/scenery/sanctuary_masonry.gd:12` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: massas de terreno e túnel visual do santuário. |
| `scripts/scenery/sanctuary_masonry.gd:26` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: massas de terreno e túnel visual do santuário. |
| `scripts/scenery/sanctuary_masonry.gd:29` | `_surface` | Desenha/cria a superfície local solicitada conforme o papel deste componente. |
| `scripts/scenery/sanctuary_masonry.gd:34` | `_rock_polygon` | Desenha a massa rochosa com coordenadas UV coerentes. |
| `scripts/scenery/sanctuary_masonry.gd:39` | `_roots` | Repete o acabamento de raízes dentro da face do terreno. |
| `scripts/scenery/sanctuary_masonry.gd:45` | `_mass` | Desenha o volume inferior da massa de terreno, sem alterar sua superfície física. |
| `scripts/scenery/sanctuary_masonry.gd:50` | `_island` | Desenha bordas e espessura da ilha sobre a geometria existente. |
| `scripts/scenery/sanctuary_masonry.gd:57` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: massas de terreno e túnel visual do santuário. |
| `scripts/scenery/stage_scenery.gd:10` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: camadas decorativas das fases 1 e 6. |
| `scripts/scenery/stage_scenery.gd:37` | `thicket` | Adiciona vegetação nativa com raiz apoiada e movimento decorativo sutil. |
| `scripts/scenery/stage_scenery.gd:51` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: camadas decorativas das fases 1 e 6. |
| `scripts/scenery/stage_scenery.gd:60` | `plant` | Alinha a planta pela região opaca da textura; sua decoração não recebe colisão. |
| `scripts/scenery/stage_scenery.gd:81` | `tree_sprite` | Configura o recorte da árvore e seu movimento decorativo, preservando o apoio visual. |
| `scripts/scenery/stage_scenery.gd:97` | `_draw` | Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: camadas decorativas das fases 1 e 6. |
| `scripts/ui/friendship_ending.gd:4` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: celebração final com os seis personagens. |
| `scripts/ui/imported_phase_hud.gd:8` | `_enter_tree` | Prepara o componente antes da entrada de seus filhos na árvore. Contexto: interface das fases integradas. |
| `scripts/ui/imported_phase_hud.gd:13` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: interface das fases integradas. |
| `scripts/ui/imported_phase_hud.gd:33` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: interface das fases integradas. |
| `scripts/ui/imported_phase_hud.gd:56` | `show_completion` | Mostra o estado de conclusão e as opções de fluxo disponíveis. |
| `scripts/ui/phase_hud.gd:12` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: mensagens, cristal e conclusão na interface. |
| `scripts/ui/phase_hud.gd:26` | `_add_hud_backplate` | Cria o fundo de leitura da interface sem capturar entradas de movimento. |
| `scripts/ui/phase_hud.gd:44` | `set_crystal_collected` | Sincroniza a indicação do cristal com o estado de coleta. |
| `scripts/ui/phase_hud.gd:48` | `show_message` | Apresenta uma mensagem temporária com duração configurada. |
| `scripts/ui/phase_hud.gd:56` | `_hide_timed_message` | Oculta a mensagem ao terminar seu tempo de exibição. |
| `scripts/ui/phase_hud.gd:60` | `set_jake_bridge_prompt` | Atualiza a orientação contextual da habilidade de ponte. |
| `scripts/ui/phase_hud.gd:64` | `show_completion` | Mostra o estado de conclusão e as opções de fluxo disponíveis. |
| `scripts/ui/phase_hud.gd:70` | `_return_to_phase_select` | Retorna à seleção de fases pelo fluxo existente. |
| `scripts/ui/phase_select.gd:19` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: seleção das fases disponíveis. |
| `scripts/ui/phase_select.gd:25` | `_build_screen` | Constrói a seleção responsiva com as fases realmente disponíveis. |
| `scripts/ui/phase_select.gd:67` | `_add_phase_button` | Cria o botão da fase, mantendo indisponíveis as ainda não integradas. |
| `scripts/ui/phase_select.gd:81` | `_style_button` | Aplica estilos visuais e de foco ao botão. |
| `scripts/ui/phase_select.gd:100` | `_button_panel` | Cria o estilo de painel usado pelo botão. |
| `scripts/ui/phase_select.gd:115` | `_add_label` | Cria um rótulo com texto, tamanho e cor configurados. |
| `scripts/ui/phase_select.gd:132` | `_fit_design` | Ajusta a composição à janela preservando sua proporção. |
| `scripts/ui/quality_presentation.gd:16` | `_ready` | Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: ajuda opcional e apresentação contextual das jornadas. |
| `scripts/ui/quality_presentation.gd:50` | `_unhandled_key_input` | Trata comandos contextuais de teclado não consumidos pela interface. Contexto: ajuda opcional e apresentação contextual das jornadas. |
| `scripts/ui/quality_presentation.gd:59` | `_process` | Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: ajuda opcional e apresentação contextual das jornadas. |
| `scripts/ui/quality_presentation.gd:96` | `_exit_tree` | Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: ajuda opcional e apresentação contextual das jornadas. |
| `scripts/ui/quality_presentation.gd:104` | `fade_out` | Executa o escurecimento breve da transição e aguarda o tween terminar. |
| `scripts/ui/quality_presentation.gd:109` | `fade_in` | Restaura gradualmente a visão após a transição. |
