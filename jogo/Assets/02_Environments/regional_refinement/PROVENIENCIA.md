# Complemento regional de pixel art
Gerado com a ferramenta integrada image_gen, usando a folha dos tiles existentes como referência. Originais preservados. Não houve download de pacotes externos.

Prompt utilizado: atlas 8 colunas × 6 linhas, sem rótulos e com transparência; cada par de linhas representa gelo, caverna e oficina. Linha de terreno com três variações de chão, bordas esquerda/direita, base, canto e plataforma. Linha de adereços com três vegetações pequenas, dois arbustos, coluna, trepadeira e luminária. Paletas limitadas, contornos escuros e agrupamentos de pixels conforme a referência, sem personagens.

O resultado bruto ficou em `source_atlas.png` (1448×1086). A grade vertical gerada não era uniforme: a extração usa intervalos conferidos na imagem. Os sprites são separados, normalizados proporcionalmente para 32×32 com Nearest e alpha abaixo de 0,8 descartado. Nenhum personagem foi redimensionado.

`tests/extract_regional_atlas.gd` reproduz a extração; `tests/build_regional_variants.gd` cria três atlas regionais usando os limites originais e variações somente no interior do material sólido. São ferramentas de autoria, não necessárias durante a partida.

Para cada prefixo ice/cave/candy:
- ground_a, ground_b, ground_c: três propostas de chão que alimentam as variações internas;
- edge_left, edge_right, bottom, corner, platform: peças complementares disponíveis; não se afirma que todas sejam usadas;
- grass_a, grass_b, grass_c: três vegetações pequenas utilizadas;
- bush_a, bush_b: dois volumes maiores utilizados;
- column, vine, lantern: estruturas e ambientação utilizadas;
- terrain_0, terrain_1, terrain_2: atlas aplicados ao TileMap local, com as mesmas colisões do original.

A arte nova requer avaliação humana. Não representa aprovação automática de estilo ou ausência de qualquer defeito de pixel.
