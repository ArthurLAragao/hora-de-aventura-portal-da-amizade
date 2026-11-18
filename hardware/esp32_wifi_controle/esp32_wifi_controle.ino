// ESP32 -> Godot sem Python: Wi-Fi AP + datagramas UDP.
// Usa apenas WiFi.h e WiFiUdp.h do pacote ESP32 Arduino.
// PC: conectar-se à rede "HoraAventura-ESP32" com a senha abaixo.
// Godot: projeto com Esp32InputBridge autoload; UDP porta 42033.
#include <WiFi.h>
#include <WiFiUdp.h>

const char* WIFI_NAME = "HoraAventura-ESP32";
const char* WIFI_PASSWORD = "Aventura2026";  // WPA2: altere se desejar
const IPAddress AP_IP(192, 168, 4, 1);
const IPAddress AP_GATEWAY(192, 168, 4, 1);
const IPAddress AP_MASK(255, 255, 255, 0);
const IPAddress BROADCAST_IP(192, 168, 4, 255);
const uint16_t GODOT_PORT = 42033;

const int PIN_X = 32;
const int PIN_Y = 35;
const int PIN_AUX = 34;
const int PIN_JUMP = 22;
const int PIN_INTERACT = 23;
const int PLAYER_ID = 1;     // 1 ou 2
const int DEADZONE = 780;
const bool INVERT_X = false;
const bool INVERT_Y = false;
// GPIO34 não possui pull-up interno. Deixe false se estiver desconectado.
const bool AUX_ENABLED = false;
const bool AUX_ACTIVE_LOW = true;
const int AUX_THRESHOLD_LOW = 800;
const int AUX_THRESHOLD_HIGH = 3300;
const unsigned long SEND_PERIOD_MS = 25;
const unsigned long DEBUG_PERIOD_MS = 1000;

WiFiUDP udp;
unsigned long lastSend = 0;
unsigned long lastDebug = 0;

uint8_t readMask(int &x, int &y, int &aux) {
  x = analogRead(PIN_X);
  y = analogRead(PIN_Y);
  aux = analogRead(PIN_AUX);
  if (INVERT_X) x = 4095 - x;
  if (INVERT_Y) y = 4095 - y;
  uint8_t mask = 0;
  if (x < 2048 - DEADZONE) mask |= 1;  // esquerda
  if (x > 2048 + DEADZONE) mask |= 2;  // direita
  if (y < 2048 - DEADZONE || digitalRead(PIN_JUMP) == LOW) mask |= 4;
  if (digitalRead(PIN_INTERACT) == LOW) mask |= 8;
  if (AUX_ENABLED &&
      ((AUX_ACTIVE_LOW && aux < AUX_THRESHOLD_LOW) ||
       (!AUX_ACTIVE_LOW && aux > AUX_THRESHOLD_HIGH))) {
    mask |= 16;  // habilidade
  }
  return mask;
}

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);
  pinMode(PIN_X, INPUT);
  pinMode(PIN_Y, INPUT);
  pinMode(PIN_AUX, INPUT);
  pinMode(PIN_JUMP, INPUT_PULLUP);
  pinMode(PIN_INTERACT, INPUT_PULLUP);

  WiFi.mode(WIFI_AP);
  WiFi.softAPConfig(AP_IP, AP_GATEWAY, AP_MASK);
  if (!WiFi.softAP(WIFI_NAME, WIFI_PASSWORD)) {
    Serial.println("Falha ao iniciar Wi-Fi AP.");
    return;
  }
  Serial.println("Wi-Fi criado: HoraAventura-ESP32");
  Serial.println("Conecte o Windows a esta rede. O aviso 'Sem Internet' e normal.");
  Serial.print("Endereco ESP32: ");
  Serial.println(WiFi.softAPIP());
}

void loop() {
  if (millis() - lastSend < SEND_PERIOD_MS) return;
  lastSend = millis();

  int x, y, aux;
  const uint8_t mask = readMask(x, y, aux);
  // Pacote compatível com o receptor GDScript: AT1,jogador,mascara
  char payload[24];
  snprintf(payload, sizeof(payload), "AT1,%d,%u", PLAYER_ID, mask);
  if (WiFi.softAPgetStationNum() > 0) {
    udp.beginPacket(BROADCAST_IP, GODOT_PORT);
    udp.write(reinterpret_cast<const uint8_t*>(payload), strlen(payload));
    udp.endPacket();
  }
  if (millis() - lastDebug >= DEBUG_PERIOD_MS) {
    lastDebug = millis();
    Serial.printf("PCs conectados=%d X=%d Y=%d AUX=%d GPIO22=%d GPIO23=%d MASK=%u\n",
      WiFi.softAPgetStationNum(), x, y, aux,
      digitalRead(PIN_JUMP), digitalRead(PIN_INTERACT), mask);
  }
}
