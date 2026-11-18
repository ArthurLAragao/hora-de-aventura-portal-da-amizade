# Apresentação da aventura — 05/11/2026

## Feedback registrado e prioridade

**Ponto crítico: design e composição das fases 2, 3, 4 e 5.** O usuário não aprovou o acabamento anterior dessas regiões. Os layouts das Fases 1 e 6 foram apreciados e ficam preservados. A plataforma da Fase 4 não foi tratada como defeito: o próprio usuário esclareceu que conseguiu operá-la.

Esta rodada concentra composição de cenário, HUD e passagem narrativa entre fases. Não redesenha as soluções dos puzzles nem aumenta distâncias de salto. A aprovação visual da nova versão continua dependendo do usuário.

## Cenário e identidade

| Fase | Trabalho desta rodada |
|---|---|
| 1 — Casa na Árvore | Cenário e layout intactos; recebe a HUD e a viagem para o Reino Gelado. |
| 2 — Reino Gelado | Fundação de rocha facetada, contraste do panorama reduzido, vegetação agrupada e estruturas congeladas ao fundo. Túneis, pontes e margens físicas preservados. |
| 3 — Caverna Musical | Planos de rocha, flora mineral e iluminação sutil, fundo com contraste menor e fundação menos ruidosa. Retirados detalhes suspensos sem apoio durante a inspeção. |
| 4 — Oficina Doce | Bases estruturais e tanques ao fundo conectam a apresentação das áreas de máquinas. Transporte do tronco, terminais e circuito mantidos. |
| 5 — Torre dos Espelhos | Contrafortes, bandeiras presas à estrutura, grupos decorativos apoiados e fundação de alvenaria. Feixes, espelhos, varandas e rastejo mantidos. |
| 6 — Portal | Cenário, sequência de duplas e celebração intactos; HUD acompanha cada dupla e desaparece no encerramento. |

O acabamento usa desenho nativo do Godot e assets locais. Nenhum PNG original foi sobrescrito. Não foram baixados assets nem adicionadas dependências. A composição é visual: nenhum colisor é criado pelo novo componente `habitat_finish.gd`; as lacunas do terreno são consultadas antes de desenhar as fundações.

## HUD personalizada

- Molduras discretas de metal/madeira, retratos originais e nomes de P1/P2.
- Emblema com seis encaixes numerados e cristais facetados: preenchimento, brilho e forma indicam conquista, além da cor.
- Texto: **Cristais recuperados · N/6**.
- Botões de Ajuda e Fases substituem os anteriores, evitando duplicação.
- Retratos acompanham os papéis invertidos e as trocas da Fase 6.
- HUD e diálogos reservam áreas separadas em todas as resoluções verificadas.
- Sem vidas artificiais: o jogo continua usando sua recuperação após quedas.

**Persistência:** o emblema registra os cristais realmente conquistados durante a sessão aberta do jogo. Mantém o registro ao repetir uma fase ou voltar ao menu, sem desbloquear o cristal ou a saída da nova tentativa. Fechar o jogo encerra esse registro; não é um sistema de save em disco. Abrir diretamente a Fase 6 não concede os cinco anteriores.

## Vinhetas entre fases

Ao selecionar **Próxima fase**, a dupla caminha numa vista do destino com suas animações originais e uma frase curta de ligação. Cada viagem dura aproximadamente 5,3 segundos; **Seguir viagem** permite antecipar. Não aparece ao abrir diretamente uma fase pelo editor/seletor, nem existe viagem para uma Fase 7.

A fase encerrada fica pausada durante a apresentação. A nova cena recebe os papéis de controle anteriores; a pausa é restaurada e as teclas precisam ser soltas antes de voltar ao jogo. As vinhetas não concedem solução, cristal ou checkpoint.

As falas existentes foram preservadas integralmente. No componente do diálogo, apenas o posicionamento responsivo e a proteção de uma chamada adiada durante saída de cena mudaram. Essa proteção corrige um erro real encontrado nesta rodada: o cálculo de altura tentava acessar a árvore após a cena sair.

## Validação e seus limites

- Percursos por entradas nas seis fases, P1/P2 padrão e invertidos, com coleta e conclusão. Nenhuma manipulação de posição usada como prova desses percursos.
- Testes isolados de HUD: dupla correta, seis encaixes, ausência de conquistas falsas, coleta idempotente, troca de dupla e manutenção do registro da sessão.
- Transições 1→2→3→4→5→6: saída automática e antecipada, corpos desativados pela conclusão, pausa, papéis e retorno à fase correta.
- Regressões de orientações, menu, conclusão e diálogos.
- HUD/telas em 800×450, 1024×768, 1280×720 e 1920×1080. Percursos executados na referência 1280×720; isso não equivale a repetir cada percurso em todas as resoluções.
- Renderização D3D12 no Godot 4.7.2, inspeção das capturas e gravação curta da vinheta. Capturas panorâmicas usam câmera de inspeção; não são evidência de travessia.
- Os testes de estados finais e emblema completo preparam estados exclusivamente para validar a interface. Não contam como coleta por percurso.
- Áudio executado com driver Dummy, sem avaliação auditiva. Não foram feitos testes com duas pessoas, exportação ou outro computador. Diversão, conforto e aprovação visual permanecem humanos.

O registro técnico externo contém os resultados atuais e os logs finais. Os testes intermediários que revelaram sobreposição ou erros de saída de cena não foram tratados como aprovação.

## Arquivos

Alterados: `level_2.tscn`, `level_3.tscn`, `level_4.tscn`, `level_5.tscn`, `scripts/ui/game_screens.gd`, `scripts/ui/friendship_story.gd`.

Adicionados: `scripts/scenery/habitat_finish.gd`, `scripts/ui/adventure_hud.gd`, `scripts/ui/journey_interlude.gd`, respectivos UIDs e este documento. QA fica em `development/qa`, fora de `jogo`.

`project.godot`, personagens, controles, habilidades, scripts de puzzles, Fase 1 e Fase 6 foram comparados com o backup. A configuração local preexistente de 1920×1080 não foi alterada ou incluída indiscriminadamente no commit.

## Backup e evidências

Backup externo integral, sem caches: `C:\Users\Ryzen\Documents\ChatGPT\SGDD\work\apresentacao-2026-11-05\backup`.

Evidências locais: diretórios `final`, `tests`, `video` e `validation.json` na mesma pasta. Imagens e gravação pesadas não são adicionadas ao repositório jogável.

## Checklist manual

1. Abra o projeto original, execute pelo menu e observe os retratos e o emblema em uma fase ainda não coletada.
2. Confira terreno, flora e planos de fundo nas Fases 2–5, sobretudo ao redor dos mecanismos.
3. Colete um cristal: deve preencher somente seu encaixe. Repita a fase: a saída ainda exige a coleta desta tentativa.
4. Termine a fase, escolha Próxima fase e experimente tanto assistir quanto antecipar a viagem.
5. Na Fase 6, confira os retratos ao trocar de dupla e a retirada da HUD na celebração.
6. Redimensione a janela e abra/feche a ajuda: o diálogo não deve ficar atrás da HUD, nem os controles presos.

Branch autorizada: `codex/revisao-qualidade-fases-1-6`. Sem force push ou alteração da main. Publicação em blocos revisados; histórico exato informado na entrega.
