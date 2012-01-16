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
float[] birthRegions = new float[5];
int lastTime = 0;
float date = 1970.000;

/*
 Setup function
 Read files and store in datastructures
 Calculate the coordinates of the humans
 */
void setup() {
	size(1024,768);
	centre = new Vec2D(width/2, height/2);
	readHumansFile(humansFile);
	humans = sortHashMapByAge(humans);
	readRelationshipFile(relationFile);
	readTransmissionEventsFile(transmissionEventFile);
	fillHumansAmountOfRelation();
	calculateCoordinatesHumans(humansAmountOfRelationsMale);
	radius = 25.0;
	calculateCoordinatesHumans(humansAmountOfRelationsFemale);
}

/*
  Redraw the regions/relations/humans every 100ms
*/
void draw() {
	if( millis() - lastTime >= 100) {
		background(255);
		fill(0);
		drawRegions();
		text(date, 10, 15);
		drawRelations(date);
		boolean noOneLeft = drawHumans(date);
                // When there is no one left it should stop the loop
		if(noOneLeft) {
			noLoop();
		}
		date += 0.100;
		lastTime = millis();
	}
}

// On mousepress change from pause to running or running to pause
void mousePressed() {
	if(pause) {
		pause = false;
		loop();
	} else {
		pause = true;
		noLoop();
	}
}

// draw 4 rectangle representing the 4 different age areas
void drawRegions() {
	fill(#E1FFF4);
	rect(0,0, width/2, height/2); //top left area
	fill(#FBFFDD);
	rect(width/2,0, width/2, height/2);//top right area
	fill(255,239,237);
	rect(0,height/2, width/2, height/2);//bottom left area
	fill(#FED6D7);
	rect(width/2,height/2, width/2, height/2); //bottom right area
	fill(0, 102, 153);
	text(birthRegions[0]+" - "+birthRegions[1], width-200, height-100);
	text(birthRegions[1]+" - "+birthRegions[2], 100, height-100);
	text(birthRegions[2]+" - "+birthRegions[3], 100, 100);
	text(birthRegions[3]+" - "+birthRegions[4], width-200, 100);
}

// Method to calculate the coordinates of a human on the visualization
void calculateCoordinatesHumans(HashMap humansAmountOfRelations) {
  // calculate perimeter of the circle
	double perimeter = 2*Math.PI*radius;
// put the keys of the hashmap in list and sort it
	Set keySet = humansAmountOfRelations.keySet();
	List list = new ArrayList(keySet);
	Collections.sort(list);
	Collections.reverse(list);
// a for loop to draw the humans on a circle, the position of the circle is based on the ammount of relations
	for (int i = 0 ; i < humansAmountOfRelations.size() ; i++) {
		ArrayList humanIDs = (ArrayList)humansAmountOfRelations.get(list.get(i));
		ArrayList regions = new ArrayList();
		regions.add(new ArrayList());
		regions.add(new ArrayList());
		regions.add(new ArrayList());
		regions.add(new ArrayList());
// for every human add it to the right region arraylist
		for (int m = 0 ; m < humanIDs.size(); m++) {
			int humanID = (Integer) humanIDs.get(m);
			Human human = (Human) humans.get(humanID);
			ArrayList group = (ArrayList) regions.get(human.region);
			group.add(human);
			regions.set(human.region, group);
		}
		double spaceBetweenNodes = perimeter / humanIDs.size();
		double angle = 0.0;
		ellipseMode(CENTER);
		fill(0,0);
		ellipse(centre.x, centre.y, radius*2, radius*2);
		Vec2D origin = new Vec2D(0-radius,0);
          // loop through every region
		for (int k = 0 ; k < regions.size(); k++) {
			ArrayList group = (ArrayList) regions.get(k);
          // loop through every human in the region
			for (int n = 0 ; n < group.size() ; n++) {
				Human human = (Human) group.get(n);
				Vec2D coordinates;
          // calculate the next point on the circle based on the previous point, the readius and the angle
				coordinates = pointOnCircle(radius, angle, origin);
				origin = coordinates;
				ellipseMode(CENTER);
				angle += 90.0/group.size();
				coordinates.x = centre.x + coordinates.x;
				coordinates.y = centre.y + coordinates.y;
				human.coordinates = coordinates;
				human.hasBeenDrawn = true;
				humans.put(human.id, human);
			}
		}
		radius += 50;
	}
}
// calculate the next point on the circle based on the previous point, the readius and the angle
public Vec2D pointOnCircle(float radius, double angle, Vec2D origin) {
	double x = radius * Math.cos(angle*(PI/180));
	double y = radius * Math.sin(angle*(PI/180));
	return new Vec2D((float)x, (float)y);
}

// fill the hashmap with the humans based on their ammount of relations
void fillHumansAmountOfRelation() {
	Iterator it = humans.entrySet().iterator();
	while(it.hasNext()) {
		Map.Entry pairs = (Map.Entry) it.next();
		int keyNumberOfRelations = (Integer) pairs.getKey();
		Human human = (Human) pairs.getValue();
		if(human.gender == 'M') {
			fillHumansAmountOfRelationHashMaps(humansAmountOfRelationsMale, human, keyNumberOfRelations);
		} else {
			fillHumansAmountOfRelationHashMaps(humansAmountOfRelationsFemale, human, keyNumberOfRelations);
		}
	}
}

// fill the hashmap with the humans based on their ammount of relations
void fillHumansAmountOfRelationHashMaps(HashMap humansAmountOfRelations, Human human, int keyNumberOfRelations) {
	ArrayList a;
	if(humansAmountOfRelations.containsKey(human.relations.size())) {
		a = (ArrayList) humansAmountOfRelations.get(human.relations.size());
	} else {
		a = new ArrayList();
	}
	a.add(keyNumberOfRelations);
	humansAmountOfRelations.put(human.relations.size(), a);
}

// read the humans file and find the different birthregions
void readHumansFile(String file) {
	float firstBirth = 100000.0;
	float lastBirth = 0.0;
	String[] lines = loadStrings(file);
	for (int i=1 ; i < lines.length ; i++) {
		String[] line = split(lines[i], "\t");
// check if the valid line is valid
		if (line.length == 33) {
			Human human = createHuman(line);
			humans.put(human.id, human);
			if(human.birth < firstBirth)
			        firstBirth = human.birth;
			if(human.birth > lastBirth)
			        lastBirth = human.birth;
		}
	}
	birthRegions[0] = firstBirth;
	birthRegions[1] = firstBirth + ((lastBirth - firstBirth) / 4);
	birthRegions[2] = firstBirth + (((lastBirth - firstBirth) / 4) * 2);
	birthRegions[3] = firstBirth + (((lastBirth - firstBirth) / 4) * 3);
	birthRegions[4] = lastBirth;

//assign the right region to the human object
	Set keySet = humans.keySet();
	List list = new ArrayList(keySet);
	for (int i = 0 ; i < list.size() ;i++) {
		int humanId = (Integer) list.get(i);
		Human human = (Human) humans.get(humanId);
		int region;
		if(human.birth < birthRegions[1])
		      human.region = 0; else if(human.birth < birthRegions[2])
		      human.region = 1; else if(human.birth < birthRegions[3])
		      human.region = 2; else if(human.birth < birthRegions[4])
		      human.region = 3;
	}
}
// read relationship file
void readRelationshipFile(String file) {
	String[] lines = loadStrings(file);
	for (int i=1 ; i < lines.length ; i++) {
		String[] line = split(lines[i], "\t");
		if (line.length == 11) {
			Relation relation = createRelation(line);
			if(relation != null) {
				relations.put(relation.id, relation);
			}
		}
	}
}
// read transmissionevents file
void readTransmissionEventsFile(String file) {
	String[] lines = loadStrings(file);
	int counter = 0;
	for (int i=1 ; i < lines.length ; i++) {
		String[] line = split(lines[i], "\t");
		if (line.length == 12) {
			Human human = (Human) humans.get(int(line[8]));
			if(human != null) {
				human.hivDate = float(line[3]);
				human.infector = (Human) humans.get(int(line[9]));
				humans.put(human.id, human);
				counter++;
			}
		}
	}
}
// create a relation object based on an input line
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
	return relation;
}
// create a human object based on an input line
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

// draw human on canvas based on its coordinates (assigned previously)
boolean drawHumans(float date) {
	boolean noOneLeft = true;
	Iterator it = humans.entrySet().iterator();
	while(it.hasNext()) {
		Map.Entry pairs = (Map.Entry) it.next();
		Human human = (Human) pairs.getValue();
// check if there are still people alive
		if(human.death > date && human.birth < date) {
			noOneLeft = false;
// change color and size if the human is inftected with hiv
			if(human.hivDate < date) {
				fill(color(30,157,68));
				ellipse(human.coordinates.x, human.coordinates.y, 8, 8);
			}
// change color based on gender
			if(human.gender == 'F') {
				fill(color(255,0,0));
			} else {
				fill(color(0,0,255));
			}
			ellipse(human.coordinates.x, human.coordinates.y, 2, 2);
		}
	}
	return noOneLeft;
}
// draw relations between humans
void drawRelations(float date) {
	Iterator it = relations.entrySet().iterator();
	while(it.hasNext()) {
		Map.Entry pairs = (Map.Entry) it.next();
		Relation relation = (Relation) pairs.getValue();
                // check if both female and male are drawn and if the relation is active
		if(relation.male.hasBeenDrawn & relation.female.hasBeenDrawn & relation.date_start <= date & relation.date_stop >= date) {
			if((relation.male.hivDate < date && relation.female.hivDate < date)) { //give relation a green line if both man and female have hiv, else black line
				stroke(color(63,227,15)); 
			} else {
				stroke(color(0,0,0));
			}
			line(relation.male.coordinates.x, relation.male.coordinates.y, relation.female.coordinates.x, relation.female.coordinates.y);
		}
	}
}
// sort a hashmap of humans by age
public LinkedHashMap sortHashMapByAge(HashMap passedMap) {
	AgeComparator agecomp = new AgeComparator(humans);
	List mapKeys = new ArrayList(passedMap.keySet());
	List mapValues = new ArrayList(passedMap.values());
	Collections.sort(mapValues,agecomp);
	Collections.sort(mapKeys);
	LinkedHashMap sortedMap = new LinkedHashMap();
	Iterator valueIt = mapValues.iterator();
	while (valueIt.hasNext()) {
		Object val = valueIt.next();
		Iterator keyIt = mapKeys.iterator();
		while (keyIt.hasNext()) {
			Object key = keyIt.next();
			String comp1 = passedMap.get(key).toString();
			String comp2 = val.toString();
			if (comp1.equals(comp2)) {
				passedMap.remove(key);
				mapKeys.remove(key);
				sortedMap.put((Integer)key, (Human)val);
				break;
			}
		}
	}
	return sortedMap;
}
