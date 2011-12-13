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
	import com.greensock.easing.*;
	import com.ithaca.traces.Obsel;
	import com.ithaca.traces.ObselCollection;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.events.ResizeEvent;
	
	import traceSelector.dummyTraceSelector;
	
	import ui.timeline.TimeRange;
	import ui.trace.timeline.TraceLineRenderers.GenericRenderer;
	import ui.trace.timeline.TraceLineRenderers.ITraceRenderer;
	import ui.trace.timeline.events.InternalTimelineEvent;
	import ui.trace.timeline.events.TimelineEvent;

	[Event(name="itemZoomOn" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStartEdit" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStopEdit" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemGotoAndPlay" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="obselClick" , type="ui.trace.timeline.events.TimelineEvent")]
	[Event(name="obselOver" , type="ui.trace.timeline.events.TimelineEvent")]
	
	public class TraceLineBase extends Canvas
	{

		protected var _model:TimelineModel;
		protected var _traceData:ObselCollection;
		protected var _traceFilter:Object;
		public var endTraceFilter:Object;
        public var timeHoleDrawingCanvas:Canvas;
		public var startEndMatchingProperty:String;
		
		[Bindable]
		protected var _startTime:Number;
		
		[Bindable]
		protected var _stopTime:Number;
		
		[Bindable]
		protected var _direction:String = "vertical"; //or "horizontal"
		
		
		public var renderAlign:String = "after"; //or "middle", "before"
		public var deltaPos:Number = 0;
		
		public var startPadding:Number = 0;
		public var endPadding:Number = 0;

        public var isDrawingTimeHoles:Boolean = true;
		
		protected var _timeRange:TimeRange = null;
		
		public var sizedByEnd:Boolean = false;
        
        

		
		protected var filteredTrace:ObselCollection = new ObselCollection();
		
		

		public function TraceLineBase()
		{
			super();
			this.addEventListener(ResizeEvent.RESIZE,invalidateDisplayListOnEvent);
			


			
			this.verticalScrollPolicy = "off";
			this.horizontalScrollPolicy = "off";
			
		}
        
        override protected function createChildren():void 
        {
            super.createChildren();
            
            if(!timeHoleDrawingCanvas)
            {	
                timeHoleDrawingCanvas = new Canvas();
                timeHoleDrawingCanvas.verticalScrollPolicy = "off";
                timeHoleDrawingCanvas.horizontalScrollPolicy = "off";
                timeHoleDrawingCanvas.x = 0;
                timeHoleDrawingCanvas.y = 0;
                
                
                this.addChild(timeHoleDrawingCanvas);
            }
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
                _timeRange.addEventListener(TimeRange.TIMERANGES_EVENT_CHANGE, invalidateDisplayListOnEvent);
                _timeRange.addEventListener(TimeRange.TIMERANGES_EVENT_SHIFT, invalidateDisplayListOnEvent);
                invalidateDisplayList();
            }
		}

		public function get traceFilter():Object
		{
			return _traceFilter;
		}

		public function set traceFilter(value:Object):void
		{
			_traceFilter = value;
			//if(_traceFilter is dummyTraceSelector)
				//(_traceFilter as dummyTraceSelector).a
				
			reset();
		}


        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w,h);
            
            if(_traceData && isDrawingTimeHoles)
            {
                this.timeHoleDrawingCanvas.graphics.clear();
                this.timeHoleDrawingCanvas.height = h;
                this.timeHoleDrawingCanvas.width = w;
                
                drawTimeHoles();
            }
        }
		
		public function invalidateDisplayListOnEvent(e:Event):void
		{
            invalidateDisplayList();
		}
		
		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			_direction = value;
			
			reset();
		}

		public function get stopTime():Number
		{
			return _stopTime;
		}

		public function set stopTime(value:Number):void
		{
			_stopTime = value;
			
            invalidateDisplayList();
			//if(_stopTime != undefined && !isNaN(_stopTime))
				//BindingUtils.bindSetter(timeChanged,this,"stopTime");
		}

		public function get startTime():Number
		{
			return _startTime;
		}

		public function set startTime(value:Number):void
		{
			_startTime = value;
			
			/*if(useRendererFunction)
			{ 
				timeHoleDrawingCanvas.width = this.width + this.getPosFromTime(startTime);
				timeHoleDrawingCanvas.x = - this.getPosFromTime(startTime);
			}
			else*/
            invalidateDisplayList();
			//if(_startTime != undefined && !isNaN(_startTime))
				//BindingUtils.bindSetter(timeChanged,this,"startTime");
		}
		
		
		
		public function timeChanged(n:Number):void
		{
            invalidateDisplayList();
		}


        
		public function get model():TimelineModel
		{
			return _model;
		}

		public function set model(value:TimelineModel):void
		{
			_model = value;
		
		}

        protected function listenObsels(obs:Obsel):void
        {
            obs.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onObselUpdate);
        }
        
        protected function onObselUpdate(e:PropertyChangeEvent):void
        {
            var obs:Obsel = e.currentTarget as Obsel;
            
            if(filteredTrace.contains(obs)) // si l'obsel eté considéré et qu'il est effacé, ou que sa valeur begin ou end evolue
            {
                if(e.kind == PropertyChangeEventKind.DELETE || ( e.kind == PropertyChangeEventKind.UPDATE && (e.property ==  "begin" || e.property == "end")))
                {
                    reset(); //on reinitie l'affichage
                }
            }
            else // si l'obsel n'etait pas affiché
            {
                var filteredOK:Boolean = true;
                if(traceFilter && traceFilter is dummyTraceSelector)
                    filteredOK = (traceFilter as dummyTraceSelector).testObsel(obs);
                else if(traceFilter)
                    filteredOK = filterObsel(obs);
                
                //mais qu'après les changement effectué sur celui-ci il devrait l'etre (filteredOK à true).
                
                if(filteredOK)
                    reset(); //on reinitie l'affichage
            }
            
            
        }

		public function get traceData():ObselCollection
		{
			return _traceData;
		}

		public function set traceData(value:ObselCollection):void
		{
			_traceData = value;
			
            if(_traceData)
            {
                _traceData.addEventListener(CollectionEvent.COLLECTION_CHANGE,onTraceDataCollectionChange);
                for each(var obs:Obsel in _traceData._obsels)
                    listenObsels(obs);
            }

			reset();
		}
		
		public function onTraceDataCollectionChange(e:CollectionEvent):void
		{
			if(e.kind == CollectionEventKind.ADD)
			{
				for each(var item:Obsel in e.items)
                {
                    
                    if(filterObsel(item))
                    {
                        filteredTrace.push(item)    
                        
					    renderObsel(item);
                        listenObsels(item);
                    }
                }
				

			}
			else if
			(e.kind == CollectionEventKind.REFRESH 
			|| e.kind == CollectionEventKind.REMOVE
			|| e.kind == CollectionEventKind.RESET 
			|| e.kind == CollectionEventKind.REPLACE
			)
			{
				reset();
			}
			else //for UPDATE & MOVE
			{
                invalidateDisplayList();
				
			}
		}
		
		public function reset(e:Event = null):void
		{
            filterTrace();
			initDisplay();
            invalidateDisplayList();
			//updateRenderer();
		}
        

        protected function initDisplay():void
        {	
            //to override
            trace("init display "+this.id);
        }
        
        protected function renderObsel(pObs:Obsel):void
        {
            //to override 
        }
        
		
        protected function filterTrace():void
        {
            //for each obsel
            

            filteredTrace.removeAll();

            if(_traceData)
            {
                for(var i:int = 0; i < _traceData.length; i++)
                {
                    var obs:Obsel = _traceData.getItemAt(i) as Obsel;
                    if(filterObsel(obs))
                        filteredTrace.push(obs); //we add the obs to a filteredTrace Collection	
                }
            } 
        }
        
		protected function filterObsel(obs:Obsel, traceFilterToUse:Object = null):Boolean
		{
            if(!obs)
                return false;
            
            if(!traceFilterToUse)
                traceFilterToUse = traceFilter;
            
            if(traceFilterToUse && traceFilterToUse is dummyTraceSelector)
                return (traceFilterToUse as dummyTraceSelector).testObsel(obs);
            else if(traceFilterToUse)
            {
                // Un filtre teste un ou plusieurs attribut avec plusieurs valeurs
                // Cette fonction renvoie vrai si :
                //			- la trace donnée comporte tous les attribut specifiés dans le filtre
                // 			- pour chaque attribut, une des valeurs specifiée dans le filtre 

				for(var filter:String in traceFilterToUse) // pour chaque element du filtre
				{
					var valueFound:Boolean = false;
					var value: String;

					if(obs.hasOwnProperty(filter)) // si l'attribut est présent dans l'objet trace 
					{
						//et si une des valeurs du filtre est associée à cette attribut
						for (value in traceFilterToUse[filter])
						{
							if(obs[filter] == traceFilterToUse[filter][value] )
								valueFound = true;
						}
					}	
						
					if(obs.getAttributeValueByLabel(filter)) // si l'attribut est présent dans l'attribut props de la trace
					{
						//et si une des valeurs du filtre est associée à cette attribut
						for (value in traceFilterToUse[filter])
						{	
							if(obs.getAttributeValueByLabel(filter) == traceFilterToUse[filter][value] ) //on cherche également dans props
								valueFound = true;
						}
					}

				    return valueFound;
				}
			}
			
            //else //si pas de filtre spécifier, alors on accepte tout
                return true;
            
            
		}
		

        
		
		protected function onItemRendererCreationComplete(e:FlexEvent):void
		{
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_RENDERER_CREATION_COMPLETE, e.currentTarget as DisplayObject));
		}
		
		protected function onItemEvent(e:InternalTimelineEvent):void
		{
			this.dispatchEvent(new InternalTimelineEvent(e.type, e.itemRenderer, e.timeStamp, e.callBackFunc));
		}

		
       
		


		public function getEndTrace(oTrace:Object):Obsel
		{
			if(endTraceFilter && oTrace && oTrace.props && oTrace.props[startEndMatchingProperty])
			{
				endTraceFilter[startEndMatchingProperty] = new Array();
				
				if(oTrace.hasOwnProperty(startEndMatchingProperty) && oTrace[startEndMatchingProperty])	
					(endTraceFilter[startEndMatchingProperty] as Array).push(oTrace[startEndMatchingProperty]);
				
				if(oTrace.props[startEndMatchingProperty])	
					(endTraceFilter[startEndMatchingProperty] as Array).push(oTrace.props[startEndMatchingProperty]);
				
				for each(var item:Obsel in _traceData._obsels)
				 	if(filterObsel(item,endTraceFilter))
						return item;
			
			}
			
			return null;
				
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
					
					var pos:Number;
					
					if(timeRange)
						pos = timeRange.timeToPosition(t,size,startTime,stopTime);
					else
						pos = (size / length) * (diff);  //we calculate the pos, we consider "t minus startTime" here in order to replace t in the interval defined by [startTime, stopTime]
					
					
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
                
                var diff:int = t - _startTime;
                
                var size:Number;
                
                if(direction == "vertical")
                    size = this.height;
                else
                    size = this.width;
                
                size -= (startPadding + endPadding);
                
                pos -= startPadding;
                
                
                if(timeRange)
                    return timeRange.positionToTime(pos,size,_startTime,_stopTime);
                else
                {
                    
                    //we calculate the pos, we consider "t plus startTime" here in order to replace t in the interval defined by [startTime, stopTime]
                    var t:Number = ((length / size) * pos) + _startTime;
                    
                    return t;
                }
            }
            
            return NaN;
        }
		

		

		

		
		protected function drawTimeHoles():void
		{
			if(timeRange && _startTime && _stopTime)
			{
				this.timeHoleDrawingCanvas.graphics.beginFill(0xFF0000);
				//this.timeHoleDrawingCanvas.graphics.lineStyle(1);
				
				for each(var th:Array in timeRange.getTimeHoles())
				{
					var posDebut:Number = timeRange.timeToPosition(th[0]-1,this.width,_startTime,_stopTime);
					
					if(!isNaN(posDebut))
					{
						//we draw a crossed rectangle
						if(direction == "vertical")
						{
							this.timeHoleDrawingCanvas.graphics.drawRect(0,posDebut,this.width,timeRange.timeHoleWidth);
							/*this.timeHoleDrawingCanvas.graphics.moveTo(0,posDebut);
							this.timeHoleDrawingCanvas.graphics.lineTo(this.width,posDebut+timeRange.timeHoleWidth);
							this.timeHoleDrawingCanvas.graphics.moveTo(this.width,posDebut);
							this.timeHoleDrawingCanvas.graphics.lineTo(0,posDebut+timeRange.timeHoleWidth);*/
							
						}
						else
						{
							this.timeHoleDrawingCanvas.graphics.drawRect(posDebut,0,timeRange.timeHoleWidth,this.height);
							/*this.timeHoleDrawingCanvas.graphics.moveTo(posDebut,0);
							this.timeHoleDrawingCanvas.graphics.lineTo(posDebut+timeRange.timeHoleWidth,this.height);
							this.timeHoleDrawingCanvas.graphics.moveTo(posDebut,this.height);
							this.timeHoleDrawingCanvas.graphics.lineTo(posDebut+timeRange.timeHoleWidth,0);*/
						}
					}
					else
						;
					
					//this.timeHoleDrawingCanvas.graphics.lineStyle(0);
				}
			
			
			}
		}

		


		
	}
}
