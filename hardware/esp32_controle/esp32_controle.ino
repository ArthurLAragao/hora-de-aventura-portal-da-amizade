// ESP32 DevKit (Arduino): joystick X/Y, entrada auxiliar analógica e dois botões.
// Ligue o joystick a 3V3, NUNCA a 5V. GPIO34/35 não têm pull-up interno.
// GPIO34 requer circuito externo definido; consulte hardware/README.md.
const int PIN_X = 32;
const int PIN_Y = 35;
const int PIN_AUX = 34;
const int PIN_JUMP = 22;
const int PIN_INTERACT = 23;
const unsigned long PERIOD_MS = 16;
unsigned long last_send = 0;

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);
  pinMode(PIN_X, INPUT);
  pinMode(PIN_Y, INPUT);
  pinMode(PIN_AUX, INPUT);
  pinMode(PIN_JUMP, INPUT_PULLUP);
  pinMode(PIN_INTERACT, INPUT_PULLUP);
}

void loop() {
  if (millis() - last_send < PERIOD_MS) return;
  last_send = millis();
  // Uma linha por amostra: x,y,aux,botao22,botao23 (botões ativos em LOW).
  Serial.printf("%d,%d,%d,%d,%d\n",
    analogRead(PIN_X), analogRead(PIN_Y), analogRead(PIN_AUX),
    digitalRead(PIN_JUMP) == LOW ? 1 : 0,
    digitalRead(PIN_INTERACT) == LOW ? 1 : 0);
}
