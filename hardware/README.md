# CONTROLE ESP32 SEM PYTHON — SOMENTE ARDUINO IDE + GODOT

**Este é o método recomendado em computadores bloqueados.** O ESP32 cria uma rede Wi-Fi própria e manda comandos UDP diretamente ao Godot. Não é necessário instalar Python, bibliotecas Python ou um servidor intermediário. O pacote de placas ESP32 deve já estar disponível no Arduino IDE.

## Passo a passo
1. Abra `hardware/esp32_wifi_controle/esp32_wifi_controle.ino` no **Arduino IDE**.
2. Em Ferramentas, selecione a placa ESP32 e a porta USB, e faça **Upload**. Feche o Monitor Serial se for trocar a porta; ele serve para verificar os valores X/Y/AUX.
3. No **Windows**, conecte-se à rede Wi-Fi `HoraAventura-ESP32`, senha `Aventura2026`. A mensagem **Sem Internet** é esperada; o ESP32 gera uma rede local sem conexão à internet. Se o PC não tiver Wi-Fi, será necessário um adaptador de rede Wi-Fi ou outro caminho de comunicação.
4. No **Godot 4.7.2**, abra `jogo/project.godot` desta branch e execute com **F5**. O autoload `Esp32InputBridge` já faz parte do projeto e recebe UDP na porta **42033**.
5. Teste joystick esquerda/direita, movimento para cima (salto), botão no GPIO22 (salto) e GPIO23 (interação). A tela do Godot deve ter foco para ações de interface. A leitura do GPIO34 para habilidade fica **desativada por padrão**, para não disparar habilidade com pino flutuante.
6. Se não houver resposta, confira se o Windows está conectado à rede do ESP32 e se o **Firewall do Windows** permite o Godot receber tráfego **UDP 42033** nessa rede. A liberação pode exigir permissão do administrador. Se o dispositivo bloqueia também conexões Wi-Fi ou regras de firewall, esse método pode não ser viável sem liberação da TI.

## Pinos
- GPIO32 = eixo X analógico (movimento esquerda/direita)
- GPIO35 = eixo Y analógico (para cima = salto)
- GPIO34 = entrada auxiliar. Se for clique SW do joystick, requer resistor externo de ~10 kΩ ligando GPIO34 a 3V3 e botão SW ao GND. Só então configure `AUX_ENABLED = true` no firmware.
- GPIO22 = botão de pular para GND
- GPIO23 = botão de interagir para GND

Alimente o joystick com **3,3 V** e use GND comum. **Não aplique 5 V aos GPIOs do ESP32**. GPIO34/35 não têm pull-up interno. Os botões de GPIO22/23 usam `INPUT_PULLUP`.

## Personalização
- `PLAYER_ID = 1` controla o jogador 1; mude para `2` para o jogador 2.
- `INVERT_X = true` ou `INVERT_Y = true` inverte a direção caso o joystick tenha sido montado ao contrário.
- `AUX_ENABLED = true` ativa o GPIO34 somente depois de validar a ligação.
- O controle conserva as ações e a lógica dos personagens já existentes. A habilidade depende de personagem.
- Comandos são liberados automaticamente se a conexão for perdida por ~350 ms.
- O firmware envia apenas para a rede dedicada do ESP32. O receptor aceita somente pacotes de `192.168.4.1` (ESP32) e `127.0.0.1` (ponte antiga).

## Diagnóstico sem Python
Abra **Ferramentas → Monitor Serial**, configure **115200 baud** e verifique:
- `PCs conectados=1` quando o Windows entra na rede.
- O valor `X` muda ao mover o joystick horizontalmente.
- O valor `Y` muda ao mover verticalmente.
- `GPIO22=0` e `GPIO23=0` quando os botões são pressionados.
- `MASK` indica a soma das ações: 1 esquerda, 2 direita, 4 salto, 8 interação, 16 habilidade.

**Validação:** código preparado no GitHub, ainda não testado com a placa física/Firewall do computador. Conexão Wi-Fi e compilação dependem do ambiente local.

---

## Método alternativo anterior (USB serial + Python)

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
