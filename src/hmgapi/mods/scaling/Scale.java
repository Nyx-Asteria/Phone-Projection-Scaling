package hmgapi.mods.scaling;

public final class Scale {
    private Scale() {}
    public static int percent(String value) {
        try {
            int n = Integer.parseInt(value);
            return n >= 75 && n <= 125 && n % 5 == 0 ? n : 100;
        } catch (NumberFormatException e) {
            return 100;
        }
    }
    public static int density(int original, int percent) {
        if (percent == 100 || original <= 0) return original;
        return (int) Math.max(60L, Math.min(480L, (original * (long) percent + 50) / 100));
    }
}
