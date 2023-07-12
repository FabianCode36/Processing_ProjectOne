import processing.sound.*;
//######################### INITALISIERUNGEN ####################
//----- playerSetup-----
int playerX = 320;
int playerY = 275;

float playerSpeed = 3.0;
float playerWidth = 20;
float playerHeight = 40;

// Player Control Unit
boolean moveLeft = false;
boolean moveRight = false;
boolean moveUp = false;
boolean moveDown = false;

//Klasse um HighScore Objekte zu erstellen
class HighScore{
  int gameNumber;
  int score;
  
  HighScore(int gameID, int gameScore){
    gameNumber = gameID;
    score = gameScore;  
  }
}

ArrayList<HighScore> highScores = new ArrayList<HighScore>();
ArrayList<PImage>carImages = new ArrayList<PImage>();

//----- carSetup -----
PImage carRed;
PImage carGreen;
PImage carYellow;
PImage Bike;

float carHeight = 45;
float carWidth = 20;
float startCarSpeed = 2.0;

float[] flowTrafficX = {400, 400, 400, 400, 400}; //Auto Array 
float[] flowTrafficY = {320, 250, 180, 110, 30}; // Auto Array Spawn
float[] onCommingTrafficX = {120, 120, 120, 120, 120};//Gegenverkehr Array
float[] onCommingTrafficY = {320, 250, 180, 110, 30}; // Gegenverkehr Array

//----- Hilfsvariablen -----
boolean showStart = false;
boolean isPaused = false;
float offset = 0;
int gameCounter = 0;
int score = 0;

int minutes = 0;
int seconds = 0;
int lastTime = 0;

// Intervall in Millisekunden
int timerInterval = 1000;

//---------- Bildschirme ----------
boolean startScreen = true;
boolean isCountdown = false;
int countdownTimer = 3;
int countdownStartTime;
boolean isGameStarted = false;
PFont font;
PImage img;
PImage pauseImg;
SoundFile lobbySound;
SoundFile gameSound;


void setup() {
  size(640, 320);
  noStroke();  
  
  // Lade die gewünschte Schriftart
  font = createFont("sthupo.ttf", 20);
  textFont(font);
  
  //Laden der Bilder
  img = loadImage("startscreen2.png");
  pauseImg = loadImage("Paused.png");
  
  //Laden der Sounds
  lobbySound = new SoundFile(this, "LobbySound.wav");
  gameSound = new SoundFile(this, "GamingSound.wav");
  
   Bike = loadImage("bike.png");
   carGreen = loadImage("carGreen.png");
   carYellow = loadImage("carYellow.png");
   carRed = loadImage("carRed.png");
   carImages.add(carGreen);
   carImages.add(carYellow);
   carImages.add(carRed);

}

//########################## ALLE DRAW METHODEN #####################
//------------------ Draw allg. -----------------
void draw() {
  if(showStart){
    drawStartScreen();
    if(!lobbySound.isPlaying()){
      lobbySound.play();
    }
    gameCounter++;
    return; // Beende die draw() Funktion, um den Startbildschirm anzuzeigen
  }
  else{
    background(50); //Hintergrundfarbe
    if (!isPaused) {
      for(int i = 0; i < flowTrafficX.length; i++){
          flowTrafficY[i] += playerSpeed + startCarSpeed;
      }
       for(int i = 0; i < onCommingTrafficX.length; i++){
           onCommingTrafficY[i] += playerSpeed + startCarSpeed;
       }
        controllUnit();
    }
    else {
      fill(188, 0, 0);
      textSize(48);
      drawPauseScreen();
      gameSound.stop(); // Stoppe das Spiel-Sound
      return; // Beende die draw() Funktion, um das Spiel anzuhalten
    }

    //Sound für das Spiel abspielen lassen
    if (!gameSound.isPlaying()) {
      gameSound.play(); // Spiele das Spiel-Sound ab, wenn es noch nicht abgespielt wird
    }
    
    //Countdown für das wiederbeitreten nach der Pause
  if (isCountdown) {
    fill(255);
    textSize(48);
    int countdown = countdownTimer - (millis() - countdownStartTime) / 1000;
    if (countdown > 0) {
      text(countdown, width / 2, height / 2);
    } else {
      isCountdown = false;
    }
    return; // Beende die draw() Funktion, um den Countdown anzuzeigen
  }

    offset++;
    
    //Setzt den offsetLeft zurück auf 0, soablt er größer als height ist, und somit aus dem Bild läuft
  if(offset > height){
    offset = 0;
  }
    
    drawRoadMarks();
    drawPlayer();
    for (int i = 0; i < flowTrafficX.length; i++) {
    drawCar(flowTrafficX[i], flowTrafficY[i]);
    if (flowTrafficY[i] > height) {
      flowTrafficY[i] = -carHeight; // Auto am oberen Rand positionieren
      flowTrafficX[i] = 400 + generateRandomSpawnArea(); // Spawnbereich
      score++; // Score erhöhen, wenn ein Auto den Bildschirm verlässt
    }
  }

  for (int i = 0; i < onCommingTrafficX.length; i++) {
    drawCar(onCommingTrafficX[i], onCommingTrafficY[i]);
    if (onCommingTrafficY[i] > height) {
      onCommingTrafficY[i] = -carHeight; // Auto am oberen Rand positionieren
      onCommingTrafficX[i] = 120 + generateRandomSpawnArea(); // Spawnbereich
      score++; // Score erhöhen, wenn ein Auto den Bildschirm verlässt
    }
  }
    isPaused = carCollisionDetect();
    
    //Get the number of milliseconds (thousandths of a second) since starting the sketch
    int currentTime = millis();
    if(!isPaused && currentTime - lastTime >= timerInterval){
      lastTime = currentTime;
      incrementTime();
    }
    
    showScoreWhilePlaying();
  }
}

boolean carCollisionDetect(){
  for(int x = 0; x < flowTrafficX.length; x++)
      if(flowTrafficX[x] > playerX && flowTrafficX[x] < playerX + carWidth || flowTrafficX[x] + carWidth > playerX && flowTrafficX[x] + carWidth < playerX + carWidth) //X Kollision
        if(flowTrafficY[x] > playerY && flowTrafficY[x] < playerY + carHeight || flowTrafficY[x] + carHeight > playerY && flowTrafficY[x] + carHeight < playerY + carHeight) //Y Kollision
          return true;
    for(int x = 0; x < onCommingTrafficX.length; x++)
      if(onCommingTrafficX[x] > playerX && onCommingTrafficX[x] < playerX + carWidth || onCommingTrafficX[x] + carWidth > playerX && onCommingTrafficX[x] + carWidth < playerX + carWidth) //X Kollision
        if(onCommingTrafficY[x] > playerY && onCommingTrafficY[x] < playerY + carHeight || onCommingTrafficY[x] + carHeight > playerY && onCommingTrafficY[x] + carHeight < playerY + carHeight) //Y Kollision
          return true;
  
  return false; // Keine Kollision
}

void incrementTime(){
  seconds++;
  if (seconds >= 60) {
    seconds = 0;
    minutes++;
  }
}

void showScoreWhilePlaying(){
  fill(255);
  textSize(24);
  textAlign(LEFT);
  text("Score: " + score, 10, 30);
  
  fill(255); // Textfarbe
  textSize(24); // Schriftgröße
  textAlign(LEFT, BOTTOM); // Links unten ausrichten
  text(String.format("%02d:%02d", minutes, seconds), 10, height - 10);
}

int generateRandomSpawnArea(){
  return int(random(-76, 224.0));
}

//--------------- Fahrbahnlinien zeichnen -------------------- 
void drawRoadMarks() {
  int markWidth = 5; // Breite der Markierungen
  int laneWidth = width / 2; // Breite jeder Fahrspur
  int middleX = width / 2;

  // Zeichne die durchgezogenen Linien in der Mitte
  stroke(255); // Weiße Farbe
  strokeWeight(4); // Strichstärke

  // Durchgezogene Linie
  line(middleX + markWidth, 0, middleX + markWidth, height);
  line(middleX - markWidth, 0 , middleX - markWidth, height);
  
  int dashLength = 23; // Länge der gestrichelten Streifen
  
  // Zeichne gestrichelte Linie auf der linken Seite
  int leftStripeX = middleX - markWidth - laneWidth / 2;
  for (float y = offset - height; y < height; y += 40) {
    line(leftStripeX, y, leftStripeX, y + dashLength);
  }

  // Zeichne gestrichelte Linie auf der rechten Seite
  int rightStripeX = middleX + markWidth + laneWidth / 2;
  for (float y = offset - height; y < height; y += 40) {
    line(rightStripeX, y, rightStripeX, y + dashLength);
  }
}


//------------------- Draw Player ----------------------
void drawPlayer() {
  //int playerColor = color(30,144,255); // Farbe des spielbaren Objekts (Fahrrad)
  //fill(playerColor); // Setze die Farbe des spielbaren Objekts (Fahrrad)
  //rect(playerX, playerY, playerWidth, playerHeight); // Zeichne das Rechteck (Fahrrad)

    image(Bike, playerX, playerY, playerWidth, playerHeight);

}

//------------------- Draw Car ------------------------
void drawCar(float carX, float carY) {
  //int carColor = color(255, 165, 0); // Farbe des KfZ-Objekts (rot)
  //fill(carColor); // Setze die Farbe des KfZ-Objekts
  //rect(carX, carY, carWidth, carHeight); // Zeichne das Rechteck (KfZ-Objekt)
  
  // Random hat funktoniert müsste aber in einer Klasse bzw. in einem Car Objekt gespeichert werden
  //int rand = (int)random(3);
  //image(carImages.get(rand), carX, carY, carWidth, carHeight);
  image(carGreen, carX, carY, carWidth, carHeight);

}

void controllUnit() {
  if (keyPressed) {
    if (key == 'R' || key == 'r') {
      if (!isGameStarted) {
        resetGame();
        startScreen = true; // Zeige den Willkommensbildschirm
        lobbySound.play(); // Spiele den Lobby-Sound ab, wenn das Spiel neu gestartet wird
      }
    }
    
    if (keyCode == ENTER && startScreen) {
      lobbySound.stop(); // Sound der Lobby wird gestoppt
      startScreen = false; // Startbildschirm ausblenden
      isPaused = false; // Spiel starten
    } else if (key == 'P' || key == 'p') {
      if (!isCountdown) {
        isPaused = !isPaused; // Pause umschalten
        if (!isPaused) {
          gameSound.stop(); // Stoppe das Spiel-Sound, wenn das Spiel pausiert ist
          countdownTimer = 3;
          countdownStartTime = millis();
          isCountdown = true;
        }
      }
    }

    if (keyCode == LEFT) {
      moveLeft = true;
    } else if (keyCode == RIGHT) {
      moveRight = true;
    } else if (keyCode == UP) {
      moveUp = true;
    } else if (keyCode == DOWN) {
      moveDown = true;
    }
  } else {
    if (key == 'R' || key == 'r') {
      if (!isGameStarted) {
        resetGame();
        startScreen = true; // Zeige den Willkommensbildschirm
        lobbySound.play(); // Spiele den Lobby-Sound ab, wenn das Spiel neu gestartet wird
      }
    }

    if (keyCode == LEFT) {
      moveLeft = false;
    } else if (keyCode == RIGHT) {
      moveRight = false;
    } else if (keyCode == UP) {
      moveUp = false;
    } else if (keyCode == DOWN) {
      moveDown = false;
    }
  }

  if (moveUp) {
    if (playerY > 0) {
      playerY -= playerSpeed;
    }
  }
  if (moveLeft) {
    if (playerX > 0) {
      playerX -= playerSpeed;
    }
  }
  if (moveDown) {
    if (playerY + carHeight < height) {
      playerY += playerSpeed;
    }
  }
  if (moveRight) {
    if (playerX + carHeight < width) {
      playerX += playerSpeed;
    }
  }
}

/*void controllUnit() {
  if(keyPressed){
    switch(keyCode){
      case UP:
        if(playerY > 0){
          playerY -= playerSpeed;
        }
        break;
      case LEFT:
        if(playerX > 0){
          playerX -= playerSpeed;
        }
        break;
      case DOWN:
        if(playerY + carHeight < height){
          playerY += playerSpeed;
        }
        break;
      case RIGHT:
        if(playerX +  carHeight < width){
          playerX += playerSpeed;
        }
        break;
    }
  }
}*/

//################## Startbildschirm ##################
void drawStartScreen() {
  background(0);
  image(img,125,65); 
  fill(255); // Textfarbe (weiß)
  textSize(20);
  textAlign(CENTER);
  text("Welcome to", width / 2, height / 2 - 120);
  textSize(30);
  text("THE CAR DODGE GAME", width / 2, height / 2 - 85);
  textSize(30);
  text("Press ENTER to Start", width / 2, height / 2 + 105);
  textSize(10);
  text("created by Melli & Hatice", width / 2, height / 2 + 130);
}

void drawPauseScreen() {
  background(0);
  image(pauseImg,100,0);
  fill(255); // Textfarbe (weiß)
  textAlign(CENTER);
  textSize(20);
  textSize(20);
  text("> Press R to return to Home", width / 2, height / 2 + 20);
  text("> Press ENTER to continue", width / 2, height / 2 + 60);
}

//######################### STEUERUNG ######################
void resetGame() {
  // Hier werden alle Spielvariablen auf den Anfangszustand zurückgesetzt
  playerX = 320;
  playerY = 275;
}

void keyPressed() {
//Start in das Spiel per Enter
  if (keyCode == ENTER && startScreen) {
    lobbySound.stop();//Sound der Lobby wird gestoppt
    startScreen = false; // Startbildschirm ausblenden
    isPaused = false; // Spiel starten
  } else if (key == 'P' || key == 'p') {
    if (!isCountdown) {
      isPaused = !isPaused; // Pause umschalten
      if (!isPaused) {
        gameSound.stop(); // Stoppe das Spiel-Sound, wenn das Spiel pausiert ist
        countdownTimer = 3;
        countdownStartTime = millis();
        isCountdown = true;
      }
    }
  }

//Richtungen für die Steuerungen
  if (keyCode == LEFT) {
    moveLeft = true;
  } else if (keyCode == RIGHT) {
    moveRight = true;
  } else if (keyCode == UP) {
    moveUp = true;
  } else if (keyCode == DOWN) {
    moveDown = true;
  }
}

void keyReleased() {
  if (key == 'R' || key == 'r') {
    if (!isGameStarted) {
      resetGame();
      startScreen = true; // Zeige den Willkommensbildschirm
      lobbySound.play(); // Spiele den Lobby-Sound ab, wenn das Spiel neu gestartet wird
    }
  }
  
  if (keyCode == LEFT) {
    moveLeft = false;
  } else if (keyCode == RIGHT) {
    moveRight = false;
  } else if (keyCode == UP) {
    moveUp = false;
  } else if (keyCode == DOWN) {
    moveDown = false;
  }
}
