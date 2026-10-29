package com.indianequipments.neonupdater;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import androidx.core.content.FileProvider;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.UsedByGodot;

public final class NeonAndroidUpdater extends GodotPlugin {
    public NeonAndroidUpdater(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "NeonAndroidUpdater";
    }

    @UsedByGodot
    public boolean installApk(String apkPath) {
        Activity activity = getActivity();
        if (activity == null || apkPath == null || apkPath.trim().isEmpty()) {
            return false;
        }
        File source = new File(apkPath);
        if (!source.isFile() || !source.canRead()) {
            return false;
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                    && !activity.getPackageManager().canRequestPackageInstalls()) {
                Intent settings = new Intent(
                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:" + activity.getPackageName())
                );
                settings.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                activity.startActivity(settings);
                return false;
            }
            File cachedApk = new File(activity.getCacheDir(), "neon-update.apk");
            try (FileInputStream input = new FileInputStream(source);
                 FileOutputStream output = new FileOutputStream(cachedApk, false)) {
                byte[] buffer = new byte[64 * 1024];
                int count;
                while ((count = input.read(buffer)) != -1) {
                    output.write(buffer, 0, count);
                }
                output.flush();
            }
            Uri uri = FileProvider.getUriForFile(
                activity,
                activity.getPackageName() + ".neonupdater.fileprovider",
                cachedApk
            );
            Intent install = new Intent(Intent.ACTION_VIEW);
            install.setDataAndType(uri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(install);
            return true;
        } catch (IOException | RuntimeException error) {
            return false;
        }
    }
}
