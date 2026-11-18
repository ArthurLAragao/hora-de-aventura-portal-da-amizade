# Otimização e organização — 28/10/2026

## O que mudou

- Scripts agrupados por responsabilidade, preservando nomes/classes, UIDs e as cenas principais na raiz.
- Cinco scripts necessários ao jogo foram retirados da pasta de testes e promovidos a `mechanisms/`; a âncora de Cake usa diretamente o controlador real.
- Túnel, manivela, painel musical e terminal de símbolos agora têm cenas independentes. A Fase 6 não instancia salas de teste para extrair um único objeto.
- QA, matrizes grandes, folhas de revisão e ferramentas de autoria ficam fora da pasta de execução. Foram arquivados, não descartados. Créditos continuam em `docs/CREDITOS_E_FONTES.md`.
- Nove sprites nativos idênticos aos resultados anteriores substituem recorte, redimensionamento e varredura de alpha na inicialização das fases 1/6. Não houve nova arte.
- O portal calcula uma vez as células internas da abertura, raio e fase fixa da onda. A animação reutiliza esses coeficientes; a fórmula, cores, geometria e ritmo foram preservados.
- Código morto da antiga decoração e o helper de extração de salas foram retirados. A ajuda fechada não consulta o grupo de jogadores a cada quadro.
- Todas as 379 funções GDScript mantidas recebem comentário de propósito em português e índice em `CODIGO.md`. Shaders também têm descrição de seus métodos.

Não foram alterados saltos, gravidade, inputs, colisões, progressão, regras de pontes/túnel, checkpoints, sequências ou condições de conclusão. A Fase 5 permanece pendente e seus recursos foram preservados.

## Medidas e limites

O tamanho de recursos antes da edição era 96.080.465 bytes, excluindo `.godot` e `.git`. O tamanho final e do ZIP estão no relatório externo `delivery.json`. A diferença é material de QA/autoria separado, não uma redução artificial de resolução ou perda de conteúdo jogável.

Foram coletados startup, tempo de processamento ocioso, física, draw calls e memória nas cinco cenas. São amostras locais sensíveis a cache e carga do computador, não um benchmark isolado nem uma promessa de ganho de FPS. Os draw calls e a memória de texturas em repouso permaneceram essencialmente iguais: a otimização evita trabalho de preparação e reduz o pacote fonte, sem reduzir a qualidade visual. Não há alegação de menor uso permanente de VRAM.

## Verificação

- Percursos completos das fases 1, 2, 3, 4 e 6 via entradas, com papéis padrão/invertidos, diretamente no projeto limpo usando QA externo.
- Suíte atual de segurança: conquista e retorno de checkpoint, quedas, cancelamentos, transições, manutenção de progresso e reinícios.
- Recuperação/transportador das regiões, abertura/fechamento dos portões e estados do circuito.
- Menu e seletor: fluxo, cinco fases disponíveis, Fase 5 indisponível, apresentação responsiva.
- Referências literais de recursos sem arquivo ausente, ausência de dependências `res://tests/` e documentação de todas as funções.
- Sprites preparados conferidos byte a byte com o resultado original; células e coeficientes do portal comparados com a fórmula anterior.
- Capturas reais dos percursos inspecionadas. O projeto foi mantido no Godot 4.7.2; nenhuma dependência instalada.

Um teste legado de checkpoint pressupunha a hierarquia antiga e emitiu erros. Foi separado em `development/archive/legacy_qa/`, sem ser contabilizado como aprovação. O checkpoint atual foi validado pela suíte das jornadas. O teste legado de menu não gerava JSON; o runner atual registra sua saída explícita e seu código de retorno.

## Recuperação e entrega

Backup externo completo: `D:\TEMP\godot-optimization-2026-10-28\backup`.

Materiais de desenvolvimento: `D:\TEMP\godot-optimization-2026-10-28\development`. No GitHub ficam fora de `jogo/`.

O pacote ZIP exclui cache, QA, backups e matrizes. É um projeto fonte, não um build executável exportado. A pasta `.godot` existente não foi editada manualmente nem usada para inflar a medida de economia.

Pendente: novo teste humano de conforto com duas pessoas, áudio ouvido, exportação e outro computador. Não há promessa de zero bugs. A abertura das abas de apresentação é registrada separadamente, distinguindo o que foi observado no Godot de abas solicitadas no Codex.
