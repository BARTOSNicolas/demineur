//Class Case pour chaque case de Démineur
class Case{
  //----- Attributs -----//
  //POSITION
  int x;
  int y;
  //INDEX dans le tableau
  int indexX = x/50;
  int indexY = y/50;

  //Variable de la Mine
  boolean isAMine = false;
  int mineAround = 0;
  // Variable de Clic
  boolean clicked = false;
  boolean isAFlag = false;
  
  //----- Constructeur -----//
  Case(int cX, int cY){
    x = cX;
    y = cY;
  }
  
  //----- Methodes -----//
  //Créé une mine
  void createMine(){
    isAMine = true;
  } 
  //Change le drapeau
  void changeFlag(){
    isAFlag = !isAFlag;
  }  
  //Crée une case CACHE
  void hiddenCase(int cw){
    fill(#DDDDDD);
    rect(x*cw, y*cw, cw, cw);
  }
  //Créé une case VIDE
  void emptyCase(int cw){
    stroke(#111111);
    fill(#FFFFFF);
    rect(x*cw, y*cw, cw, cw);
  }
  //Créé une case MINE
  void mineCase(int cw){
    stroke(#111111);
    fill(#FFFFFF);
    rect(x*cw, y*cw, cw, cw);
    fill(#111111);
    circle(x*cw + cw/2, y*cw + cw/2, cw-10);
    fill(#CCCCCC);
    circle(x*cw + cw/2 +7, y*cw + cw/2 -7, cw-38);
  }
  //Créé une Case PROXIMITE
  void aroundCase(int cw){
    stroke(#111111);
    fill(#FFFFFF);
    rect(x*cw, y*cw, cw, cw);
    if(mineAround == 1){fill(#00FF00);}
    if(mineAround == 2){fill(#0000FF);}
    if(mineAround == 3){fill(#FF8C00);}
    if(mineAround == 4){fill(#FF0000);}
    if(mineAround >= 5){fill(#800080);}
    textSize(16);
    textAlign(CENTER, CENTER);
    text(str(mineAround),x*cw, y*cw, cw, cw);
  }
  //Créé une CASE drapeau pour le clique droit
  void flagCase(int cw){
    stroke(#111111);
    fill(#DDDDDD);
    rect(x*cw, y*cw, cw, cw);
    fill(#111111);
    line(x*cw+15, y*cw+10, x*cw+15, y*cw+40);
    fill(#FF0000);
    triangle(x*cw+15, y*cw+10, x*cw+15, y*cw+30, x*cw+40, y*cw+20);     
  }
  //Changement mineAround
  void howAround(int value){
    mineAround = value;
  }
}

//-----------------------------------------//
//Variable du GAME
int nbrCase;
int caseWidth;
int nbrMine;
int flagCount;
int sizeWidth;
boolean win;
boolean lose;
Case[][] gameBoard;

//-----------------------------------------//
// Initialisation du Game
void settings(){
  //Nombre de Cases Horizontales et Verticales
  nbrCase = 10;
  caseWidth = 50;
  //Nombre de Mines
  nbrMine = 10;
  flagCount=nbrMine;
  //Fin de partie sur False
  lose = false;
  //Initialisation de la taille écran
  sizeWidth = (nbrCase*caseWidth)+1;
  size(sizeWidth, sizeWidth+100);
  //Initialisation du Tableau 2D
  gameBoard = new Case[nbrCase][nbrCase];
  //Remplissage avec la Classe Case
  for(int x = 0; x < gameBoard.length; x++){
    for(int y = 0; y < gameBoard[x].length; y++){
      gameBoard[x][y] = new Case(x, y);
    }
  }  
}

//-----------------------------------------//
//Lancement du Jeu
void setup(){
  //Remplissage du plateau avec des Cases face caché
  for(int x = 0; x < gameBoard.length; x++){
    for(int y = 0; y < gameBoard[x].length; y++){
      gameBoard[x][y].hiddenCase(caseWidth);
    }
  }
  //Activation aléatoire des Mines
  for(int m = 0; m < nbrMine; m++){
    int randomX = int(random(0, nbrCase));
    int randomY = int(random(0, nbrCase));
    gameBoard[randomX][randomY].createMine();
  }
  mousePressed(); //MousePressed ICI resoud des BUG graphique et de comptages
}

//-----------------------------------------//
//Affichage du Mouse click
void draw(){ 
  gameMenu();
  frameRate(30); 
}

//-----------------------------------------//
//Gestion de la souris
void mousePressed(){
  for(int x = 0; x < gameBoard.length; x++){
    for(int y = 0; y < gameBoard[x].length; y++){
        boolean mouseOver = mouseX >= x*caseWidth && mouseX <= (x*caseWidth)+caseWidth && mouseY >= y*caseWidth && mouseY <= (y*caseWidth)+caseWidth;
      //Quand la souris passe au dessus d'une case + clic gauche
      if(mouseButton == LEFT && mouseOver && !lose && !gameBoard[x][y].isAFlag){
        //Si c'est une mine affiche une CASE MINE + GAMEOVER
        if(gameBoard[x][y].isAMine){
          gameBoard[x][y].mineCase(caseWidth);
          gameOver();
        }
        //SINON
        else{
          // On vérifie les Mines autour
          checkMine(x, y);
          //SI Mine autour on affiche une case MINEAROUD + on verifie si on a gagné
          if(gameBoard[x][y].mineAround > 0){
            gameBoard[x][y].aroundCase(caseWidth);
            gameBoard[x][y].clicked = true;
            checkWin();
            
          }
          //SINON on affiche une CASE VIDE + on verifie si on a gagné
          else{
            gameBoard[x][y].emptyCase(caseWidth);
            gameBoard[x][y].clicked = true;
            checkWin();
          }
        }
      }
      //Clic droit pour ajouter un drapeaux si il y a des drapeaux disponible
      if(mouseButton == RIGHT && mouseOver && !lose && flagCount > 0 && !gameBoard[x][y].isAFlag){
        if(!gameBoard[x][y].isAFlag && !gameBoard[x][y].clicked){
          gameBoard[x][y].flagCase(caseWidth);
          gameBoard[x][y].changeFlag();
          flagCount--;
          checkWin();
        }
      }
      //QClic droit pour enlever un drapeaux 
      else if(mouseButton == RIGHT && mouseOver && !lose && flagCount < nbrMine && gameBoard[x][y].isAFlag){
        if(gameBoard[x][y].isAFlag && !gameBoard[x][y].clicked){
          gameBoard[x][y].hiddenCase(caseWidth);
          gameBoard[x][y].changeFlag();
          flagCount++;
        }
      }
    }
  }
}
void checkMine(int indexX, int indexY){
    int mineAround = 0;// Variable pour compter les mines autours
    // On verifie les cases autour qui sont dans le tableau
    if(indexX- 1 >= 0 && indexY-1 >= 0 && gameBoard[indexX-1][indexY-1].isAMine){mineAround++;}
    if(indexX- 1 >= 0 && gameBoard[indexX-1][indexY].isAMine){mineAround++;}
    if(indexX- 1 >= 0 && indexY+1 < gameBoard.length && gameBoard[indexX-1][indexY+1].isAMine){mineAround++;}
    if(indexY-1 >= 0 && gameBoard[indexX][indexY-1].isAMine){mineAround++;}
    if(indexY+1 < gameBoard.length && gameBoard[indexX][indexY+1].isAMine){mineAround++;}
    if(indexX+ 1 < gameBoard.length && indexY-1 >= 0  && gameBoard[indexX+1][indexY-1].isAMine){mineAround++;}
    if(indexX+ 1 < gameBoard.length && gameBoard[indexX+1][indexY].isAMine){mineAround++;}
    if(indexX+ 1 < gameBoard.length && indexY+1 < gameBoard.length && gameBoard[indexX+1][indexY+1].isAMine){mineAround++;}
    gameBoard[indexX][indexY].howAround(mineAround);// on ajoute le nombre de Mines à l'objet Case
}
void checkWin(){
  int caseToWin = 0; //Variable qui compte les case pour gagner
  int mineFlaged = 0; // Variable qui compte les case avec un drapeau
  for(int x = 0; x < gameBoard.length; x++){
    for(int y = 0; y < gameBoard[x].length; y++){
      //SI une case cliqués ou avec une mine Ajoute +1
      if(gameBoard[x][y].clicked || gameBoard[x][y].isAMine){
        caseToWin++;
      }
      //SI les cases avec une MINE ont un drapeau Ajoute +1
      if(gameBoard[x][y].isAMine && gameBoard[x][y].isAFlag){
        mineFlaged++;
      }
    }
  }
  //Si caseToWin est egal au nombre de case sur le plateau c'est gagné
  if(caseToWin == nbrCase*nbrCase){
    win = true;
    gameOver();
  }
  //Si mineFlaged est egal au nombre de Mine du jeu c'est gagné
  if(mineFlaged == nbrMine){
    win = true;
    gameOver();
  }
}
//-----------------------------------------//
//Fin du GAME
void gameOver(){
  //Game over on affiche toutes les CASES
  for(int x = 0; x < gameBoard.length; x++){
    for(int y = 0; y < gameBoard[x].length; y++){
      if(gameBoard[x][y].isAMine){
        gameBoard[x][y].mineCase(caseWidth);
      }
      else{
        if(gameBoard[x][y].mineAround > 0){
          gameBoard[x][y].aroundCase(caseWidth);
        }
        else{
          gameBoard[x][y].emptyCase(caseWidth);
        }
      }
    }
  }
  //Message GameOver
  String message = "YOU LOSE";
  color colorValue = #FF0000;
  //Si on gagne le message et couleur change
  if(win){
    message = "YOU WIN";
    colorValue = #00FF00;
  }
  fill(50,50,50,230);  
  rect(25, (sizeWidth/4)+12.5, sizeWidth-50, (sizeWidth-50)/2);
  fill(colorValue);
  textSize(sizeWidth/8);
  textAlign(CENTER, CENTER);
  text(message, 25, (sizeWidth/4)+12.5, sizeWidth-50, (sizeWidth-50)/2);
  //Variable gameOver sur TRUE pour ne plus cliquer
  lose = true;
}
//-----------------------------------------//
//GAME MENU
void gameMenu(){
  //Flag
  stroke(#CCCCCC);
  fill(#CCCCCC);
  rect(50+51, sizeWidth+25, 50, 50);
  fill(#111111);
  stroke(#111111);
  line(50+15, sizeWidth+25+10, 50+15, sizeWidth+25+40);
  fill(#FF0000);
  triangle(50+15, sizeWidth+25+10, 50+15, sizeWidth+25+30, 50+40, sizeWidth+25+20);
  fill(#111111);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("= "+str(flagCount), 50+51, sizeWidth+25, 50, 50);
  //Mine
  stroke(#CCCCCC);
  fill(#CCCCCC);
  rect(200+20, sizeWidth+25, 50, 50);
  fill(#111111);
  circle(200, sizeWidth+50, 30);
  fill(#CCCCCC);
  circle(200+5, sizeWidth+50-5, 8);
  fill(#111111);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("= "+str(nbrMine), 200+20, sizeWidth+25, 50, 50);
  
}
