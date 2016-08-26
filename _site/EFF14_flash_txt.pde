/**
 * EFF14_flash_txt
 * 3dwardsharp
 * http://edwardsharp.net
 *
 * a cyber-poem for processing.js
 * screened with many other processing sketches at the 
 * Expierimental Film Festival in 2014 
 *
 */
 

int timeStamp;
int timeStampMots;
int valR = 0;
int dutyCycleMod = 10;
int dutyCycleCount = 0;
boolean enableGlitch = false;
String[] tMots = {
  "obscure", "root", "executable", "header", "the",
  "problem", "with", "universals", "anti-forensics",
  "embedded", "malware", "plastic", "pill", "jars",
  "slamming", "our", "doors", "trapped", "under",
  "the", "rubble", "pile", "the", "boundaries", "as", 
  "my", "own", "emotion", "rocks", "&", "dust", "on", 
  "my", "face", "and", "where", "i", "sleep", "at", 
  "night", "my", "own", "private", "achromatic", 
  "prison", "dark", "alleyways", "and", "elevators", 
  "used", "as", "negotiating", "spaces", "for", 
  "my", "self", "which", "is", "under", "realistic", 
  "scrutiny", "anyway", "personal", "property", 
  "architected", "on", "pleasure", "profit", 
  "principals", "do", "not", "give", "that", "guy",
  "money"
}; 

void setup() {
  
  sketch_width = displayWidth;
  sketch_height = displayHeight;

  size(sketch_width, sketch_height);

  smooth();
  background(0);
  timeStamp = millis();
  timeStampMots = millis();

}

void draw() {
  noStroke();

  int tempsEcoule = millis() - timeStamp;
  int tempsEcouleMots = millis() - timeStampMots;
  int tempsRand = int(random(0,333));
  
  //this probably doesn't ned to be calculated every frame...
  int timeX = (tMots[valR].length() * 44);
  tempsRand = tempsRand + timeX;
  
  if (tempsEcouleMots >= tempsRand/2) {
    background(0);
  }
  
  if (tempsEcouleMots >= tempsRand) {
    background(0);
    fill(255);
    textSize(66);
    int x = 300;//int(random(0, width-75));
    int y = 266;//int(random(30, height-30));
    
    if(dutyCycleCount % dutyCycleMod == 0){
      valR = int(random(0, tMots.length));
      dutyCycleMod = int(random(22,44));

      text(tMots[valR], x, y);
      
    }else{
      valR++;
      if(valR > tMots.length - 1){
        valR = 0;
      }
      text(tMots[valR], x, y);
    }
    dutyCycleCount++;
    if(dutyCycleCount>999999){
      dutyCycleCount = 0;
    }
    
    
    timeStampMots = millis();
  }
}
