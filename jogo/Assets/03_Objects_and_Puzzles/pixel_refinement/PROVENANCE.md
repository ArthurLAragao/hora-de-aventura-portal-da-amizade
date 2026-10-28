# Proveniência e uso

Três matrizes geradas com image_gen integrado em 28/10/2026, usando o atlas interno das regiões como referência visual. Prompts completos em `sources/prompts.json`; arquivos originais gerados preservados em `sources/*_master.png`.

Os recursos usados em execução são os PNGs pequenos deste diretório. Foram extraídos e montados em tamanhos nativos pelo script `tools/art/build_pixel_finish.gd`, com Nearest, alpha binário e paleta reduzida. Versões baixas das portas removem faixas repetíveis, mantendo ornamentos centrais e a abertura física existente. As peças não usam escala fracionária no jogo.

`sources/.gdignore` mantém as matrizes fora da importação do Godot. O jogo não precisa de gerador, dependência nova ou conexão de rede. Nenhum PNG anterior foi substituído.

As matrizes são arte gerada para este acabamento; isso não constitui auditoria de licença dos demais recursos do projeto.
