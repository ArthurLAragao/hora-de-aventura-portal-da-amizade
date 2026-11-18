# Arquitetura do jogo

## Fluxo

`project.godot` → menu em `Assets/04_Interface/Godot/main_menu.tscn` → `phase_select.tscn` → cena da fase. O seletor libera somente 1, 2, 3, 4 e 6. Não existe Fase 5 concluída nem Fase 7.

## Responsabilidades

| Área | Responsabilidade | Referências para estudar |
|---|---|---|
| Personagens | Movimento, salto tolerante, animação e capacidades | `scripts/characters/player.gd` e derivados |
| Pontes | Aproximação, transformação, apoio seguro e retração | `scripts/bridges/` |
| Interações | Alcance, autorização, operador local, cancelamento e conclusão | `mechanisms/` |
| Puzzles | Blocos, placas, portões, cristais, checkpoints e saída | `scripts/puzzles/` |
| Fases | Composição e progresso local | `scripts/levels/` |
| Apresentação | Fundo, terreno, portal e decoração, sem nova física | `scripts/scenery/` |
| Interface | Seleção, ajuda e mensagens | `scripts/ui/` |
| Construção | Pequenas fábricas de nós para as jornadas | `scripts/core/journey_build.gd` |

As cenas dinâmicas da Fase 1 são construídas por `journey_level_1.gd`; a Fase 6 por `level_6.gd`. `level_1.gd` é uma entrada pequena de compatibilidade e foi mantida. A estrutura existente não foi substituída por outro framework.

## Identidade e controles

`character_id` identifica a personagem; `player_id` escolhe as ações `p1_*`/`p2_*`; `has_ability()` consulta capacidades. Trocar os papéis não deve mudar as habilidades. Os valores de salto, gravidade e tolerância não foram alterados nesta otimização.

## Contratos de segurança

- Ponte: aproximação solicitada → extensão visual → apoio → espera por dependentes → retração → controle normal. Parceiro no ar sobre o vão também pode depender do apoio.
- Interação: somente o operador perde movimento; o proprietário da ação é responsável por concluir/cancelar e devolver o controle. Painéis não pausam globalmente o jogo.
- Checkpoint: só um checkpoint conquistado fornece destinos de retorno. Recuperação preserva progresso, limpa ações transitórias e não equivale a resolver um puzzle.
- Fase 6: uma dupla ativa por vez; a transição encerra ações, atualiza câmera/referências e preserva os setores concluídos.
- Cristal/saída: coleta e conclusão são idempotentes; a saída verifica as condições de cooperação existentes.

## Recursos e desempenho

As texturas de vegetação/rocha antes recortadas em execução agora estão em `Assets/02_Environments/runtime_prepared/`. Seus pixels são os resultados exatos do processamento anterior. `pixel_environment.gd` apenas carrega a variante registrada, deixando ResourceLoader reutilizar recursos vivos sem um cache estático de imagens.

Os quatro mecanismos extraídos da antiga sala de teste têm cenas próprias. A Fase 6 não precisa mais instanciar uma sala completa e descartá-la para obter um único objeto. A máscara fixa do portal é preparada uma vez; a animação continua com as mesmas células, cores e fase temporal.
