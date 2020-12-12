// упаковщик-распаковщик звука в изображение
// AlexGyver, 2020, https://alexgyver.ru/

/*
  В Processing зайти "Набросок / Импортировать библиотеку... / Добавить библиотеку..."
 В поиске найти и установить библиотеку ControlP5
 В поиске найти и установить библиотеку Sound
 */
import controlP5.*;
ControlP5 cp5;
Textarea debugArea;
String cryptPath="", refPath="", soundPath="";
PImage imageCrypt, imageRef;
int imgWidth;

import processing.sound.*;
import javax.sound.sampled.*;
import java.io.*;
SoundFile file;
// https://discourse.processing.org/t/saving-audiosample-as-a-sound-file-of-any-format/23174/5

byte[] pcm_data;
int divider = 1;
int bits = 8;

void setup() {
  size(400, 245);
  background(130);

  // GUI
  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  IMAGE").setPosition(10, 10).setSize(120, 25);
  cp5.addButton("load_crypt_text").setCaptionLabel("LOAD  AUDIO").setPosition(10, 40).setSize(120, 25);
  cp5.addButton("load_crypt").setCaptionLabel("LOAD  CRYPT  IMAGE").setPosition(10, 70).setSize(120, 25);

  cp5.addToggle("bit_res").setCaptionLabel("8/16 bit").setPosition(10, 100).setSize(45, 25).setMode(ControlP5.SWITCH).setValue(true);

  cp5.addSlider("quality").setCaptionLabel("QUALITY").setPosition(65, 100).setSize(65, 25).setRange(1, 8).setValue(1).setNumberOfTickMarks(8);
  cp5.getController("quality").getCaptionLabel().setPaddingX(-35);

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
    .setPosition(150, 10)
    .setSize(240, 85)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(0))
    .setColorBackground(color(180))
    .setColorForeground(color(180));
  ;

  debugArea.setText("CryptoProSound v1.0 by AlexGyver");
}

void draw() {
}

// получаем сид из ключа шифрования
int getSeed() {  
  String thisKey = cp5.get(Textfield.class, "key").getText();
  int keySeed = 1;
  for (int i = 0; i < thisKey.length(); i++) keySeed *= int(thisKey.charAt(i));  // перемножением    
  return keySeed;
}

// кнопка шифровки
void encrypt() {
  if (refPath.length() != 0 && soundPath.length() != 0) {
    // загружаем картинку и считаем её размер
    imageCrypt = loadImage(refPath);
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;

    // ошибки
    if (pcm_data.length == 0) {
      debugArea.setText("Empty sound file");
      return;
    }
    if (pcm_data.length >= imgSize) {
      debugArea.setText("Image is too small");
      return;
    }

    // добавляем ноль (ноль как число!) в самый конец
    pcm_data[pcm_data.length-1] = 0;

    randomSeed(getSeed());

    // переменные
    int[] pixs = new int[pcm_data.length];  // запоминает предыдущие занятые пиксели    
    int counter = 0;

    // цикл шифрования
    for (int i = 0; i < pcm_data.length; i++) {    // пробегаем по фреймам (минус последний нулевой)
      // поиск свободного пикселя
      int thisPix;
      while (true) {
        thisPix = (int)random(0, imgSize);         // выбираем случайный
        boolean check = true;                      // флаг проверки
        for (int k = 0; k < counter; k++) {        // пробегаем по предыдущим выбранным пикселям
          if (thisPix == pixs[k]) check = false;   // если пиксель уже занят, флаг опустить
        }
        if (check) {                               // пиксель свободен
          pixs[counter] = thisPix;                 // запоминаем в буфер
          counter++;                               // ++
          break;                                   // покидаем цикл
        }
      }        

      int thisFrame = pcm_data[i];                  // читаем текущий фрейм
      if (thisFrame == 0) thisFrame = 1;            // не даём фрейму быть 0
      //thisFrame = byte(thisFrame + 128);
      //if (thisFrame == 0) thisFrame = 1;
      int thisColor = imageCrypt.pixels[thisPix];   // читаем пиксель

      // упаковка в RGB 323
      int newColor = (thisColor & 0xF80000);   // 11111000 00000000 00000000
      newColor |= (thisFrame & 0xE0) << 11;    // 00000111 00000000 00000000
      newColor |= (thisColor & (0x3F << 10));  // 00000000 11111100 00000000
      newColor |= (thisFrame & 0x18) << 5;     // 00000000 00000011 00000000
      newColor |= (thisColor & (0x1F << 3));   // 00000000 00000000 11111000
      newColor |= (thisFrame & 0x7);           // 00000000 00000000 00000111

      imageCrypt.pixels[thisPix] = newColor;   // запихиваем обратно в картинку
    }
    imageCrypt.updatePixels();                 // обновляем изображение
    imageCrypt.save("crypt_image.bmp");        // сохраняем
    debugArea.setText("Finished");    

  } else debugArea.setText("Image is not selected");
}

// кнопка дешифровки
void decrypt() {
  if (cryptPath.length() != 0) {
    // загружаем картинку и считаем её размер
    imageCrypt = loadImage(cryptPath);
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;

    randomSeed(getSeed());

    int[] pixs = new int[imgSize];      // буфер занятых пикселей
    byte[] pcmBuf = new byte[imgSize];  // буфер значений 
    int counter = 0;

    // цикл дешифровки
    while (true) {

      // поиск свободного пикселя, такой же как выше
      int thisPix;
      while (true) {    
        thisPix = (int)random(0, imgSize);
        boolean check = true;
        for (int k = 0; k < counter; k++) {
          if (thisPix == pixs[k]) check = false;
        }
        if (check) {
          pixs[counter] = thisPix;
          //counter++;          
          break;
        }
      }

      // читаем пиксель
      int thisColor = imageCrypt.pixels[thisPix];

      // распаковка из RGB 323 обратно в байт
      int thisFrame = 0;
      thisFrame |= (thisColor & 0x70000) >> 11;  // 00000111 00000000 00000000 -> 00000000 00000000 11100000
      thisFrame |= (thisColor & 0x300) >> 5;     // 00000000 00000011 00000000 -> 00000000 00000000 00011000
      thisFrame |= (thisColor & 0x7);            // 00000000 00000000 00000111

      if (thisFrame == 0) break;                 // конец расшифровки (этот ноль мы сами добавили в конец). Выходим
      pcmBuf[counter] = byte(thisFrame);
      counter++;
    }
    // закидываем в новый буфер размером с принятые данные
    byte[] pcm = new byte[counter];  // буфер значений 
    for (int i = 0; i < counter; i++) pcm[i] = pcmBuf[i];

    // и сохраняем
    saveSound(pcm, divider, bits);
    debugArea.setText("Saved in decrypt_audio.wav");
  } else debugArea.setText("Crypted image is not selected");
}

// преобразовать float массив в целые числа. Вернёт размер
int processSound(SoundFile file, int reducer, int bits, int chs) {
  float[] floatData = new float [file.frames() * chs];
  file.read(floatData);  
  if (bits == 8) {
    pcm_data = new byte[floatData.length/reducer/chs+1];  // +1 для нулевого
    for (int i = 0; i < floatData.length/reducer/chs; i++) {    
      pcm_data[i] = byte(255 * floatData[i*reducer*chs]);
    }
  } else if (bits == 16) {
    pcm_data = new byte[2 * floatData.length/reducer/chs+1];  // +1 для нулевого
    for (int i = 0; i < floatData.length/reducer/chs; i++) {
      int aux = floor(32767 * floatData[i*reducer*chs]);
      pcm_data[i * 2] = byte(aux); 
      pcm_data[(i * 2) + 1] = (byte)((int) aux >> 8);
    }
  }  
  return pcm_data.length;
}

// сохранить целочисленный звук в файл
void saveSound(byte[] pcm_data, int reducer, int bits) {
  // Samplerate, Samplesize em Bits, channels, signed, bigendian
  AudioFormat frmt = new AudioFormat(44100/reducer, bits, 1, true, false); 
  AudioInputStream ais = new AudioInputStream( 
    new ByteArrayInputStream(pcm_data), 
    frmt, 
    pcm_data.length / frmt.getFrameSize()
    );
  try {
    AudioSystem.write(ais, AudioFileFormat.Type.WAVE, new
      File(dataPath("") + "decrypt_audio.wav")
      );
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}

// прочие кнопки
void quality(int val) {
  divider = 9-val;
}
void bit_res(boolean state) {
  bits = state ? 8 : 16;
}

void load_ref() {
  selectInput("", "selectRef");
}

void selectRef(File selection) {
  if (selection != null) {
    refPath = selection.getAbsolutePath();
    PImage image = loadImage(refPath);

    String debug = "";
    debug += refPath + "\r\n";
    debug += "size " + (image.width * image.height) + " pixels \r\n";

    debugArea.setText(debug);
  } else debugArea.setText("Image is not selected");
}

void load_crypt() {
  selectInput("", "selectCrypt");
}

void selectCrypt(File selection) {
  if (selection != null) {
    cryptPath = selection.getAbsolutePath();
    PImage image = loadImage(cryptPath);

    String debug = "";
    debug += cryptPath + "\r\n";
    debug += "size " + (image.width * image.height) + " pixels \r\n";

    debugArea.setText(debug);
  } else debugArea.setText("Crypted image is not selected");
}

void load_crypt_text() {
  selectInput("", "selectSound");
}

void selectSound(File selection) {
  if (selection != null) {
    soundPath = selection.getAbsolutePath();
    file = new SoundFile(this, soundPath);

    // файл, делитель фреймов (1-10), битность (8 или 16), колво каналов (1 или 2)
    processSound(file, divider, bits, file.channels());

    String debug = "";
    debug += soundPath + "\r\n";
    debug += "loaded " + (pcm_data.length) + " frames \r\n";

    debugArea.setText(debug);    
  } else debugArea.setText("Audio file is not selected");
}
