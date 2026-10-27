# Hora de Aventura: O Portal da Amizade

Atualização mais recente: [direção de arte e apresentação das fases 1 e 6](DIRECAO_ARTE_FINAL.md). Candidata para nova avaliação humana; não aprovada automaticamente pelos testes anteriores.

Projeto cooperativo local para dois jogadores, no **Godot 4.7.2**, com os assets existentes. Rodada atual: correção concentrada de qualidade das fases **1 e 6**. Consulte [REVISAO_QUALIDADE.md](REVISAO_QUALIDADE.md) para causas, correções e limites da validação. A Fase 2 foi preservada; as fases 3, 4 e 5 não foram implementadas nesta rodada.

## Abrir

1. Importe `project.godot` no Godot 4.7.2 e aguarde a importação normal.
2. **Fase 1:** F5 > Jogar > Fase 1, ou abra `level_1.tscn` e pressione F6.
3. **Fase 6:** abra `level_6.tscn` e pressione F6. Ela começa com Finn/Jake e funciona independentemente das fases 2–5. Os cinco cristais anteriores são contexto narrativo; não existe carregamento fictício de save.
4. A Fase 1 retorna à seleção ao terminar; não carrega a Fase 6 automaticamente. Menu e fluxo anterior foram preservados.

## Controles

| Ação | P1 | P2 |
|---|---|---|
| Movimento | A / D | Setas esquerda / direita |
| Salto | Espaço ou W | Seta para cima |
| Interação | E | Enter |
| Habilidade | Q | Shift direito |
| Restaurar bloco próximo | R | Backspace |

Na Fase 1, Finn empurra caminhando contra o tronco. Jake solicita a ponte perto da âncora e mantém a habilidade: ele caminha visivelmente até a marca antes de se esticar. Soltar, saltar, mudar para a direção oposta ou usar Esc cancela a aproximação. Fionna empurra caminhando, Cake entra no túnel por interação, Marceline usa habilidade no ar para flutuar e interação no painel musical, e BMO opera o terminal por interação.

**Esc:** cancelar ações locais com segurança (a ponte aguarda quem ainda depende dela). **F2:** reinício completo da fase, preservando a configuração de papéis do Inspector. Uma queda é recuperação e preserva o progresso conquistado; restaurar um objeto é reset local.

## Fase 1 — construir o caminho um para o outro

Início seguro → Finn leva o tronco à placa e libera o acesso → Jake sustenta a travessia de Finn → Finn aciona a alavanca e deixa passagem permanente para Jake → acampamento/checkpoint → segundo tronco serve de degrau para Jake → Jake mantém a placa superior, liberando o corredor inferior → Finn leva o mesmo tronco ao encaixe → portão fica aberto, cristal aparece energizado → saída conjunta.

A placa superior exige a capacidade de Jake e o encaixe exige o objeto. Finn não pode fazer tudo sozinho. O checkpoint só é conquistado por entrada física após reparar a passagem. A grade original 32×20 foi mantida.

Na raiz de `level_1.tscn`, **Finn Player Id = 1 ou 2**; Jake recebe o papel complementar.

## Fase 6 — um portal, três reparos

O mesmo santuário externo permanece visível enquanto três duplas restauram estrutura, mecanismo e sinal:

- **Finn/Jake:** passagem temporária até o contrapeso remoto. Finn posiciona o tronco, a conexão se torna permanente e os dois se reúnem nas placas com seus nomes.
- **Fionna/Cake:** Cake atravessa um túnel real e libera a manivela. Fionna reutiliza o tronco anterior como degrau, sobe e estende um apoio de retorno. Cake usa esse apoio e reencontra Fionna no terraço.
- **Marceline/BMO:** Marceline salta e flutua até o painel musical. A interação revela formas; BMO insere **triângulo → círculo → quadrado** no terminal. Esquerda/direita do próprio jogador selecionam; interação confirma; Esc cancela. A parceira continua controlável.

A última dupla confirma em duas placas, coleta o sexto cristal e entra junta no portal. Seis animações existentes compõem uma celebração estável; somente dois personagens são controlados durante o jogo. Não há Fase 7.

Na raiz de `level_6.tscn`, **Primary Player Id = 1 ou 2** define Finn, depois Fionna e Marceline no mesmo papel; os parceiros recebem o complementar. Cada troca encerra ações anteriores e atualiza a câmera. Queda conserva o setor e os reparos; F2 volta à primeira dupla.

## Estrutura e preservação

`level_1.gd` encaminha para `journey_level_1.gd`; as montagens são determinísticas e locais. `level_6.gd` monta o santuário. Os auxiliares `journey_*` reaproveitam cenas, regras e texturas existentes, preservando os PNGs originais. Os ajustes compartilhados estão identificados no relatório de qualidade. A passagem permanente usa a textura de madeira montada sem deformação sobre toda a largura do apoio.

`level_2.gd`, `level_2.tscn`, seus assets, túnel, terminais, manivelas, câmera compartilhada, menu e HUD principal permanecem sem alterações de design. Pontes, ordenação dos sprites e reset seguro de blocos receberam correções compartilhadas com regressão pertinente. A Fase 2 mantém seu estado anterior de cenário e percurso testável; este trabalho não a declara fase completa.

## Verificações atuais

```powershell
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/verify_journey_1.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/verify_journey_6.gd
& 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/verify_journey_safety.gd
```

Os dois primeiros percursos simulam as ações do Input Map, com papéis padrão/invertidos e sem reposicionamento. O ensaio de segurança usa preparações isoladas para provocar erros e quedas: elas não contam como travessia. `verify_journey_finn.gd` e `verify_journey_jake.gd` reutilizam as regressões das salas de personagens, substituindo somente a parte do ensaio antigo com coordenadas da Fase 1 anterior. Os ensaios históricos foram preservados; suas coordenadas antigas não validam o layout novo.

Também são pertinentes `verify_marceline`, `verify_bmo`, `verify_fionna`, `qa_cake_regression`, `verify_cake_bridge`, `verify_level_2` e `verify_menu` em `tests/`.

As fases novas exigem avaliação humana de clareza e conforto com duas pessoas. Foram exercitadas janelas de 1152×648 e 1280×720; isso não aprova todas as resoluções. Exportação, áudio ouvido, desempenho em outro computador e uso simultâneo por duas pessoas continuam sem validação nesta rodada. BMO, Fionna e as funcionalidades anteriores de Cake continuam com as aprovações manuais dadas pelo usuário; a avaliação fina de Marceline continua pendente.

F1 abre uma ajuda opcional de controles, sem pausar. Os objetivos normais mostram apenas a próxima ação. A ponte tem uma pequena subida de entrada que ainda se vence por salto normal; não houve mudança global de salto ou gravidade.
