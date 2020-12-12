// AlexGyver, 2020, https://alexgyver.ru/
float phaseShift = 147.9;

/*
  В Processing зайти "Набросок / Импортировать библиотеку... / Добавить библиотеку..."
 В поиске найти и установить библиотеку ControlP5
 В поиске найти и установить библиотеку Sound
 */
import controlP5.*;
ControlP5 cp5;
Textarea debugArea;
String refPath="", imagePath="";
PImage imageCrypt;
int imgWidth;

import processing.sound.*;
import javax.sound.sampled.*;
import java.io.*;

SoundFile file;
float[] ref, img;
float refAmpl = 1.0, imgAmpl = 1.0;
int spectW = 370;
PGraphics pg;
boolean updFlag = true;
boolean saveFlag = false;
float phaseVal = 0;
int framerate = 44100;
int audioSize = 5;
boolean createFlag = false;

void setup() {
  size(500, 350);
  background(130);

  // GUI
  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  AUDIO").setPosition(10, 10).setSize(100, 25);
  cp5.addButton("create_ref").setCaptionLabel("CREATE  AUDIO").setPosition(10, 40).setSize(100, 25);
  
  cp5.addSlider("audio_size").setCaptionLabel("LENGTH").setPosition(10, 70).setSize(100, 25).setRange(0, 30).setValue(5);
  cp5.getController("audio_size").getCaptionLabel().setPaddingX(-35);
  
  cp5.addButton("load_image").setCaptionLabel("LOAD  IMAGE").setPosition(10, 100).setSize(100, 25);
  cp5.addButton("encrypt").setCaptionLabel("ENCRYPT  AND  SAVE").setPosition(10, 130).setSize(100, 25); 

  cp5.addSlider("ref_vol").setCaptionLabel("REF VOL").setPosition(120, 10).setSize(10, 50).setRange(0, 200).setValue(100);
  cp5.addSlider("img_vol").setCaptionLabel("IMG VOL").setPosition(310, 10).setSize(10, 50).setRange(0, 200).setValue(100);

  cp5.addSlider("spect_w").setCaptionLabel("WIDTH").setPosition(10, 310).setSize(100, 25).setRange(0, 370).setValue(370);
  cp5.getController("spect_w").getCaptionLabel().setPaddingX(-35);

  //cp5.addSlider("phase").setCaptionLabel("PHASE").setPosition(10, 130).setSize(100, 25).setRange(0, 3).setValue(1.0);
  //cp5.getController("phase").getCaptionLabel().setPaddingX(-35);

  pg = createGraphics(width, height);
}

void draw() {
  background(130);
  update();
  image(pg, 0, 0);
}


// обновление слоя графики 
void update() {
  if (updFlag) {
    updFlag = false;
    int spectX = 120;
    int spectY = 80;   
    int vol1X = 150;
    int vol2X = 340;
    int volSize = 150;

    pg.beginDraw();
    pg.background(130);
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(1);
    pg.rect(vol1X, 10, volSize, 50);
    pg.rect(vol2X, 10, volSize, 50);
    pg.rect(spectX, spectY, spectW, 128*2);

    if (refPath.length() != 0 || createFlag) {
      for (int i = 0; i < volSize; i++) {
        float maxVal = 0;
        int part = ref.length / volSize;
        for (int j = 0; j < part; j++) {
          if (ref[i*part+j] > maxVal) maxVal = ref[i*part+j];
        }
        maxVal *= refAmpl;
        pg.line(vol1X + i, 60, vol1X + i, 60 - maxVal*50);
      }
    }

    if (imagePath.length() != 0) {
      for (int i = 0; i < img.length; i++) img[i] = 0;
      for (int i = 0; i < imageCrypt.width; i++) {
        for (int j = 0; j < 128; j++) {
          int val = (int)brightness(imageCrypt.pixels[i + imageCrypt.width * (127-j)]);
          for (int k = 0; k < 256; k++) {
            img[i * 256 + k] += val/255.0 * 0.006 * sin((k+j*phaseVal)/framerate*2*PI*(500+j*150));
          }
        }
      }
      for (int i = 0; i < volSize; i++) {
        float maxVal = 0;
        int part = img.length / volSize;
        for (int j = 0; j < part; j++) {
          if (img[i*part+j] > maxVal) maxVal = img[i*part+j];
        }
        maxVal *= imgAmpl;
        pg.line(vol2X + i, 60, vol2X + i, 60 - maxVal*50);
      }
    }

    if (refPath.length() != 0 || createFlag) {      
      float[] fitImg = new float[ref.length];

      if (imagePath.length() != 0) {
        int amount = ref.length/img.length;
        if (amount == 0) return;
        int counter = 0;
        for (int i = 0; i < img.length/256; i++) {
          for (int j = 0; j < amount; j++) {
            for (int k = 0; k < 256; k++) {
              fitImg[counter++] = img[i * 256 + k];
            }
          }
        }
      }

      int parts = ref.length / spectW;
      for (int i = 0; i < spectW; i++) {
        float soundPiece[] = new float[256];
        for (int j = 0; j < 256; j++) {
          soundPiece[j] = ref[i*parts+j]*refAmpl;
          soundPiece[j] += fitImg[i*parts+j]*imgAmpl;
        }
        float[] spectrum = new float[256];
        FFT(soundPiece, spectrum, 256, 256);
        for (int j = 0; j < 256; j++) {
          pg.stroke(spectrum[j/2]*30000);
          pg.point(spectX+i, spectY+256-j);
        }
      }
      if (saveFlag) {
        saveFlag = false;
        for (int i = 0; i < fitImg.length; i++) {
          fitImg[i] = ref[i]*refAmpl + fitImg[i]*imgAmpl;
        }
        processSound(fitImg, 1);
      }
    }

    pg.endDraw();
  }
}

// крутилки
void ref_vol(int val) {
  refAmpl = val / 100.0;
  updFlag = true;
}
void img_vol(int val) {
  imgAmpl = val / 100.0;
  updFlag = true;
}
void spect_w(int val) {
  spectW = val;
  updFlag = true;
}
void audio_size(int val) {
  audioSize = val;
  updFlag = true;
}
void phase(float val) {
  phaseVal = val;
  updFlag = true;
}

// кнопка шифровки
void encrypt() {
  if (refPath.length() != 0 || createFlag) {
    saveFlag = true;
    updFlag = true;
  }
}


void load_ref() {
  selectInput("", "selectRef");
  createFlag = false;
}

void create_ref() {  
  framerate = 44100;
  phaseVal = phaseShift * framerate / 44100;
  ref = new float [framerate*audioSize];
  updFlag = true;
  createFlag = true;
}


void selectRef(File selection) {
  if (selection != null) {
    refPath = selection.getAbsolutePath(); 
    file = new SoundFile(this, refPath);
    float newRef[] = new float [file.frames() * file.channels()];
    framerate = int(file.frames() / file.duration());
    phaseVal = phaseShift * framerate / 44100;
    ref = new float [file.frames()];
    file.read(newRef);
    for (int i = 0; i < ref.length; i++) ref[i] = newRef[i*file.channels()];
    updFlag = true;
  }
}


void load_image() {
  selectInput("", "selectImage");
}

void selectImage(File selection) {
  if (selection != null) {
    imagePath = selection.getAbsolutePath();
    imageCrypt = loadImage(imagePath);    
    imageCrypt.resize(0, 128);
    imageCrypt.filter(GRAY);
    imageCrypt.loadPixels();
    img = new float[imageCrypt.width * 256];
    updFlag = true;
  }
}

// сохранить float массив как wav
void processSound(float[] floatData, int chs) {    
  byte[] pcm_data = new byte[2 * floatData.length / chs];
  for (int i = 0; i < floatData.length / chs; i++) {
    int aux = floor(32767 * floatData[i * chs]);
    pcm_data[i * 2] = byte(aux); 
    pcm_data[(i * 2) + 1] = byte((int)aux >> 8);
  }

  // https://discourse.processing.org/t/saving-audiosample-as-a-sound-file-of-any-format/23174/5
  // Samplerate, Samplesize em Bits, channels, signed, bigendian
  AudioFormat frmt = new AudioFormat(framerate, 16, chs, true, false); 
  AudioInputStream ais = new AudioInputStream( 
    new ByteArrayInputStream(pcm_data), 
    frmt, 
    pcm_data.length / frmt.getFrameSize()
    );
  try {
    AudioSystem.write(ais, AudioFileFormat.Type.WAVE, new
      File(dataPath("") + "new.wav")
      );
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}
