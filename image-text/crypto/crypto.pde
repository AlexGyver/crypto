import controlP5.*;
ControlP5 cp5;
Textarea myTextarea;
String cryptPath="", refPath="", textPath="";
PImage imageCrypt, imageRef;
int imgWidth;

void setup() {
  size(400, 205);
  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  REFERENCE  IMAGE").setPosition(10, 10).setSize(120, 25);
  cp5.addButton("load_crypt_text").setCaptionLabel("LOAD  TEXT").setPosition(10, 40).setSize(120, 25);
  cp5.addButton("encrypt").setCaptionLabel("ENCRYPT AND  SAVE").setPosition(10, 70).setSize(120, 25);
  cp5.addButton("load_crypt").setCaptionLabel("LOAD  CRYPT  IMAGE").setPosition(10, 140).setSize(120, 25);  
  cp5.addButton("decrypt").setCaptionLabel("DECRYPT AND  SAVE").setPosition(10, 170).setSize(120, 25);

  myTextarea = cp5.addTextarea("decryptText")
    .setPosition(150, 10)
    .setSize(240, 185)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(0))
    .setColorBackground(color(180))
    .setColorForeground(color(180));
  ;
}

void draw() {
}

void encrypt() {
  if (refPath.length() != 0 && textPath.length() != 0) {
    imageCrypt = loadImage(refPath);
    imageCrypt.loadPixels();
    String[] lines = loadStrings(textPath);
    int imgSize = imageCrypt.width * imageCrypt.height;
    int textSize = 0;
    for (int i = 0; i < lines.length; i++) textSize += lines[i].length();
    if (textSize == 0) return;
    int pixStep = imageCrypt.width * imageCrypt.height / textSize;    
    int thisPix = 1;
    /*if ((int)imageCrypt.pixels[0] < -200)*/ imageCrypt.pixels[0] += pixStep;    
    //else imageCrypt.pixels[0] -= pixStep;

    for (int i = 0; i < lines.length; i++) {
      for (int j = 0; j < lines[i].length(); j++) {
        int thisChar = lines[i].charAt(j);
        if (thisChar > 1000) thisChar -= 800;  // костыль для русских букоф    

        if (thisChar > pixStep) {  // вмещаем с остатком
          int whole = thisChar / (pixStep-1);
          int left = thisChar % (pixStep-1);
          for (int k = 0; k < pixStep-1; k++) {
            imageCrypt.pixels[thisPix+k] += whole;//((int)imageCrypt.pixels[thisPix+k] < -200) ? whole : -whole;
          }
          imageCrypt.pixels[thisPix+pixStep-1] += left;//((int)imageCrypt.pixels[thisPix+whole] < -200) ? left : -left;
        } else {                   // по 1
          for (int k = 0; k < thisChar; k++) {
            imageCrypt.pixels[thisPix+k] += 1;//((int)imageCrypt.pixels[thisPix+k] < -200) ? 1 : -1;
          }
        }
        thisPix += pixStep;
        if (thisPix+pixStep > imgSize) break;
      }
    }
    imageCrypt.updatePixels();
    imageCrypt.save("crypt_image.bmp");
  } else println("not selected");
}

void decrypt() {
  if (refPath.length() != 0 && cryptPath.length() != 0) {
    imageRef = loadImage(refPath);
    imageCrypt = loadImage(cryptPath);
    imageRef.loadPixels();
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;
    String decryptText = "";
    int thisPix = 1;
    int pixStep;
    /*if ((int)imageRef.pixels[0] < -200)*/ pixStep = imageCrypt.pixels[0] - imageRef.pixels[0]; 
    //else pixStep = imageRef.pixels[0] - imageCrypt.pixels[0];

    while (true) {
      int thisChar = 0;
      for (int i = 0; i < pixStep; i++) {        
        /*if ((int)imageRef.pixels[thisPix+i] < -200)*/ thisChar += imageCrypt.pixels[thisPix+i] - imageRef.pixels[thisPix+i];
        //else thisChar += imageRef.pixels[thisPix+i] - imageCrypt.pixels[thisPix+i];
      }      

      if (thisChar == 0) break;
      if (thisChar > 200) thisChar += 800;  // костыль для русских букоф
      decryptText += char(thisChar);      
      thisPix += pixStep;
      if (thisPix+pixStep > imgSize) break;
    }
    myTextarea.setText(decryptText);
    String[] lines = new String[1];
    lines[0] = decryptText;
    saveStrings("decrypt_text.txt", lines);
  } else println("not selected");
}

void load_ref() {
  selectInput("", "selectRef");
}

void selectRef(File selection) {
  if (selection != null) refPath = selection.getAbsolutePath();
}

void load_crypt() {
  selectInput("", "selectCrypt");
}

void selectCrypt(File selection) {
  if (selection != null) cryptPath = selection.getAbsolutePath();
}

void load_crypt_text() {
  selectInput("", "selectCryptText");
}

void selectCryptText(File selection) {
  if (selection != null) textPath = selection.getAbsolutePath();
}
