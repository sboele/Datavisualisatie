/*

 Main STDSIM Visualisation Class
 
 November, 2011
 Sander Boele (0806692)
 Jacob van Lingen (0809702)
 
 */

// Imports
import toxi.geom.*;

// Variables
PFont font;
HashMap humansAmountOfRelationsMale = new HashMap();
HashMap humansAmountOfRelationsFemale = new HashMap();
Map sorted_map = new LinkedHashMap();

HashMap humans = new LinkedHashMap();
HashMap relations = new HashMap();
String humansFile = "ks05N158H.000";
String relationFile = "ks05N158Z.000";
String transmissionEventFile = "ks05N158X.000";

Vec2D centre;
float radius = 50.0;

boolean pause = false;

/*
 Setup function
 Read files and store in datastructures
 */
void setup() {
  size(1024,768);
  centre = new Vec2D(width/2, height/2);
  
  readHumansFile(humansFile);
  humans = sortHashMapByValuesD(humans);
  readRelationshipFile(relationFile);
  readTransmissionEventsFile(transmissionEventFile);
  fillHumansAmountOfRelation();
  
  calculateCoordinatesHumans(humansAmountOfRelationsMale);
  radius = 25.0;
  calculateCoordinatesHumans(humansAmountOfRelationsFemale);
}

int lastTime = 0;
float date = 1995.000;

void draw(){
  if( millis() - lastTime >= 100){
    background(255);
    fill(0);
    text(date, 10, 15);
    drawRelations(date);  
    boolean noOneLeft = drawHumans(date);
    if(noOneLeft) {
      noLoop();
    }
    date += 0.005;
    lastTime = millis();
  }
}

void mousePressed() {
  if(pause) {
    pause = false;
    loop();
  }
  else {
    pause = true;
    noLoop();
  }
}

void calculateCoordinatesHumans(HashMap humansAmountOfRelations) {
  double perimeter = 2*Math.PI*radius;
  Set keySet = humansAmountOfRelations.keySet();
  List list = new ArrayList(keySet);
  Collections.sort(list);
  Collections.reverse(list);
  for(int i = 0 ; i < humansAmountOfRelations.size() ; i++) {
    ArrayList humanIDs = (ArrayList)humansAmountOfRelations.get(list.get(i));
    double spaceBetweenNodes = perimeter / humanIDs.size();
    double angle = 0.0;
    ellipseMode(CENTER);
    fill(0,0);
    ellipse(centre.x, centre.y, radius*2, radius*2);
    Vec2D origin = new Vec2D(0-radius,0);
    for(int k = 0 ; k < humanIDs.size(); k++) {      
      int humanID = (Integer) humanIDs.get(k);
      Human human = (Human) humans.get(humanID);
      Vec2D coordinates;

      coordinates = pointOnCircle(radius, angle, origin);
      origin = coordinates;
      //System.out.println("First: Size: "+humanIDs.size()+" Coordinates: "+coordinates+" Radius: "+radius+" Angle: "+angle+" - M/F: "+human.gender + " - Age: "+human.birth + " hivDate: "+human.hivDate);
      
      ellipseMode(CENTER);
      angle += 360.0/humanIDs.size();
      coordinates.x = centre.x + coordinates.x;
      coordinates.y = centre.y + coordinates.y;
      
      human.coordinates = coordinates;
      human.hasBeenDrawn = true;
      humans.put(humanID, human);
    }
    radius += 50;
  }
}

public Vec2D pointOnCircle(float radius, double angle, Vec2D origin) {
  double x = radius * Math.cos(angle*(PI/180));
  double y = radius * Math.sin(angle*(PI/180));
  
  return new Vec2D((float)x, (float)y);
}

void fillHumansAmountOfRelation() {  
  Iterator it = humans.entrySet().iterator();
  
  while(it.hasNext()) {
    Map.Entry pairs = (Map.Entry) it.next();
    int keyNumberOfRelations = (Integer) pairs.getKey();
    Human human = (Human) pairs.getValue();
   
    if(human.gender == 'M') {
      fillHumansAmountOfRelationHashMaps(humansAmountOfRelationsMale, human, keyNumberOfRelations);
    }
    else {
      fillHumansAmountOfRelationHashMaps(humansAmountOfRelationsFemale, human, keyNumberOfRelations);
    }    
  }
}

void fillHumansAmountOfRelationHashMaps(HashMap humansAmountOfRelations, Human human, int keyNumberOfRelations)
{
  ArrayList a;
  if(humansAmountOfRelations.containsKey(human.relations.size())) {
    a = (ArrayList) humansAmountOfRelations.get(human.relations.size());
  }
  else {
    a = new ArrayList();
  }
   
  a.add(keyNumberOfRelations);
  humansAmountOfRelations.put(human.relations.size(), a);
}

void readHumansFile(String file) {
  String[] lines = loadStrings(file);
  for (int i=1 ; i < lines.length ; i++) {
    String[] line = split(lines[i], "\t");
    if (line.length == 33) {
      Human human = createHuman(line);
      humans.put(human.id, human);
     // println("Added human:"+human.id+" to hashmap");
    }
  }
}

void readRelationshipFile(String file) {
  String[] lines = loadStrings(file);
  for (int i=1 ; i < lines.length ; i++) {
    String[] line = split(lines[i], "\t");
    if (line.length == 11) {
      Relation relation = createRelation(line);
      if(relation != null) {
      relations.put(relation.id, relation);
      }
     // println("Added relation:"+relation.id+" to hashmap");
    }
  }
}

void readTransmissionEventsFile(String file) {
  String[] lines = loadStrings(file);
  int counter = 0;
  for(int i=1 ; i < lines.length ; i++) {
    String[] line = split(lines[i], "\t");
    if (line.length == 12) {
      Human human = (Human) humans.get(int(line[8]));
      if(human != null) {
        human.hivDate = float(line[3]);
        human.infector = (Human) humans.get(int(line[9]));
        humans.put(human.id, human);
        counter++;
        System.out.println(human.hivDate);
      }
      System.out.println(counter);
    }
  }
}


Relation createRelation(String[] line) {
  Relation relation = new Relation();
  relation.id = int(line[3]);
  relation.type = line[4];
  relation.male = (Human) humans.get(int(line[5]));
  relation.female = (Human) humans.get(int(line[6]));
  
  if(relation.male == null || relation.female == null) {
    return null;
  }
  
  relation.date_start = float(line[7]);
  relation.date_stop = float(line[8]);
  relation.condom = float(line[9]);
  relation.intv = float(line[10]);
  relation.colour = color(255, 0, 0);

  relation.male.relations.add(relation);
  relation.female.relations.add(relation);

  //TODO sexworker colour: red;  
  return relation;
}

Human createHuman(String[] line) {
  Human human = new Human();
  human.id = int(line[5]);
  human.gender = line[4].charAt(0);
  human.birth = float(line[6]);
  human.death = float(line[7]);
  human.immigrant = boolean(line[8]);
  human.emigrant = boolean(line[9]);
  human.av_evt = float(line[10]);
  human.isAvaliable = boolean(line[11]);
  human.virgin = boolean(line[12]);
  human.debut = float(line[13]);
  human.promiscuity = float(line[14]);
  human.useCondom = boolean(line[15]);
  human.csw = line[16];
  human.cursty = int(line[17]);
  human.recsty = int(line[18]);
  human.lifsty = int(line[19]);
  human.curcas = int(line[20]);
  human.reccas = int(line[21]);
  human.lifcas = int(line[21]);
  human.recvis = int(line[22]);
  human.lifvis = int(line[23]);
  human.hivStage = int(line[25]);
  human.hivInfector = int(line[26]);

  return human;
}

boolean drawHumans(float date) {
  boolean noOneLeft = true;
  Iterator it = humans.entrySet().iterator();  
  while(it.hasNext()) {
    Map.Entry pairs = (Map.Entry) it.next();
    Human human = (Human) pairs.getValue();
    
    if(human.death > date && human.birth < date) {
      noOneLeft = false;
      if(human.hivDate < date) {
        fill(color(30,157,68));
        ellipse(human.coordinates.x, human.coordinates.y, 5, 5);
      }
      if(human.gender == 'F') {
        fill(color(255,0,0));
      }
      else {
        fill(color(0,0,255));
      }
      ellipse(human.coordinates.x, human.coordinates.y, 4, 4);
    }
  }
  return noOneLeft;
}

void drawRelations(float date) {
  Iterator it = relations.entrySet().iterator();  
  while(it.hasNext()) {
    Map.Entry pairs = (Map.Entry) it.next();
    Relation relation = (Relation) pairs.getValue();
    if(relation.male.hasBeenDrawn & relation.female.hasBeenDrawn & relation.date_start <= date & relation.date_stop >= date) {
      if((relation.male.hivDate < date && relation.female.hivDate < date)) {
        stroke(color(63,227,15));
        //System.out.println("DUS: " + relation.male.hivDate + " DAT: " + relation.female.hivDate + " DATE: " + date);
      }
      else {
        stroke(color(0,0,0));
      }
      line(relation.male.coordinates.x, relation.male.coordinates.y, relation.female.coordinates.x, relation.female.coordinates.y);
    }
    //Line2D line = new Line2D(relation.male.coordinates, relation.female.coordinates);
  }
}

public LinkedHashMap sortHashMapByValuesD(HashMap passedMap) {
    AgeComparator agecomp = new AgeComparator(humans);
    List mapKeys = new ArrayList(passedMap.keySet());
    List mapValues = new ArrayList(passedMap.values());
    Collections.sort(mapValues,agecomp);
//    Collections.reverse(mapValues);
    Collections.sort(mapKeys);
//    Collections.reverse(mapKeys);
        
    LinkedHashMap sortedMap = new LinkedHashMap();
    
    Iterator valueIt = mapValues.iterator();
    while (valueIt.hasNext()) {
        Object val = valueIt.next();
        Iterator keyIt = mapKeys.iterator();
        
        while (keyIt.hasNext()) {
            Object key = keyIt.next();
            String comp1 = passedMap.get(key).toString();
            String comp2 = val.toString();
            
            if (comp1.equals(comp2)){
                passedMap.remove(key);
                mapKeys.remove(key);
                sortedMap.put((Integer)key, (Human)val);
                break;
            }

        }

    }
    return sortedMap;
}
