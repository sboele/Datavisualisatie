/*

 Human Object Class
 
 November, 2011
 Sander Boele (0806692)
 Jacob van Lingen (0809702)
 
 */

public class Human {
  int id; // ID of the person (unique within one simulation run)
  char gender; // M or F
  float birth; // birthdate (in years as a floating point number)
  float death; // deathdate (maybe advanced due to HIV death) or emigration date (for emigrants)
  boolean immigrant; // immigrant (T/F)
  boolean emigrant; // emigrant (T/F) note: a record of emigrants who recently emigrated is kept during the interval between t1 and t2 
  float av_evt; // future moment of becoming (un)available
  boolean isAvaliable; // currently available (T/F)
  boolean virgin; // virgin (T/F)
  float debut; // time of sexual debut (in years either in the future or in the past)
  float promiscuity; // promiscuity index (real number, avg of pop = 1)
  boolean useCondom; // currently using condoms (careful with this, as condom use in a sex act may also depend on other characteristics)
  String csw; // CWS == Commercial Sex Worker, VIS == Visitor, - == nothing
  int cursty; // number of current steady partners
  int recsty; // number of recent steady partners
  int lifsty; // number of lifetime steady partners
  int curcas; // number of current casual partners
  int reccas; // number of recent casual partners
  int lifcas; // number of lifetime casual partners
  int recvis; // number of recent SW visits
  int lifvis; // number of lifetime SW visits
  int hivStage; // HIV stage
  int hivInfector; // ID of HIV infector
  ArrayList relations;
  Vec2D coordinates;
  String position;
  boolean hasBeenDrawn = false;

  Human() {
    relations = new ArrayList();
    coordinates = new Vec2D();
  };
}

