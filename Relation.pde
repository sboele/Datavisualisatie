/*

 Human Object Class
 
 November, 2011
 Sander Boele (0806692)
 Jacob van Lingen (0809702)
 
 */

public class Relation {
  int id; // ID of the relation (unique within one simulation run)
  String type; // casu == Casual, Steady == stea
  Human male;
  Human female;
  float date_start;
  float date_stop;
  float condom;
  float intv;
  
  int x_start;
  int y_start;
  int x_end;
  int y_end;
  color colour;
  
  Relation() {
  };
}
