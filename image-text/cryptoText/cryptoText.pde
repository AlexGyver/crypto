// упаковщик-распаковщик текста в изображение
// AlexGyver, 2020, https://alexgyver.ru/
// Добавил парсинг переноса строк

/*
  В Processing зайти "Набросок / Импортировать библиотеку... / Добавить библиотеку..."
 В поиске найти и установить библиотеку ControlP5
 */
import controlP5.*;
ControlP5 cp5;
Textarea debugArea;
String cryptPath="", refPath="", textPath="";
PImage imageCrypt, imageRef;
int imgWidth;

void setup() {
  size(400, 205);

  // GUI
  cp5 = new ControlP5(this);
  cp5.addButton("load_ref").setCaptionLabel("LOAD  IMAGE").setPosition(10, 10).setSize(120, 25);
  cp5.addButton("load_crypt_text").setCaptionLabel("LOAD  TEXT").setPosition(10, 40).setSize(120, 25);
  cp5.addButton("load_crypt").setCaptionLabel("LOAD  CRYPT  IMAGE").setPosition(10, 70).setSize(120, 25);
  cp5.addTextfield("key")
    .setPosition(10, 110)
    .setSize(120, 25)
    .setFont(createFont("arial", 15))
    .setAutoClear(false)
    .setCaptionLabel("")
    .setText("key")
    ;
  cp5.addButton("encrypt").setCaptionLabel("ENCRYPT  AND  SAVE").setPosition(10, 140).setSize(120, 25);  
  cp5.addButton("decrypt").setCaptionLabel("DECRYPT  AND  SAVE").setPosition(10, 170).setSize(120, 25);

  debugArea = cp5.addTextarea("decryptText")
    .setPosition(150, 10)
    .setSize(240, 185)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(0))
    .setColorBackground(color(180))
    .setColorForeground(color(180));
  ;
  debugArea.setText("CryptoText v1.0 by AlexGyver");
}

void draw() {
}

// получаем сид из ключа шифрования
int getSeed() {  
  String thisKey = cp5.get(Textfield.class, "key").getText();
  int keySeed = 1;
  for (int i = 0; i < thisKey.length()-1; i++) 
    keySeed *= int(thisKey.charAt(i) * (thisKey.charAt(i)-thisKey.charAt(i+1)));  // перемножением с разностью
  return keySeed;
}

// кнопка шифровки
void encrypt() {
  if (refPath.length() != 0 && textPath.length() != 0) {
    // загружаем картинку и считаем её размер
    imageCrypt = loadImage(refPath);
    imageCrypt.loadPixels();
    int imgSize = imageCrypt.width * imageCrypt.height;

    // загружаем текст и считаем его размер
    String[] lines = loadStrings(textPath);    
    int textSize = 0;
    for (int i = 0; i < lines.length; i++) textSize += (lines[i].length() + 1);  // +1 на перенос    

    // ошибки
    if (textSize == 0) {
      debugArea.setText("Empty text file");
      return;
    }
    if (textSize >= imgSize) {
      debugArea.setText("Image is too small");
      return;
    }

    // добавляем ноль (ноль как число!) в самый конец текста
    lines[lines.length-1] += '\0';
    textSize += 1;

    randomSeed(getSeed());

    // переменные
    int[] pixs = new int[textSize];  // запоминает предыдущие занятые пиксели    
    int counter = 0;

    // цикл шифрования
    for (int i = 0; i < lines.length; i++) {         // пробегаем по строкам
      for (int j = 0; j < lines[i].length() + 1; j++) {  // и каждому символу в них +1

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
        
        int thisChar;
        if (j == lines[i].length()) thisChar = int('\n');  // последний - перенос строки
        else thisChar = lines[i].charAt(j);       // читаем текущий символ
        
        if (thisChar > 1000) thisChar -= 890;    // костыль для русских букоф        

        int thisColor = imageCrypt.pixels[thisPix];  // читаем пиксель

        // упаковка в RGB 323
        int newColor = (thisColor & 0xF80000);   // 11111000 00000000 00000000
        newColor |= (thisChar & 0xE0) << 11;     // 00000111 00000000 00000000
        newColor |= (thisColor & (0x3F << 10));  // 00000000 11111100 00000000
        newColor |= (thisChar & 0x18) << 5;      // 00000000 00000011 00000000
        newColor |= (thisColor & (0x1F << 3));   // 00000000 00000000 11111000
        newColor |= (thisChar & 0x7);            // 00000000 00000000 00000111

        imageCrypt.pixels[thisPix] = newColor;   // запихиваем обратно в картинку
      }
    }
    imageCrypt.updatePixels();                   // обновляем изображение
    imageCrypt.save("crypt_image.bmp");          // сохраняем
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

    int[] pixs = new int[imgSize];  // буфер занятых пикселей
    String decryptText = "";        // буфер текста
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
          counter++;          
          break;
        }
      }

      // читаем пиксель
      int thisColor = imageCrypt.pixels[thisPix];

      // распаковка из RGB 323 обратно в байт
      int thisChar = 0;
      thisChar |= (thisColor & 0x70000) >> 11;  // 00000111 00000000 00000000 -> 00000000 00000000 11100000
      thisChar |= (thisColor & 0x300) >> 5;     // 00000000 00000011 00000000 -> 00000000 00000000 00011000
      thisChar |= (thisColor & 0x7);            // 00000000 00000000 00000111

      if (thisChar > 130) thisChar += 890;      // костыль для русских букоф
      if (thisChar == 0) break;                 // конец текста (этот ноль мы сами добавили в конец). Выходим
      decryptText += char(thisChar);            // пишем в буфер
    }
    debugArea.setText(decryptText);            // выводим в гуи

    // и сохраняем в txt
    String[] lines = new String[1];
    lines[0] = decryptText;
    saveStrings("decrypt_text.txt", lines);
  } else debugArea.setText("Crypted image is not selected");
}

// прочие кнопки
void load_ref() {
  selectInput("", "selectRef");
}

void selectRef(File selection) {
  if (selection != null) {
    refPath = selection.getAbsolutePath();
    debugArea.setText(refPath);
  } else debugArea.setText("Image is not selected");
}

void load_crypt() {
  selectInput("", "selectCrypt");
}

void selectCrypt(File selection) {
  if (selection != null) {
    cryptPath = selection.getAbsolutePath();
    debugArea.setText(cryptPath);
  } else debugArea.setText("Crypted image is not selected");
}

void load_crypt_text() {
  selectInput("", "selectCryptText");
}

void selectCryptText(File selection) {
  if (selection != null) {
    textPath = selection.getAbsolutePath();
    debugArea.setText(textPath);
  } else debugArea.setText("Text file is not selected");
}
