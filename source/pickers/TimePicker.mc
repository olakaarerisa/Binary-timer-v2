//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;



//! Picker that allows the user to choose a time
class TimePicker extends WatchUi.Picker {
	private enum TimerKeys {
        TIMER_KEY_DURATION,
        TIMER_KEY_START_TIME,
        TIMER_KEY_PAUSE_TIME
    }
    //! Constructor
    hidden var data;
    
    public function initialize() {
    	self.data=data;
        var title = new WatchUi.Text({:text=>$.Rez.Strings.timePickerTitle, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        
        var factories = new[5];

        factories[0] = new NumberFactory(0, 23, 1, {});
        factories[1] = new WatchUi.Text({:text=>":", :font=>Graphics.FONT_MEDIUM, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER, :color=>Graphics.COLOR_WHITE});
        factories[2] = new NumberFactory(0, 59, 1, {});
        factories[3] = new WatchUi.Text({:text=>":", :font=>Graphics.FONT_MEDIUM, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER, :color=>Graphics.COLOR_WHITE});
        factories[4] = new NumberFactory(0, 59, 1, {});

        var defaults = splitStoredTime(factories.size());
        
        
        defaults[0] = factories[0].getIndex(defaults[0].toNumber());
        defaults[2] = factories[2].getIndex(defaults[2].toNumber());
        defaults[4] = factories[4].getIndex(defaults[4].toNumber());
        

        Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
        
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }

    //! Get the stored time in an array
    //! @param factoryCount Number of factories used to make the time
    //! @return Array with the stored time
    function splitStoredTime(arraySize) {
        var storedValue = Storage.getValue(TIMER_KEY_DURATION);
        if (storedValue == null) {
        	storedValue = 3600;
        }
        var defaults = new [arraySize];
        var seconds = storedValue % 60;
		var minutes = (storedValue / 60) % 60;
		var hours = storedValue / 60 /60;
		defaults[0] = hours;
        //defaults[1] = ":";
		defaults[2] = minutes;
        //defaults[3] = ":";
		defaults[4]= seconds;
        return defaults;
    }


}

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends WatchUi.PickerDelegate {
	private enum TimerKeys {
        TIMER_KEY_DURATION,
        TIMER_KEY_START_TIME,
        TIMER_KEY_PAUSE_TIME
    }
    //! Constructor
    public function initialize() {
        PickerDelegate.initialize();
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    function onAccept(values) {
        var time = values[0] *60*60 + values[2]*60 + values[4];
        

		Storage.setValue(TIMER_KEY_DURATION, time);
		System.println(Storage.getValue(TIMER_KEY_DURATION));
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}