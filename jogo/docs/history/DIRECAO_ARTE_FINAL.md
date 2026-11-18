# Direção de arte e apresentação — candidata 27/10/2026

Esta rodada atende à nova reprovação visual das fases 1 e 6. Os resultados anteriores não foram tratados como aprovação humana. Godot 4.7.2 preservado. Nenhum redesenho de puzzles ou da Fase 2.

## Causas e alterações

| Problema | Causa confirmada | Correção localizada |
|---|---|---|
| Placas invisíveis na Fase 1 | Sprite em Z=-1, atrás do terreno Z=0; textura 64×64 com conteúdo abaixo da linha do chão | Representação local em Z=1, abaixo dos personagens Z=2, sem mudar Area2D; bordas expostas durante pressão e emblema lateral preso à base |
| Reunião/confirmadores ocultos | A apresentação escondia as áreas até os pré-requisitos | Visíveis no setor ativo desde o início: inativos, disponíveis, pressionados e concluídos; emblemas e mudança de altura/check distinguem estados sem depender só de cor |
| Confusão entre placa, botão e reunião | Mesma apresentação pouco visível | Placa de peso com tampo/rim; reunião com inlay e duas balizas; interruptor usa seu sprite e uma tecla somente no alcance válido |
| Portal flutuante e destoante | Base do sprite anterior avançava sobre o vão; escala/detalhe não favoreciam o contato | Nova variante raster com base integrada, paleta de pedra azul/brass e contorno pixelado; proporção uniforme e recorte Atlas; assentada inteira na margem direita |
| Selos soltos no céu | Receptores independentes em Y fixo | Agora dentro dos três encaixes da coroa; off/on e check existentes preservados |
| Vegetação flutuante | Plantas do portal têm alpha terminando em 29/30, mas usavam offset de textura cheia 32 | Cada sprite alinhado pelo alpha e pela superfície do seu grupo; composição por bordas, acampamento e clareiras, não dispersão aleatória |
| Floresta sem volumes | Apenas pequenas plantas espaçadas | Três árvores intermediárias, arbustos agrupados e bordas discretas de madeira; fundo original preservado |
| Objetos suspensos e texto técnico | Indicador musical sem apoio, botão do túnel longe do alcance real, alvos/nomes de teste | Indicadores alinhados ao painel e ao chão; marcador técnico de reset ocultado; nomes/contexto somente quando relevantes |
| Final em painel de protótipo | Cartão grande e controles de retorno disputando mensagens | Palco texturizado, seis animações existentes alinhadas, mensagem curta e botões separados para seleção e menu; HUD e indicador musical ocultados no encerramento |

O único ajuste de geometria de mecanismo é a área da saída final: centro X=640 → 688, largura 160 → 112, alinhada à entrada do novo portal sobre o chão. Terreno, obstáculos, movimento, pontes e gatilhos das placas não mudaram. A chegada final de Marceline usa um salto normal para subir da passagem à margem, sem teleporte. O cristal e os requisitos de conclusão conjunta foram preservados.

## Recursos

PNG novos, sem sobrescrever originais:

- `Assets/02_Environments/01_tree_house/tree_midground_v2.png`
- `Assets/03_Objects_and_Puzzles/sprites/portal_sanctuary_v2.png`

Essas duas variantes foram criadas com a ferramenta imagegen usando um contato dos assets internos como referência de paleta, contorno e pixel art. Não houve download de pacote externo. Um ensaio vetorial que destoava foi descartado antes da aplicação ao original. Recortes são Atlas/retângulos no Godot; os PNGs gerados e os originais permanecem preservados. Escalas uniformes, nearest somente nos novos elementos, nenhuma mudança global de filtragem. O efeito de energia do portal é a animação já existente em `Assets/05_Effects/frames/portal`.

## Camadas e leitura

Fundo existente → árvores intermediárias em Z=-3 → terreno e frisos abaixo da linha de caminhada → plantas apoiadas e mecanismos → placas Z=1 → personagens Z=2. A decoração evita entradas, pés e áreas de pressão. Não foram adicionadas colisões à decoração. Emblemas de peso e ligações discretas no solo relacionam encaixes e portões. Uma tecla só aparece em ações de interação, não nas placas automáticas.

Cabeçalho compacto com objetivo imediato, identificação breve de papéis na troca e ajuda F1 opcional. Esc fecha a ajuda/cancela a ação local; F2 reinicia. A ajuda não pausa globalmente nem começa aberta. Não se criou um sistema novo de pausa.

## Verificação

Percursos normais automatizados das fases 1 e 6, papéis padrão/invertidos, 1152×648 e 1280×720. `qa_art_states.gd` prepara estados isolados e captura placas antes/durante/depois, após recuperação, troca e reinício; verifica também pixels efetivamente renderizados e alinhamento do alpha da vegetação. Preparações isoladas não contam como percurso normal. Regressões de segurança, pontes, túnel, manivela, terminal, cristal, saída e percurso existente da Fase 2. A celebração verifica seis sprites e botões dentro do quadro. Capturas abertas e inspecionadas, incluindo detalhes ampliados.

Os logs do ambiente restrito podem registrar acesso ao repositório de certificados ou cache de shader; eles são separados dos resultados finais no original. A importação padrão pelo próprio Godot é usada, sem editar `.godot` manualmente.

## Avaliação ainda pendente

Aparência, conforto e clareza da candidata dependem de novo teste humano. Não se presume aprovação de Marceline, ponte de Cake, duas pessoas jogando, áudio ouvido (Dummy nos ensaios), exportação, outro computador ou todas as resoluções. BMO/Fionna e movimento/túnel/poses de Cake mantêm apenas suas aprovações anteriores. A Fase 2 mantém as pendências anteriores de cristal e conclusão conjunta.

## Checklist curto

- Placas aparecem antes de chegar? Continuam visíveis sob Jake e sob o tronco? O estado resolvido é reconhecível?
- As áreas de reunião distinguem-se de botões de interação e não mostram tecla indevida?
- Árvores, plantas, painel e portal parecem apoiados? Alguma decoração cobre mecanismo ou pés?
- As pontes, checkpoint e os três setores continuam confortáveis com papéis invertidos?
- O portal reparado, cristal e celebração comunicam o final sem texto cortado ou sobreposição?
- F1/Esc/F2 e os botões de seleção/menu funcionam como esperado?
