package com.facedetection;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

/**
 * ViewModel class for storing and providing access to gaze point data.
 */
public class GazeViewModel extends ViewModel {
    private MutableLiveData<String> gazePointLiveData = new MutableLiveData<>();

    /**
     * Sets the current gaze point data.
     *
     * @param gazePoint The gaze point data to set.
     */
    public void setGazePoint(String gazePoint) {
        gazePointLiveData.setValue(gazePoint);
    }

    /**
     * Retrieves the LiveData containing the current gaze point data.
     *
     * @return LiveData for observing gaze point changes.
     */
    public LiveData<String> getGazePoint() {
        return gazePointLiveData;
    }
}


