package ui.timeline
{	
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.sampler.NewObjectSample;
	
	import mx.collections.ArrayCollection;
	
	import ui.trace.timeline.events.TimelineEvent;
	
	public class TimeRange extends EventDispatcher
	{		
		static public const TIMERANGES_EVENT_CHANGE 	: String = "timeranges_change";
		static public const TIMERANGES_EVENT_SHIFT 	: String = "timeranges_shift";
		
		public  var _ranges 	: ArrayCollection;
		private var _originalRanges 	: ArrayCollection;
		private var _start		: Number;
		private var _end		: Number;
		private var _duration 	: Number;
		private var _zoom		: Boolean  = false;
		public  var	timeHoleWidth : Number = 10;
		
		public function TimeRange( startValue : Number = 0 , durationValue : Number = 1 ) : void 
		{
			_ranges = new ArrayCollection();	
			_originalRanges = new ArrayCollection();	
	//		addTime(startValue, startValue + durationValue);
		}
		
		public function isEmpty () : Boolean
		{
			return _ranges.length == 0;
		}
		
		public function get numIntervals() 			: Number { return _ranges.length/2; }
		public function get begin() 				: Number { return _start; }
//		public function set begin( value :Number ) 	: void 	 { _ranges[0] = value;  }
		public function get end() 					: Number { return _end; }
//		public function set end( value : Number ) 	: void 	 { _ranges[_ranges.length -1] = value; }
		public function get totalDuration() 		: Number { return end - begin; }	
		public function get duration() 				: Number { return _duration; }	
		
		private function addItem( value : Number, pos : Number = Infinity ) : void
		{
			if ( pos > _ranges.length - 1)
				_ranges.addItem( value );
			else
				_ranges.addItemAt( value, pos );
		}
		
		public function timeToPosition( timeValue : Number, width : Number, localStart:Number = NaN, localEnd:Number = NaN ) : Number
		{
			var position : Number = 0;
			
			if(isNaN(localStart))
				localStart = begin;
			else
				localStart = Math.max(begin, localStart);
			
			if(isNaN(localEnd))
				localStart = end;
			else
				localEnd = Math.min(end, localEnd);
			
			var localDuration:Number = localEnd - localStart;
			
			if ( timeValue <= localStart)
				return NaN;		
			else if ( timeValue >= localEnd )
				return NaN;
			else for ( var i : int = 1; i < _ranges.length; i ++ )
				if ( localStart <= _ranges[i]  )
				{
					var rangeStart : Number = Math.max( localStart, _ranges[i - 1] );
										
					if ( timeValue <= _ranges[i]  )
					{
						if ( i % 2 == 0)
							position += timeHoleWidth;
						else
							position += ( timeValue - rangeStart ) * width / localDuration;
						break;
					}
					else				
					{
						var intervalWidth : Number = (i % 2 == 0) ? timeHoleWidth : ( _ranges[i] - rangeStart) * width / duration;
						position +=  intervalWidth ;				
					}
				}
			return position;
		}
		
		public function positionToTime( positionValue : Number, width : Number ,  localStart:Number = NaN, localEnd:Number = NaN ) : Number
		{
			if(isNaN(localStart))
				localStart = begin;
			else
				localStart = Math.max(begin, localStart);
			
			if(isNaN(localEnd))
				localStart = end;
			else
				localEnd = Math.min(end, localEnd);
			
			var localDuration:Number = localEnd - localStart;
			
			var time : Number = 0;	
			var currentPostion: Number = 0;
			if ( positionValue <= 0 )
				time = localStart;		
			else if ( positionValue >= width )
				time = localEnd;
			else for ( var i : int = 1; i < _ranges.length; i ++ )
				if ( localStart <= _ranges[i]  )
				{
					var rangeStart : Number = Math.max( localStart, _ranges[i - 1] );
					var intervalWidth : Number = (i % 2 == 0) ? timeHoleWidth : ( _ranges[i] - rangeStart) * width / duration;
					if ( positionValue < currentPostion + intervalWidth )
					{						
						time = rangeStart + ( positionValue - currentPostion )  * localDuration / width;
						break;
					}
					else
						currentPostion += intervalWidth;
				}
				
			return time;
		}
		
		public function updateDuration ( ) : void
		{
			_duration = 0;
			
			if(_ranges && _ranges.length > 0)
			{
				for ( var i : int = 0; i < _ranges.length; i += 2 )
					if ( _start <= _ranges[i + 1] && _end >= _ranges[i] )
						_duration += Math.min(_ranges[i + 1], _end) - Math.max( _ranges[i], _start);
			}
			else
				_duration = 0;
			
			if ( _duration == 0)
				trace("duration 0");
		}		
		
		public function addTime ( beginValue : Number , endValue : Number,  fillHole : Boolean = false ) : void
		{				
			var beginIndex 	: Number  	= _ranges.length;
			var endIndex 	: Number 	= _ranges.length;
			
			_originalRanges.addItem( { begin : beginValue, end : endValue } );
			
			for ( var i : int = 0; i < _ranges.length; i++ )
				if ( beginValue <= _ranges[i] )
				{	
					beginIndex = i;
					break;
				}
				
			for ( var j : int  = i; j < _ranges.length; j++ )
				if ( endValue <= _ranges[j] )
				{
					endIndex = j;
					break;
				}
				
			if ( beginIndex == endIndex ) 
			{
				if ( beginIndex % 2 == 0 )  
				{
					if ( !fillHole || _ranges.length == 0)
					{
						addItem(endValue, endIndex);
						addItem(beginValue, beginIndex);
					}				
					else
					{
						if ( beginIndex == _ranges.length )
							_ranges[ _ranges.length - 1 ] = endValue;
						else								
							_ranges[ beginIndex ] = beginValue;
					}
				}
				else 	
					return; // the new interval is in another interval
			} 
			else
			{				
				if ( beginIndex % 2 == 0)	
					_ranges[ beginIndex++ ] = beginValue;						

				if ( endIndex % 2 == 0)					
					_ranges[ --endIndex ] = endValue;						
					
				for ( var toRemove : int = beginIndex; toRemove < endIndex; toRemove++ )
					_ranges.removeItemAt(  beginIndex );
			}		
			
			if ( !_zoom)
				resetLimits();
				
			updateDuration();	
			
			dispatchEvent( new Event( TIMERANGES_EVENT_CHANGE, true )); 	
		}
		
		public function clone( tr : TimeRange ) : void
		{	
			_ranges.removeAll();
			for each( var value : Number in tr._ranges )
				_ranges.addItem( value);			
			_start 	= tr._start;
			_end 	= tr.end;
			_duration = tr.duration;
			dispatchEvent( new Event( TIMERANGES_EVENT_CHANGE, true )); 	
		}
		
		public function makeTimeHole (beginValue : Number , endValue : Number ) : void
		{
			var beginIndex 	: Number  	= _ranges.length;
			var endIndex 	: Number 	= _ranges.length;
			
			for ( var i : int = 0; i < _ranges.length; i++ )
				if ( beginValue <= _ranges[i] )
				{	
					beginIndex = i;
					break;
				}
				
			for ( var j : int  = i; j < _ranges.length; j++ )
				if ( endValue <= _ranges[j] )
				{
					endIndex = j;
					break;
				}
				
			if ( beginIndex == endIndex ) 
			{
				if ( beginIndex % 2 != 0 && beginIndex <  _ranges.length)  
				{
					addItem(endValue, endIndex);
					addItem(beginValue, beginIndex);
				}
				else 	
					return; // the new interval is in another interval
			} 
			else
			{				
				if ( beginIndex % 2 != 0)	
					_ranges[ beginIndex++ ] = beginValue;						

				if ( endIndex % 2 != 0)					
					_ranges[ --endIndex ] = endValue;						
					
				for ( var toRemove : int = beginIndex; toRemove < endIndex; toRemove++ )
					_ranges.removeItemAt(  beginIndex );
			}		
			
			if ( !_zoom)
				resetLimits();
				
			updateDuration();		
			
			dispatchEvent( new Event( TIMERANGES_EVENT_CHANGE, true )); 	
		}
		
		public function changeLimits ( begin : Number , end : Number ) : void
		{			
			_start = begin;
			_end = end;
			_zoom = true ;
			updateDuration();
			
			dispatchEvent( new Event( TIMERANGES_EVENT_CHANGE, true )); 	
		}	
		
		public function shiftLimits ( delta : Number ) : void
		{			
			if(!isNaN(_start) && !isNaN(_end))
			{
				_start 	+= delta;
				_end 	+= delta;
				
				dispatchEvent( new Event( TIMERANGES_EVENT_SHIFT, true )); 	
			}
			
			
		}	
		
		public function resetLimits ( ) : void
		{
			if(_ranges && _ranges.length > 0)
			{
				_start 	= _ranges[ 0 ];
				_end 	= _ranges[ _ranges.length -1 ];
			}
			else
			{
				_start = NaN;
				_end = NaN;
			}
			
			_zoom	= false;
			updateDuration();	
			
			dispatchEvent( new Event( TIMERANGES_EVENT_CHANGE, true )); 		
		}	
		
		
		public function reset ( ) : void
		{
			_ranges.removeAll();
			
			var ranges : ArrayCollection = _originalRanges;
			_originalRanges = new ArrayCollection();
			for (var i : uint = 0; i < ranges.length; i++ )
			{
				var interval : Object = ranges.getItemAt(i);
				addTime( interval.begin, interval.end );
			}
				
			resetLimits( );
		}
		
		
		public function clear ( ) : void
		{
			_ranges.removeAll();
			
			_originalRanges.removeAll();
			
		
			
			resetLimits( );
		}
		
		//Return an array of intervals [begin,end] representing the different timeholes.
		public function getTimeHoles():Array
		{
			var arReturn:Array = [];
			for ( var i : int = 1; i < _ranges.length-1; i+=2 )
			{
				arReturn.push([_ranges[i], _ranges[i+1]]);
			}
			return arReturn;
			
		}
		
		//Return an array of intervals [begin,end] representing the different ranges.
		public function getRanges():Array
		{
			var arReturn:Array = [];
			for ( var i : int = 0; i < _ranges.length-1; i+=2 )
			{
				arReturn.push([_ranges[i], _ranges[i+1]]);
			}
			return arReturn;
			
		}
	}
}
