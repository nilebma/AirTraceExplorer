/**
 * Copyright Université Lyon 1 / Université Lyon 2 (2009,2010)
 * 
 * <ithaca@liris.cnrs.fr>
 * 
 * This file is part of Visu.
 * 
 * This software is a computer program whose purpose is to provide an
 * enriched videoconference application.
 * 
 * Visu is a free software subjected to a double license.
 * You can redistribute it and/or modify since you respect the terms of either 
 * (at least one of the both license) :
 * - the GNU Lesser General Public License as published by the Free Software Foundation; 
 *   either version 3 of the License, or any later version. 
 * - the CeCILL-C as published by CeCILL; either version 2 of the License, or any later version.
 * 
 * -- GNU LGPL license
 * 
 * Visu is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * Visu is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with Visu.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * -- CeCILL-C license
 * 
 * This software is governed by the CeCILL-C license under French law and
 * abiding by the rules of distribution of free software.  You can  use, 
 * modify and/ or redistribute the software under the terms of the CeCILL-C
 * license as circulated by CEA, CNRS and INRIA at the following URL
 * "http://www.cecill.info". 
 * 
 * As a counterpart to the access to the source code and  rights to copy,
 * modify and redistribute granted by the license, users are provided only
 * with a limited warranty  and the software's author,  the holder of the
 * economic rights,  and the successive licensors  have only  limited
 * liability. 
 * 
 * In this respect, the user's attention is drawn to the risks associated
 * with loading,  using,  modifying and/or developing or reproducing the
 * software by the user in light of its specific status of free software,
 * that may mean  that it is complicated to manipulate,  and  that  also
 * therefore means  that it is reserved for developers  and  experienced
 * professionals having in-depth computer knowledge. Users are therefore
 * encouraged to load and test the software's suitability as regards their
 * requirements in conditions enabling the security of their systems and/or 
 * data to be ensured and,  more generally, to use and operate it in the 
 * same conditions as regards security. 
 * 
 * The fact that you are presently reading this means that you have had
 * knowledge of the CeCILL-C license and that you accept its terms.
 * 
 * -- End of licenses
 */
package ui.trace.timeline
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import com.greensock.*;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import ui.trace.timeline.PlayLineRenders.ControlHead;
	import ui.trace.timeline.PlayLineRenders.ControlHeadForHorizontal;
	import ui.trace.timeline.PlayLineRenders.PlayHeadWithTime;
	import ui.trace.timeline.PlayLineRenders.PlayHeadWithTimeHorizontalTop;

	public class PlayLine extends Canvas
	{
		[Bindable]
		private var _currentTime:Number;
		
		[Bindable]
		private var _startTime:Number;
		
		[Bindable]
		private var _stopTime:Number;
		
		[Bindable]
		private var _direction:String = "vertical"; //or "horizontal"
		
		[Bindable]
		public var model:TimelineModel;
		
		public var RendererType:Class;
		public var renderAlign:String = "middle"; //or "after", "before"
		
		private var theRenderer:DisplayObject;
		private var theContainer:UIComponent;
		
		public var startPadding:Number = 0;
		public var endPadding:Number = 0;
		
		public function PlayLine()
		{
			super();
			this.addEventListener(ResizeEvent.RESIZE,updateRenderer);

			this.verticalScrollPolicy = "off";
			this.horizontalScrollPolicy = "off";
			
		
		}
		

		
		public function get currentTime():Number
		{
			return _currentTime;
		
		}

		public function set currentTime(value:Number):void
		{
 			
			_currentTime = value;
			
			updateRenderer(null);
		}

		public function get stopTime():Number
		{
			return _stopTime;
		}

		public function set stopTime(value:Number):void
		{
			_stopTime = value;
			
			updateRenderer();

		}

		public function get startTime():Number
		{
			return _startTime;
		}

		public function set startTime(value:Number):void
		{
			_startTime = value;

			updateRenderer();
		}
		
		public function get direction():String
		{
			return _direction;
		}
		
		public function set direction(value:String):void
		{
			_direction = value;
			
			updateRenderer();
		}

		
		public function resetRenderer(e:Event = null):void
		{
			deleteRenderer();
			initRenderer();
			updateRenderer();
		}
		
		private function initRenderer():void
		{
			if(RendererType)
			{
				theRenderer = new RendererType();
						
				//Some renderer type may not implement UIComponent (and lead to errors)
				// then we wrap this kind of renderer in a UIComponent
				if(theRenderer is UIComponent)
					theContainer = theRenderer as UIComponent;
				else
				{
					theContainer = new UIComponent();
					theContainer.addChild(theRenderer);
					theContainer.width = theRenderer.width;
					theContainer.height = theRenderer.height;
				}
				
				if(theRenderer is ControlHead)
				{
					(theRenderer as ControlHead).model = model;
					(theRenderer as ControlHead).parentLine = this;
				}

				if(theRenderer is ControlHeadForHorizontal)
				{
					(theRenderer as ControlHeadForHorizontal).model = model;
					(theRenderer as ControlHeadForHorizontal).parentLine = this;
				}
				
				updateRenderer();
			}
		}
		
		
		public function updateRenderer(e:Event = null):void
		{
			if(!_currentTime || !_stopTime || !_startTime)
				return;
			
			if(!theContainer)
				return initRenderer();

			if(theRenderer is PlayHeadWithTime)
				(theRenderer as PlayHeadWithTime).setCurrentTime(currentTime-startTime);
			
			if(theRenderer is PlayHeadWithTimeHorizontalTop)
				(theRenderer as PlayHeadWithTimeHorizontalTop).setCurrentTime(currentTime-startTime);
			
			if(theRenderer is ControlHeadForHorizontal)
				(theRenderer as ControlHeadForHorizontal).setCurrentTime(currentTime-startTime);
						
		
			//we calculate the possible yPosition of the renderer based on its startTime						
			var futurPosition:Number = getPosFromTime(Math.min(currentTime,stopTime));
					
			if(_direction == "vertical")
			{
				if(renderAlign == "middle")
					futurPosition -= theContainer.height/2;	
				
				if(renderAlign == "before")
					futurPosition -= theContainer.height;	
			}
			else
			{
				if(renderAlign == "middle")
					futurPosition -= theContainer.width/2;	
				
				if(renderAlign == "before")
					futurPosition -= theContainer.width;	
			}
			
			//if the renderer has a valid yPosition (basically between the boundaries defined by startTime et StopTime)
			if(!isNaN(futurPosition))
			{
				//we set the its position and add it to the traceLine
				theContainer.visible = true;
				
				if(!this.contains(theContainer))
					this.addChild(theContainer);
				
				TweenMax.killTweensOf(theContainer);
				
				if(_direction == "vertical")
				{
					theContainer.y = futurPosition;
					theContainer.x = 0;
				}
				else
				{
					theContainer.x = futurPosition;
					theContainer.y = 0;
				}
			}
						
	
		}
		
		
		// return the y position (in the timeLine) to match the time t
		//or null if such position does not exist
		public function getPosFromTime(t:Number):Number
		{
			
			//UNDER TEST : we DONT check if t is between the boundaries of the traceLine (startTime et stopTime)
			if(!isNaN(startTime) && !isNaN(_stopTime)) //&& t >= startTime && t <= stopTime)
			{
				var length:Number = _stopTime - _startTime;
				
				var diff:int = t - _startTime;
				
				var size:Number;
				
				if(direction == "vertical")
					size = this.height;
				else
					size = this.width;
				
				size -= (startPadding + endPadding);
				
				//we calculate the pos, we consider "t minus startTime" here in order to replace t in the interval defined by [startTime, stopTime]
				var pos:Number = (size / length) * (diff);
				
				pos += startPadding;	
				
				return pos;
			}
			
			return NaN;
		}
		
		public function getTimeFromPos(pos:Number):Number
		{
			if(!isNaN(_startTime) && !isNaN(_stopTime))
			{
				var length:Number = _stopTime - _startTime;
				
				var size:Number;
				
				if(direction == "vertical")
					size = this.height;
				else
					size = this.width;
				
				size -= (startPadding + endPadding);
				
				var t:Number = ((length / size) * (pos - startPadding)) + _startTime;
				
				return t;
			}
			
			return NaN;
		}
		
		private function deleteRenderer():void
		{
			//we first clear the traceLine
			this.removeAllChildren();
			
			//TODO : delete theRenderer
		}
	}
}
