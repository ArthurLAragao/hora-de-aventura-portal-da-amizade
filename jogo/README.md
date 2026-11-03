# Hora de Aventura: O Portal da Amizade

Plataforma 2D cooperativo local para dois jogadores. Abra `project.godot` com **Godot 4.7.2** e use **F5** para o menu. Fases disponíveis: **1, 2, 3, 4, 5 e 6**. A Torre dos Espelhos possui percurso cooperativo, cristal e ligação com a Fase 6.

## Estrutura enxuta

- `Assets/`: recursos do jogo e materiais dos seis ambientes.
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

- [Apresentação limpa — retirada dos tutoriais](docs/APRESENTACAO_LIMPA.md)
- [Conteúdo de 03/11 — história e miniconversas](docs/CONTEUDO_03_11.md)
- [Desafios e obstáculos — revisão do item de 29/10](docs/DESAFIOS_29_10.md)
- [Roteiro para a professora](docs/APRESENTACAO.md)
- [Fase 5 — percurso, óptica e testes](docs/FASE_5.md)
- [Arquitetura e estados](docs/ARQUITETURA.md)
- [Índice de todas as funções](docs/CODIGO.md)
- [Otimização e validação](docs/OTIMIZACAO.md)
- [Manutenção e QA externo](docs/MANUTENCAO.md)
- [Créditos e fontes preservados](docs/CREDITOS_E_FONTES.md)
- [Relatórios anteriores](docs/history/)

O ZIP otimizado é um projeto fonte Godot, não um executável exportado. A validação técnica não substitui uma sessão de duas pessoas nem a avaliação manual de conforto.
