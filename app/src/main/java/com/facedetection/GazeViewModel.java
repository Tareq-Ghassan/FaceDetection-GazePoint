package com.facedetection;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;


public class GazeViewModel extends ViewModel {
    private MutableLiveData<String> gazePointLiveData = new MutableLiveData<>();

    public void setGazePoint(String gazePoint) {
        gazePointLiveData.setValue(gazePoint);
    }

    public LiveData<String> getGazePoint() {
        return gazePointLiveData;
    }
}


