# Revisão de qualidade — fases 1 e 6

Godot 4.7.2, 27/10/2026. Versão candidata para nova avaliação humana. As aprovações de personagens anteriores não aprovam automaticamente os layouts e os ajustes desta revisão.

## Problemas reproduzidos e correções

| Problema | Evidência / causa confirmada | Correção | Verificação |
|---|---|---|---|
| Procurar a coordenada da ponte | A oferta antiga tinha apenas 8 unidades para Jake e 16 para Cake | Oferta ampla, marca fixa e caminhada assistida curta a 96 unidades/s, solicitada pelo jogador | P1/P2, aproximações nos dois sentidos e limites seguros, cancelamentos, parceiro/parede no trajeto, duas âncoras |
| Cake prendia a parceira na cabeça | Travessia caminhando parava no degrau do polígono, sem queda ou recuperação | Apoio plano e trecho central continuado atrás da cabeça, preservando extremidades e PNGs | Fionna caminha pelo centro e pela cabeça, sem salto para vencer esse relevo |
| Pés acima do terreno do portal | O alpha do tile começa na linha 17; o colisor estava na 11 | Tileset duplicado localmente e superfícies recortadas na linha correta; objetos locais acompanham a altura | Capturas reais de chão, degraus e terraço; corpos dos personagens preservados |
| Fragmentos no portal e indicadores | 14 pixels desconectados na imagem reparada e sombras separadas sob indicadores flutuantes | Composição localizada e recorte Atlas; originais preservados | Renderização do portal reparado e concluído |
| Portões com leitura confusa | Arte e corpo de dimensões diferentes, escala fracionária, filtro herdado; não se encontrou um pixel separado no PNG do portão | Recorte, nearest, escala inteira e corpo correspondente; portão aberto deixa de desenhar uma barreira translúcida | Estados fechado/aberto no percurso; a causa exata do pixel específico relatado no portão não foi reproduzida isoladamente |
| BMO coberto pelo terminal | Ordem de desenho do sprite jogável | Sprite do personagem à frente dos objetos | Painel aberto com BMO visível e Marceline controlável |
| Tronco permitia dispensar Jake | No original, apenas caminhando/empurrando e saltando, Finn levou o tronco sobre o vazio e cruzou sem ponte | O primeiro tronco encaixa e permanece; blocos dessas duas fases exigem chão sob o centro antes de mover | Tentativa repetida por entradas normais; nenhuma progressão atribuída por recuperação |
| Pista musical acessível sem o papel esperado | Degrau intermediário eliminava a distância de flutuação; área musical aceitava tentativa de baixo | Degraus de preparação e vão de flutuação legíveis; interação requer chão na prateleira real | Salto comum e interação de baixo recusados; percurso com flutuação e terminal completo |
| Tutorial e finais sobrepostos | Controles futuros, textos longos, conclusão duplicada e cortada | Objetivo atual, prompts locais com tecla correta, ajuda F1 opcional, mensagens temporárias e final limpo | Inspeção das capturas em duas resoluções |
| Entrada herdada na troca de dupla | Tecla mantida podia afetar a próxima dupla | Transição breve, nomes P1/P2, corpos antigos desativados, novos spawns assentados fisicamente, liberação após soltar as teclas | Teclas mantidas, reinício durante fade, câmera e duas entidades ativas |
| Reset de bloco dentro de personagem | Retorno imediato podia sobrepor o operador | Reset aguarda o destino desocupado e conclui automaticamente | Destino ocupado, afastamento e retorno seguro |

Variações de um pixel nos pés da caminhada foram preservadas como parte dos frames existentes; não se deslocou o corpo para mascará-las. Não foram alterados velocidade, gravidade ou altura global do salto.

## Como testar

Abra `level_1.tscn` ou `level_6.tscn` com F6. Na raiz, **Finn Player Id** ou **Primary Player Id** alterna entre 1 e 2; o parceiro recebe o outro papel. F5 mantém o menu e o fluxo da primeira fase. A Fase 6 continua independente das fases intermediárias.

P1: A/D, Espaço/W, E, Q. P2: setas laterais, seta para cima, Enter, Shift direito. Esc cancela a ação local; F2 reinicia completamente. R/Backspace repõe o bloco próximo quando permitido. F1 mostra controles sem pausar. No painel de BMO, esquerda/direita seleciona, interação confirma, Esc cancela.

As pontes oferecem a ação a partir de piso seguro e com caminho livre. A formação tem ponto fixo: ampliar a oferta não desloca o apoio final para fora das margens. A aproximação não atravessa chão, corpos ou paredes; pode ser cancelada. Uma entrada de salto normal ainda é necessária na subida do dorso. O apoio só é liberado após a composição completa renderizada; é mantido enquanto o parceiro está sobre o vão, inclusive no ar.

## Evidência e limites

Os percursos automatizados de `verify_journey_1` e `verify_journey_6` usam Input Map, sem reposicionar personagens ou atribuir progresso. Foram executados com papéis padrão/invertidos. As gravações desses percursos representam controle automatizado, não duas pessoas jogando.

`qa_bridge_matrix`, `verify_journey_safety` e `qa_progression_risks` usam também preparações isoladas declaradas para provocar bloqueios, quedas, cancelamentos e estados de transição. Essas preparações não contam como travessia normal. Os testes antigos que pressupunham a faixa estreita/ausência de aproximação não aprovam o novo comportamento: os adaptadores mantêm movimento/túnel e a matriz nova verifica a substituição autorizada. O teste de reset de Finn foi atualizado para exigir que não haja sobreposição.

A inspeção visual usa imagens reais do viewport do Godot, observadas após a renderização. A captura nativa Windows/OpenGL retornou cinza e não serve como prova de jogabilidade. Áudio executado com driver Dummy, sem avaliação auditiva. Não foram aprovados: diversão/conforto por duas pessoas, build exportado, outro computador, todas as resoluções ou avaliação fina da flutuação de Marceline. Testes em 1152×648 e 1280×720 cobrem apenas essas dimensões.

## Preservação

Backup externo integral e comparação dos arquivos antes da aplicação; nenhuma exclusão. PNGs, animações originais, túnel, menu, câmera compartilhada e HUD principal preservados. Fase 2 sem mudança de design: seu percurso existente foi regredido após as mudanças compartilhadas. Cristal/saída da Fase 2 continuam pendentes no estado anterior; não são apresentados como conclusão desta revisão. Fases 3–5 não implementadas.

BMO e Fionna continuam aprovados manualmente nas subetapas anteriores. Cake mantém aprovação anterior de movimento/túnel/poses, que não equivale a aprovar a ponte funcional ou esta revisão. Marceline não recebeu aprovação manual presumida.

## Checklist humano

- Ative Jake e Cake de vários pontos próximos da marca; solte e cancele durante a aproximação.
- Atravesse a ponte, pare e salte enquanto o outro jogador solta a habilidade.
- Confira pés, cabeça de Cake, portões abertos/fechados e portal na escala real.
- Conclua a Fase 1 com o tronco-degrau, placa de Jake, alavanca, checkpoint, cristal e ambos na saída.
- Conclua os três setores da Fase 6; mantenha teclas durante a troca e confira os nomes dos jogadores.
- Provoque uma queda antes/depois dos checkpoints, cancele terminal/manivela e reinicie com F2.
- Avalie se os objetivos curtos e os efeitos dos mecanismos permitem jogar sem conhecer o roteiro da automação.
