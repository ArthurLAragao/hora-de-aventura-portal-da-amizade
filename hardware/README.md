# Controle físico ESP32 — Hora de Aventura

Integração para **Godot 4** (PC) usando ESP32 DevKit conectado por USB. O ESP32 não executa o jogo: ele envia leituras pela serial, e `bridge.py` envia comandos UDP apenas a `127.0.0.1:42033`. O autoload no Godot converte esses comandos nas ações existentes P1/P2. Não modifica a lógica das seis fases e mantém o teclado.

## Ligações (ESP32 clássico)
| GPIO | Conexão | Ação |
| --- | --- | --- |
| 32 | VRx do joystick | Esquerda / direita |
| 35 | VRy do joystick | Cima = pular |
| 34 | Terceira entrada analógica / SW com pull-up **externo** | Habilidade |
| 22 | Botão ao GND (INPUT_PULLUP) | Pular |
| 23 | Botão ao GND (INPUT_PULLUP) | Interagir |

Alimente o módulo joystick em **3V3**, com GND comum. Não envie 5V aos GPIOs do ESP32. **GPIO34 e GPIO35 são somente entrada e não possuem pull-up interno.** Se GPIO34 for o contato SW (digital) do joystick, coloque um resistor externo de ~10 kΩ entre GPIO34 e 3V3 e ligue SW ao GND quando pressionado; sua leitura analógica será baixa ao pressionar. Se GPIO34 for um terceiro potenciômetro ou sensor analógico, configure os limiares em `bridge.py` conforme o circuito. Não deixe GPIO34 flutuando; use `--aux-mode off` até instalar o resistor. GPIO22/23 usam pull-up interno e botões para GND.

## Passo a passo (Windows)
1. Abra `hardware/esp32_controle/esp32_controle.ino` no Arduino IDE, selecione sua placa ESP32 e grave o firmware.
2. No terminal, na raiz do repositório: `py -m pip install -r hardware/requirements.txt`.
3. Abra `jogo/project.godot` no Godot e inicie com **F5**.
4. Descubra a porta serial no Gerenciador de Dispositivos do Windows (exemplo: COM5).
5. Em outro terminal, rode: `py hardware/bridge.py --port COM5 --player 1`. Use `--player 2` para controlar o segundo personagem, mas apenas um processo por porta ESP32.
6. Teste: movimento X, salto por Y para cima ou GPIO22, interação GPIO23 e habilidade GPIO34. Inverta um eixo com `--invert-x` ou `--invert-y` se a orientação estiver invertida.

**Observação:** o joystick vertical para baixo não tem ação padrão, porque o jogo é de plataforma horizontal. O comando de habilidade funciona somente quando o personagem possui a habilidade correspondente; isso é regra do jogo.

## Protocolo
Firmware envia `x,y,aux,b22,b23\n` a 115200 baud (ADC 0–4095; botões 1 quando pressionados). Python converte para `AT1,player,mask` via UDP. Bits: 1 esquerda, 2 direita, 4 pular, 8 interagir, 16 habilidade. Envia heartbeat a cada 100 ms; o Godot libera comandos 350 ms após perda de pacotes para evitar travamento dos controles.

## Testes sugeridos
- Sem ESP32: teclado deve continuar funcional (P1 A/D, Espaço/W, E, Q; P2 setas, cima, Enter, Shift direito).
- Em cada fase, mova P1 e P2, pule, interaja e use a habilidade disponível, verificando se puzzles e limites de distância funcionam.
- Desligue o USB durante uma caminhada: o personagem deve parar em até 350 ms.
- Abra e feche orientações com F1 e teste bloqueios temporários das habilidades.
- **Ainda é necessário validar o circuito real e executar o Godot no computador com a placa conectada.**
