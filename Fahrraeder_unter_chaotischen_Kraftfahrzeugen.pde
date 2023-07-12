import processing.sound.*;
//######################### INITALISIERUNGEN ####################
//----- playerSetup-----
int playerX = 320;
int playerY = 275;
float playerSpeed = 4.0;
boolean moveLeft = false;
boolean moveRight = false;
boolean moveUp = false;
boolean moveDown = false;
float playerWidth = 10;
float playerHeight = 40;


//----- carSetup -----
int carX = 320;
int carY = 80;
float carSpeed = 4.0;
int carHeight;
float carWidth = 20;

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

//----- helper -----
boolean isPaused = false;
float offsetLeft = 0;
float offsetRight = 0;
int boarderSize = 25;
int laneWidth = width;
int gameState = 0; // 0 für Spiel läuft, 1 für Spiel vorbei
int score = 0;


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
}


//########################## ALLE DRAW METHODEN #####################
//------------------ Draw allg. -----------------
void draw() {
  background(50); // Hintergrundfarbe des Spielfelds (grau)

 if (startScreen) {
    drawStartScreen();
    if(!lobbySound.isPlaying()){
      lobbySound.play();
    }
    return; // Beende die draw() Funktion, um den Startbildschirm anzuzeigen
  }
  
  if (isPaused) {
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

  offsetLeft += 1;
  offsetRight -= 1;
  
  //Setzt den offsetLeft zurück auf 0, soablt er größer als height ist, und somit aus dem Bild läuft
  if(offsetLeft > height || offsetRight > height ){
    offsetLeft = 0;
    offsetRight = 0;
  }
  
  drawRoadMarks(); // Zeichne die Mittellinie für die Fahrrichtungstrennung
  drawPlayer();
  drawCar(carX, carY);
  carY += carSpeed; // Bewege die Autos nach unten
  
  updatePlayerPosition();
  
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
  line(middleX + markWidth, 0, middleX + markWidth, height );
  line(middleX - markWidth, 0 , middleX - markWidth, height );
  
  int dashLength = 23; // Länge der gestrichelten Streifen
  
  // Zeichne gestrichelte Linie auf der linken Seite
  int leftStripeX = middleX - markWidth - laneWidth / 2;
  for (float y = offsetLeft - height; y < height; y += 40) {
    line(leftStripeX, y, leftStripeX, y + dashLength);
  }

  // Zeichne gestrichelte Linie auf der rechten Seite
  int rightStripeX = middleX + markWidth + laneWidth / 2;
  for (float y = offsetLeft - height; y < height; y += 40) {
    line(rightStripeX, y, rightStripeX, y + dashLength);
  }
}


//----------------- Fahrbahntrennung ----------------- 
/*(Brauchst du evtl nicht mehr vielleicht kannst du die For-Schleifen auslagern ist aber unnötig)
Lass aber nochmal den Code drin vielleicht geht er ja ich habe da so eine Idee
*/
void drawDashedLine(int xCoordinate, float offset) {
  int dashLength = 23; // Länge der gestrichelten Streifen
  int gapLength = 15; // Länge der Lücke zwischen den gestrichelten Streifen
  boolean drawLine = true;

  strokeWeight(3); // Strichstärke
  float currentY = offset;

  while (currentY < height) {
    if (drawLine) {
      // Zeichne einen Strich
      line(xCoordinate, currentY, xCoordinate, currentY + dashLength);
    }

    // Aktualisiere die Position für die nächste Linie
    currentY += dashLength;
    drawLine = !drawLine; // Wechsle zwischen Strich und Lücke

    // Überspringe die Lücke
    currentY += gapLength;
  }
}


//------------------- Draw Player ----------------------
void drawPlayer() {
  int playerWidth = 10; // Breite des spielbaren Objekts (Fahrrad)
  int playerHeight = 40; // Höhe des spielbaren Objekts (Fahrrad)
  int playerColor = color(30,144,255); // Farbe des spielbaren Objekts (Fahrrad)

  fill(playerColor); // Setze die Farbe des spielbaren Objekts (Fahrrad)
  rectMode(CENTER); // Zentrierter Rechteckmodus
  rect(playerX, playerY, playerWidth, playerHeight); // Zeichne das Rechteck (Fahrrad)
}


//------------------- Draw Car ------------------------
void drawCar(float x, float y) {
  int carWidth = 20; // Breite des KfZ-Objekts
  int carHeight = 40; // Höhe des KfZ-Objekts
  int carColor = color(255, 0, 0); // Farbe des KfZ-Objekts (rot)

  fill(carColor); // Setze die Farbe des KfZ-Objekts
  rectMode(CENTER); // Zentrierter Rechteckmodus
  rect(x, y, carWidth, carHeight); // Zeichne das Rechteck (KfZ-Objekt)
}

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
  carX = 320;
  carY = 80;
  // Weitere Reset-Anweisungen hier...
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


void updatePlayerPosition() {
  if (moveLeft && playerX > boarderSize) {
    playerX -= playerSpeed; // Bewege das Fahrrad nach links
  }
  if (moveRight && playerX < width - boarderSize) {
    playerX += playerSpeed; // Bewege das Fahrrad nach rechts
  }
  if (moveUp && playerY > boarderSize) {
    playerY -= playerSpeed; // Bewege das Fahrrad nach oben
  }
  if (moveDown && playerY < height - boarderSize) {
    playerY += playerSpeed; // Bewege das Fahrrad nach unten
  }
}


//############## Kollisionsdetektion ################
boolean carCollisionDetection() {
    return true;
}

void gameOver() {
  gameState = 1; // Spiel vorbei
  score = 0; // Punktzahl zurücksetzen
}
