class PanelControl {

  //Variables para el dibujo de la Rosa
  int r0;//distancia para el inicio de la linea de radio
  int r1;//distancia para el final de la linea de radio
  int L;//largo del segmento de radio

  int cantColumns; // numbers of table columns

  float cxro, cyro;//centro rosa 
  color cb; //color del backgroun 
  PFont Text;
  float anguloVar;//Angulo entre cada linea de la Rosa

  float [][] csv; //to store arrays from table
  int contador; //contador para seleccionar cada numero de linea 
  int filasLength; // lenght of filas froma rray
  float [] puntoCor; //array con el color de cada punto dibujado
  float [] diamAn; //array con el diametro de cada anillo dibujado

  int velLect; //cantidad de lineas que se salta entre cada lectura
  float angCompass;// angulo para brujula
  boolean stop = true; //to know if gps is moving or not.
  
//variables para dibujar percurso
  float distPercurso;
  float velocidad=0;
  float cxp, cyp; //centro de ponto de percurso
  float ln=0; //contador para velocimetro
  float marcador=0; //obtiene la posicion de mouseX y la mapea 0-1023
  float anguloPuntero=PI; //varia angulo segun valor de marcador
  
  PanelControl (int r0_, int L_, color c) {
    r0=r0_; 
    r1=r0_+L_; 
    L=L_;

    //variables de trabajo con la tabela de datos
    csv=table.csv; //ARRAY 2D que almacena los datos de la tabla
    contador = 0; //contador para seleccionar cada numero de linea
    filasLength=table.filasLength; //cantidad de filas de la tabela

    cb= c;
    cantColumns = table.csvWidth-2;
    Text= loadFont("ArialMT-48.vlw");
    anguloVar=TWO_PI/cantColumns;
  }

  void update () {
    //Velocidad de lectura
     float f = constrain ( map (marcador, 0, 1024, 1, 20), 1, 20);
     velLect = (int)f;
//    velLect = 5;
    contador = contador + velLect;
    if (contador > table.filasLength-1) {
      contador = 0;
      background (220);
    }
  }

  void drawRosa (float cx_, float cy_) {
    if (contador > table.filasLength) contador = 0;
    pushMatrix(); 
    cxro=cx_;  
    cyro=cy_;  //centro de la rosa
    translate(cxro, cyro);

    rosaBackground ();
    rosa();
    compass ();
    popMatrix();
  }

  void rosaBackground () {
    pushStyle();
    strokeWeight(1);
    fill(cb); 
    noStroke();
    ellipse (0, 0, r1*2, r1*2); //width,height);  

    int i=0; //Variable que se ocupara como indice para obtener los nombres
    for (float angulo=0; angulo<TWO_PI; angulo+=anguloVar) {

      float d = dist (r0*cos(angulo), r0*sin(angulo), r1*cos(angulo), r1*sin(angulo) );

      //Dibujamos las lineas de la Rosa
      for (int x=0 ; x<d ; x++) {
        float cc = map ( x, 0, d, 0, 255); 
        color c = color (cc, 220, 200, 10);
        stroke (c); 
        point ((x+r0)*cos(angulo), (x+r0)*sin(angulo));
      }

      fill(255);
      textFont(Text, 15);
      textAlign(CENTER, CENTER);
      text (i, r1*cos(angulo)*.9, r1*sin(angulo)*.9);
      i++;
    }
    popStyle();
  }

  //DIBUJAMOS LA ROSA CENTRAL 
  void rosa () {
    //PLAY de archivos de sonido
    player.play();
    player2.play();

    ///Variables del método
    int cant = cantColumns;

    puntoCor = new float [cant];
    diamAn = new float [cant];
    PVector [] puntos = new PVector [cant];

    int iFila = contador; //variable para ir por cada columa de la tabela de datos
    if (iFila > filasLength-1) iFila = 0; //el valor de index va de 0 a filesLength

    float angulo=0; //angulo que ocuparemos para dibujar los puntos

    //OBTENEMOS LOS VALOR DE TODAS LAS COLUMNAS DE LA FILA CORRESPONDIENTE

    for (int iCol=0 ; iCol<cant ; ++iCol) { //for para pasar por todas las Columnas de cada Fila

      //Variables para no extraer los datos de Lat y Long de la tabla, no se mostraran en la Rosa
      int iColum = iCol;
      if (iCol > 3) iColum= iCol+2;//el valor de Lat esta en la pos 3 del array, se suma dos para saltarse este valor y el de Long

      //variables e instrucciones para obener valores de las Filas anteriores de la Tabela y mantenerlas dentro de los rangos del array
      int iFila_p, iFila_pp; 
      if (iFila   == 0 ) iFila_p  = filasLength-1;
      else iFila_p = iFila-1;
      if (iFila_p == 0 ) iFila_pp = filasLength-1;
      else iFila_pp = iFila_p-1;

      //Obtenes los valores en posiciones específicas del array de datos
      float numcA=( csv [iFila]    [iColum] ); //valor encontrado en la columna "iColum" en la fila "iFila"
      float numcB=( csv [iFila_p]  [iColum] ); //valor encontrado en la columna "iColum" en la fila anterior a "iFila" 
      float numcC=( csv [iFila_pp] [iColum] ); //valor encontrado en la columna "iColum" en dos filas anteriores a "iFila"

      //Establecemos la posicion del punto segun los valores máximos y minimos de cada columna en la lista
      //MMs[e].x valor maximo,MMs[e].y valor min
      float valMax = table.MMs[iColum].x; 
      float valMin = table.MMs[iColum].y;
      float currentA  = r0 + ((numcA-valMin) / (valMax-valMin))*L*0.9;  //calculo de posición segun max y min
      float currentB  = r0 + ((numcB-valMin) / (valMax-valMin))*L*0.9;  //calculo de posición segun max y min
      //arriba se multiplica por 0.9 para que el dibujo no llegue al extremo

      //DIAMETRO del anillo que se dibujo sobre cada punto, el tamaño depende de la diferencia de magnitud con el punto anterior
      float difAB = abs (currentA-currentB); 
      float d = map (difAB, 0, L*0.9, 5, 25);
      diamAn[iCol]=constrain(d, 5, 30);//println (" D[e]: "+ diamAn[e]);

      //POSICION se almacena en un array de vectores la posicion de este valor para la columna y fila actual
      puntos[iCol]= new PVector (currentA*cos(angulo), currentA*sin(angulo));

      //COLOR 
      float cor = map(numcA, valMin, valMax, 0, 255);
      cor = constrain (cor, 0, 255);
      puntoCor[iCol]=cor;

      angulo+=anguloVar;
    }

    //PROMEDIO que obtiene una posicion de la suma de todas las columnas de una fila.

    //variables para establecer maximos y minimos de la suma de variablesX del poligono dibujado
    float maxSumX=-100000; 
    float minSumX=100000; 
    //variables para establecer s y minimos de la suma de variablesY del poligono dibujado
    float maxSumY=-100000; 
    float minSumY=100000;

    PVector sumTotal; 
    float totalX=0; 
    float totalY=0;
    for (int e=0; e<cant; ++e) {
      totalX=totalX+puntos[e].x;
      totalY=totalY+puntos[e].y;
    } 
    sumTotal= new PVector (totalX, totalY);
    //Constrain max and mins
    if (sumTotal.x>maxSumX) maxSumX= sumTotal.x;
    if (sumTotal.x<minSumX) minSumX= sumTotal.x;
    if (sumTotal.y>maxSumY) maxSumY= sumTotal.y;
    if (sumTotal.y<minSumY) minSumY= sumTotal.y;

    //FILTRO DE SONIDO

    //    player.setFilter  ( (sumTotal.y/maxSumY*5000), sumTotal.x / maxSumX);
    //    player2.setFilter ( (sumTotal.y/maxSumY*5000), sumTotal.x / maxSumX);

    //    player2.ramp(1., 1000);    

    //DISEÑO DEL POLIGONO QUE DIBUJA LA ROSA (lineas con cambios de color)

    for (int iCol=0 ; iCol<cant ; ++iCol) {
      //Color para cada punto
      color cc = color (puntoCor[iCol], 220, 220); 
      noFill(); 
      int alphaP= 100 - (iCol*10); //un canal alfa cambiante
      stroke (cc, alphaP);

      //Indices que nos permitiran indicar las columnas de diferentes filas
      int pAc=iCol; //indice para columna de la fila "central"
      int pPr, pSe; // pPr columa anterior, pSe columna siguiente 

        if (pAc==0) {
        pPr=cant-1;
        pSe=pAc+1;
      }
      else if (pAc==cant-1) {
        pPr=pAc-1;
        pSe=0;
      }
      else {
        pPr=pAc-1;
        pSe=pAc+1;
      }
      //Obtenemos la distancia entre una columna y los valores de la columna anterior y siguiente.
      float dSe= dist (puntos[pAc].x, puntos[pAc].y, puntos[pSe].x, puntos[pSe].y); //dist from actual to next 
      float dPr= dist (puntos[pAc].x, puntos[pAc].y, puntos[pPr].x, puntos[pPr].y); //dist from actual to previous
      float dCe= dist (sumTotal.x*0.1, sumTotal.y*0.1, puntos[pAc].x, puntos[pAc].y); //dist from center to actual

      //Dibujamos cada anillo alrededor de cada punto
      float W=2-(diamAn[iCol]*0.05); //variable que cambia el grosor de las lineas (hechas 
      fill(0); 
      stroke (cc); 
      strokeWeight (W); 
      ellipse (puntos[iCol].x, puntos[iCol].y, diamAn[iCol], diamAn[iCol]);

      //Dibujamos las lineas que cambian de color, DIBUJANDO PUNTO POR PUNTO
      int gradenteC = int (dCe);
      gradenteC = int (gradenteC-(diamAn[iCol]/2));
      for (int j=0; j<gradenteC; ++j) {
        float xdif =  sumTotal.x*0.1 - puntos[pAc].x;
        float ydif =  sumTotal.y*0.1 - puntos[pAc].y; 
        float ptx= -1 * xdif; 
        float pty = -1* ydif;

        float alpha = map ( j, 5, gradenteC, 20, 255);
        alpha = constrain (alpha, 0, 255);
        color cx = color (puntoCor[iCol], 220, alpha, 200);
        stroke (cx); 
        strokeWeight(1);

        pushMatrix();
        translate (sumTotal.x*0.1, sumTotal.y*0.1);
        float angu = atan2 (pty, ptx);
        point (j*cos(angu), j*sin(angu));
        popMatrix();
      }
      //Dibujo del poligono
      int gradenteA = int (dSe);
      for (int j=int(diamAn[iCol]/2); j<gradenteA; ++j) {
        float xdif =  puntos[pAc].x -  puntos[pSe].x;
        float ydif =  puntos[pAc].y -  puntos[pSe].y; 
        float ptx= -1 * xdif; 
        float pty = -1* ydif;

        float alpha = map ( j, diamAn[iCol]/2, gradenteA, 0, 255); 
        color cx = color (puntoCor[iCol], 220, 220, 255-alpha);
        stroke (cx);

        pushMatrix();
        translate (puntos[pAc].x, puntos[pAc].y);
        float angu = atan2 (pty, ptx);
        //println ("angu: "+angu);
        point (j*cos(angu), j*sin(angu));
        //stroke (255); line (0,0, ptx,pty);
        popMatrix();
      }
      int gradenteB = int (dPr);
      for (int j=int(diamAn[e]/2); j<gradenteB; ++j) {
        float xdif =  puntos[pAc].x -  puntos[pPr].x;
        float ydif =  puntos[pAc].y -  puntos[pPr].y; 
        float ptx= -1 * xdif; 
        float pty = -1* ydif;

        float alpha = map ( j, diamAn[iCol]/2, gradenteB, 0, 255); 
        color cx = color (puntoCor[iCol], 220, 220, 255-alpha);
        stroke (cx);

        pushMatrix();
        translate (puntos[pAc].x, puntos[pAc].y);
        float angu = atan2 (pty, ptx);
        point (j*cos(angu), j*sin(angu));
        //stroke (255); line (0,0, ptx,pty);
        popMatrix();
      }
    }
  }

  //______________________________________________________________________________________________________________

  void compass () {
    color com= color(0);//(0,220,220);
    //dibujo del anillo sobre el que se divuja el puntero
    noFill();
    stroke (220); 
    strokeWeight (50);
    ellipse (0, 0, r1*2.2, r1*2.2);
    //dibujo del borde da rosa
    stroke (255); 
    strokeWeight (12);
    ellipse (0, 0, r1*2.07, r1*2.07); 
    strokeWeight (1);  
    stroke(com); 
    noFill();// fill(255);
    ellipse (0, 0, r1*2.14, r1*2.14); 



    int ts=25; 
    int ptx=ts/2; //text size, and adjust to x position of text
    textAlign(CENTER, CENTER);
    textFont(Text, ts); 
    fill(0, 255, 255);
    float rt = r1*1.15;
    text ("N", rt*cos(radians(-90)), rt*sin(radians(-90))); 
    fill(0);
    text ("E", rt*cos(radians(0)), rt*sin(radians(0)));
    text ("O", rt*cos(radians(180)), rt*sin(radians(180)));
    text ("S", rt*cos(radians(90)), rt*sin(radians(90)));
    textAlign(LEFT, BOTTOM);
    //Frame counter as the principal counter between 0 and filasLength 
    // 

    float LastAngCompass=angCompass;
    int x = contador;
    if (x > filasLength-1) x = 0;
    //get the angle to set a compass
    if ( x == filasLength-1) x= x-1;
    float currentLat = csv[x][4]; 
    float nextLat = csv[x+1][4];

    float currentLon = csv[x][5];  
    float nextLon = csv[x+1][5];

    //*-1 para invertir la polaridad del canvas segun la polaridad de la latitud, 
    //hacia el norte (arriba) es -, hacia el sur (abajo) es +
    //currentLat = currentLat*-1;  nextLat = nextLat*-1;
    currentLon = currentLon*-1;  
    nextLon = nextLon*-1;

    float deltaLat = nextLat - currentLat;
    float deltaLon = nextLon - currentLon;
    //println ("deltaLat: "+ deltaLat+ " deltaLon: "+deltaLon+ " divs deltas: "+(deltaLat / deltaLon));      

    pushMatrix();
    translate (currentLat, currentLon);
    angCompass = atan2 (deltaLon, deltaLat);
    //println ("anguloCompass: "+ radians(angCompass) );
    popMatrix();

    pushMatrix();
    if (angCompass == 0) {
      angCompass = LastAngCompass;
      stop = true;
    }
    else stop = false;

    translate (r1*cos(angCompass)*1.2, r1*sin(angCompass)*1.2);
    rotate (angCompass); 
    noStroke(); 
    fill (com); 
    triangle (0, 0, -30, -30, -30, 30);
    fill (250); 
    triangle (-5, 0, -31, -25, -31, 25);

    popMatrix();
  }

  //______________________________________________________________________________________________________________

  void leyenda (float cx_, float cy_) {
    pushMatrix();
    pushStyle();
    strokeWeight(1);
    textAlign(CENTER, BOTTOM); 
    cxr=cx_;  
    cyr=cy_;  //centro de la rosa
    translate(cxr, cyr);

    float largura = width/4;
    float alto = height/2;

    rectMode(CORNER);
    float cant = cantColumns;
    float y=alto/4;

    int x = contador;
    if (x > filasLength-1) x = 0;

    for (int i=0; i<cant; i++) { 

      int ee =  i;//creamos la variable ee para extraer los datos, por que no ocuparemos Lat ni Long
      if (i > 3) ee=i+2;
      float numc=(csv[x][ee]);

      float valMax = table.MMs[ee].x; 
      float valMin = table.MMs[ee].y;

      float size  = r0 + ((numc-valMin) / (valMax-valMin))*L; 
      float tsize = map (size, r0, r1, 10, 20); //map change size font

      float cor = map(numc, valMin, valMax, 0, 250);
      cor = constrain (cor, 0, 255);

      String z = table.nomes[i];
      if (i > 3 && i < cant) z = table.nomes[i+2]; //evitamos escribir Lat y Long

      float di=diamAn [i]*0.8;
      float yp = (i+1)*y; //println(yp);

      //TEXT 
      textAlign(CENTER, BOTTOM);
      noStroke(); 
      fill(220); 
      rect (0, yp-2, largura, -28); //rect fondo para texto e linea Titulo
      rect (largura-60, yp-15, 60, 12); //rect fondo para texto e linea Max y minis
      rect (largura-70, yp+33, 70, 12);
      fill(0); 
      textFont(Text, 15);
      text (i+": ", -20, yp-5);
      textFont(Text, tsize);
      text (z+": "+numc, (largura/2)-30, yp-5 );

      //MAX MIN TEXTS
      stroke (220); strokeWeight (1.2); 
      line (0, yp, largura, yp); line (0, yp+30, largura, yp+30); stroke (#000000); 
      strokeWeight (1);
      line (0, yp, largura, yp); 
      textAlign(RIGHT, TOP); 
      textSize(12);
      text ("Min: "+valMin, largura, yp-15);
      line (0, yp+30, largura, yp+30); 
      textAlign(RIGHT, BOTTOM);
      text ("Max: "+valMax, largura, yp+45);

      //DRAW COLORS
      float Xp = map (x-velLect, 0, filasLength, 0, largura);
      float Xc = map (x, 0, filasLength, 0, largura);
      float Yc = yp; 
      //stroke (cor, 220, 220); 
      strokeWeight (1); 
      float lsize = map (size, r0, r1, 5, 30); //map change size font
      float tc = cor/lsize;
      float cc=0;
      for (int h=0; h<lsize; ++h) {

        stroke (cc, 220, 220, 180);
        strokeWeight(1);
        if (h+1>lsize) stroke (0); 
        strokeWeight(.5); 
        point (Xc, Yc+h); 
        line (Xp, Yc+h, Xc, Yc+h); 
        cc += tc;
      }
    }
    
    //draw rectangle 
    if (x < 2 || x==filasLength-1) {
      fill(220);
      noStroke();
      rect(0, 0, largura, alto*2, 10);//marco
    }
    else noFill();
//    stroke(255);  
//    strokeWeight(5);
    //rect (0,0, largura, alto, 10);//marco
    //strokeWeight(1); stroke (0); rect (-2.5, -2.5,  largura+5, alto+5, 10); //borde preto
    textAlign(LEFT, BOTTOM);
    popMatrix();
    popStyle();
  }

//______________________________________________________________________________________________________________

  void percurso (float cx_, float cy_) {
  pushMatrix(); 
  pushStyle();
  cxr=cx_;  
  cyr=cy_;  
  translate(cxr, cyr);
  
  float largura = width/4;
  float alto = -height/2.5;
  
  //draw rectangle 
  //fill(0,0,220,35); stroke(0); rectMode(CORNER); strokeWeight (5); //noStroke()R
  //rect (0, 0,  largura+5, alto+5, 10);
  
  //contador
   
  int x = contador;
  if (x > filasLength-1) x = 0;
  
  float valLat  = (csv[x][4]);//Y
  float valLong = (csv[x][5]);//X
  //Test Position: ellipse ( width/1.56, height/12, 5, 5); //derecha width/1.6,
  
  float valMinLat = table.MMs[4].y;
  float valMaxLat = table.MMs[4].x;
  float valMinLon = table.MMs[5].y;
  float valMaxLon = table.MMs[5].x;
//  float pointLat  = (alto+20) - ((valLat-valMinLat) / (valMaxLat-valMinLat))*(alto+40);
//  float pointLong = (largura-20) - ((valLong-valMinLon) / (valMaxLon-valMinLon))*(largura-40);
 
  float pointLat  = (valLat-valMinLat) / (valMaxLat-valMinLat) *  alto;
  float pointLong = (valLong-valMinLon) / (valMaxLon-valMinLon) * largura ;  
  
  
  //DRAW ELLIPSE_BACK
  fill(0,0,220,60); noStroke(); rectMode(CORNER); 
  ellipse (int(pointLong), int(pointLat), 100,100);
  
  //DRAW SHIP
  ship (int(pointLong), int(pointLat));
  //strokeWeight (2); stroke(255,0,255);  point (pointLong,pointLat); 
  cxp= int(pointLong)+cxr;
  cyp= int(pointLat)+cyr;
  
  //DRAW PERCURSO
  
  for (int p=0; p<x; p+= 5) {
    float alpha=map (p, 0, x, 220, 80);
    float Pyt  = (csv[p][4]);//Y
    float Pxt = (csv[p][5]);//X
    Pyt  = ((Pyt-table.MMs[4].y) / (table.MMs[4].x-table.MMs[4].y))*alto;
    Pxt = ((Pxt-table.MMs[5].y) / (table.MMs[5].x-table.MMs[5].y)*largura);
    stroke (alpha); smooth();strokeWeight (.5); point (Pxt, Pyt);
  }
  
  distance();
  //LEYENDAS DO PERCURSO
  float firstLat  =  ((csv[0][4]-table.MMs[4].y) / (table.MMs[4].x-table.MMs[4].y)) *  alto;
  float firstLong = ((csv[0][5]-table.MMs[5].y) / (table.MMs[5].x-table.MMs[5].y)) * largura;
  float lastLat  = ((csv[filasLength-1][4]-table.MMs[4].y) / (table.MMs[4].x-table.MMs[4].y)) * alto;
  float lastLong = ((csv[filasLength-1][5]-table.MMs[5].y) / (table.MMs[5].x-table.MMs[5].y)) *largura;
//  println (" firstpoints: " + firstLong+" "+firstLat+"  finalPoints: "+lastLong+" "+lastLat);
  
  //lines
  textFont(Text,15); fill(0); strokeWeight (0.5); stroke (0); 
  line (firstLong, firstLat, firstLong-150, firstLat);
  line (lastLong, lastLat, lastLong+250, lastLat);
  
  //line (20, alto+20, 250, alto+20);
  strokeWeight (5); point(firstLong, firstLat); //point(20, alto+20);
  point(lastLong, lastLat);
  
  //texts
  textFont(Text,15);
  float h = textAscent() + textDescent();
  fill(220); noStroke();
  rect (0, (alto*.135)-2 , 130, h*1.4); //rect behind text
  rect (0, (alto*.135)+22, 120, h*1.4); //rect behind number
  rect (firstLong-150, firstLat-20 , 80, 15); //rect behind SALVADOR
  rect (120, alto+5, 80, 15); //rect behind CACHOEIRA
  
  fill(0); 
  text ("distância percorrida: ", 0, alto*.135 - 2);
  textSize(20);
  text (distPercurso+" Km", 0, alto*.135 +22);
  
  textAlign(LEFT, BOTTOM);textSize(12);
  //text ("Ponto de partida e chegada", firstLong-250, firstLat-5);
  text ("SALVADOR", firstLong-150, firstLat-5); //firstLong-250, firstLat-5-(h*1.4));

  text ("CACHOEIRA", 120, alto+20 );
  
  popMatrix();
  popStyle();
 }

//______________________________________________________________________________________________________________

void ship (int px, int py) {
  float cant = cantColumns;
  float brazo=10;
  int i = 0;

  //TRAIL
  for (float angulo=0; angulo<TWO_PI ; angulo+=anguloVar) {
    //float Di = diamAn[e];
    color cc = color (puntoCor [i], 220,220);
    float di=diamAn [i];
    float huella=0;
    if (stop) huella = di*0.4;
    else huella = di;
    pushMatrix();
    translate (px, py); rotate (angulo);
    
    //DRAW BEHIND POINT arco  bajo linea
    fill (220); stroke(220);arc (0,0, brazo*1.5, brazo*1.5, (-PI*0.2), (PI*0.2)); 
    stroke (0); strokeWeight (1.5); 
    line (0, 0, brazo*0.5*cos(0), brazo*0.5*sin(0) );
    
    //anillo visual
    float w=brazo*4; 
    
    //circle Behind ship
  //  stroke(220); noFill();  strokeWeight (8); ellipse(0,0, w, w);
    stroke(220); fill(220);  strokeWeight (8); ellipse(0,0, w*2, w*2);
 //   stroke(255,100,220); noFill();  strokeWeight (1); ellipse(0,0, w, w);
    strokeWeight (1);
    
    //ship Trace
    noFill(); stroke(cc); 
    arc (-1*(huella/2), 0,  huella, di*0.3, (-PI/2), (PI/2));
    popMatrix();
    velocimetroShip (px,py, w);
    ++i;  
    }
  }
  
  void velocimetroShip (float px_, float py_, float dc) {
   pushMatrix();
   textAlign (CENTER, CENTER);
   translate(px_, py_);
   float aa= noise (px_, py_);
   float t=-PI/4;
   
   float ll;
   //LINE CONECTION
   if (velocidad != 0) ln+=0.2;
     else ln-=0.2;
   ll=49-ln;
   if (ll >  49) ln = 0 ;//l =50;
   if (ll <  (dc*.55)) { ll =(dc*.54); ln -=.2; }
   noFill();
   int cc=220; float w=40;
   
   pushMatrix();
   float top = -260;// -height/2.5;
   float angVe = map (py_, -20, top, 0, PI*.3);
   angVe = constrain (angVe,  0, PI*.3);
   rotate (angVe);
   for (int ct=0; ct<2; ct++) {
     stroke (cc); strokeWeight(w);
     line (ll*cos(-PI/4), ll*sin(-PI/4), 49*cos(t), 49*sin(t)); //linea desde velocidad a barco
     stroke(255,100,220); noFill();  strokeWeight (1); ellipse(0,0, dc, dc); //dibujo de anillo
     point ((ll-2.5)*cos(-PI/4), (ll-2.5)*sin(-PI/4));
     if (ct ==1) { strokeWeight (3); point ((ll-2.5)*cos(-PI/4), (ll-2.5)*sin(-PI/4));}
     cc=color(255,200,220); w=.5;
   }
   popMatrix();
   
   //TEXT
   textAlign (LEFT,TOP);
   textFont(Text, 13);
   float h = textAscent() + textDescent();
   fill(220); noStroke();rect (50*cos(t+angVe), (50*sin(t+angVe))-5, 110, h*3); //rect behind text
   fill(0); 
   text (velocidad+" Km/h", (50*cos(t+angVe))+3, 50*sin(t+angVe) );
   popMatrix();
   
 }  

//______________________________________________________________________________________________________________

void distance() {
   float angMenor = 0;
   float angMayor = PI*2;
     
   pushMatrix();
   translate (cxro, cyro);
  
    
   int x = contador;
   if (x > filasLength-1) x = 0;
   
      int xx; //variables para obener valores previos de cada punto
      if (x==0) {
        xx = 0;
        distPercurso=0;
      }
      else xx = x-velLect ;

      float dlat1=(csv[x][4]); //valor latitud punto actual
      float dlon1=(csv[x][5]); //valor longitud punto actual
      float dlat2=(csv[xx][4]); //valor latitud punto anterior
      float dlon2=(csv[xx][5]); //valor longitud punto anterior
      
      distanceEqu (dlat1, dlon1, dlat2, dlon2);
    
    textFont(Text, 12);
    noStroke();//stroke(0); 
    fill(220); 
    //rect (0, 0, largura, alto);//rect fondo para texto e linea
    fill(0); 
    //text ("Distância percorrida: "+distPercurso+"Km", 0, -10 );
    //stroke(0);line (0,0,200,0);
    
    pushMatrix();
    rotate (PI);
    stroke (0);strokeWeight(2); noFill();
    float an= map (x, 0, filasLength, 0,PI*2);
    //arc (0,0, L*3, L*3, angMenor, an);
    popMatrix();
    
    popMatrix();
  }
  
void distanceEqu (float la1, float lo1, float la2, float lo2) {
      
      float dlat1=la1; //degree latitude point actual
      float dlon1=lo1; //degree longitude point actual
      float dlat2=la2;
      float dlon2=lo2; //degree longitude last point
      
      
      float R=6371; //km earth's radius
      
      //CONVERSION TO RADIANS
      float dLat = radians (dlat1 - dlat2);
      float dLon = radians (dlon1 - dlon2);
      float lon1 = radians (dlon1);
      float lat1 = radians (dlat1);
      float lon2 = radians (dlon2);
      float lat2 = radians (dlat2);   
      
      //EQUATIONS
      float a =  sin (dLat/2) * sin (dLat/2) +
                 sin (dLon/2) * sin (dLon/2) *
                 cos (lat1) * cos (lat2);
      float c = 2 * atan2 ( sqrt(a),  sqrt(1-a) );
      
      float distActual = R*c; //en kilometros
      //println ("distActual "+distActual);
      /*float dd= acos ( sin (lat1) * sin (lat2) +
                       cos (lat1) * cos (lat2) *
                       cos (lon2-lon1)) * R;*/
     distPercurso=distPercurso+distActual;
   //  println (" distPercurso: "+distPercurso);
     distPercurso=round(distPercurso * 10.0f ) / 10.0f;
//     distActual = round( distPercurso * 10.0f ) / 10.0f;
     float vel= distActual / (2*velLect); //we get lectures every 5 seconds
     velocidad=vel*360; //kilómeter per hora
     velocidad= round( velocidad * 10.0f ) / 10.0f;
     //String.format("PI=%.2f or %.4f",PI,PI)
  }
  
  void velocimetro (int dx_, int dy_, int diam_){
  int dx=dx_;
  int dy=dy_;
  int diam=diam_; 
  int rad = diam/2;
  
  float perimetro=2*PI*rad; //perimetro del velocimetro
  float angInicio = PI *1; //angulo minimo en el dibujo de velocidad
  float angFinal = PI *2; //angulo maximo en el dibujo de velocidad
  float angSuma = (PI*1.5) / (perimetro*1.5); //unidad que se suma en el for que dibuja las lineas de color de la velocidad
  float radInt = (rad*.8) ; //radio interior del dibujo del color de velocidad
  float radExt = (rad*.95) ; //radio exterior del dibujo de color de velocidad
  
  pushMatrix();
  pushStyle();
  textAlign(CENTER, CENTER);
  //colorMode (RGB);
  translate(dx, dy);
//  println ("ang: " + atan2 (mouseY-dy, mouseX-dx) );
  //ellipse de fondo
  fill(220); noStroke();
  ellipse (0,0, diam*1.1, diam*1.1);
  rectMode (CENTER);
  rect (0, -rad*1.1, diam, 20);
  noFill(); stroke(0); strokeWeight(.5);
 // arc (0,0, diam, diam, angInicio, angFinal);
 
  
 //MOUSE Obtenemos la velocidad por mouseX
  float iz =  -dx + 100 ;//*.4 ;
  float de =  -dx + 300 ;
  float alt = -rad*1.2;
  float dist = iz-de;

  //Obtiene el angulo hasta donde dibujar el arco de velocidad
  if (mousePressed) {
    if (mouseX > 100 && mouseX <300 && mouseY > (dy-rad) && mouseY < (dy) ) { 
      anguloPuntero = constrain ( (map (atan2 (mouseY-dy, mouseX-dx),-3.13,.1,angInicio, angFinal)),angInicio, angFinal);
      marcador = map (anguloPuntero, angInicio, angFinal, 0, 1023);  
    }
  }
  //println ("anguloPuntero: "+ anguloPuntero); 
  
 
  //Dibujo Colores Velocimetro
  strokeWeight (1);
  int contadorInt = 0;
  for (float ang = angInicio ; ang < angFinal ; ang += angSuma ) {
    
    if (contadorInt == 10) {
      contadorInt=0;
      ang += (angSuma * 20);
    }
    
    int cor = (int) map (ang, angInicio, angFinal, 60, 0); 
    stroke (cor, 220,220, 50); 
    line (radInt *cos(ang), radInt *sin(ang), radExt*cos(ang), radExt*sin(ang) );
    contadorInt++;
  }
  contadorInt=0;
  for (float ang = angInicio ; ang < anguloPuntero ; ang += angSuma ) {
    
    if (contadorInt == 10) {
      contadorInt=0;
      ang += (angSuma * 20);
    }
    
    int cor = (int) map (ang, angInicio, angFinal, 60, 0); 
    stroke (cor, 220,220); 
    line (radInt *cos(ang), radInt *sin(ang), radExt*cos(ang), radExt*sin(ang) );
  
    contadorInt++;
  }
  
  //Texto
  fill(0); textSize (15); textFont (Text, 15);
  text ("clique para mover a agulha", 0, -rad*1.1);
  text ("Velocidade de",0,35);
  text ("visualizaçao",0,55);
  
  //AGJA
  pushMatrix();
  stroke(255,200,200);
  fill(255,230,230);
  ellipse (0,0, 20,20);
  rotate (anguloPuntero);
  
  beginShape();
  vertex(-20, 5);
  vertex(-20, -5);
  vertex(rad, 0);
  endShape(CLOSE);//line (0, 0, rad*cos(anguloPuntero), rad*sin(anguloPuntero) );
  popMatrix();
  
  
  //frameR = map (anguloPuntero, angInicio, angFinal, 10, 120);
  float velS = map (anguloPuntero, angInicio, angFinal, .05, 2);
  
  player2.speed(velS);
  player.speed ((player.getLengthMs()/player2.getLengthMs()) *(velS*0.25) );  
  
  popMatrix();
  popStyle();
  
 }
}

