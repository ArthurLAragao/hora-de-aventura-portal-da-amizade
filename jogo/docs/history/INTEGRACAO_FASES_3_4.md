# Integração funcional das fases 3 e 4

Data: 27/10/2026. Godot preservado: 4.7.2.stable.official.ed1daf0bf.

## O que foi recebido e transferido

`level_3.tscn`, `level_3.gd`, `level_3.gd.uid`, `level_4.tscn`, `level_4.gd` e `level_4.gd.uid`, fornecidos em Downloads. Não existiam fases 3 e 4 nesses caminhos do projeto; nenhum trabalho anterior foi sobrescrito. As cópias exatas recebidas estão em `D:/TEMP/integracao-fases-3-4-2026-10-27/recebidos`.

## Ajustes de código

* Fase 3: referências de jogadores, checkpoint e retorno por queda estavam nulas; foram conectadas à dupla Marceline/BMO.
* Checkpoints dessas duas fases: a implementação compartilhada exige a passagem de Jake da Fase 1. Uma extensão local exige a porta musical anterior na Fase 3 ou a porta do tronco na Fase 4. Uma entrada física nova conquista o checkpoint; sua existência na cena não o ativa.
* Recuperação: os pontos recebidos estavam altos demais para a verificação de chão e os marcadores de checkpoint não consideravam os colisores atuais. Os destinos são apoiados por raycast contra o chão existente, considerando o corpo de cada personagem. Isso só configura o retorno; não move a dupla no percurso nem altera o terreno. A recuperação reaproveita `fall_zone.gd` e cancela ações locais de BMO/Marceline antes de mover a dupla.
* HUD: as cenas omitiam um filho opcional `JakeBridgeHint` exigido pela base. O adaptador local o cria oculto antes dos `@onready`, preservando as instruções recebidas de cada dupla.
* Fase 4: havia conexão duplicada do sinal de energia, no script e na cena. Mantida somente a conexão recebida na cena.
* Referências externas: removidos UIDs de dependências das cenas recebidas para usar os caminhos corretos deste projeto. Preservados os arquivos `.gd.uid` enviados.
* F2 reinicia as fases e libera interações. A saída conjunta apresenta a conclusão e a opção de voltar à seleção, encerrando os controles da dupla após concluir.
* Seleção: botões 3 e 4 habilitados com seus respectivos caminhos. A disposição visual do menu e o acesso anterior à Fase 1 foram preservados. As fases 2 e 6 continuam com o acesso anterior direto pelo editor.

## Preservação do design

Nenhuma edição de textura, tile, layout, posição de objetos, escala ou geometria de colisão nas cenas recebidas. Comparação das propriedades visuais/espaciais e dos dados de TileMap está em `ARQUIVOS.json`, no diretório externo da integração. Os únicos ajustes nos tscn são referências de scripts/recursos e caminhos necessários ao funcionamento. Não houve ajuste de personagens, movimentação ou cenas das fases 1, 2 e 6.

## Como jogar

F5 → Jogar → Fase 3 ou Fase 4. Também é possível abrir `level_3.tscn` ou `level_4.tscn` e pressionar F6.

P1: A/D, Espaço ou W, E. Na Fase 3, Q permite a flutuação limitada de Marceline. P2/BMO: setas laterais, seta para cima, Enter. No painel de símbolos, esquerda/direita escolhem e Enter confirma. Esc cancela; F2 reinicia. Na Fase 4, Finn empurra caminhando contra o tronco; R restaura um tronco próximo.

A sequência recebida da Fase 3 é círculo → triângulo → quadrado (0, 2, 1), configurável na raiz. Marceline aciona o painel musical; BMO opera símbolos e energia. A Fase 4 usa o tronco/placa e a ligação de energia de BMO.

## Verificações realizadas

* Percurso com renderização e entrada simulada pelo Input Map em ambas as fases: movimento, saltos, mecanismo musical, sequência, energia, tronco/placa, checkpoint, cristal e conclusão conjunta. Sem posicionamento por script e sem recuperação usados para completar esses percursos.
* Casos isolados preparados por script (não contam como travessia): quedas próximas dos dois personagens, retorno ao início, rejeição do checkpoint antes da porta anterior, retorno aos marcadores conquistados e preservação de progresso.
* Painel de BMO: a parceira continua andando, Escape cancela, queda fecha o painel e libera controles, e F2 restaura o estado inicial.
* Navegação real pelos sinais dos botões de seleção e retorno; verificação do menu principal e seleção em proporções 16:9 e 4:3.
* Regressão dos percursos já existentes das fases 1 e 2, com resultados sem falhas. Nenhum arquivo de gameplay compartilhado foi modificado.
* Inspeção de capturas reais do início, terminais e conclusão. O design recebido permanece simples e seu polimento visual fica para outra rodada.

Limites: teste automatizado de percurso em 1152×648 com papéis fixos recebidos (Marceline/Finn P1, BMO P2), sem avaliação humana com duas pessoas, sem áudio audível e sem build exportado. Houve uma falha isolada de acionamento musical em uma execução automatizada; três repetições seguintes passaram com alcance e estado da personagem confirmados, sem erros de execução. O registro dessa ocorrência foi preservado em `logs/routes-validated-console.txt`; não é tratado como aprovação manual de conforto. Texto duplicado/cortado da conclusão no mundo e acabamento dos elementos recebidos foram observados e deixados como pendências visuais, respeitando o pedido de não trabalhar no design agora.

## Arquivos e backup

Adicionados: os seis arquivos recebidos; `imported_phase_runtime.gd`, `imported_phase_checkpoint.gd`, `imported_phase_hud.gd`; dois testes `tests/verify_imported_levels.gd` e `tests/verify_imported_recovery.gd`; este documento. Metadados UID são gerados/preservados pelo Godot.

Alterados: `phase_select.gd`, `tests/verify_menu.gd` (expectativa das fases disponíveis) e `README.md`.

Backup externo dos arquivos anteriores: `D:/TEMP/integracao-fases-3-4-2026-10-27/backup-original`. Estado anterior completo por hashes: `baseline.json`. Originais enviados em Downloads permanecem intactos. Evidências e logs de desenvolvimento ficam fora dos recursos do jogo.

## Checklist manual

1. Abra cada fase pela seleção e confirme a dupla correta.
2. Na Fase 3, use E no painel musical; com BMO, insira a sequência e conecte energia.
3. Na Fase 4, empurre o tronco à placa e conecte a energia com Enter.
4. Caia antes e depois do checkpoint; confira ambos os retornos.
5. Cancele o painel com Esc e reinicie com F2.
6. Recupere o cristal, reúna a dupla na bandeira e volte à seleção.
