import controlP5.*;
ControlP5 cp5;
int R, G, B, Add;

void setup() {
  size(350, 220);

  cp5 = new ControlP5(this);
  cp5.addSlider("R")
    .setPosition(10, 10)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(0)
    ;
  cp5.addSlider("G")
    .setPosition(10, 35)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(0)
    ;
  cp5.addSlider("B")
    .setPosition(10, 60)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(0)
    ;

  cp5.addSlider("ADD")
    .setPosition(10, 85)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(0)
    ;
}

void R(int val) {
  R = val;
}
void G(int val) {
  G = val;
}
void B(int val) {
  B = val;
}
void ADD(int val) {
  Add = val;
}

void draw() {
  background(150);
  color col = color(R, G, B);
  // col += Add;  // прибавление

  // упаковка
  int newColor = (col & 0xF80000);   // 11111000 00000000 00000000
  newColor |= (Add & 0xE0) << 11;    // 00000111 00000000 00000000
  newColor |= (col & (0x3F << 10));  // 00000000 11111100 00000000
  newColor |= (Add & 0x18) << 5;     // 00000000 00000011 00000000
  newColor |= (col & (0x1F << 3));   // 00000000 00000000 11111000
  newColor |= (Add & 0x7);           // 00000000 00000000 00000111
  
  col = newColor | 0xFF000000;  // + альфа канал
  // упаковка

  fill(col);
  noStroke();
  rect(10, 110, 100, 100);
  textSize(15);
  text("R: " + red(col), 120, 140);
  text("G: " + green(col), 120, 160);
  text("B: " + blue(col), 120, 180);
  text(binary(col&0xFFFFFF), 35, 200);
}
