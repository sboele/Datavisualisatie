public class AgeComparator implements Comparator {

  Map base;
  public AgeComparator(Map base) {
      this.base = base;
  }

  public int compare(Object a, Object b) {
    return (Human)base.get(a).birth - (Human)base.get(b).birth;
  }
}
