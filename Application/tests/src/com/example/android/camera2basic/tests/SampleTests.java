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

import static org.junit.Assert.assertNotNull;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import com.example.android.camera2basic.Camera2BasicFragment;
import com.example.android.camera2basic.CameraActivity;
import com.example.android.camera2basic.R;

import org.junit.Test;
import org.junit.runner.RunWith;

/**
* Tests for Camera2Basic sample.
*/
@RunWith(AndroidJUnit4.class)
public class SampleTests {

    /**
    * Test if the test fixture has been set up correctly.
    */
    @Test
    public void activityCreatesCameraFragmentBeforePermissionGrant() {
        try (ActivityScenario<CameraActivity> scenario =
                     ActivityScenario.launch(CameraActivity.class)) {
            scenario.onActivity(activity -> {
                Camera2BasicFragment fragment = (Camera2BasicFragment)
                        activity.getFragmentManager().findFragmentById(R.id.container);
                assertNotNull("Camera fragment is null", fragment);
            });
        }
    }
}
