public class AgeComparator implements Comparator {

  Map base;
  public AgeComparator(Map base) {
      this.base = base;
  }

  public int compare(Object a, Object b) {
    Human one = (Human) a;
    Human two = (Human) b;
    return int(one.birth) - int(two.birth);
  }
}
