# Conteúdo do jogo — item de 03/11

## Tema e proposta

O cronograma fornecido pede em 03/11: **situações, diálogos ou desafios que expressem o tema escolhido**. O tema é amizade e cooperação, apresentado pelo enredo do SGDD: amigos procuram cristais e restauram juntos o portal. Esta rodada acrescenta conteúdo às seis fases existentes; não cria outro requisito de avaliação nem altera as soluções dos desafios.

Foram integradas miniconversas com retratos originais, nome e papel atual do personagem. A abertura contextualiza o objetivo, conquistas recebem reações dos amigos, a primeira recuperação incentiva nova tentativa e os encerramentos reconhecem a contribuição da dupla. O portal conecta narrativamente os três reparos e encerra com o caminho de casa reconstruído pelos seis.

As conversas são vinhetas de diálogo **sem bloquear o jogo**. O texto aparece completo, com uma entrada suave. Não há dublagem nova, pausa global, movimento automático, teleporte, alteração de câmera ou recompensa concedida pela narrativa. As animações das ações e a transição de duplas continuam sendo as existentes.

## Evidência do tema em cada fase

| Fase | Situação narrativa | O que a criança pode perceber | Reação ligada ao jogo |
|---|---|---|---|
| 1 — Casa na Árvore | O portal falhou; Finn e Jake vão buscar o primeiro cristal. | Pedir e oferecer ajuda; deixar caminho para o amigo continuar. | A abertura da passagem permanente e o encaixe final geram falas de reconhecimento. |
| 2 — Reino Gelado | Duas rotas diferentes ajudam a atravessar o mesmo lugar. | Reciprocidade: Cake libera o mecanismo e Fionna deixa uma passagem de volta. | Interruptor, primeira manivela e passagem final possuem reações próprias. |
| 3 — Caverna Musical | Marceline encontra informações que BMO precisa usar. | Compartilhar o que se percebe e ouvir o parceiro. | Pista revelada, sequência resolvida e placas conjuntas recebem comentários. O terminal incentiva conferir a pista juntos após erro. |
| 4 — Oficina | Cada amigo assume uma parte da tarefa de restaurar a energia. | Dividir tarefas sem deixar uma pessoa fazer tudo. | Transporte, posicionamento do bloco e energia conectada são reconhecidos pelos personagens. |
| 5 — Torre | Uma amiga acessa caminhos que a outra não alcança. | Capacidades diferentes podem se complementar. | Primeiro sinal, circuito entre os espelhos e dois receptores finais geram falas específicas. |
| 6 — Portal | Cada dupla continua o trabalho da anterior. | O resultado é coletivo, não uma disputa por quem fez mais. | Cada nova dupla comenta o reparo anterior; a última restaura o sinal e os seis celebram o caminho de casa. |

## Apresentação e controles

Refinamento posterior: as dicas de tutorial e a legenda de comandos do cartão foram retiradas da tela. Os diálogos, o avanço automático e as teclas abaixo continuam funcionando. Consulte [APRESENTACAO_LIMPA.md](APRESENTACAO_LIMPA.md).

- Leitura automática com mínimo inicial de **7 segundos por fala**; frases maiores podem permanecer mais tempo. É um valor provisório, não uma validação de velocidade de leitura para crianças.
- **Tab** passa para a próxima fala. **F3** relê a conversa mais recente. Saltar uma fala não resolve puzzles nem avança a fase.
- Movimento, salto, interação e habilidade mantêm seus controles. O cartão não toma foco nem captura esses comandos.
- Só um cartão aparece por vez, no alto à direita, afastado do chão e do HUD principal. Uma conquista pode substituir uma introdução que ficou para trás. A fila é limitada para não acumular explicações atrasadas.
- Painel do terminal, ajuda, recuperação e troca de dupla têm prioridade. Conversas anteriores são retiradas quando o contexto muda; a nova dupla fala após receber seus controles.
- A celebração final não fica coberta pelo cartão. Sua mensagem agora liga o portal à contribuição dos seis amigos.
- A primeira recuperação usa uma fala de incentivo, sem culpa. Não repete a introdução após cada queda; o reinício completo por F2 começa a história da fase novamente.
- A Fase 6 apresenta os cristais anteriores como contexto narrativo. Não houve criação de save nem carregamento fictício de progresso global.

## Onde editar

`scripts/content/friendship_lines.gd` contém as falas originais em português. Cada entrada tem personagem e texto. As chaves `intro`, `first`, `passage`, `cooperation`, `crystal` e `ending` correspondem a momentos da fase; `pair1` e `pair2` pertencem às trocas do portal.

`scripts/ui/friendship_story.gd` lê os estados conquistados, escolhe os retratos e apresenta o cartão. Não escreve nas condições dos puzzles. Na raiz de cada cena, selecione o filho `FriendshipStory`: `enabled` permite desativar as falas e `minimum_read_seconds` regula o tempo mínimo. `phase` identifica o roteiro da cena e deve manter o valor configurado.

As seis cenas receberam somente o recurso e o nó de apresentação. Terreno, colisões, instâncias, posições e scripts de gameplay anteriores foram conferidos contra o backup. Em `mechanisms/bmo_terminal.gd`, apenas a frase de erro mudou; em `friendship_ending.gd`, apenas o subtítulo da celebração.

## Validação e limites

Foram executados percursos completos das seis fases com os papéis padrão/invertidos, em 1280×720 e 1152×648, com a nova apresentação ativa. Regressões de pontes, túneis, terminal, energia, checkpoints, recuperação, cristal, saída e transições mantidas. Capturas renderizadas foram inspecionadas; um problema de altura inicial do cartão foi encontrado e corrigido antes da entrega.

O QA narrativo externo verifica abertura, identificação P1/P2, retrato, limites do cartão, movimento durante falas, Tab/F3, tempo automático, evento único, prioridade do terminal, recuperação, troca de dupla e reinício. Alguns estados são preparados por script nesses testes isolados; isso não conta como percurso normal. As regressões de percurso usam entradas reais de ação, sem reposicionar personagens para concluir.

A gravação da abertura mostra o jogo executando, a fala de Finn, a resposta de Jake e movimento por entradas. Não é uma montagem visual. O áudio foi desativado na validação; não há vozes novas. Compreensão, velocidade de leitura e conforto ainda precisam da avaliação do usuário e, idealmente, de crianças; não são comprovados pela automação.

## Demonstração curta à professora

1. Executar a Fase 1: deixar Finn explicar o problema e Jake responder. Andar durante a conversa mostra que a leitura não bloqueia a ação.
2. Mostrar uma conquista cooperativa e a reação correspondente. Na Fase 3, explicar que compartilhar a pista faz parte do tema, não só acertar símbolos.
3. Errar no terminal e conferir a mensagem de nova tentativa; ou demonstrar uma recuperação segura e o incentivo da dupla.
4. Na Fase 6, concluir um setor e observar a próxima dupla continuar o trabalho. A celebração reconhece os seis.
5. Usar Tab para adiantar e F3 para reler se necessário. Não apresentar preparação de estados de QA como travessia ou progresso normal.

## Falas implementadas

Os textos abaixo são conteúdo ficcional criado para o projeto, não transcrições oficiais da série.

### Fase 1

**Abertura**

- Finn: O portal quebrou e espalhou os cristais. Vamos buscar o primeiro!
- Jake: Vou com você. Ninguém fica para trás!

**Primeira conquista**

- Jake: Um caminho aberto! Agora posso ajudar na travessia.

**Caminho aberto**

- Jake: Você abriu a passagem! Agora também posso atravessar.

**Cooperação reconhecida**

- Finn: Seu caminho por cima ajudou meu tronco a chegar!

**Cristal**

- Jake: Um cristal! Ele vai ajudar a consertar o portal.

**Encerramento**

- Finn: A trilha era difícil sozinho. Em dupla, deu certo!
- Jake: Vamos encontrar os outros. Ainda faltam cristais!

### Fase 2

**Abertura**

- Fionna: Há um cristal depois das pontes de gelo.
- Cake: Eu vejo uma passagem pequena. Vamos abrir caminho juntas!

**Primeira conquista**

- Cake: Achei o interruptor! Agora você pode girar a manivela.

**Caminho aberto**

- Fionna: Você abriu o mecanismo; eu abri a passagem. Boa parceria!

**Cooperação reconhecida**

- Cake: Você deixou um caminho para mim também. Obrigada!

**Cristal**

- Fionna: Outro cristal para o portal. Vamos levá-lo juntas!

**Encerramento**

- Cake: A gente se ajudou dos dois lados do gelo.
- Fionna: É assim que as duas conseguem seguir!

### Fase 3

**Abertura**

- Marceline: Esta caverna guarda uma pista para achar o cristal.
- BMO: Eu leio símbolos! Você me conta o que encontrar?

**Primeira conquista**

- Marceline: A música revelou três formas. Vamos olhar a mesma pista.

**Caminho aberto**

- BMO: Você encontrou a pista e eu completei a sequência!

**Cooperação reconhecida**

- Marceline: As duas placas acenderam. Estamos na mesma sintonia!

**Cristal**

- BMO: Cristal encontrado. O portal está mais perto de voltar!

**Encerramento**

- Marceline: Contar o que eu vi fez toda a diferença.
- BMO: Ouvir um amigo também ajuda a resolver desafios!

### Fase 4

**Abertura**

- Finn: A oficina parou. Sem energia, não alcançamos o cristal.
- BMO: Eu cuido da máquina. Você me ajuda com o bloco?

**Primeira conquista**

- BMO: Entrega feita! Obrigado por preparar a carga, Finn.

**Caminho aberto**

- Finn: O bloco chegou ao lugar certo. Agora falta ligar a energia.

**Cooperação reconhecida**

- BMO: Você alinhou os tubos; eu fiz a conexão. Funcionou!

**Cristal**

- Finn: Mais um cristal! Nosso trabalho em equipe valeu a pena.

**Encerramento**

- BMO: Cada um fez uma parte da mesma tarefa.
- Finn: E ninguém precisou fazer tudo sozinho!

### Fase 5

**Abertura**

- Cake: O cristal está na torre, mas os portões estão fechados.
- Marceline: Vamos guiar a luz. Eu vejo os espelhos de cima!

**Primeira conquista**

- Marceline: A luz acendeu o sinal! Podemos repetir a ideia juntas.

**Caminho aberto**

- Cake: Meu espelho e o seu formaram um só caminho de luz!

**Cooperação reconhecida**

- Marceline: Dois sinais acesos. Cada uma alcançou uma parte importante.

**Cristal**

- Cake: O quinto cristal! Agora vamos ajudar a restaurar o portal.

**Encerramento**

- Marceline: Você viu caminhos que eu não conseguia alcançar.
- Cake: Juntas, vimos a solução inteira!

### Fase 6

**Abertura**

- Finn: Os cristais chegaram. Agora precisamos reconstruir o portal.
- Jake: Vamos preparar o acesso para nossos amigos!

**Primeira conquista**

- Jake: A base está firme. Já podemos chamar a próxima dupla!

**Chegada de Fionna e Cake**

- Fionna: Finn e Jake prepararam o acesso. Nossa vez de ajudar!
- Cake: Eu abro o caminho pequeno; você cuida da manivela.

**Chegada de Marceline e BMO**

- Marceline: A estrutura e o mecanismo voltaram. Falta o sinal!
- BMO: Você revela as formas, e eu conecto o portal.

**Caminho aberto**

- Marceline: A pista apareceu. Vou compartilhar as formas com você!

**Cooperação reconhecida**

- BMO: Sinal recebido! Todos os amigos ajudaram neste reparo.

**Cristal**

- Marceline: O último cristal! Vamos concluir esta parte juntos.

## Falas transversais

- Primeira recuperação: “Tudo bem. Vamos tentar de novo em dupla!”
- Sequência incorreta no terminal: “Tudo bem! Confiram a pista juntos e tentem de novo.”
- Celebração: “Cada amigo trouxe uma parte. Juntos, encontramos o caminho de casa.”
