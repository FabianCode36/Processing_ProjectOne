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
}


//########################## ALLE DRAW METHODEN #####################
//------------------ Draw allg. -----------------
void draw() {
  background(50); // Hintergrundfarbe des Spielfelds (grau)


  offsetLeft += 1;
  offsetRight -= 1;
  
  //Setzt den offsetLeft zurück auf 0, soablt er größer als height ist, und somit aus dem Bild läuft
  if(offsetLeft > height || offsetRight > height ){
    offsetLeft = 0;
    offsetRight = 0;
  }

  if (!isPaused) {
    // ...
  } else {
    fill(188, 0, 0);
    textSize(48);
    text("Pause", width / 2, height / 2);
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
  //drawDashedLine(leftStripeX, offset);

  // Zeichne gestrichelte Linie auf der rechten Seite
  int rightStripeX = middleX + markWidth + laneWidth / 2;
  for (float y = offsetLeft - height; y < height; y += 40) {
    line(rightStripeX, y, rightStripeX, y + dashLength);
  }
  //drawDashedLine(rightStripeX, offset);
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

/*void drawDashedLine(float x, float dashLength, float gapLength) {
  
  float currentY = dashLength / 2 + offset; // Starte bei der Hälfte des ersten Striches
  boolean isDash = true;

  while (currentY < height) {
    if (isDash) {
      line(x, currentY, x, currentY + dashLength);
    }
    currentY += dashLength + gapLength;
    isDash = !isDash;
  }
} */


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



//######################### STEUERUNG ######################
void keyPressed() {
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

/* Ich habe den Player so angepasst, dass er nicht über den Rand kann und noch eine Border hinzugefügt
    so kann er nicht cheaten und an der seite gammeln...
*/

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
boolean carCollisionDetection(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  // Überprüft, ob zwei Rechtecke kollidieren
  if (x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2) {
    return true;
  }
  return false;
}

void gameOver() {
  gameState = 1; // Spiel vorbei
  score = 0; // Punktzahl zurücksetzen
}
