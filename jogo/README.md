# Hora de Aventura: O Portal da Amizade

Plataforma 2D cooperativo local para dois jogadores. Abra `project.godot` com **Godot 4.7.2** e use **F5** para o menu. Fases disponíveis: **1, 2, 3, 4 e 6**. A Fase 5 continua pendente; seus assets foram preservados.

## Estrutura enxuta

- `Assets/`: recursos do jogo, incluindo materiais reservados para a Fase 5.
- `scripts/characters`, `bridges`, `levels`, `puzzles`, `scenery`, `ui`, `core`: scripts por responsabilidade, mantendo nomes e identidades de classe.
- `mechanisms/`: terminal, túnel, manivela, plataforma e painel musical reutilizáveis.
- `docs/`: arquitetura, funções, manutenção, apresentação e registros históricos.
- Cenas principais permanecem na raiz para abrir facilmente com F6.

QA e matrizes de arte ficam **fora da pasta do projeto**, na área opcional `development/` do repositório. Não são necessários para jogar. Nada é baixado ou instalado ao abrir o jogo.

## Controles

| Papel | Movimento | Salto | Interação | Habilidade |
|---|---|---|---|---|
| P1 | A / D | Espaço ou W | E | Q |
| P2 | Setas laterais | Seta para cima | Enter | Shift direito |

F2 reinicia a cena; Esc cancela ações contextuais. A ajuda disponível na cena descreve os comandos específicos. Habilidades dependem do personagem, não do número do jogador.

## Documentação

- [Roteiro para a professora](docs/APRESENTACAO.md)
- [Arquitetura e estados](docs/ARQUITETURA.md)
- [Índice de todas as funções](docs/CODIGO.md)
- [Otimização e validação](docs/OTIMIZACAO.md)
- [Manutenção e QA externo](docs/MANUTENCAO.md)
- [Créditos e fontes preservados](docs/CREDITOS_E_FONTES.md)
- [Relatórios anteriores](docs/history/)

O ZIP otimizado é um projeto fonte Godot, não um executável exportado. A validação técnica não substitui uma sessão de duas pessoas nem a avaliação manual de conforto.
