// упаковщик-распаковщик изображения в звук
// AlexGyver, 2020, https://alexgyver.ru/

/*
  В Processing зайти "Набросок / Импортировать библиотеку... / Добавить библиотеку..."
 В поиске найти и установить библиотеку ControlP5
 В поиске найти и установить библиотеку Sound
 */
import controlP5.*;
ControlP5 cp5;
Textarea debugArea;
String cryptPath="", refPath="", imagePath="";

import processing.sound.*;
import javax.sound.sampled.*;
import java.io.*;
// https://discourse.processing.org/t/saving-audiosample-as-a-sound-file-of-any-format/23174/5
PGraphics pg;

void setup() {
  size(400, 245);
  pg = createGraphics(width, height);
  background(130);

  // GUI
  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  AUDIO").setPosition(10, 10).setSize(120, 25);
  cp5.addButton("load_image").setCaptionLabel("LOAD  IMAGE").setPosition(10, 40).setSize(120, 25);
  cp5.addButton("load_crypt").setCaptionLabel("LOAD  CRYPT  AUDIO").setPosition(10, 70).setSize(120, 25);

  cp5.addTextfield("key")
    .setPosition(10, 150)
    .setSize(120, 25)
    .setFont(createFont("arial", 15))
    .setAutoClear(false)
    .setCaptionLabel("")
    .setText("key")
    ;
  cp5.addButton("encrypt").setCaptionLabel("ENCRYPT  AND  SAVE").setPosition(10, 180).setSize(120, 25);  
  cp5.addButton("decrypt").setCaptionLabel("DECRYPT  AND  SAVE").setPosition(10, 210).setSize(120, 25);

  debugArea = cp5.addTextarea("decryptText")
    .setPosition(10, 100)
    .setSize(120, 40)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(0))
    .setColorBackground(color(180))
    .setColorForeground(color(180));
  ;

  debugArea.setText("CryptoAmpli v1.0 by AlexGyver");
}

void draw() {
  image(pg, 0, 0);    // вывод картинки в окне программы
}

// получаем сид из ключа шифрования
int getSeed() {  
  String thisKey = cp5.get(Textfield.class, "key").getText();
  int keySeed = 1;
  for (int i = 0; i < thisKey.length(); i++) keySeed *= int(thisKey.charAt(i));  // перемножением    
  return keySeed;
}

// получить незанятое случайное число
int getFreeRnd(int[] buf, int max, int count) {
  while (true) {    
    int thisVal = (int)random(0, max);
    boolean check = true;
    for (int k = 0; k < count; k++) {
      if (thisVal == buf[k]) check = false;
    }
    if (check) {
      buf[count] = thisVal;
      return thisVal;
    }
  }
}

// кнопка шифровки
void encrypt() {
  if (refPath.length() != 0 && imagePath.length() != 0) {    
    randomSeed(getSeed());
    SoundFile file = new SoundFile(this, refPath);
    byte[] pcmRef = new byte[2 * file.frames() * file.channels()];
    int framerate = int(file.frames() / file.duration());           // частота оцифровки
    loadSound(file, pcmRef);

    PImage image = loadImage(imagePath);
    image.loadPixels();
    if (pcmRef.length < (image.width * image.height) * 3 * 2 + 4) {  // 3 байта, через фрейм + 4 служебных
      debugArea.setText("Audio is too small for image");
      return;
    }

    int[] used = new int[pcmRef.length / 2];
    int count = 0;
    int maxVal = pcmRef.length / 2;    
    pcmRef[getFreeRnd(used, maxVal, count++) * 2 + 1] = byte((image.width) & 0xFF);
    pcmRef[getFreeRnd(used, maxVal, count++) * 2 + 1] = byte((int(image.width) & 0xFF00) >> 8); 
    pcmRef[getFreeRnd(used, maxVal, count++) * 2 + 1] = byte((image.height) & 0xFF);
    pcmRef[getFreeRnd(used, maxVal, count++) * 2 + 1] = byte((int(image.height) & 0xFF00) >> 8);

    for (int i = 0; i < image.width * image.height; i++) {      
      pcmRef[getFreeRnd(used, maxVal, count++) * 2] = byte(constrain( ((image.pixels[i] & 0xFF0000) >> 16), 1, 254));
      pcmRef[getFreeRnd(used, maxVal, count++) * 2] = byte(constrain( ((image.pixels[i] & 0xFF00) >> 8), 1, 254));
      pcmRef[getFreeRnd(used, maxVal, count++) * 2] = byte(constrain( (image.pixels[i] & 0xFF), 1, 254));
    }
    saveSound(pcmRef, framerate, file.channels());
    debugArea.setText("Finished");
  } else debugArea.setText("Image is not selected");
}


// кнопка дешифровки
void decrypt() {
  if (cryptPath.length() != 0) {
    randomSeed(getSeed());
    SoundFile file = new SoundFile(this, cryptPath);
    byte[] pcmCrypt = new byte[2 * file.frames() * file.channels()];    
    loadSound(file, pcmCrypt);
    int[] used = new int[pcmCrypt.length / 2];
    int count = 0;
    int maxVal = pcmCrypt.length / 2;
    
    int w = (pcmCrypt[getFreeRnd(used, maxVal, count++) * 2 + 1] & 0xFF) 
      | ((pcmCrypt[getFreeRnd(used, maxVal, count++) * 2 + 1] & 0xFF) << 8);
    int h = (pcmCrypt[getFreeRnd(used, maxVal, count++) * 2 + 1] & 0xFF) 
      | ((pcmCrypt[getFreeRnd(used, maxVal, count++) * 2 + 1] & 0xFF) << 8);

    if (w*h*2*3+4 > pcmCrypt.length) {
      debugArea.setText("Error");
      return;
    }
    PImage decrypt = createImage(w, h, RGB);

    decrypt.loadPixels();
    for (int i = 0; i < w * h; i++) {
      decrypt.pixels[i] |= ((pcmCrypt[getFreeRnd(used, pcmCrypt.length / 2, count++) * 2] & 0xFF) << 16);
      decrypt.pixels[i] |= ((pcmCrypt[getFreeRnd(used, pcmCrypt.length / 2, count++) * 2] & 0xFF) << 8);
      decrypt.pixels[i] |= (pcmCrypt[getFreeRnd(used, pcmCrypt.length / 2, count++) * 2] & 0xFF);
    }

    decrypt.updatePixels();                 // обновляем изображение
    decrypt.save("decrypt_image.bmp");      // сохраняем
    debugArea.setText("Finished");

    // вывести в окно программы
    pg.beginDraw();
    pg.background(130);
    int maxW = width-130;
    int maxH = height-20;
    decrypt.resize(0, maxH);
    if (decrypt.width > maxW) decrypt.resize(maxW, 0);
    pg.image(decrypt, 150, 10);
    pg.endDraw();
  } else debugArea.setText("Crypted image is not selected");
}

// загрузить файл (моно или стерео) в pcmRef
void loadSound(SoundFile file, byte[] pcm) {
  float floatData[] = new float [file.frames() * file.channels()];  // полный массив  
  file.read(floatData);                                             // читаем в массив  
  for (int i = 0; i < floatData.length; i++) {
    int aux = floor(32767 * floatData[i]);
    pcm[i * 2] = byte(aux); 
    pcm[(i * 2) + 1] = byte((int)aux >> 8);
  }
}

// сохранить pcm как wav
void saveSound(byte[] pcm, int rate, int channels) {    
  // https://discourse.processing.org/t/saving-audiosample-as-a-sound-file-of-any-format/23174/5
  // Samplerate, Samplesize em Bits, channels, signed, bigendian
  AudioFormat frmt = new AudioFormat(rate, 16, channels, true, false); 
  AudioInputStream ais = new AudioInputStream( 
    new ByteArrayInputStream(pcm), 
    frmt, 
    pcm.length / frmt.getFrameSize()
    );
  try {
    AudioSystem.write(ais, AudioFileFormat.Type.WAVE, new File(dataPath("") + "_crypt.wav"));
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}


void load_ref() {
  selectInput("", "selectRef");
}

void selectRef(File selection) {
  if (selection != null) {
    refPath = selection.getAbsolutePath();
    debugArea.setText(refPath);
  } else debugArea.setText("Audio is not selected");
}

void load_image() {
  selectInput("", "selectImage");
}

void selectImage(File selection) {
  if (selection != null) {
    imagePath = selection.getAbsolutePath();    
    debugArea.setText(imagePath);
  } else debugArea.setText("Image is not selected");
}

void load_crypt() {
  selectInput("", "selectCrypt");
}

void selectCrypt(File selection) {
  if (selection != null) {
    cryptPath = selection.getAbsolutePath();
    debugArea.setText(cryptPath);
  } else debugArea.setText("Crypted sound is not selected");
}
