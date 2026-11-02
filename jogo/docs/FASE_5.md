# Fase 5 — Torre dos Espelhos

## Conceito e percurso

Galeria violeta e dourada nas nuvens, usando o background arquitetônico e os tiles originais da Torre dos Espelhos. Marceline controla os espelhos altos; Cake alcança os inferiores através de dois túneis. Feixes sem dano, orientações discretas, símbolos junto das cores e portões permanentemente abertos após cada solução.

Mapa lateral (unidades do mundo; piso em Y=500):

```text
160/224 → 360 → [portão 560] → túnel 700–860 / balcão 852 → [1160]
 início    ◇                   Cake ↓ / Marceline ↑           |
                 checkpoint conjunto 1230 ←─────────────────┘
     → túnel 1300–1460 / balcão 1492 → △ + □ → [1760] → cristal 1940 → saída 2110
```

1. **Entrada:** Marceline gira o primeiro espelho para desviar a luz até ◇. Cake avança com ela; este momento ensina a consequência imediata de uma interação.
2. **Galeria cooperativa:** Cake entra rastejando, desvia a luz sob o teto e pode recuar. Marceline usa os degraus/balcão e sua flutuação limitada para alcançar o ajuste alto. Um espelho fixo conecta as duas partes; ○ abre a segunda passagem. As distâncias não permitem o ajuste alto a partir do chão.
3. **Checkpoint:** conquistado pelas duas no chão, após os dois circuitos anteriores. A bandeira muda de estado; uma queda anterior não concede esse progresso.
4. **Final:** Cake ativa △ pelo túnel; Marceline ativa □ no balcão. Os dois receptores precisam estar acesos na mesma atualização. Não é necessário manter teclas pressionadas. A solução trava os ajustes e preserva o portão aberto.
5. **Recompensa:** cristal rosa existente, coleta única. A saída exige o cristal e as duas personagens. O botão Continuar abre a Fase 6, preservando os papéis de controle. A Fase 4 mantém seu retorno existente ao seletor; a Fase 5 está disponível ali.

## Execução e controles

Abra `level_5.tscn` e pressione F6, ou escolha Fase 5 no seletor normal. A cena é construída em execução, seguindo o padrão de construção já empregado no projeto.

Na raiz da cena, `lead_player_id` define Marceline como P1 ou P2; Cake recebe o papel complementar. P1: A/D, Espaço/W, E e Q. P2: setas laterais, Cima, Enter e Shift direito. E/Enter gira o espelho contextual ou inicia o rastejo na entrada; Q/Shift direito mantém a flutuação aérea limitada existente. Esc fecha a ajuda e solicita postura normal somente com espaço livre. F1 abre ajuda opcional; F2 reinicia a fase.

`initial_orientations` configura as orientações iniciais (/ = 0; \ = 1), na ordem de registro dos espelhos. Valor padrão: `[1,0,0,1,0,1]`; a peça fixa conserva sua orientação. `reflection_limit` tem padrão 12: mantenha esse valor para o percurso entregue. Reduzi-lo pode interromper um circuito antes do receptor.

## Implementação e recuperação

- `scripts/levels/level_5.gd`: construção local, seleção contextual por capacidade, óptica, checkpoint, recuperação e conclusão. Funções documentadas em português.
- Raios atualizados apenas ao iniciar ou alterar um espelho; interseções determinísticas com terreno, tetos, balcões e portões fechados. Limite de reflexões e pares posição/direção visitados interrompem ciclos.
- Receptores recomputam seu estado; cada circuito concluído abre uma única vez. Feixes e lentes alinhados; personagens desenhados à frente dos feixes. Espelhos elevados e receptores possuem suporte visual.
- Túneis reutilizam o mecanismo de Cake, com teto físico em Y=420–478 e altura livre de 22 unidades. Travessia controlada, sem teleporte, com restauração de postura apenas quando permitida.
- Recuperação por queda usa limpeza existente dos personagens, zera velocidade e estados temporários, limpa ocupantes antigos da saída e preserva soluções/cristal. Uma guarda evita recuperação duplicada. Retorno separado no início ou no checkpoint conquistado.
- Reinício completo por F2 recria o estado inicial e preserva somente a configuração dos papéis. Não equivale a recuperação após queda.
- Personagens, câmera, HUD e mecanismos existentes reutilizados. Nenhum controlador compartilhado foi alterado; apenas o mapa de disponibilidade do seletor recebeu a Fase 5.
- Nenhuma arte externa ou PNG novo: atlas dos espelhos, receptores, cristal, bandeira, terreno e decoração existentes. Correntes e portões são detalhes locais desenhados em pixels; os originais permanecem intactos.

## Verificação e limites

Percursos renderizados completos por entradas de movimento/interação, sem reposicionamento para concluir, com Marceline P1 e P2 em 1280×720 e 1152×648. Verificados os três circuitos, travessia real dos túneis, checkpoint, coleta, recusa da saída com uma personagem, conclusão conjunta sem recuperação e ligação com a Fase 6.

Testes isolados de estados usam preparação por script, separados do percurso: orientação incorreta, desativação do receptor antes da solução, rota bloqueada por portão, repetição, um receptor final insuficiente, ciclos, postura sob teto, recuo, quedas próximas, cristal preservado, reinício e recuperação. Esses testes não são apresentados como travessias normais.

Capturas reais inspecionadas para fundo, contato com o piso, balcões, túnel, lentes, feixes, portões e interface. Áudio foi desativado nos testes. Não houve validação com duas pessoas reais, exportação, outro computador ou aprovação humana de conforto/diversão. A fase tem piso seguro contínuo; a rotina de queda foi exercitada isoladamente, não por criar buracos obrigatórios.

## Checklist manual

- Executar F6 e pelo seletor; experimentar ambos os papéis.
- Girar um espelho incorretamente e depois completar ◇.
- Cake atravessa/recua no túnel; Marceline chega ao balcão sem ajustes no chão.
- Conquistar o checkpoint em dupla; confirmar △ e □ e a abertura permanente.
- Tentar sair sozinha e sem cristal; depois coletar e concluir juntas.
- Continuar para a Fase 6; testar ajuda opcional e F2 durante o percurso.

Os layouts e arquivos das Fases 1, 2, 3, 4 e 6 foram preservados. O pacote ZIP anterior e os arquivos de exportação não foram refeitos.
