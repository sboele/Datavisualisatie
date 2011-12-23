public class AgeComparator implements Comparator {

  Map base;
  public AgeComparator(Map base) {
      this.base = base;
  }

  public int compare(Object a, Object b) {

    if((Human)base.get(a).birth < (Human)base.get(b).birth) {
      return 1;
    } else if((Human)base.get(a).birth == (Human)base.get(b).birth) {
      return 0;
    } else {
      return -1;
    }
  }
}
