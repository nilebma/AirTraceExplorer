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
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.events.ResizeEvent;
	import mx.graphics.BitmapSmoothingQuality;
	import mx.utils.ColorUtil;
	
	import spark.components.Group;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	import traceSelector.dummyTraceSelector;
	
	import ui.timeline.TimeRange;
	import ui.trace.timeline.TraceLineRenderers.GenericRenderer;
	import ui.trace.timeline.TraceLineRenderers.ITraceRenderer;
	import ui.trace.timeline.events.InternalTimelineEvent;
	import ui.trace.timeline.events.TimelineEvent;
	
	public class TraceLineBitmap extends TraceLineBase
	{

		
		
		

		private var bitmapData:BitmapData;
		private var bitmapImage:BitmapImage;
		private var bitmapImageWrapper:Group;
		public var rendererFunctionParams:Object = null;
		public var rendererFunctionData:Object = null;
		private var currentTT:ObselPreviewer;

        
        private var timeGen:Number = 0;
        private var timeInteraction:Number = 0;
        private var timeDrawing:Number = 0;
        private var timeSetting:Number = 0;
        private var timeRetrievingParam:Number = 0;
        private var timeTesting:Number = 0;
        
		


		
		
		public function TraceLineBitmap()
		{
			super();

            
            this.addEventListener(MouseEvent.CLICK,onMouseClick);	
            
			// for obselpreviewer
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			
			bitmapImage = new BitmapImage();
			bitmapImage.x=0;
			bitmapImage.y = 0;
			bitmapImage.width = 8000;
			bitmapImage.height = this.height;
			bitmapImageWrapper = new Group();
			bitmapImageWrapper.x = 0;
			bitmapImageWrapper.y = 0;
			bitmapImageWrapper.width = this.width;
			bitmapImageWrapper.height = this.height;
            bitmapImageWrapper.clipAndEnableScrolling = true;
			bitmapImageWrapper.addElement(bitmapImage);
			this.addChild(bitmapImageWrapper);
			
		}
		


		override public function set timeRange(value:TimeRange):void
		{
            super.timeRange = value;
            
            if(_timeRange != value)
                  reset();
		}

		
		//This function instantiate the renderers considering on traceData and traceFilter
		override protected function initDisplay():void
		{	
            super.initDisplay();
            if(filteredTrace)
				constructBitmapData();
            
            invalidateDisplayList();
		}
        
        override public function onTraceDataCollectionChange(e:CollectionEvent):void
        {
            if(e.kind == CollectionEventKind.ADD)
            {
                var d1:Number = new Date().time;
                var timeFiltering:Number = 0;
                var timeRendering:Number = 0;
                var timeListening:Number = 0;
                var timeSorting:Number = 0;
                var newFilteredObsels:ObselCollection = new ObselCollection();
                for each(var item:Obsel in e.items)
                {
                    var df:Number = new Date().time;
                    if(filterObsel(item))
                    {
                        newFilteredObsels.push(item);
                        timeFiltering += new Date().time - df;
                        

                        
                        var dl:Number = new Date().time;
                        listenObsels(item);
                        timeListening += new Date().time - dl;
                        
                    }
                    else
                        timeFiltering += new Date().time - df;
                    
                   
                }
                
                var ds:Number = new Date().time;
                newFilteredObsels.sortByBegin();
                filteredTrace.pushFromOtherObselCollection(newFilteredObsels._obsels);
                timeSorting += new Date().time - ds;
                
                var dr:Number = new Date().time;
                renderMultipleObsels(newFilteredObsels);
                timeRendering += new Date().time - dr;
                
                var timeGen:Number = new Date().time - d1;
                //trace(id, "Adding", e.items.length, "obsels", "nbRendering", nbRendering, "time", timeGen);
                //trace("rendering",timeRendering,"listening",timeListening,"filtering",timeFiltering,"other",timeGen - timeFiltering - timeListening - timeRendering);
                if(this is TraceLineBitmap)
                    (this as TraceLineBitmap).traceRenderTime();
            }
            else
                super.onTraceDataCollectionChange(e);
        }
		
		private function constructBitmapData():void
		{
			bitmapData = new BitmapData(8000,1,true,0x00000000);

			renderingFunctionReset();

            bitmapImage.smooth = true;
            bitmapImage.clearOnLoad = true;
            
			if(timeRange)
            {
			
			    for each(var obs:Obsel in filteredTrace._obsels)
				    if((obs.begin >= timeRange.begin && obs.begin <= timeRange.end)
                        || (obs.end >= timeRange.begin && obs.end <= timeRange.end))
					    renderObsel(obs);
            }

           bitmapImage.source = bitmapData;
           bitmapImage.smooth = true;
           
           //trace(id,"nbConstruct", nbConstruct++, "nbRendering",nbRendering);
		}
		

		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);

			if(_traceData && timeRange)
			{

		
				var beginX:Number = timeRange.timeToPosition(_startTime,8000);
				var endX:Number = timeRange.timeToPosition(_stopTime,8000);
					
                var coeff:Number = this.width / (endX - beginX);
				bitmapImage.width = 8000 * coeff;
				bitmapImage.x = -beginX * coeff;
                bitmapImage.y = - 10;
                bitmapImage.height = this.height + 10;
				bitmapImageWrapper.x = 0;
				bitmapImageWrapper.y = 0;
				bitmapImageWrapper.width = this.width;
				bitmapImageWrapper.height = this.height; 
				
				//renderingFunctionReset();
				

				
				/*for each(var obs:Obsel in filteredTrace._obsels)
					if(obs.begin >= _startTime && obs.begin <= _stopTime
						|| obs.end >= _startTime && obs.end <= _stopTime)
									renderingFunctionOnBitmap(obs);*/
				
				if(timeRange)
					drawTimeHoles();
			}					

			
			
			
		}
		

		
	
		

		

		

		
		public function renderingFunctionReset():void
		{
			rendererFunctionData = new Object();
			rendererFunctionData["obsAndRect"] = new ArrayCollection();
			
		}
		

		
		/*public function renderingFunction(obs:Obsel):void
		{
			//If the obsel is (event partly) in the time window to display
			if(!isNaN(getPosFromTime(Number(obs["begin"]))) || !isNaN(getPosFromTime(Number(obs["end"]))))
			{
				//We deal with renderinfFunctionParams Object
				var bgColor:uint = 0x00FF00;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("color"))
					bgColor = rendererFunctionParams["color"];
				
				var minSize:Number = 1;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("minSize"))
					minSize = rendererFunctionParams["minSize"];
				
				var bgAlpha:Number = 1;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("alpha"))
					bgAlpha = rendererFunctionParams["alpha"];				
				
				//We set the values we will use to draw
				var posDebut:Number = getPosFromTime(Number(obs["begin"]));
				if(isNaN(posDebut)) //if the begin of the obsel is not in the time window to displau
					posDebut = 0;
				
				var size:Number;
				if(!isNaN(getPosFromTime(Number(obs["end"]))))
					size = getPosFromTime(Number(obs["end"])) - posDebut;
				else
					size = this.width;
				
				size = Math.max(1,minSize);
				posDebut -= size/2;
				
				//we draw
				if(!isNaN(posDebut) && !isNaN(size))
				{
					this.rendererFunctionCanvas.graphics.beginFill(bgColor,bgAlpha);
					//this.rendererFunctionCanvas.graphics.lineStyle(null);
					if(direction == "vertical")
						this.rendererFunctionCanvas.graphics.drawRect(0,posDebut,this.width,size);
					else
						this.rendererFunctionCanvas.graphics.drawRect(posDebut,0,size,this.height);
				}	
				
				//we save the rectange coordinates and map it with the obsel (useful for mouse interaction amongst other things)
				var theRect:Rectangle;
				if(direction == "vertical")
					theRect = new Rectangle(0,posDebut,this.width,size);
				else
					theRect = new Rectangle(posDebut,0,size,this.height);
				
				(rendererFunctionData["obsAndRect"] as ArrayCollection).addItem({"obs":obs,"rect":theRect});
			}
		}*/
        
        public function traceRenderTime():void
        {
            trace("timeGen",timeGen,"timeInteraction", timeInteraction,
                "timeDrawing", timeDrawing, "timeSetting", timeSetting,
                "timeRetrievingParam", timeRetrievingParam,
                "other", timeGen - timeInteraction - timeDrawing - timeSetting - timeRetrievingParam - timeTesting);
        }
		
        override protected function renderObsel(obs:Obsel):void
		{
            var dg:Number = new Date().time;            
			//If the obsel is (event partly) in the time window to display
			//if(!isNaN(getPosFromTime(Number(obs["begin"]))) || !isNaN(getPosFromTime(Number(obs["end"]))))
			//{
                
                //We deal with renderinfFunctionParams Object
                var drp:Number = new Date().time;
				
				var bgColor:uint = 0x00FF00;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("color"))
					bgColor = rendererFunctionParams["color"];
				
				var minSize:Number = 8;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("minSize"))
					minSize = rendererFunctionParams["minSize"];
				
				var bgAlpha:Number = 1;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("alpha"))
					bgAlpha = rendererFunctionParams["alpha"];
                
                timeRetrievingParam += new Date().time - drp;
                
                var argb:uint = returnARGB(bgColor, bgAlpha);
				
                
                
                //We set the values we will use to draw
                var ds:Number = new Date().time;
				
				var posDebut:Number = timeRange.timeToPosition(Number(obs["begin"]),8000);
                
                var abort:Boolean = false;
				
				if(isNaN(posDebut) || posDebut < 0) //if the begin of the obsel is not in the time window to displau
                    abort = true;
				
				var size:Number = timeRange.timeToPosition(Number(obs["end"]),8000) 
				if(!isNaN(size))
					size -= posDebut;
				else
				    abort = true;
                    //size = this.width;
				
				size = Math.max(size,minSize);
				//posDebut -= size/2;
                
                timeSetting += new Date().time - ds;
                
                if(abort)
                {
                    timeGen += new Date().time - dg;
                    return;
                }
				
               // bitmapData.fillRect(new Rectangle(posDebut,0,size,this.height),argb);
                
                
                
				//we draw
                renderDrawingObsel(posDebut, size, obs, argb, bgAlpha);
				
                renderHandlingInteraction(posDebut, size, obs);
                
                //nbRendering++;
			
            
            timeGen += new Date().time - dg;
            

		}
        
        
        protected function renderMultipleObsels(obsCol:ObselCollection):void
        {
            var dg:Number = new Date().time;            
            //If the obsel is (event partly) in the time window to display
            //if(!isNaN(getPosFromTime(Number(obs["begin"]))) || !isNaN(getPosFromTime(Number(obs["end"]))))
            //{
            
            //We deal with renderinfFunctionParams Object
            var drp:Number = new Date().time;
            
            var bgColor:uint = 0x00FF00;
            if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("color"))
                bgColor = rendererFunctionParams["color"];
            
            var minSize:Number = 8;
            if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("minSize"))
                minSize = rendererFunctionParams["minSize"];
            
            var bgAlpha:Number = 1;
            if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("alpha"))
                bgAlpha = rendererFunctionParams["alpha"];
            
            timeRetrievingParam += new Date().time - drp;
            
            
            var ds:Number = new Date().time;
            var argb:uint = returnARGB(bgColor, bgAlpha);
            
            
            //We get the measure of the timeRanges
            var localDuration:Number = timeRange.getDurationMinusTimeHoles(timeRange.begin, timeRange.end);
            var timeRangesInfo:Array = timeRange.getRangesWithPositions(8000);
            var coeff:Number = 8000 / localDuration;
            
            var obsColWithPos:Dictionary = new Dictionary();
            
            var iRange:int = 0;
            for each(var obs:Obsel in obsCol._obsels)
            {
                if(obs.begin > timeRangesInfo[iRange+1]["begin"] && iRange+3 < timeRangesInfo.length )
                {
                    trace("to");
                    iRange += 2;
                }
                obsColWithPos[obs] = {};
                var pb:Number = (timeRangesInfo[iRange]["posBegin"]) + (( obs.begin - timeRangesInfo[iRange]["begin"] ) * coeff);
                obsColWithPos[obs]["posBegin"] = pb;
            }
            
            obsCol.sortByEnd()
            iRange = 0;
            for each(var obs:Obsel in obsCol._obsels)
            {
                if(obs.end > timeRangesInfo[iRange+1]["begin"] && iRange+3 < timeRangesInfo.length )
                    iRange += 2;
                
                obsColWithPos[obs]["posEnd"] = (timeRangesInfo[iRange]["posBegin"]) + (( obs.end - timeRangesInfo[iRange]["begin"] ) * coeff);
            }
            
            timeSetting += new Date().time - ds;
            
        
            for(var theObsel:Object in obsColWithPos)
            {
                var oPos:Object = obsColWithPos[theObsel]
                var posDebut:Number = oPos["posBegin"];
                var size:Number = oPos["posEnd"] - posDebut;
                
                size = Math.max(size, minSize);
                
                renderDrawingObsel(posDebut, size, theObsel as Obsel, argb, bgAlpha);
                                
                renderHandlingInteraction(posDebut, size, theObsel as Obsel);
                
                //nbRendering++;
            }
            
        
            
            
            

            


            
            
            
            timeGen += new Date().time - dg;
            
            
        }
        
        private function renderDrawingObsel(posDebut:Number, size:Number, obs:Obsel, argb:uint, bgAlpha:Number):void
        {
            var dr:Number = new Date().time;
            if(!isNaN(posDebut) && !isNaN(size))
            {
                for(var i:int = posDebut; i < Math.min(posDebut+size,8000); i++)
                {
                    var currentColor:uint = bitmapData.getPixel32(i,0);
                    if(currentColor == 0x00000000)
                        bitmapData.setPixel32(i,0,argb);
                    else
                    {
                        var newColor:uint = addAtoARGB(currentColor,bgAlpha);
                        bitmapData.setPixel32(i,0,newColor);
                    }
                    
                    //bitmapData.setPixel(i,0,argb);
                }
                
            }	
            
            timeDrawing += new Date().time - dr;
        }
        
        private function renderHandlingInteraction(posDebut:Number, size:Number, obs:Obsel):void
        {
            var di:Number = new Date().time;
            //we save the rectange coordinates and map it with the obsel (useful for mouse interaction amongst other things)
            var theRect:Rectangle;		
            if(direction == "vertical")
                theRect = new Rectangle(0,posDebut,this.width,size);
            else
                theRect = new Rectangle(posDebut,0,size,this.height);
            
            (rendererFunctionData["obsAndRect"] as ArrayCollection).addItem({"obs":obs,"rect":theRect});
            
            timeInteraction += new Date().time - di;
        }
        
		
		
        private function returnARGB(rgb:uint, newAlpha:Number):uint{
            //newAlpha has to be in the 0 to 255 range
            var argb:uint = 0;
            var newAlphaHexa:uint = newAlpha * 0xFF;
            argb += (newAlphaHexa<<24);
            argb += (rgb);
            return argb;
        }
        
        private function addAtoARGB(argb:uint, addAlpha:Number):uint{
            //newAlpha has to be in the 0 to 255 range
            var a:uint = argb >> 24 & 0xFF;
            var r:uint = argb >> 16 & 0xFF;
            var g:uint = argb >> 8 & 0xFF;
            var b:uint = argb & 0xFF;
            var addAlphaHexa:uint = addAlpha * 0xFF;
            a = Math.min (a + addAlphaHexa, 0xFF);
            return a << 24 | r <<16 | g <<8 | b;
        }
        
        /*public static function colorSum (col1: uint, col2: uint): uint
        {
            var c1: Array = toRGB (col1);
            var c2: Array = toRGB (col2);
            var r: uint = Math.min (c1 [0] + c2 [0], 255);
            var g: uint = Math.min (c1 [1] + c2 [1], 255);
            var b: uint = Math.min (c1 [2] + c2 [2], 255);
            return r <<16 | g <<8 | b;
        }
        
        public static function toARGB( argb:uint ):Array
        {
            var a:uint = argb >> 24 & 0xFF;
            var r:uint = argb >> 16 & 0xFF;
            var g:uint = argb >> 8 & 0xFF;
            var b:uint = argb & 0xFF;
            return [a,r,g,b];
        }*/
		
		public function renderingFunctionGetObselFromPos(p:Point):Array
		{
			var result:Array= new Array();
			
			if(rendererFunctionData && rendererFunctionData["obsAndRect"])
			{
                var coeff = 8000 / bitmapImage.width;
                var gx:Number = (p.x - bitmapImage.x)*coeff;
                var gy:Number = 1;

				for each(var or:Object in rendererFunctionData["obsAndRect"])
					if((or["rect"] as Rectangle).contains(gx, gy))
						result.push(or["obs"]);
			}
			
			return result;
		}

		protected function onMouseClick(e:MouseEvent):void
		{
			var tle:TimelineEvent = new TimelineEvent(TimelineEvent.OBSEL_CLICK);
			tle.obselSet = renderingFunctionGetObselFromPos(new Point(e.localX,e.localY));
			this.dispatchEvent(tle);
		}
		
		/**
		 * Mouse over associé aux tooltips 
		 * @param e
		 * 
		 */
		protected function onMouseOver(e:MouseEvent):void
		{
			var obselset:Array = renderingFunctionGetObselFromPos(new Point(e.localX,e.localY));
			if(obselset && obselset.length>0){
				if(currentTT){
					mx.core.FlexGlobals.topLevelApplication.removeElement(currentTT);
					currentTT = null;
				}
				//currentTT = ToolTipManager.createToolTip("Il y a "+ obselset.length +" Obsels", e.stageX+5, e.stageY) as CustomToolTip;
				var obsPreview:ObselPreviewer = new ObselPreviewer;
				if(mx.core.FlexGlobals.topLevelApplication.width/2 < e.stageX)
					obsPreview.x = e.stageX-270;
				else obsPreview.x = e.stageX;
				obsPreview.y = e.stageY;
				obsPreview.data = obselset;
				
				mx.core.FlexGlobals.topLevelApplication.addElement(obsPreview);
				currentTT = obsPreview;
			}
			
		}
		
		/**
		 * Mouse out associé aux tooltips 
		 * @param e
		 * 
		 */
		protected function onMouseOut(e:MouseEvent):void
		{
			if(currentTT){
				mx.core.FlexGlobals.topLevelApplication.removeElement(currentTT);
				currentTT = null;
			}
		}
		
	}
}
