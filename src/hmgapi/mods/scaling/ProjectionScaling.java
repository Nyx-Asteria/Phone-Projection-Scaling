package hmgapi.mods.scaling;

import hmgapi.hook.LoadedApp;
import hmgapi.hook.MethodHook;
import hmgapi.hook.ModContext;
import hmgapi.hook.ModEntry;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.ByteArrayOutputStream;
import org.json.JSONObject;

public final class ProjectionScaling extends ModEntry {
    private static final String DIPO = "com.daudio.app.dipo";
    private static final String GPM = "com.google.android.projection.sink";
    private static final String CORE = "/system/lib/libCarPlayCore.so";
    private static final String MD5 = "d3a47296437df56fb1ffc7ac3dfca4cb";
    private boolean supportedCore;
    private File scaleFile;

    @Override public void zygoteInit(ModContext mod) {
        supportedCore = MD5.equals(ModContext.md5(CORE));
    }

    @Override public void appLoaded(final ModContext mod, LoadedApp app) {
        if (DIPO.equals(app.packageName)) {
            if (app.context == null || !DIPO.equals(app.processName)) return;
            scaleFile = new File(app.context.getFilesDir(), "pps-scale");
            if (!supportedCore || !mod.enabled()) { clear(mod); return; }
            int percent = Scale.percent(mod.settingString("carplay_scale", "100"));
            if (percent == 100) { clear(mod); return; }
            // CPUL and PPS patch the same /info branch. Never request both.
            if (cpulOwnsInfo(mod)) { clear(mod); return; }
            if (write(mod, percent)) {
                mod.log("Requesting verified CarPlay scaling recipe (" + percent + "%)");
                mod.nativePatch(app, "libCarPlayCore.so");
            }
            return;
        }
        if (!GPM.equals(app.packageName)) return;
        final int percent = Scale.percent(mod.settingString("android_auto_scale", "100"));
        if (percent == 100) return;
        if (managedDensity(mod)) return;
        java.lang.reflect.Member hook = mod.hook(app.classLoader, "gpm.video_sink.nearest", new MethodHook() {
            @Override protected void beforeHookedMethod(Param p) {
                if (p.args.length != 6 || !(p.args[2] instanceof Integer)
                        || !(p.args[3] instanceof Integer)) return;
                int density = (Integer) p.args[2];
                int real = (Integer) p.args[3];
                p.args[2] = Scale.density(density, percent);
                p.args[3] = Scale.density(real, percent);
            }
        });
        mod.log("Android Auto scaling " + percent + "%; hook=" + (hook != null));
    }

    /** Conservative boot-time arbitration using HMG-API's public enabled-mod snapshot.
     * Old CPUL builds also own the branch, but only compatible builds consume PPS settings.
     * Restart after changing either mod's enabled state or scaling settings. */
    private static boolean cpulOwnsInfo(ModContext mod) {
        try {
            FileInputStream in = new FileInputStream("/data/hmgapi/public/state.json");
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            try {
                byte[] buf = new byte[4096]; int n;
                while ((n = in.read(buf)) != -1) {
                    if (out.size() + n > 4 * 1024 * 1024) throw new java.io.IOException("state too large");
                    out.write(buf, 0, n);
                }
            } finally { in.close(); }
            JSONObject mods = new JSONObject(out.toString("UTF-8")).getJSONObject("mods");
            JSONObject cpul = mods.optJSONObject("carplay-ultra-lite-k5");
            if (cpul != null && cpul.optBoolean("enabled", false)) {
                mod.log("CarPlay /info owned by CPUL; standalone recipe withheld; compatible CPUL consumes PPS scale");
                return true;
            }
            return false;
        } catch (Exception e) {
            mod.error("Cannot establish CarPlay native ownership; standalone recipe withheld", e);
            return true;
        }
    }

    // HMG-API owns an explicit absolute density override; never stack a relative override on it.
    private static boolean managedDensity(ModContext mod) {
        try {
            FileInputStream in = new FileInputStream("/data/hmgapi/public/state.json");
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            try {
                byte[] buf = new byte[4096]; int n;
                while ((n = in.read(buf)) != -1) {
                    if (out.size() + n > 4 * 1024 * 1024) throw new java.io.IOException("state too large");
                    out.write(buf, 0, n);
                }
            } finally { in.close(); }
            JSONObject projection = new JSONObject(out.toString("UTF-8")).optJSONObject("projection");
            if (projection != null && projection.optInt("aa_density", 0) > 0) {
                mod.log("Android Auto scaling withheld: HMG-API already manages density");
                return true;
            }
            return false;
        } catch (Exception e) {
            mod.error("Cannot verify density ownership; leaving Android Auto stock", e);
            return true;
        }
    }

    private boolean write(ModContext mod, int percent) {
        File tmp = new File(scaleFile.getParentFile(), "pps-scale.tmp");
        try {
            FileOutputStream out = new FileOutputStream(tmp);
            try { out.write((percent + "\n").getBytes("US-ASCII")); } finally { out.close(); }
            if (!tmp.renameTo(scaleFile)) throw new java.io.IOException("rename failed");
            return true;
        } catch (Exception e) {
            tmp.delete(); clear(mod);
            mod.error("CarPlay scale write failed", e);
            return false;
        }
    }

    private void clear(ModContext mod) {
        if (scaleFile != null && scaleFile.exists() && !scaleFile.delete()) {
            // A loaded native hook treats 100 as stock.
            try {
                FileOutputStream out = new FileOutputStream(scaleFile);
                try { out.write(new byte[]{49,48,48,10}); } finally { out.close(); }
            } catch (Exception e) { mod.error("CarPlay scale reset failed; restart required", e); }
        }
    }

    @Override public void onEnabled(ModContext mod, boolean enabled) {
        if (!enabled) clear(mod);
    }

    @Override public void onSettingsChanged(ModContext mod) {
        if (Scale.percent(mod.settingString("carplay_scale", "100")) == 100) clear(mod);
    }
}
