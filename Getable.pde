class Getable {

  float [][] csv;
  int csvWidth=0;
  int filasLength=0;

  String lines[];

  PVector [] MMs;//array de maximos y minimos
  String [] nomes;//array de nombres de cada columna

  Getable (String ar) {
    lines = loadStrings(ar);//loadStrings("DATALOG_dia04_ed.CSV");   
    
//    println("there are " + lines.length + " lines");
/*    for (int i=0; i < lines.length; i++) {
      println(lines[i]);
    }*/
    
    tablaMatriz(); //Genramos una tabla con los datos
    MaxMin(); //calculamos minimos y maximos de la tabla
 }

  void tablaMatriz () {

    nomes = split(lines[0], ';'); 

    //calculamos la cantidad de elementos de cada fila o linea
    for (int i=0; i < lines.length; i++) {
      String [] chars=split(lines[i], ';');
      if (chars.length>csvWidth) {
        csvWidth=chars.length;
      }
    }

    //se crea el array csv basado en # de filas y columnas del archivo
    csv = new float [lines.length-1][csvWidth]; //-1 por que la primera son los nombres
    filasLength=lines.length-1;

    //Se ingresan los valores de la matriz 2D
    String [] temp = new String [lines.length];
    for (int i=1; i < lines.length; i++) {
      temp= split(lines[i], ';');
      //println(temp);
      for (int j=0; j < temp.length; j++) {
        csv[i-1][j] =float(temp[j]);
      }
    }
//    println("csv [0][3]=:"+csv[0][3]);
  }


  void MaxMin() {
    MMs= new PVector [csvWidth];

    for (int e=0; e<csvWidth; ++e) {

      PVector MM;
      float maxVal=-100000;
      float minVal=100000;
      
      for (int x=0; x<filasLength; ++x) {
        float currentVal=csv[x][e];
        if (currentVal>maxVal) {
          maxVal=currentVal;
        }
        else if (currentVal<minVal) {
          minVal=currentVal;
        }
      }

 //     println ("max: "+maxVal+"  min: "+ minVal);
      MM = new PVector(maxVal, minVal);
      MMs[e]= MM;
    }
    //println(MMs);
  }
 
 

   
    
}
