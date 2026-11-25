import hmgapi.mods.scaling.Scale;
public final class ScaleTest {
    public static void main(String[] args) {
        for (int p = 50; p <= 100; p += 5) {
            if (Scale.percent(Integer.toString(p)) != p || Scale.density(240,p) != 240*p/100)
                throw new AssertionError(p);
        }
        for (String s : new String[]{"49","51","101","105","125","bad","",null})
            if (Scale.percent(s) != 100) throw new AssertionError(s);
        if (Scale.density(0,75)!=0 || Scale.density(500,100)!=500 ||
            Scale.density(60,75)!=60 || Scale.density(480,50)!=240)
            throw new AssertionError("density limits");
    }
}
