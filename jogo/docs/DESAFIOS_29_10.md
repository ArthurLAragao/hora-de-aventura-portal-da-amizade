# Desafios e obstáculos — revisão para o item de 29/10

Revisão realizada em 02/11/2026 sobre o projeto otimizado atual, Godot 4.7.2. O cronograma fornecido define 29/10 como **Desafios do jogo: desafios e obstáculos programados**. Este documento organiza as evidências desse item; não acrescenta critérios de nota nem afirma que exportação, áudio ou controle físico foram avaliados.

## Resultado e prioridade

As seis fases possuem desafios programados e percursos completos executados com os dois papéis de controle. A revisão preservou cenário, colisões, movimentação, duração das habilidades e soluções dos puzzles. Corrigiu limites de progressão, reinício e concorrência nas Fases 2–4. Não foi necessário adicionar inimigos, dano, cronômetros, novos sistemas ou aumentar a dificuldade para demonstrar desafios.

A avaliação técnica indica manter o nível atual para teste com o público: o esforço deve vir da comunicação, do posicionamento e da leitura das consequências. Diversão, conforto e tempo de resolução por crianças ainda dependem de observação humana; não estão aprovados por esta revisão.

## Desafios por fase

| Fase | Desafios e obstáculos efetivamente programados | Contribuições da dupla | Feedback, erro e nova tentativa | Avaliação técnica |
|---|---|---|---|---|
| 1 — Trilha da Casa na Árvore | Tronco inicial e placa; vão com ponte de Jake; alavanca e passagem permanente; rotas complementares; tronco e encaixes finais; cristal e saída conjunta. | Finn move o tronco e opera a alavanca; Jake sustenta a travessia e ocupa o encaixe elevado enquanto Finn posiciona o objeto. | Portões/passagem mudam visivelmente; recuperação conjunta e checkpoint preservam soluções; reset local do tronco. | Apresentação gradual e combinação final preservadas. O salto comum sobre o vão da ponte foi recusado no teste isolado existente. |
| 2 — Passagem do Reino Gelado | Bloco usado como degrau; túnel com recuo; interruptor de Cake libera primeira manivela; cristas de gelo; ponte temporária e segunda passagem; cristal e saída. | Fionna posiciona bloco e opera manivelas; Cake acessa o caminho baixo, libera o mecanismo e sustenta a ponte no percurso demonstrado. | Postura impedida sob teto; plataformas aguardam espaço; bandeira sinaliza checkpoint; Esc/F2 permitem retomar. Cristal exige as duas passagens resolvidas. | Corrigidas progressão incompleta, ativação aérea do checkpoint, reinício e movimento após conclusão. Saltos alternativos que preservem o circuito cooperativo não foram tratados como erro. |
| 3 — Caverna Musical | Painel musical elevado; pista de três símbolos; terminal; ilhas de eco; conexão de energia; confirmação em duas placas; cristal e saída. | Marceline alcança e revela a pista; BMO reproduz a sequência e conecta energia; as duas confirmam a etapa final. | Pista visual, símbolos e nomes; sequência errada permite repetir; Esc libera o operador; a parceira continua controlável. | Preservada a separação entre comunicação/memória e o circuito espacial da oficina. Corrigida troca involuntária dos papéis ao reiniciar. |
| 4 — Oficina do Reino Doce | Carregamento do bloco; transportador operado por BMO; bloco sobre placa; dois condutores rotativos; conexão final; cristal e saída. | Finn carrega, posiciona e alinha o circuito; BMO transporta e energiza. | Plataforma espera quando alguém ocupa o caminho; reset do bloco restaura etapa não resolvida; encaixes mostram alinhamento; Esc cancela conexão. | Corrigidos giro duplo por entrada, mudança do circuito durante conexão e perda dos papéis no reinício. |
| 5 — Torre dos Espelhos | Primeiro receptor; túnel e espelho inferior; balcão e espelho superior; dois receptores finais simultâneos; cristal e saída. | Cake ajusta a rota inferior; Marceline alcança o ajuste elevado com salto/flutuação. | Feixes sem dano, formas além das cores, receptores ativos e portões persistentes. Limite de reflexões interrompe ciclos; checkpoint preserva progresso. | Não foi necessário aumentar sequências ou introduzir precisão extrema. Ação nos espelhos e feedback óptico mantidos. |
| 6 — Portal da Amizade | Estrutura com Finn/Jake; túnel, interruptor e manivela com Fionna/Cake; pista musical e terminal com Marceline/BMO; confirmação, sexto cristal e celebração. | Cada dupla restaura uma parte do mesmo portal; transições mantêm apenas dois atores controláveis. | Três luzes mostram os reparos; reuniões confirmam trocas; recuperação mantém setor e dupla corretos; conclusão exige confirmação, cristal e dupla. | Recombinação das habilidades preservada. Transições, ações pendentes e recuperação cobertas pelas regressões existentes. |

## Defeitos reproduzidos e corrigidos

| Problema | Reprodução isolada | Causa confirmada | Correção | Validação |
|---|---|---|---|---|
| F2 trocava os papéis nas Fases 2, 3 e 4 | Executar com papéis invertidos e reiniciar. | Recarga simples recriava os valores padrão do Inspector. | Reutilização de `journey_build.restart/restore_restart_role`; nenhum novo sistema de controles. | Mesmos casos passaram; percursos padrão/invertidos repetidos. |
| Checkpoint gelado ativava no ar | Com primeira passagem resolvida, aproximar a dupla pelo ar. | Condição verificava progresso e X, sem verificar apoio. | Exigir ambas no chão antes de conquistar. | Recusa aérea e aceitação após pouso. |
| Cake andava após conclusão da Fase 2 | Concluir e manter direção. | Controlador de Cake limpava a trava simples usada pela conclusão. | Desativar processamento dos dois atores após concluir; não alterar controlador compartilhado. | Posição estável e F2 funcional. |
| Cristal gelado podia ignorar primeira etapa | Preparar somente a segunda passagem e alcançar o cristal. | Disponibilidade consultava somente a manivela final. | Exigir primeira e segunda passagens concluídas. | Coleta antecipada recusada; percurso normal ainda coleta. |
| Uma entrada girava duas peças na oficina | Finn ocupa a sobreposição das áreas dos condutores e interage. | Cada área consumia separadamente o mesmo `just_pressed`. | Escolher uma única área elegível mais próxima; desempate determinístico. | Preparação confirmou duas áreas sobrepostas; uma só peça gira em P1/P2. |
| Circuito mudava enquanto BMO conectava | Alinhar, iniciar energia e girar com Finn durante a animação. | Peças continuavam aceitando comandos enquanto o terminal estava pendente. | Suspender giro durante conexão; Esc libera nova tentativa, conclusão trava o circuito. | Tentativa durante conexão recusada; cancelamento, realinhamento e ativação única passaram nos dois papéis. |

## Validação executada e limites

- Suítes externas: `verify_journey_1`, `verify_level_2`, `verify_final_regions` (3/4), `verify_mirror_tower`, `verify_journey_6`, `verify_journey_safety`, `verify_regional_states`, `verify_mirror_safety`, `verify_challenge_edges` e `verify_menu`.
- Percursos principais usam entradas de movimento/interação, sem posicionamento por script para concluir. Casos de erro preparam posições e estados isolados, e ficam explicitamente separados da evidência de percurso normal.
- Testes de limites incluem: reinício invertido, retorno antes/depois do checkpoint, quedas próximas, parceiro no ar ao soltar ponte, cancelamento, painel sem confirmação acidental, sequência errada/nova tentativa, parceira em movimento com painel aberto, energia repetida, ciclos ópticos, recusa de saída sem cristal/com uma personagem e trocas de dupla.
- Renderização D3D12, percursos em 1280×720 e 1152×648. O teste externo antigo da Fase 2 ignorava a resolução solicitada e fixava 1152×648: foi corrigido para respeitar e registrar o tamanho real. Isso altera o teste, não a resolução do jogo.
- Inspeção de capturas reais dos mecanismos e estados representativos das seis fases. Logs e PNGs ficam fora do projeto; um resumo pequeno acompanha o QA no repositório.
- Áudio desativado; não houve sessão com duas pessoas reais, crianças, outro computador ou build exportado. Não foram testadas todas as combinações possíveis de entrada. Aprovação humana de conforto não é inferida de testes automatizados.

## Diferenças do planejamento e pendências honestas

- O piso gelado mantém a física atual sem deslizamento adicional, conforme a decisão anterior. Isso não é apresentado como mecânica de gelo implementada. Testar deslizamento seria um ajuste localizado futuro de conforto, não requisito novo inferido do cronograma.
- A Torre utiliza balcões sobre piso seguro, não uma torre vertical punitiva. Recuperação por queda foi exercitada isoladamente; a ausência de buracos obrigatórios não é apresentada como travessia de vãos.
- Saltos alternativos em vãos curtos da Fase 2 merecem observação manual. A regra do cristal agora preserva a primeira contribuição cooperativa; não foram adicionadas paredes invisíveis para impor uma rota única.
- O SGDD sugere duração de 5–8 minutos por fase **a validar**. Não há medição com crianças que comprove esse intervalo, comunicação ou aprendizado.
- Remapeamento completo, controle físico, exportação e testes de áudio pertencem a itens próprios. Não são dados como concluídos para o item de desafios de 29/10.

## Roteiro curto para avaliação manual/apresentação

Abra o seletor com F5 ou `level_1.tscn` a `level_6.tscn` com F6. P1: A/D, Espaço/W, E, Q. P2: setas laterais, Cima, Enter, Shift direito. F2 reinicia; Esc cancela conforme o mecanismo.

1. Demonstre uma ação necessária de cada parceiro em cada fase (consulte a tabela).
2. Na Fase 2, confira a bandeira após pouso, as duas manivelas e a saída estável; repita com Cake P1.
3. Na Fase 3, insira uma sequência errada, mova Marceline com o painel aberto e tente novamente.
4. Na Fase 4, interaja entre os dois condutores e tente girar enquanto BMO conecta; cancele e conclua.
5. Nas Fases 1/2, solte a habilidade com o parceiro sobre a ponte e saltando sobre o vão.
6. Na Fase 5, erre um espelho e complete os dois receptores; na Fase 6, confira troca de dupla e celebração.
7. Observe se alguém fica sem participação, precisa de explicação externa ou não entende a consequência de uma ação. Esses achados são a próxima referência de ajuste de dificuldade, não a quantidade de testes.

## Arquivos e preservação

Código de execução alterado somente em `scripts/levels/level_2.gd`, `scripts/levels/imported_phase_runtime.gd` e `scripts/puzzles/workshop_connections.gd`. Cenários, texturas, personagens, controles e layouts preservados. A integração compartilhada afeta apenas as Fases 3/4; ambas foram repetidas do início ao fim. Backups, testes e capturas permanecem fora dos recursos do jogo. Não foi refeito ZIP nem exportado executável.
