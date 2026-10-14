// Input pin declarations (7474 Q outputs)
const int PIN_A = 2; // Q0 (LSB)
const int PIN_B = 3; // Q1
const int PIN_C = 4; // Q2
const int PIN_D = 5; // Q3 (MSB)

// Output pin declarations (7474 D inputs)
const int PIN_W = 6; // D0 (LSB)
const int PIN_X = 7; // D1
const int PIN_Y = 8; // D2
const int PIN_Z = 9; // D3 (MSB)

const int PIN_CLK = 13; // Clock pulse signal pin

void setup() {
  // Set D2-D5 as inputs from flip-flops
  pinMode(PIN_A, INPUT);
  pinMode(PIN_B, INPUT);
  pinMode(PIN_C, INPUT);
  pinMode(PIN_D, INPUT);

  // Set D6-D9 and D13 as outputs
  pinMode(PIN_W, OUTPUT);
  pinMode(PIN_X, OUTPUT);
  pinMode(PIN_Y, OUTPUT);
  pinMode(PIN_Z, OUTPUT);
  pinMode(PIN_CLK, OUTPUT);

  digitalWrite(PIN_CLK, LOW);
}

void loop() {
  // Read current flip-flop outputs A, B, C, D
  int A = digitalRead(PIN_A);
  int B = digitalRead(PIN_B);
  int C = digitalRead(PIN_C);
  int D = digitalRead(PIN_D);

  // Evaluate K-Map minimized logic equations
  int W = !A;
  int X = (B && !A) || (!D && !B && A);
  int Y = (C && !A) || (C && !B) || (!C && B && A);
  int Z = (D && !A) || (A && B && C);

  // Drive calculated values to 7474 D-inputs
  digitalWrite(PIN_W, W);
  digitalWrite(PIN_X, X);
  digitalWrite(PIN_Y, Y);
  digitalWrite(PIN_Z, Z);

  // Generate Clock pulse (Rising Edge triggers 7474 flip-flops)
  digitalWrite(PIN_CLK, HIGH);
  delay(500);
  digitalWrite(PIN_CLK, LOW);
  delay(500);
}
