package ui.timeline
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectProxy;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	
	import spark.components.VideoDisplay;
	import spark.components.VideoPlayer;
	
	import valueObjects.Intervalle;
	import valueObjects.Media;
	
	[Event(name="currentTimeChange",type="org.osmf.events.TimeEvent")]
	[Event(name="playingStateChange",type="org.osmf.events.TimeEvent")]

	[Bindable]
	public class TimeAndPlayManager extends EventDispatcher
	{
		private var _startTime:Number;
		private var _stopTime:Number;
		private var _currentTime:Number;
		
		private var _timeRange:TimeRange;
		private var _medias:ObjectProxy;
		
		public var theVideoDisplay:VideoDisplay;
		
		private var _isPlaying:Boolean = false;
		private var _isStopped:Boolean = true;
		private var _idMediaPlaying:Number = NaN;
		private var _mediaPlaying:Object = null;
		
		private var _theTimer:Timer = null;
		
		public function TimeAndPlayManager()
		{
			initTimer();
		}
		
		public function get medias():ObjectProxy
		{
			return _medias;
		}

		public function set medias(value:ObjectProxy):void
		{
			if(_medias != value)
			{
				if(_medias)
					_medias.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onMediaListUpdate);
				
				_medias = value;
				_medias.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onMediaListUpdate);
				onMediaListUpdate();
			}
		}
		
		protected function onMediaListUpdate(e:PropertyChangeEvent = null)
		{
			if(isNaN(trySwitchToMedia(_currentTime,_isPlaying)))
				if(_isPlaying)
					_theTimer.start();
		}

		public function get timeRange():TimeRange
		{
			return _timeRange;
		}

		public function set timeRange(value:TimeRange):void
		{
			if(_timeRange != value)
			{
				_timeRange = value;
			
				_timeRange.addEventListener(TimeRange.TIMERANGES_EVENT_CHANGE, onTimeRangeChange);
			}
		}
		
		public function onTimeRangeChange(e:Event):void
		{
			startTime = _timeRange.begin;
			stopTime = _timeRange.end;
		}
		
		[Bindable("playingStateChange")]
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		public function play():void
		{
			if(isNaN(_currentTime))
				currentTime = _startTime;
			
			_isPlaying = true;
			_isStopped = false;
			this.dispatchEvent(new TimeEvent("playingStateChange",false,false,_currentTime));
			
			if(isNaN(_idMediaPlaying))
				_theTimer.start();
			else
				theVideoDisplay.play();			
		}
		
		public function pause():void
		{
			_isPlaying = false;
			this.dispatchEvent(new TimeEvent("playingStateChange",false,false,_currentTime));
			
			if(isNaN(_idMediaPlaying))
				_theTimer.stop();
			else
				theVideoDisplay.pause();
		}
		
		public function stop():void
		{
			_isPlaying = false;
			_isStopped = true;
			this.dispatchEvent(new TimeEvent("playingStateChange",false,false,_currentTime));
			
			if(_theTimer) 
				_theTimer.stop();
			
			if(_startTime)
				currentTime = _startTime;
		}
		
		private function initTimer():void
		{
			_theTimer = new Timer( 1000 );	
			_theTimer.addEventListener(TimerEvent.TIMER, onTimerUpdate );	
		}
		
		private function onTimerUpdate(e:TimerEvent):void
		{
			if(isNaN(_idMediaPlaying))
			{
				currentTime = _currentTime + _theTimer.delay; 
			}

		}
		
		private function trySwitchToMedia(time:Number, autoPlay:Boolean):Number //if we can play a media for the given time, we init it and return its id, else we return NaN 
		{
			//we check if a media should play at the t time
			var arMediaToPlay:Array = getMediaToPlay(time);
			
			if(arMediaToPlay.length > 0) 
			{
				var m:Object = arMediaToPlay[0]; //here we consider only the first media to play, TODO : make it work with multiple concurrent media
				if(!isNaN(_idMediaPlaying) && m.vo.id == _idMediaPlaying)
					theVideoDisplay.seek((time - (m.vo.startDate.time + m.meta.delay) ) / 1000);
				else
					initMedia(m, autoPlay);
				return m.vo.id;
			}
			
			return NaN;
		}
		
		private function initMedia(media:Object, autoplay:Boolean):void
		{
			if(theVideoDisplay.source != media.vo.url)
			{
				theVideoDisplay.source = media.vo.url;
				theVideoDisplay.autoPlay = autoplay;
				_idMediaPlaying = media.vo.id;
				_mediaPlaying = media;
				theVideoDisplay.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onMediaUpdate);
				theVideoDisplay.addEventListener(TimeEvent.COMPLETE, onMediaComplete);
				theVideoDisplay.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaStateChange);
			}
		}
		
		private function unregisterMedia():void
		{
			theVideoDisplay.source = null;
			_idMediaPlaying = NaN;
			_mediaPlaying = null;
			theVideoDisplay.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onMediaUpdate);
			theVideoDisplay.removeEventListener(TimeEvent.COMPLETE, onMediaComplete);
			theVideoDisplay.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaStateChange);
		}
		
		private function onMediaStateChange(e:MediaPlayerStateChangeEvent):void
		{
			trace(e.state);
			//Do something with time
		}
		private function onMediaUpdate(e:TimeEvent):void
		{
			if(theVideoDisplay && theVideoDisplay.source)
			{
				var m:Object = getMediaBySource(theVideoDisplay.source.toString());
				if(m)
				{
					var t:Number = m.vo.startDate.time + m.meta.delay + e.time * 1000;
					if(t>_stopTime || t<_startTime)
						stop();
					else if(!timeRange.isTimeInHole(t))
					{
						_currentTime = t;
						this.dispatchEvent(new TimeEvent("currentTimeChange",false,false,_currentTime));
					}
					else
						currentTime = t; // si le nouveau temps tombe dans un timehole, on fait appelle ou setter de currenttime pour gerer
				}
			}	
			
			//TODO : check timeRanges 
		}
		
		private function onMediaComplete(e:TimeEvent):void
		{
			unregisterMedia();
			_theTimer.start();
		}
		
		private function getMediaToPlay(t:Number):Array
		{
			var arReturn:Array = [];
			for each(var m:Object in _medias)
			{
				if(isTimeInMediaRange(t,m))
					arReturn.push(m);
			}
			return arReturn;
		}
		
		private function isTimeInMediaRange(t:Number, media:Object, considerTimeHoles:Boolean = true):Boolean
		{
			if( media.vo && media.meta
				&& (media.vo.startDate.time + media.meta.delay) < t
				&& (media.vo.startDate.time + media.vo.length + media.meta.delay) > t)
			{
				if(considerTimeHoles)
				{
					return !timeRange.isTimeInHole(t);
				}
				else
					return true;
			}
			else
					return false;
		}
		
		private function getMediaBySource(src:String):Object
		{
			for each(var m:Object in _medias)
			{
				if(m.vo.url == src)
					return m;
			}
			return null;
		}
		
		private function setCurrentTime(t:Number):void
		{

		}

		[Bindable("currentTimeChange")]
		public function get currentTime():Number
		{
			return _currentTime;
		}

		public function set currentTime(t:Number):void
		{
			if(_currentTime != t)
			{
				if(t>=_stopTime || t<_startTime) // on stop si on sort des bornes temporelles
					stop();
				else if(timeRange.isTimeInHole(t)) // on regarde si le nouveau temps ne tombe pas dans un timehole, sinon on passe au timerange suivant
				{
					var numRange:Number = timeRange.getRangeByTime(t);
					if(isNaN(numRange) || numRange >= (timeRange._ranges.length-1) || numRange < 0)
						stop();
					else
						currentTime = timeRange._ranges[numRange+1] + 1;
					
					return;
				}
				else
				{
				 	if(isNaN(trySwitchToMedia(t, _isPlaying)))
					{
						if(!isNaN(_idMediaPlaying))
							unregisterMedia();
						_currentTime = t;
						this.dispatchEvent(new TimeEvent("currentTimeChange",false,false,_currentTime));
					}
				}
			}
		}
		
		[Bindable]
		public function get stopTime():Number
		{
			return _stopTime;
		}
		
		public function set stopTime(t:Number):void
		{
			if(isNaN(_stopTime) || _stopTime != t)
			{
				_stopTime = t;
					
				if(_currentTime > _stopTime)
					stop();
			}
		}

		[Bindable]
		public function get startTime():Number
		{
			return _startTime;
		}
		
		public function set startTime(t:Number):void
		{
			if(isNaN(_startTime) || _startTime != t)
			{
				_startTime = t;
				
				if(!_theTimer)
					initTimer();
				
				if(_isStopped)
					_currentTime = _startTime;	
				else if(_currentTime < _startTime)
					stop();
			}
		}
		

	}
}