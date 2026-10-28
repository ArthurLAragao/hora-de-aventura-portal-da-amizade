[Latest manual-feedback revision: Phases 2, 3 and 4](FEEDBACK_PHASES_2_3_4.md)

# Fases 2, 3 e 4 — cenário e percurso, 28/10/2026

Godot **4.7.2** mantido. Abrir `level_2.tscn`, `level_3.tscn` ou `level_4.tscn` e pressionar F6; também acessíveis por F5 > Jogar. Fases 1 e 6 preservadas; fase 5 aguarda molde do colega.

## Identidade e mapas laterais

**2 — Reino Gelado.** Trilha nevada com pequenos bosques, pilares de gelo e passagens quebradas. Não foi convertida em floresta verde: o tema gelado do SGDD permanece.

`Clareira segura → bloco/degrau + túnel de Cake → interruptor → manivela e passagem → checkpoint da dupla → âncora/ponte de Cake → manivela permanente → cristal → saída conjunta`

O percurso físico anterior foi preservado. Interruptor ganhou apoio visual. Cristal, saída e checkpoint agora são reais; duas áreas reservadas antigas ficam ocultas, preservadas no arquivo. A ponte e o túnel usam os controladores existentes. Checkpoint local exige que a primeira passagem esteja resolvida e ambos tenham alcançado o trecho seguinte. Queda preserva mecanismos resolvidos e cristal; F2 reinicia tudo.

**3 — Caverna Musical.** Salões de cristais, rochas escuras, musgo frio, ruínas e luzes discretas.

`Área segura → degrau inferior → balcão/painel de Marceline → pista de três símbolos → porta e checkpoint → terminal de BMO → conexão de energia → duas placas simultâneas → cristal → saída conjunta`

O painel foi elevado; a pista aparece após a ação musical. As plataformas têm colisão e desenho de apoio. Uma varanda opcional varia a leitura vertical sem eliminar o caminho de BMO. A confirmação usa duas placas existentes, separadas fisicamente; depois de resolvida, fica preservada. O cristal aguarda os mecanismos, evitando que saltar por um portão conte como conclusão.

**4 — Oficina do Reino Doce.** Arquitetura de doces, cobre e hortas de menta. Passarelas de serviço criam uma leitura vertical, com respiro junto aos terminais.

`Início → Finn carrega bloco → BMO aciona plataforma → Finn entrega bloco à placa → portão/checkpoint → passarelas opcionais → Finn alinha conexões físicas → BMO energiza → cristal → saída conjunta`

O vão de transporte ocupa X576–704. Plataforma local de 128 unidades percorre X544–688, transportando o bloco. A marca de carga segura o bloco ao entrar nela, sem teleporte. Finn depois o empurra até a placa; a passagem permanece aberta. Cancelamento do terminal não move a plataforma. O reset do bloco permite restaurar o transporte não resolvido quando a plataforma estiver livre. As conexões têm duas posições visíveis, horizontal/vertical; não há sequência oculta nem puzzle de memória. Há somente uma rota de energia, sem editor genérico de circuitos.

## Arte e organização
- 48 peças de complemento, em 32×32, mais 9 atlas de variação do terreno; lista e procedência em `Assets/02_Environments/regional_refinement/PROVENIENCIA.md`.
- Originais não sobrescritos. O terreno mantém suas bordas superiores/laterais e colisões; a variação é aplicada ao material interno.
- Camadas `Distant`, `Structures`, `Vegetation`, `GroundDetails`. Decoração sem colisões; plataformas funcionais em `RegionalLayout`.
- Fundos 3/4 agora usam escala uniforme, com recorte, em vez de deformação horizontal. Sem mudança de resolução global.
- Luminárias oscilam discretamente em intensidade. Sem partículas pesadas ou dependência de áudio.
- Portões locais acompanham o estado dos controladores existentes. Placas e interruptor alinhados ao chão.

## Controles e avaliação
P1: A/D, Espaço/W, E; Q para habilidade quando aplicável. P2: setas, Cima, Enter; Shift direito para habilidade. Esc cancela; F2 reinicia. Na oficina, R/Backspace restaura o bloco conforme o jogador. Na raiz da fase 2: Cake Player Id; nas fases 3/4: Lead Player Id. A ajuda local acompanha a inversão; menu global e personagens não foram alterados.

Teste manual curto:
1. Confira o túnel, a ponte e a volta ao checkpoint no gelo; termine com os dois no marco de saída.
2. Suba com Marceline, revele a pista, opere BMO e pise nas duas placas.
3. Carregue o bloco na marca; opere BMO; empurre até a placa; alinhe os dois tubos com Finn e ligue a energia com BMO.
4. Reinicie e repita invertendo os papéis; avalie se mecanismos e superfícies ficam claros sem ler instruções longas.

## Testes e limites
Os relatórios e capturas reais estão em `D:/TEMP/fases-234-final-2026-10-28`.
- Percursos completos por entradas simuladas, sem reposicionamento: fase 2, Cake P1/P2; fases 3/4, papéis padrão/invertidos. Cristal e saída conjunta verificados. Recuperações durante esses percursos: zero.
- Renderização em 1152×648 e 1280×720 nas fases 3/4; fase 2 executada/renderizada na resolução de referência e inspecionada nas duas resoluções por fixtures visuais.
- Fixtures isolados verificaram queda antes/depois do checkpoint, preservação de cristal, saída antecipada recusada, cancelamento, tentativa incorreta de energia, reset local e F2. Posições preparadas nesses testes não contam como percurso.
- Regressores das fases 1 e 6 concluíram os percursos; auditoria de hashes verifica recursos intactos. Nenhum controlador de personagem, ponte, câmera global ou menu foi editado.
- Importação normal do Godot e execuções finais sem novos erros/avisos nos logs examinados. Falhas intermediárias foram corrigidas; relatórios antigos não são a evidência final.

Pendências honestas: gelo ainda não altera a física de movimento; não se afirma implementação desse detalhe do SGDD. As conexões de energia são uma versão espacial curta, sem rede editável de peças. Diversão, conforto cooperativo e aparência aguardam sua avaliação manual. Não foram testados build exportado, outro computador, áudio ouvido ou sessão com duas pessoas reais.

## Segurança
Backup completo anterior: `D:/TEMP/fases-234-final-2026-10-28/backup`. Manifesto de alterações e resultados na mesma pasta externa. Apenas recursos locais das fases 2–4, documentação e testes pertinentes foram alterados. As cenas e todos os recursos existentes das fases 1 e 6, personagens, menu e controles são preservados na auditoria.
