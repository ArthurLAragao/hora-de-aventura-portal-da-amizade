# Hora de Aventura: O Portal da Amizade — fase 1

Projeto local para dois jogadores, feito no Godot 4.7.2. Os assets fornecidos foram preservados; o percurso usa apenas arte presente na pasta `Assets/`.

## Abrir e jogar

1. Abra esta pasta no Godot 4.7.2 e aguarde a importação dos recursos.
2. Pressione **F5**, escolha **Jogar** e depois **Fase 1 | Jogar**.
3. **Finn:** A/D para andar, Espaço para pular, E para usar a alavanca, Q para empurrar o tronco na direção em que está olhando e R para restaurá-lo ao ponto inicial quando estiver perto.
4. **Jake:** setas esquerda/direita para andar, seta para cima para pular e Shift direito para manter a ponte quando estiver junto da âncora marcada.

## Caminho da fase

Área inicial → ponte temporária do Jake → alavanca e passagem permanente → checkpoint → tronco sobre placa de pressão → duas placas simultâneas → cristal → saída que exige Finn e Jake juntos.

Os objetos do puzzle estão separados ao longo do mapa. Seis tiles soltos que apareciam no ar e dentro do primeiro vão foram removidos. A plataforma inicial agora alcança a borda esquerda e há limites físicos nas duas extremidades. O script da fase é `@tool`, então a extensão do terreno e a vegetação também aparecem ao abrir a cena no editor. O tronco é um `AnimatableBody2D` com movimento horizontal limitado por colisões; seu corpo agora encosta no piso e sua placa detecta o objeto na altura correta. O portão abre e desativa a colisão ao receber o sinal da placa. O checkpoint guarda pontos seguros distintos para Finn e Jake durante a sessão.

## Visual e menu

O menu principal conserva a arte e os botões originais. A seleção de fases foi reorganizada para remover rótulos duplicados, manter espaçamento e caber em janelas 16:9 e 4:3. Só a fase 1 fica habilitada.

O fundo usa a ilustração original uma vez e prolonga a rota com um recorte do horizonte de montanhas e colinas do mesmo arquivo; a casa na árvore não se repete. Motivos distantes desse horizonte podem voltar a aparecer. O parallax é discreto. A vegetação usa `decor_01.png` a `decor_04.png`, sem colisão.

## Limites desta entrega

- Esta entrega cobre a fase 1. As fases 2 a 6 não existem ainda e aparecem como indisponíveis.
- O progresso dos puzzles é mantido apenas enquanto a fase está aberta; não há gravação em disco.
- Os testes automatizados simulam os dois controles e o percurso. Eles não substituem uma sessão de aceitação com duas pessoas em janela, em diferentes computadores e resoluções.
- A duração pretendida de 5 a 8 minutos ainda precisa ser medida em teste com jogadores.
- A pasta não inclui preset ou executável de publicação. Uma versão pública também depende de confirmar direitos de uso dos personagens, nomes e assets da franquia.

## Verificação automatizada

No Godot 4.7.2, execute a partir desta pasta:

```powershell
& 'C:\caminho\para\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
& 'C:\caminho\para\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/verify_menu.gd
& 'C:\caminho\para\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/verify_level.gd
```

Os scripts verificam menu, seletor, entrada na fase, movimento independente, salto, ponte, alavanca, checkpoint, queda, movimento real do tronco até a placa, abertura e passagem pelo portão, placas cooperativas, cristal e saída.
