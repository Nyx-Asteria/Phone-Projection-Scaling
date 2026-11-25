package hmgapi.mods.scaling;

import hmgapi.hook.LoadedApp;
import hmgapi.hook.MethodHook;
import hmgapi.hook.ModContext;
import hmgapi.hook.ModEntry;

public final class ProjectionScaling extends ModEntry {
    @Override public void appLoaded(final ModContext mod, LoadedApp app) {
        if (!"com.google.android.projection".equals(app.packageName)) return;
        final int percent = Scale.percent(mod.settingString("android_auto_scale", "100"));
        if (percent == 100) return;
        mod.hook(app.classLoader, "gpm.video_sink.nearest", new MethodHook() {
            @Override protected void beforeHookedMethod(Param p) {
                if (p.args.length != 6 || !(p.args[2] instanceof Integer)
                        || !(p.args[3] instanceof Integer)) return;
                int density = (Integer) p.args[2];
                int real = (Integer) p.args[3];
                p.args[2] = Scale.density(density, percent);
                p.args[3] = Scale.density(real, percent);
                mod.log("Android Auto density " + density + " -> " + p.args[2]
                        + "; real density " + real + " -> " + p.args[3]);
            }
        });
    }
}
