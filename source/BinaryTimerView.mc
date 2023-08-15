//
// Copyright 2017-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

//! The main view for the timer application. This displays the
//! remaining time on the countdown timer
(:typecheck(disableBackgroundCheck))
class BinaryTimerView extends WatchUi.View {
	
	var backgroundColor = Application.getApp().getProperty("BackgroundColor");
	var _hourColor = Application.getApp().getProperty("HourColor");
	var _minuteColor = Application.getApp().getProperty("MinuteColor");
	var _secondsColor = Application.getApp().getProperty("SecondsColor");
    var hourColor = _hourColor;
    var minuteColor = _minuteColor;
    var secondsColor = _secondsColor;
    
	
    public var rectangleMode = true;
	
    private enum TimerKeys {
        TIMER_KEY_DURATION,
        TIMER_KEY_START_TIME,
        TIMER_KEY_PAUSE_TIME
    }

    private const TIMER_DURATION_DEFAULT = (5 * 60);    // 5 minutes

    private var _timerDuration as Number;
    private var _timerStartTime as Number?;
    private var _timerPauseTime as Number?;
    private var _updateTimer as Timer.Timer;

    //! Initialize variables for this view
    //! @param backgroundRan Contains background data if background ran
    public function initialize(backgroundRan as PersistableType?) {
    	
    
        View.initialize();

        // Fetch the persisted values from storage
        if (backgroundRan == null) {
        	
            var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
            if (timerDuration instanceof Number) {
                _timerDuration = timerDuration;
                _timerStartTime = null;
                _timerPauseTime = null;
                
            } else {
                _timerDuration = TIMER_DURATION_DEFAULT;
               
            }
            _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
            _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
        } else {
            // If we got an expiration event from the background process
            // when we started up, reset the timer back to the default value.
            _timerDuration = TIMER_DURATION_DEFAULT;
            _timerStartTime = null;
            _timerPauseTime = null;
        }

        // Create our timer object that is used to drive display updates
        _updateTimer = new Timer.Timer();

        // If the timer is running, we need to start the timer up now.
        if ((_timerStartTime != null) && (_timerPauseTime == null)) {
            // Update the display each second.
            _updateTimer.start(method(:requestUpdate), 1000, true);
        }
    }
    
    public function onLayout(dc) {

    }
    
	public function onShow() as Void {
		
		
		var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
        if (timerDuration instanceof Number) {
        	_timerDuration = timerDuration;
            _timerStartTime = null;
            _timerPauseTime = null;
           
        } else {
            _timerDuration = TIMER_DURATION_DEFAULT;
           
        }
        
		_timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
        _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
		

        // Create our timer object that is used to drive display updates
        _updateTimer = new Timer.Timer();

        // If the timer is running, we need to start the timer up now.
        if ((_timerStartTime != null) && (_timerPauseTime == null)) {
            // Update the display each second.
            _updateTimer.start(method(:requestUpdate), 1000, true);
        }
		
	}
		
    //! Draw the time remaining on the timer to the display
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(backgroundColor, backgroundColor);
       	dc.clear();
        
		var clockTime = System.getClockTime();
        var elapsed = 0;
        var timerStartTime = _timerStartTime;
        var timerPauseTime;
        if (timerStartTime != null) {
            timerPauseTime = _timerPauseTime;
            if (timerPauseTime != null) {
                // Draw the time in yellow if the timer is paused
                hourColor = Graphics.COLOR_YELLOW;
                minuteColor = Graphics.COLOR_YELLOW;
                secondsColor = Graphics.COLOR_YELLOW;
                elapsed = timerPauseTime - timerStartTime;
            } else {
                elapsed = Time.now().value() - timerStartTime;
            }

            if (elapsed >= _timerDuration) {
                elapsed = _timerDuration;
                // Draw the time in red if the timer has expired
                hourColor = Graphics.COLOR_RED;
                minuteColor = Graphics.COLOR_RED;
                secondsColor = Graphics.COLOR_RED;
                _timerPauseTime = Time.now().value();
                _updateTimer.stop();
                var toneLength = 120;
                var c = 1047;
                var g = 784;
                var fiss = 740;
                var giss = 831;
                var b = 988;
                var p = 0;

                if (Attention has :ToneProfile) {
    				var toneProfile =
    				[
        				new Attention.ToneProfile(c, toneLength),
        				new Attention.ToneProfile(p, toneLength * 2),
                        new Attention.ToneProfile(g, toneLength),
                        new Attention.ToneProfile(fiss, toneLength),
                        new Attention.ToneProfile(g, toneLength),
                        new Attention.ToneProfile(giss, toneLength*3),
                        new Attention.ToneProfile(g, toneLength * 1),
                        new Attention.ToneProfile(p, toneLength * 5),
                        new Attention.ToneProfile(b, toneLength),
                        new Attention.ToneProfile(p, toneLength*2),
                        new Attention.ToneProfile(c, toneLength)
    				];
    				Attention.playTone({:toneProfile=>toneProfile});
				}
				
				if (Attention has :vibrate) {
                var vibrateData = [
                        new Attention.VibeProfile(25, 100),
                        new Attention.VibeProfile(50, 100),
                        new Attention.VibeProfile(75, 100),
                        new Attention.VibeProfile(100, 100),
                        new Attention.VibeProfile(75, 100),
                        new Attention.VibeProfile(50, 100),
                        new Attention.VibeProfile(25, 100)
                      ];

                Attention.vibrate(vibrateData);
                
                }
            }
        } else {
            timerPauseTime = null;
        }
		
		var clockValue = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
        var timerValue = _timerDuration - elapsed;
		
		
		var finishValue = clockValue + timerValue;
		
        var seconds = timerValue % 60;
        var minutes = timerValue / 60 % 60;
        var hours = timerValue / 3600;
        
        
        dc.setColor(hourColor, Graphics.COLOR_BLACK);
        dc.clear();
        
        var rest_width;
        var rest_height;
        var rectangle_width;
        var rectangle_height;
        //var minY = dc.getHeight()/2 - dc.getFontHeight(mainFont);
       
        
        
        
        rest_width = (dc.getWidth() - 2) % 3;
        if ((dc.getHeight() - 5) % 6 > 4) {
            rest_height = 3;
        } else if ((dc.getHeight() - 5) % 6 > 2) {
            rest_height = 2;
        } else {
            rest_height = 1;
        }
        rectangle_width = (dc.getWidth()-2)/3 + rest_width;
        rectangle_height = (dc.getHeight()-5)/6 + rest_height;
        
        
        hourColor = _hourColor;

        if (timerPauseTime == null) {
            dc.setColor(hourColor, backgroundColor);
        }
        //draw hourrectangles
        for(var x = 0; x < 1; x ++) {
            for(var y = 0; y < 6; y ++)	{
                dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
            }
        }
        
        //show hours
        for(var i = 0; i < 5; i ++) {
            if ( hours / (Math.pow(2,4-i).toLong()) % 2 == 1) {
                dc.fillRectangle(-rest_width, (i+1)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
            }
        }
        
        minuteColor = _minuteColor;

        if (timerPauseTime == null) {
            dc.setColor(minuteColor, backgroundColor);
        }
        
        //draw minuterectangles
        for(var x = 1; x < 2; x ++) {
            for(var y = 0; y < 6; y ++)	{
                dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
            }
        }
        //show minute
        for(var i = 0; i < 6; i ++) {
            if ( minutes / (Math.pow(2,5-i).toLong()) % 2 == 1) {
                dc.fillRectangle(rectangle_width+1-rest_width, (i)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
            }
        }
        
        secondsColor = _secondsColor;

        if (timerPauseTime == null) {
            dc.setColor(secondsColor, backgroundColor);
        }
        //draw seconds rectangles
        for(var x = 2; x < 3; x ++) {
            for(var y = 0; y < 6; y ++)	{
                dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
            }
        }
        
        //show seconds rectangles
        for(var i = 0; i < 6; i ++)	{
            if ( seconds / (Math.pow(2,5-i).toLong()) % 2 == 1)	{
                dc.fillRectangle(2*(rectangle_width+1)-rest_width, (i)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
            }
        }
        
        
        
    }

    
    //! If the timer is running, pause it. Otherwise, start it up.
    public function startStopTimer() as Void {
        var now = Time.now().value();

        var timerStartTime = _timerStartTime;
        if (timerStartTime == null) {
            _timerStartTime = now;
            _updateTimer.start(method(:requestUpdate), 1000, true);
        } else {
            var timerPauseTime = _timerPauseTime;
            if (timerPauseTime == null) {
                _timerPauseTime = now;
                _updateTimer.stop();
                WatchUi.requestUpdate();
            } else {
                if ((timerPauseTime - timerStartTime) < _timerDuration) {
                    _timerStartTime = timerStartTime + (now - timerPauseTime);
                    _timerPauseTime = null;
                    _updateTimer.start(method(:requestUpdate), 1000, true);
                }
            }
        }
    }
    
    public function stopTimer() as Void {
	    _updateTimer.stop();
	    WatchUi.requestUpdate();
        
    }
    

    //! If the timer is paused, then go ahead and reset it back to the default time.
    //! @return true if timer is reset, false otherwise
    public function resetTimer() as Boolean {
        if (_timerPauseTime != null) {
            _timerStartTime = null;
            _timerPauseTime = null;
            Storage.setValue(TIMER_KEY_START_TIME, _timerStartTime);
            Storage.setValue(TIMER_KEY_PAUSE_TIME, _timerPauseTime);
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    //! Save all the persisted values into the object store. This gets
    //! called by the Application base before the application shuts down.
    public function saveProperties() as Void {
        Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
        Storage.setValue(TIMER_KEY_START_TIME, _timerStartTime);
        Storage.setValue(TIMER_KEY_PAUSE_TIME, _timerPauseTime);
    }

    //! Set up a background event to occur when the timer expires. This
    //! will alert the user that the timer has expired even if the
    //! application does not remain open.
    public function setBackgroundEvent() as Void {
        var timerStartTime = _timerStartTime;
        if ((timerStartTime != null) && (_timerPauseTime == null)) {
            var time = new Time.Moment(timerStartTime);
            time = time.add(new Time.Duration(_timerDuration));
            try {
                var info = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                Background.registerForTemporalEvent(time);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
                // We shouldn't get here because our timer is 5 minutes, which
                // matches the minimum background time. If we do get here,
                // then it is not possible to set an event at the time when
                // the timer is going to expire because we ran too recently.
            }
        }
    }

    //! Delete the background event. We can get rid of this event when the
    //! application opens because now we can see exactly when the timer
    //! is going to expire. We will set it again when the application closes.
    public function deleteBackgroundEvent() as Void {
        Background.deleteTemporalEvent();
    }

    //! If we do receive a background event while the application is open,
    //! go ahead and reset to the default timer.
    public function backgroundEvent() as Void {
        _timerDuration = TIMER_DURATION_DEFAULT;
        _timerStartTime = null;
        _timerPauseTime = null;
        WatchUi.requestUpdate();
    }

    //! This is the callback method we use for our timer. It is
    //! only needed to request display updates as the timer counts
    //! down so we see the updated time on the display.
    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }
}