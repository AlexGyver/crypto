/*
// ======= РАЗМАЗЫВАЕМ ======= 
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
 if ((int)imageCrypt.pixels[0] < -200) imageCrypt.pixels[0] += pixStep;    
 else imageCrypt.pixels[0] -= pixStep;
 
 for (int i = 0; i < lines.length; i++) {
 for (int j = 0; j < lines[i].length(); j++) {
 int thisChar = lines[i].charAt(j);
 if (thisChar > 1000) thisChar -= 800;  // костыль для русских букоф    
 
 if (thisChar > pixStep) {  // вмещаем с остатком
 int whole = thisChar / (pixStep-1);
 int left = thisChar % (pixStep-1);
 for (int k = 0; k < pixStep-1; k++) {
 imageCrypt.pixels[thisPix+k] += ((int)imageCrypt.pixels[thisPix+k] < -200) ? whole : -whole;
 }
 imageCrypt.pixels[thisPix+pixStep-1] += ((int)imageCrypt.pixels[thisPix+whole] < -200) ? left : -left;
 } else {                   // по 1
 for (int k = 0; k < thisChar; k++) {
 imageCrypt.pixels[thisPix+k] += ((int)imageCrypt.pixels[thisPix+k] < -200) ? 1 : -1;
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
 if ((int)imageRef.pixels[0] < -200) pixStep = imageCrypt.pixels[0] - imageRef.pixels[0]; 
 else pixStep = imageRef.pixels[0] - imageCrypt.pixels[0];
 
 while (true) {
 int thisChar = 0;
 for (int i = 0; i < pixStep; i++) {        
 if ((int)imageRef.pixels[thisPix+i] < -200) thisChar += imageCrypt.pixels[thisPix+i] - imageRef.pixels[thisPix+i];
 else thisChar += imageRef.pixels[thisPix+i] - imageCrypt.pixels[thisPix+i];
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
 */

/*
// ======= РАНДОМ ======= 
 void encrypt() {
 if (refPath.length() != 0 && textPath.length() != 0) {
 imageCrypt = loadImage(refPath);
 imageCrypt.loadPixels();
 String[] lines = loadStrings(textPath);    
 int textSize = 0;
 for (int i = 0; i < lines.length; i++) textSize += lines[i].length();
 if (textSize == 0) return;
 long imgSize = imageCrypt.width * imageCrypt.height;
 randomSeed(imageCrypt.pixels[0]);      
 long[] pixs = new long[textSize];
 int curPix = 0;
 for (int i = 0; i < lines.length; i++) {
 for (int j = 0; j < lines[i].length(); j++) {
 int thisPix;
 while (true) {
 thisPix = (int)random(0, imgSize);
 boolean check = true;
 for (int k = 0; k < curPix; k++) {
 if (thisPix == pixs[k]) check = false;
 }
 if (check) {
 pixs[curPix] = thisPix;
 curPix++;
 break;
 }
 }
 int thisChar = lines[i].charAt(j);
 if (thisChar > 1000) thisChar -= 800;  // костыль для русских букоф
 if ((int)imageCrypt.pixels[thisPix] < -200) imageCrypt.pixels[thisPix] += thisChar;
 else imageCrypt.pixels[thisPix] -= thisChar;
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
 String decryptText = "";
 long imgSize = imageCrypt.width * imageCrypt.height;
 randomSeed(imageRef.pixels[0]);
 long[] pixs = new long[(int)imgSize];
 int curPix = 0;
 while (true) {
 int thisChar;
 int thisPix;
 while (true) {
 println(curPix);
 thisPix = (int)random(0, imgSize);
 boolean check = true;
 for (int k = 0; k < curPix; k++) {
 if (thisPix == pixs[k]) check = false;
 }
 if (check) {
 pixs[curPix] = thisPix;
 curPix++;
 break;
 }
 }
 if ((int)imageRef.pixels[thisPix] < -200) thisChar = imageCrypt.pixels[thisPix] - imageRef.pixels[thisPix];
 else thisChar = imageRef.pixels[thisPix] - imageCrypt.pixels[thisPix];
 if (thisChar == 0) break;
 if (thisChar > 200) thisChar += 800;  // костыль для русских букоф
 decryptText += char(thisChar);
 }
 myTextarea.setText(decryptText);
 String[] lines = new String[1];
 lines[0] = decryptText;
 saveStrings("decrypt_text.txt", lines);
 } else println("not selected");
 }
 */
/*
//  ======= РАНДОМ ======= 
 void encrypt() {
 if (refPath.length() != 0 && textPath.length() != 0) {
 imageCrypt = loadImage(refPath);
 imageCrypt.loadPixels();
 String[] lines = loadStrings(textPath);    
 int textSize = 0;
 for (int i = 0; i < lines.length; i++) textSize += lines[i].length();
 if (textSize == 0) return;
 long imgSize = imageCrypt.width * imageCrypt.height;
 randomSeed(imageCrypt.pixels[0]);      
 long[] pixs = new long[textSize];
 int curPix = 0;
 for (int i = 0; i < lines.length; i++) {
 for (int j = 0; j < lines[i].length(); j++) {
 int thisPix;
 while (true) {
 thisPix = (int)random(0, imgSize);
 boolean check = true;
 for (int k = 0; k < curPix; k++) {
 if (thisPix == pixs[k]) check = false;
 }
 if (check) {
 pixs[curPix] = thisPix;
 curPix++;
 break;
 }
 }
 
 if ((int)imageCrypt.pixels[thisPix] < -200) imageCrypt.pixels[thisPix] += byte(lines[i].charAt(j));
 else imageCrypt.pixels[thisPix] -= byte(lines[i].charAt(j));
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
 String decryptText = "";
 long imgSize = imageCrypt.width * imageCrypt.height;
 randomSeed(imageRef.pixels[0]);
 long[] pixs = new long[(int)imgSize];
 int curPix = 0;
 while (true) {
 int thisChar;
 int thisPix;
 while (true) {
 println(curPix);
 thisPix = (int)random(0, imgSize);
 boolean check = true;
 for (int k = 0; k < curPix; k++) {
 if (thisPix == pixs[k]) check = false;
 }
 if (check) {
 pixs[curPix] = thisPix;
 curPix++;
 break;
 }
 }
 if ((int)imageRef.pixels[thisPix] < -200) thisChar = imageCrypt.pixels[thisPix] - imageRef.pixels[thisPix];
 else thisChar = imageRef.pixels[thisPix] - imageCrypt.pixels[thisPix];
 if (thisChar == 0) break;
 decryptText += char(thisChar);
 }
 myTextarea.setText(decryptText);
 String[] lines = new String[1];
 lines[0] = decryptText;
 saveStrings("decrypt_text.txt", lines);
 } else println("not selected");
 }
 */
 
/*
// ======= ШАГ 1 ======= 
 // зашифровать
 void encrypt() {
 if (refPath.length() != 0 && textPath.length() != 0) {
 // загружаем картинку и текст
 imageCrypt = loadImage(refPath);
 imageCrypt.loadPixels();
 String[] lines = loadStrings(textPath);
 
 int thisPix = 0;    
 for (int i = 0; i < lines.length; i++) {         // каждая строка в файле
 for (int j = 0; j < lines[i].length(); j++) {  // каждый символ в строке
 int thisChar = lines[i].charAt(j);           // читаем символ
 if (thisChar > 1000) thisChar -= 800;        // костыль для русских букоф (UTF-8)
 imageCrypt.pixels[thisPix] += thisChar;      // прибавляем код к цвету
 thisPix++;                                   // следующий пиксель
 }
 }
 
 // сохраняем зашифрованную картинку
 imageCrypt.updatePixels();
 imageCrypt.save("crypt_image.bmp");
 } else println("not selected");
 }
 
 // расшифровать
 void decrypt() {
 if (refPath.length() != 0 && cryptPath.length() != 0) {
 // загружаем картинки
 imageRef = loadImage(refPath);
 imageCrypt = loadImage(cryptPath);
 imageRef.loadPixels();
 imageCrypt.loadPixels();
 
 int thisPix = 0;
 String decryptText = "";
 while (true) {
 // код символа как разница цветов
 int thisChar = imageCrypt.pixels[thisPix] - imageRef.pixels[thisPix];  
 if (thisChar == 0) break;             // нулевой - конец
 if (thisChar > 200) thisChar += 800;  // костыль для русских букоф
 decryptText += char(thisChar);        // собираем текст
 thisPix++;                            // следующий пиксель
 }
 // выводим текст в окно программы
 myTextarea.setText(decryptText);
 String[] lines = new String[1];
 lines[0] = decryptText;
 saveStrings("decrypt_text.txt", lines);
 } else println("not selected");
 }
 */

/*
 // ======= ЗАПИСЫВАЕМ ШАГ В ПЕРВЫЙ ПИКС ======= 
 void encrypt() {
 if (refPath.length() != 0 && textPath.length() != 0) {
 // загружаем картинку и текст
 imageCrypt = loadImage(refPath);
 imageCrypt.loadPixels();
 String[] lines = loadStrings(textPath);    
 
 // находим длину текста
 int textSize = 0;
 for (int i = 0; i < lines.length; i++) textSize += lines[i].length();
 if (textSize == 0) return;  // текста нет, выход
 
 // считаем шаг как размер изображения / размер текста 
 int pixStep = imageCrypt.width * imageCrypt.height / textSize;
 
 int thisPix = 1;  // записывать будем с 1 пикселя (0 занят)
 imageCrypt.pixels[0] += pixStep;  // 0 пиксель хранит размер шага
 
 // пробегаем по всем буквам во всех строках
 for (int i = 0; i < lines.length; i++) {
 for (int j = 0; j < lines[i].length(); j++) {
 imageCrypt.pixels[thisPix] += byte(lines[i].charAt(j));        
 thisPix += pixStep;  // следующий пиксель на величину шага
 }
 }
 imageCrypt.updatePixels();
 imageCrypt.save("crypt_image.bmp");
 } else println("not selected");
 }
 
 void decrypt() {
 if (refPath.length() != 0 && cryptPath.length() != 0) {
 // загружаем обе картинки 
 imageRef = loadImage(refPath);
 imageCrypt = loadImage(cryptPath);
 imageRef.loadPixels();
 imageCrypt.loadPixels();
 
 String decryptText = "";
 int thisPix = 1;
 int pixStep = imageCrypt.pixels[0] - imageRef.pixels[0];  // размер шага
 
 while (true) {
 // вычитаем
 int thisChar = imageCrypt.pixels[thisPix] - imageRef.pixels[thisPix];
 if (thisChar == 0) break;  // завершение (одинаковые пиксели, текст кончился)
 decryptText += char(thisChar);  // буфер текста
 thisPix += pixStep;        // двигаемся на следующий
 }
 
 // вывод и сохранение
 myTextarea.setText(decryptText);
 String[] lines = new String[1];
 lines[0] = decryptText;
 saveStrings("decrypt_text.txt", lines);
 } else println("not selected");
 }
 */
