# Refino localizado de pixel art — fases 2, 3 e 4

Implementado em 28/10/2026, no Godot 4.7.2. Candidato para avaliação visual do autor; esta rodada não recebe aprovação humana automaticamente.

## Resultado

- **Caverna Musical:** portas em pedra violeta, incrustações de cristal, musgo e motivo de ressonância. Folha e moldura são sprites separados; a abertura fica realmente transparente após abrir.
- **Oficina do Reino Doce:** portas de painéis de menta, ferragens de cobre, estrutura rosa e acabamento de glacê. Há versões nativas para os dois tamanhos de abertura existentes.
- **Circuito da oficina:** bateria, placa de fundo, ramificações gravadas, isoladores, duas carcaças rotativas e receptor numa máquina contínua. As duas conexões continuam sendo os mesmos controles; Finn alinha, BMO energiza. A silhueta do condutor muda de vertical para horizontal. O receptor acompanha o estado já existente do terminal.
- **Polimento local:** recorte do último tile em plataformas de largura não múltipla de 32; bandeiras das fases 3/4 na escala nativa; vegetação da caverna apoiada no terreno/ilha correto; vegetação afastada da abertura da primeira porta da oficina; prompt do circuito mais curto e separado da indicação de BMO.
- **Fase 2:** inspecionada e testada. Suas texturas, posições e regras foram mantidas nesta rodada; não houve necessidade de nova alteração.

Não foram alteradas superfícies físicas, colisores, posições dos mecanismos, entradas, capacidades, regras, checkpoints, cristais ou condições de conclusão. As fases 1 e 6, seus assets e os controladores de personagens permaneceram intactos.

## Recursos novos

Em `Assets/03_Objects_and_Puzzles/pixel_refinement/`:

- `cave_frame_64.png`, `cave_frame_80.png`, `cave_leaf_64.png`, `cave_leaf_80.png`.
- `candy_frame_64.png`, `candy_frame_80.png`, `candy_leaf_64.png`, `candy_leaf_80.png`.
- `candy_circuit_backplate.png` (256×80), `candy_circuit_housing.png` (64×64), `candy_circuit_rotor.png` (48×40).
- `circuit_receiver.gdshader`: escurece somente o vidro do receptor desligado, preservando o restante da textura e sua transparência.
- `sources/`: três matrizes geradas, conjunto completo de prompts e `.gdignore` para não importá-las como recursos de execução.

As folhas de porta medem 48×64 ou 48×80 e cobrem exatamente os colisores existentes. As molduras medem 64×80 ou 64×96, com abertura transparente de tamanho correspondente. Renderização em escala 1, filtro Nearest, transparência binária e até 40 cores por PNG de porta; até 48 por PNG de circuito. Nada depende de uma imagem disponível apenas na pasta do gerador.

Matrizes produzidas com **image_gen integrado**, usando o atlas interno como referência. Extração, montagem das peças de arquitetura e redução para tamanhos nativos reproduzíveis em `tools/art/build_pixel_finish.gd`; não há dependência de plugin ou serviço para executar o jogo. Os PNGs anteriores não foram sobrescritos.

## Arquivos de código

| Arquivo | Motivo |
|---|---|
| `regional_gate_finish.gd` | Consome folha/moldura nativas e segue `CoopGate.is_open`; não controla a física. |
| `workshop_connections.gd` | Apresentação do circuito e sincronização do receptor; mantém as duas áreas/entradas e a regra de alinhamento. Bateria/indicador antigos permanecem como nós de referência, ocultos para evitar desenho duplicado. |
| `regional_layout.gd` | Recorta o tile final e ajusta somente a escala visual local das bandeiras. |
| `regional_composition.gd` | Reposiciona decoração em relação às ilhas existentes e mantém a abertura da porta livre. |
| `tests/verify_feedback234.gd` | Verifica apoio real da vegetação por raycast, incluindo a ilha, em vez de pressupor um único Y para toda planta. |
| `tests/verify_pixel_art_finish.gd` | Fixtures de renderização e verificação da abertura, paleta, circuito e reinício. |

## Validação realizada

| Verificação | Evidência e limite |
|---|---|
| Percursos completos 3/4 | Driver de entradas percorreu do início à conclusão, com papéis normais/invertidos, em janelas 1280×720 e 1152×648, D3D12. Sem falhas de percurso; não é teste com duas pessoas. |
| Fase 2 | Percurso automatizado, ambos os papéis, nas mesmas duas janelas. Ponte, túnel, manivelas, cristal e conclusão preservados. |
| Portas | Fechadas/abertas; tamanho da folha corresponde ao colisor; moldura transparente no vão; colisão desabilitada quando a porta abre. |
| Circuito | Desconectado, alinhado, energizado; entrada contextual original, animação de BMO, abertura da porta e retorno dos controles; reinício restaura estado inicial. |
| Recuperação/transportador | Fixtures existentes de cancelamento, recuperação e reset local sem falhas. Apoio do transportador na entrada/centro/saída preservado. |
| Renderização | Capturas reais inspecionadas em escala de jogo; detalhe ampliado do circuito; portas/circuito também renderizados em Compatibility. Sem erros/avisos reportados nos consoles das execuções registradas. |
| Preservação | Auditoria dos arquivos contra backup: nenhuma remoção; nenhum PNG original sobrescrito; nenhuma cena de fase alterada. |

Fixtures que preparam posições ou estados servem para observar objetos isolados. Não contam como conclusão de percurso. As capturas de percurso vêm dos drivers de entrada correspondentes.

A resolução de referência do projeto continua **1280×720**; 1152×648 é a segunda janela testada, usando o esticamento já configurado. Não houve alteração global de resolução, filtro ou câmera.

## Segurança, evidências e publicação

Backup completo anterior à edição: `D:\TEMP\pixel-finish-234-2026-10-28\backup`.

Evidências locais: `D:\TEMP\pixel-finish-234-2026-10-28\captures-before`, `captures-after`, relatórios JSON e logs no mesmo diretório. O baseline preservado chama-se `baseline_hashes.json`.

No GitHub, o conjunto selecionado de comparações e resultados fica em `docs/pixel-refino-234-2026-10-28/`, na branch autorizada `codex/revisao-qualidade-fases-1-6`. Backups, cache e logs temporários não integram os commits.

## Avaliação manual

1. Abra `level_3.tscn` e execute com F6: observe as portas fechadas e depois abertas, com os pés/terreno visíveis.
2. Abra `level_4.tscn`: confira a porta do bloco e a porta da energia, a bateria e o receptor sem elementos duplicados.
3. Na área de energia, Finn usa E ou Enter para girar as duas conexões; BMO usa a interação para energizar. Observe orientação dos condutores e mudança no receptor.
4. Reinicie com F2, teste os papéis invertidos e confira se as portas voltam fechadas.
5. Revise a vegetação nas ilhas da caverna e a passagem livre na oficina; percorra a Fase 2 para comparar a preservação.

Pendente: avaliação humana de aparência e conforto desta revisão. Não foram validados build exportado, áudio ouvido, uso simultâneo por duas pessoas, outros computadores ou proporções de tela diferentes das duas janelas 16:9 citadas. Nenhuma promessa de perfeição ou aprovação visual definitiva.


## Auditoria da cópia publicada

Foram encontradas e preservadas duas diferenças anteriores a esta rodada: o `project.godot` original declara 1280×720, enquanto o arquivo já versionado usa os valores padrão do Godot; um UID de teste local também não estava versionado. Esses arquivos não foram sincronizados indiscriminadamente nem alterados para obter igualdade artificial. Os arquivos desta rodada são idênticos no original e na cópia de publicação.

A cópia publicada foi importada pelo próprio Godot e validada separadamente com sua configuração existente: percursos completos 3/4 com papéis normais/invertidos e renderização do circuito/portas. Ambas as execuções terminaram sem falhas e sem mensagens de erro/aviso no console de execução. Captura da oficina publicada também inspecionada. A apresentação pode ter enquadramento/escala de tela diferentes por causa da configuração prévia preservada.
