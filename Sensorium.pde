Getable table;
PanelControl display;

//LIBRERIAS audio
Maxim maxim;
AudioPlayer player;
AudioPlayer player2;

void setup () {
  //size (displayWidth,displayHeight);
  size (1280, 600);

  //Variables  de sonidos
  maxim = new Maxim(this);
  player = maxim.loadFile("atmos1.wav");
  player.setLooping(true);
  player2 = maxim.loadFile("bells.wav");
  player2.setLooping(true);
  player.volume(0.5);
  player2.volume(0.5);

  color cb= color (0, 0, 0, 50);
  table = new Getable("DataSensorium.csv");
  display = new PanelControl (20, 200, cb); //inicio de radio, largo de radio, color
  background (220);
  colorMode (HSB);
}

void draw() {
  //  println("table.csv [0][3]=:"+table.csv[0][3]);
  //  ellipse (0,0, 200,200);
  display.update();
  display.drawRosa(width/2, height/2);
  display.leyenda (width*0.73, height/2-310);
  display.percurso(width*0.05, height*0.925);
  display.velocimetro (200,150, 200); 
}


