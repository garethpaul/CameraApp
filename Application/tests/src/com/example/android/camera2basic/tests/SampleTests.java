/*
* Copyright 2013 The Android Open Source Project
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/



/*
* Copyright (C) 2013 The Android Open Source Project
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package com.example.android.camera2basic.tests;

import static android.content.pm.PackageManager.PERMISSION_DENIED;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import android.Manifest;
import android.os.SystemClock;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject2;
import androidx.test.uiautomator.Until;

import com.example.android.camera2basic.Camera2BasicFragment;
import com.example.android.camera2basic.CameraActivity;
import com.example.android.camera2basic.R;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.lang.reflect.Field;
import java.util.concurrent.atomic.AtomicBoolean;

/**
* Tests for Camera2Basic sample.
*/
@RunWith(AndroidJUnit4.class)
public class SampleTests {

    private static final long PERMISSION_DIALOG_TIMEOUT_MS = 10_000;
    private static final String DENY_BUTTON_RESOURCE =
            "com.android.permissioncontroller:id/permission_deny_button";

    /**
    * Test pre-permission startup and denial on the pinned hosted API image.
    */
    @Test
    public void activitySurvivesCameraPermissionDenial() throws Exception {
        assertEquals(PERMISSION_DENIED,
                InstrumentationRegistry.getInstrumentation().getTargetContext()
                        .checkSelfPermission(Manifest.permission.CAMERA));

        UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
        try (ActivityScenario<CameraActivity> scenario =
                     ActivityScenario.launch(CameraActivity.class)) {
            assertCameraFragmentExists(scenario);

            UiObject2 denyButton = device.wait(
                    Until.findObject(By.res(DENY_BUTTON_RESOURCE)),
                    PERMISSION_DIALOG_TIMEOUT_MS);
            assertNotNull("Camera permission deny button is unavailable", denyButton);
            waitForPermissionRequestPending(scenario, true);
            denyButton.click();
            waitForPermissionRequestPending(scenario, false);

            assertEquals(PERMISSION_DENIED,
                    InstrumentationRegistry.getInstrumentation().getTargetContext()
                            .checkSelfPermission(Manifest.permission.CAMERA));
            assertCameraFragmentExists(scenario);
        }
    }

    private static void waitForPermissionRequestPending(
            ActivityScenario<CameraActivity> scenario, boolean expected) {
        long deadline = SystemClock.elapsedRealtime() + PERMISSION_DIALOG_TIMEOUT_MS;
        do {
            if (permissionRequestPending(scenario) == expected) {
                return;
            }
            SystemClock.sleep(100);
        } while (SystemClock.elapsedRealtime() < deadline);
        throw new AssertionError("Camera permission request state did not become " + expected);
    }

    private static boolean permissionRequestPending(ActivityScenario<CameraActivity> scenario) {
        AtomicBoolean pending = new AtomicBoolean();
        scenario.onActivity(activity -> {
            Camera2BasicFragment fragment = (Camera2BasicFragment)
                    activity.getFragmentManager().findFragmentById(R.id.container);
            assertNotNull("Camera fragment is null", fragment);
            try {
                Field field = Camera2BasicFragment.class.getDeclaredField(
                        "mCameraPermissionRequestPending");
                field.setAccessible(true);
                pending.set(field.getBoolean(fragment));
            } catch (ReflectiveOperationException exception) {
                throw new AssertionError("Camera permission request state is unavailable", exception);
            }
        });
        return pending.get();
    }

    private static void assertCameraFragmentExists(ActivityScenario<CameraActivity> scenario) {
        scenario.onActivity(activity -> {
            Camera2BasicFragment fragment = (Camera2BasicFragment)
                    activity.getFragmentManager().findFragmentById(R.id.container);
            assertNotNull("Camera fragment is null", fragment);
        });
    }
}
