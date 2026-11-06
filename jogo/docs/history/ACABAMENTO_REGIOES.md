> Registro de rodada anterior. Estado atual: [entrega de 28/10](FASES_2_3_4_ENTREGA.md).

# Acabamento visual localizado — fases 2, 3 e 4

## Alterações
- Portões das fases 3 e 4: desenho local em grade de pixels, moldura integrada e folha fechada com as medidas do colisor existente. O estado aberto deixa a passagem visivelmente livre. A apresentação acompanha `is_open`; nenhuma segunda regra de ativação.
- Reino Gelado: vegetação fria apoiada, contorno interno contínuo do túnel, mantendo o recuo e a altura livre.
- Caverna: vegetação mineral discreta e marcas no volume inferior do terreno, combinadas com os cristais existentes.
- Oficina: pequenos canteiros, reforços de alvenaria, objetos em escalas inteiras. Retirada a oscilação angular das engrenagens para preservar os contornos; a iluminação discreta permanece.
- Folhas com movimento pequeno em passos inteiros, raízes fixas. Nenhuma nova colisão.

A arte nova é desenhada por scripts locais do Godot. Não houve geração/substituição de PNGs, downloads ou alteração de filtragem global. Os originais e as cenas físicas foram preservados. As fases 1 e 6 continuam finalizadas conforme a aprovação anterior; fase 5 continua aguardando o molde.

## Arquivos
Alterado: `region_scenery.gd`.
Adicionados: `regional_details.gd`, `regional_gate_finish.gd`, seus UIDs, `tests/verify_regional_finish.gd` e este relatório.
Backup anterior: `D:/TEMP/acabamento-regioes-2026-10-27/backup`.
Manifesto e baseline completos estão na pasta externa.

## Verificação
Godot 4.7.2, sem migração.
- Fases 3/4: percursos com entradas simuladas e renderização em 1152×648 e 1280×720, incluindo mecanismos, cristal e saída conjunta; nenhum erro reportado.
- Testes visuais isolados nas duas resoluções: portão fechado corresponde à forma existente; aberto acompanha o mesmo estado físico; decoração sem corpos físicos. A abertura por script nesses testes serve somente para conferir estados, não como prova de percurso.
- Inspeção humana pelo assistente das imagens reais: caverna inicial, oficina com portão fechado e aberto, área do túnel e início do gelo. Vegetação apoiada e portões sem o recorte genérico anterior nos enquadramentos examinados.
- Fase 2: percurso completo de teste sem renderização, Cake P1/P2, túnel, manivelas, ponte, retorno de controles e reinício. A fase continua SEM coleta/conclusão funcional; não foi apresentada como jogo completo.
- Recuperação das fases importadas: quedas, checkpoints, cancelamento de painel, movimentação da parceira, reinício e acesso pelo menu verificados.

## Limitações
Duas execuções renderizadas de `verify_level_2` encerraram antes do relatório final. Outra execução e o teste antigo que redimensiona a janela durante a mesma sessão ficaram sem finalizar a captura. A causa não foi confirmada; não contam como testes aprovados. As verificações independentes com renderização em cada resolução terminaram, e o percurso headless da fase 2 terminou.
Não houve teste humano com duas pessoas, exportação, áudio ouvido ou outro computador. Novos visuais aguardam avaliação do usuário. Não se afirma revisão de cada pixel de todos os assets: esta rodada corrigiu e refinou os conjuntos locais descritos.

## Avaliação manual
1. F5 > Jogar > fases 2, 3 e 4.
2. Confira o chão da vegetação e a leitura dos objetos durante movimento.
3. Acione os portões das fases 3/4 e atravesse a abertura.
4. Confira Cake entrando e recuando no túnel; sustente a ponte até Fionna liberar a passagem.
5. Compare a nitidez dos contornos em janela e tela cheia. Registre qualquer trecho ainda visualmente inadequado.
