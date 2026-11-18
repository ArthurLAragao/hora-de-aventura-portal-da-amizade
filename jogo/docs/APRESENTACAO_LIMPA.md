# Apresentação limpa — 03/11/2026

A pedido do usuário, foram retirados da apresentação normal das seis fases os textos flutuantes de tutorial, ordens de ação, teclas de habilidade/interação, lembretes de reset, faixas de objetivo e legendas técnicas. As miniconversas permanecem no cenário com retrato, personagem e fala. O rodapé de comandos do cartão também foi ocultado; Tab e F3 continuam funcionando.

## Preservado

- Terreno, arte, posições, colisões, personagens e controles.
- Pontes, túneis, manivelas, placas, terminais, checkpoints, cristal e conclusão.
- Pistas necessárias: símbolos dos espelhos, pista musical e sequência de referência.
- Seleção, progresso, erro e comandos do painel do terminal, exibidos somente ao operá-lo.
- Ajuda opcional aberta voluntariamente, opções de navegação e celebração final.
- Todas as falas aprovadas e a identificação do personagem que está falando.

## Implementação

`scripts/ui/clean_phase_presentation.gd` é um observador de apresentação, adicionado como filho `CleanPresentation` nas seis cenas. Ele configura os controles existentes e os que são criados durante a execução. Os textos de tutorial usam camada de desenho zero, independentemente de atualizações posteriores de `text`/`visible`. Não há varredura em cada quadro, exclusão de nós ou mudança nas variáveis usadas pelo gameplay.

Pistas, conversas, celebração, símbolos e painéis abertos voluntariamente são preservados. Isso mantém o cenário limpo sem inutilizar interfaces necessárias para resolver os desafios. Os campos internos de mensagem permanecem compatíveis com os controladores existentes.

Em `friendship_story.gd`, somente a exibição do rodapé foi alterada. As seis cenas receberam apenas recurso/nó de apresentação; o restante foi comparado ao backup. Não houve alteração em scripts de movimentação, câmera, pontes, recuperação ou lógica dos puzzles.

## Verificação

O QA externo `verify_clean_presentation` confere as seis fases em P1/P2: diálogos, ocultação dos tutoriais, atualização posterior de prompt, painel do terminal, pistas, símbolos e troca de dupla. Posições e conquistas preparadas nesses casos são apenas fixtures de apresentação, não prova de percurso normal.

As suítes de percurso e de diálogos foram executadas separadamente. Capturas reais foram inspecionadas para conferir o resultado efetivamente desenhado. A primeira execução gráfica completa da Fase 2 excedeu o limite de tempo; a repetição isolada, com janela de QA visível, concluiu. Esse limite não foi contado como teste aprovado. Uma captura adicional em lote dos diálogos em 1152×648 também excedeu o prazo; a repetição funcional sem salvar imagens passou. A inspeção dedicada com capturas das seis fases em 1152×648 passou separadamente.

Não houve teste novo com duas pessoas, áudio, outro computador ou build exportado. O refinamento visual aguarda avaliação manual do usuário.

## Checklist manual

1. Abrir qualquer fase com F6: confirmar ausência da faixa de tutorial e presença da conversa.
2. Aproximar-se de ponte, tronco, túnel e manivela: os objetos continuam funcionando sem frases ou teclas sobre eles.
3. Abrir o terminal: símbolos, seleção e progresso permanecem visíveis.
4. Conferir uma pista, coletar o cristal e concluir em dupla; observar os diálogos e a celebração.
5. Se necessário, Tab avança a fala e F3 relê; ajuda e navegação continuam disponíveis.
