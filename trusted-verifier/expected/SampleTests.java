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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.Manifest;
import android.os.SystemClock;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.StaleObjectException;
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
    private static final long PERMISSION_DENY_CLICK_DURATION_MS = 100;
    private static final long PERMISSION_DENY_RETRY_WAIT_MS = 1_000;
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

            waitForPermissionRequestPending(scenario, true);
            dismissPermissionDialog(device);
            waitForPermissionDenied(scenario);
            assertFalse("Camera permission request is still pending",
                    permissionRequestPending(scenario));

            assertEquals(PERMISSION_DENIED,
                    InstrumentationRegistry.getInstrumentation().getTargetContext()
                            .checkSelfPermission(Manifest.permission.CAMERA));
            assertCameraFragmentExists(scenario);

            scenario.recreate();
            assertCameraFragmentExists(scenario);
            assertTrue("Camera permission denial was not retained after recreation",
                    cameraPermissionDenied(scenario));
            assertFalse("Camera permission request restarted after recreation",
                    permissionRequestPending(scenario));
            assertNull("Camera permission dialog was shown after activity recreation",
                    device.wait(Until.findObject(By.res(DENY_BUTTON_RESOURCE)),
                            PERMISSION_DIALOG_TIMEOUT_MS));
        }
    }

    private static void dismissPermissionDialog(UiDevice device) {
        long deadline = SystemClock.elapsedRealtime() + PERMISSION_DIALOG_TIMEOUT_MS;
        do {
            UiObject2 denyButton = device.wait(
                    Until.findObject(By.res(DENY_BUTTON_RESOURCE)),
                    PERMISSION_DENY_RETRY_WAIT_MS);
            if (denyButton == null) {
                continue;
            }
            try {
                denyButton.click(PERMISSION_DENY_CLICK_DURATION_MS);
            } catch (StaleObjectException ignored) {
                continue;
            }
            if (device.wait(Until.gone(By.res(DENY_BUTTON_RESOURCE)),
                    PERMISSION_DENY_RETRY_WAIT_MS)) {
                return;
            }
        } while (SystemClock.elapsedRealtime() < deadline);
        throw new AssertionError("Camera permission denial action did not dismiss the dialog");
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
        return fragmentBooleanField(scenario, "mCameraPermissionRequestPending");
    }

    private static void waitForPermissionDenied(ActivityScenario<CameraActivity> scenario) {
        long deadline = SystemClock.elapsedRealtime() + PERMISSION_DIALOG_TIMEOUT_MS;
        do {
            if (cameraPermissionDenied(scenario)) {
                return;
            }
            SystemClock.sleep(100);
        } while (SystemClock.elapsedRealtime() < deadline);
        throw new AssertionError("Camera permission denial callback was not observed");
    }

    private static boolean cameraPermissionDenied(ActivityScenario<CameraActivity> scenario) {
        return fragmentBooleanField(scenario, "mCameraPermissionDenied");
    }

    private static boolean fragmentBooleanField(
            ActivityScenario<CameraActivity> scenario, String fieldName) {
        AtomicBoolean value = new AtomicBoolean();
        scenario.onActivity(activity -> {
            Camera2BasicFragment fragment = (Camera2BasicFragment)
                    activity.getFragmentManager().findFragmentById(R.id.container);
            assertNotNull("Camera fragment is null", fragment);
            try {
                Field field = Camera2BasicFragment.class.getDeclaredField(fieldName);
                field.setAccessible(true);
                value.set(field.getBoolean(fragment));
            } catch (ReflectiveOperationException exception) {
                throw new AssertionError("Camera permission state is unavailable", exception);
            }
        });
        return value.get();
    }

    private static void assertCameraFragmentExists(ActivityScenario<CameraActivity> scenario) {
        scenario.onActivity(activity -> {
            Camera2BasicFragment fragment = (Camera2BasicFragment)
                    activity.getFragmentManager().findFragmentById(R.id.container);
            assertNotNull("Camera fragment is null", fragment);
        });
    }
}
