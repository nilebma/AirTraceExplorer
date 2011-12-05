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
	import mx.events.ResizeEvent;
	
	import traceSelector.dummyTraceSelector;
	
	import ui.timeline.TimeRange;
	import ui.trace.timeline.TraceLineRenderers.GenericRenderer;
	import ui.trace.timeline.TraceLineRenderers.ITraceRenderer;
	import ui.trace.timeline.events.InternalTimelineEvent;
	import ui.trace.timeline.events.TimelineEvent;

	[Event(name="itemRendererCreated" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemRendererCreationComplete" , type="ui.trace.timeline.events.InternalTimelineEvent")]

	
	public class TraceLineWithRenderers extends TraceLineBase
	{

		public var RendererType:Class;

		
		protected var aRenderer:Array = new Array();
		
        
		//these properties are only useful with GenrericRenderer as itemRendererType
		public var iconClassForGenericRenderer:Class;
		public var dataFieldForGenericRenderer:String;
		
		//these properties are here in order handle superposition
		
		
		public function TraceLineWithRenderers()
		{
			super();

			
		}

        
        override public function set model(value:TimelineModel):void
        {
            _model = value;
            
            //TO FIX, le binding devrait suffir
            for(var i:int; i < aRenderer.length; i++)
            {
                if(aRenderer[i]["renderer"] is ITraceRenderer)
                    (aRenderer[i]["renderer"] as ITraceRenderer).model = _model;
            }
            
            _model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, invalidateDisplayListOnEvent);
            
            if(aRenderer.length == 0)
                reset();			
        }
        
        override protected function initDisplay():void
        {	
            //to override
            if(!filteredTrace)// || !_model)
                return;
            
            //for each trace
            for(var i:int; i < filteredTrace.length; i++)
            {
                var obs:Obsel = filteredTrace.getItemAt(i) as Obsel;
                renderObsel(obs);
            }
            
            invalidateDisplayList();
        }


		
        override protected function renderObsel(pObs:Obsel):void
		{

							
				//if the filter is passed, we create a renderer for the trace
				
				var newRenderer:DisplayObject = new RendererType();
				var newContainer:UIComponent;
				
				//Some renderer type may not implement UIComponent (and lead to errors)
				// then we wrap this kind of renderer in a UIComponent
				if(newRenderer is UIComponent)
					newContainer = newRenderer as UIComponent;
				else
				{
					newContainer = new UIComponent();
					newContainer.width = newRenderer.width;
					newContainer.height = newRenderer.height;
				}
				
				// we look for an endTrace
				var endTrace:Obsel = getEndTrace(pObs); //endTrace is null is no endTrace is found
				
				
				//Some renderer may implement the ITraceRenderer interface
				if(newRenderer is ITraceRenderer)
				{
					//we set the traceData
					(newRenderer as ITraceRenderer).traceData = pObs;
					
					if(endTrace)
						(newRenderer as ITraceRenderer).endTraceData = endTrace;
					
					//we set the parent line (this)
					(newRenderer as ITraceRenderer).parentLine = this;
					
					//we set the parent visuData
					(newRenderer as ITraceRenderer).model = _model;
					
					(newRenderer as ITraceRenderer).direction = direction;
					
				}
				
				if(newRenderer is GenericRenderer)
				{
					if(iconClassForGenericRenderer)
						(newRenderer as GenericRenderer).iconClass = iconClassForGenericRenderer;
					
					if(dataFieldForGenericRenderer)
						(newRenderer as GenericRenderer).dataField = dataFieldForGenericRenderer;
				}
				
				
				if(newRenderer is UIComponent)
				{
					this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_RENDERER_CREATED, newRenderer));
					
					(newRenderer as UIComponent).addEventListener(FlexEvent.CREATION_COMPLETE, onItemRendererCreationComplete);
					newRenderer.addEventListener(InternalTimelineEvent.ITEM_ZOOM_ON, onItemEvent);
					newRenderer.addEventListener(InternalTimelineEvent.ITEM_EDIT_START, onItemEvent);
					newRenderer.addEventListener(InternalTimelineEvent.ITEM_EDIT_STOP, onItemEvent);
					newRenderer.addEventListener(InternalTimelineEvent.ITEM_GOTO_AND_PLAY, onItemEvent);
				}
				//the renderers are saved in the aRenderer array
				aRenderer.push({"renderer":newRenderer,"container":newContainer,"traceData":pObs,"endTraceData":endTrace});
			
				sortRendererArray();
				//the position and others appareance settings will be set in updateRenderer function

		}
		

		public function getPreviosRendererPoint(value:Obsel):Point
		{
			var nbrRenderer:uint =  aRenderer.length;
			if(nbrRenderer == 0) return new Point(0,0);
			if( nbrRenderer > 1 )
			{
			  for (var nRenderer:uint = 1; nRenderer < nbrRenderer; nRenderer++ )
			  {
				var obsel:Obsel = aRenderer[nRenderer]["traceData"] as Obsel;
				if(obsel == value)
				{
					var renderer:UIComponent = aRenderer[nRenderer-1]["container"] as UIComponent;
					return new Point(renderer.x,renderer.y);
				};
			  }
			  return new Point(aRenderer[0]["container"].x,aRenderer[0]["container"].y);
			}else return new Point(aRenderer[0]["container"].x,aRenderer[0]["container"].y);
		}

		public function getFirstObsel():Obsel
		{
			if(aRenderer.length > 0 )
			{
				var obsel:Obsel = aRenderer[0]["traceData"] as Obsel;
				if(obsel != null)
				{
					return obsel;
				}else return null;
			}else return null;
		}
		

		
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			var zPosition:int = 0;
			

			
			
				
				//we run trhough the aRenderer Array that hold our renderers object
				for(var i:int = 0; i < aRenderer.length; i++)
				{
					//we gather the renderer (or the container of the renderer) and the trace related to the renderer
					var renderer:UIComponent = aRenderer[i]["container"] as UIComponent;
					var rendererTraceData:Object = aRenderer[i]["traceData"];
					
					if(renderer && rendererTraceData["begin"] && this.width)
					{
						if(renderer is ITraceRenderer)
							(renderer as ITraceRenderer).update();
						
						var futurSize:Number;
						
						
						//////////////////////// SIZING //////////////////////////////////////////////////////////
						
						//if the renderer is not a ITraceRenderer or if it is an ITraceRanderer but not selfsized
						if( !(renderer is ITraceRenderer) || ((renderer as ITraceRenderer).selfSized == false) )
						{
							
							//if the rendererContainer has no size we set a default one
							if(renderer.width == 0)
								renderer.width = (direction == "vertical") ? this.width : this.height;
							
							if(renderer.height == 0)
								renderer.height = (direction == "vertical") ? this.width : this.height;
							
							
							//We consider the futurSize of the renderer	
							
							if(direction == "vertical")
								futurSize = renderer.height;
							else
								futurSize = renderer.width;
	
							
							//If the renderer is sized by a traceEnd
							var endTrace:Obsel = aRenderer[i]["endTraceData"];
							
							if(sizedByEnd && endTrace)
							{
								if(direction == "vertical")
								{
									renderer.scaleY = 1;
									if(!isNaN(getPosFromTime(Number(endTrace["begin"]))) && !isNaN(getPosFromTime(Number(rendererTraceData["begin"]))))
										futurSize = getPosFromTime(Number(endTrace["begin"])) - getPosFromTime(Number(rendererTraceData["begin"]));
									else
										futurSize = 0;
								}
								else
								{
									renderer.scaleX = 1;
									if(!isNaN(getPosFromTime(Number(endTrace["begin"]))) && !isNaN(getPosFromTime(Number(rendererTraceData["begin"]))))
										futurSize = getPosFromTime(Number(endTrace["begin"])) - getPosFromTime(Number(rendererTraceData["begin"]));
									else
										futurSize = 0;
								}
							}
							
							//we set the size
							if(direction == "vertical")
								renderer.height = futurSize;
							else
								renderer.width = futurSize;
	
						}
						
						/////////////////////////// POSITIONING //////////////////////////////////////////////////////////
	
						var futurPosition:Number = getPosFromRenderer(rendererTraceData, futurSize);
						
						if( !(renderer is ITraceRenderer) || ((renderer as ITraceRenderer).selfPositioned == false) )
						{
							//if the renderer has a valid futurPosition (basically between the boundaries defined by startTime et StopTime)
							if(!isNaN(futurPosition))
							{
								//we set the its position and add it to the traceLine
								renderer.visible = true;
								
								if(direction == "vertical")
								{
									renderer.y = futurPosition;
									renderer.x = 0;
								}
								else
								{
									renderer.x = futurPosition;
									renderer.y = 0;
								}
								
								displayTraceRenderer(renderer,i,rendererTraceData["begin"]);
							}
						}
						// if the renderer is self positioned
						else
						{
							renderer.visible = true;
	
							displayTraceRenderer(renderer,i,rendererTraceData["begin"]);
						}
						
					}
				}

		}
		
		public function displayTraceRenderer( renderer:UIComponent, position:int, timeStamp:Number):void
		{
			if(!isNaN(position) && (!this.contains(renderer) || this.getChildIndex(renderer) != position))
			{
				this.addChild(renderer);
				//	this.addChildAt(renderer,position);
			}
			
		}
		
		public function getEndPosFromRenderer(rendererTraceData:Object, rendererSize:Number):Number
		{
			//we calculate the possible future Position of the renderer based on its startTime and renderAlign
			if(isNaN(getPosFromTime(Number(rendererTraceData["end"]))))
				return NaN;
				
			var futurPosition:Number = getPosFromTime(Number(rendererTraceData["end"])) + deltaPos;
			
			if(renderAlign == "middle")
				futurPosition -= rendererSize/2;	
			
			if(renderAlign == "before")
				futurPosition -= rendererSize;
			
			return futurPosition;
		}
		
		public function getPosFromRenderer(rendererTraceData:Object, rendererSize:Number):Number
		{
			//we calculate the possible future Position of the renderer based on its startTime and renderAlign						
			var futurPosition:Number = getPosFromTime(Number(rendererTraceData["begin"])) + deltaPos;
			
			if(!isNaN(rendererSize) && renderAlign == "middle")
				futurPosition -= rendererSize/2;	
			
			if(!isNaN(rendererSize) && renderAlign == "before")
				futurPosition -= rendererSize;
			
			return futurPosition;
		}
		

        public function sortRendererArray():void
        {
            
            aRenderer.sort(function(a:Object,b:Object):int
            {
                if( ((a["traceData"] as Obsel).begin) <  ((b["traceData"] as Obsel).begin) )
                    return -1;
                else
                    return 1;
                
            });
            
        }
        
        override public function onTraceDataCollectionChange(e:CollectionEvent):void
        {
            super.onTraceDataCollectionChange(e);
                
            if(e.kind == CollectionEventKind.ADD)
               searchEndTraceForExistingRenderers();
        }
        
        public function searchEndTraceForExistingRenderers():void
        {
            for each(var item:Object in aRenderer)
            {
                var endTrace:Obsel = getEndTrace(item["traceData"]);
                
                if(endTrace)
                {
                    item["endTraceData"] = endTrace;
                    
                    if(item["renderer"] is ITraceRenderer)
                        (item["renderer"] as ITraceRenderer).endTraceData = endTrace;
                }
            }
        }
        

		
		private function deleteAllRenderer():void
		{

				//we first clear the traceLine
				this.removeAllChildren();

				if(aRenderer)
					while(aRenderer.length > 0)
						aRenderer.shift();
						// TODO : delete the objects
		}
		
		public function getDataFromRenderer(renderer:Object):Object
		{
			if(aRenderer)
				for each(var item:Object in aRenderer)
					if(item["renderer"] == renderer)
						return item["traceData"];
			
			return null;
		}
		

		

		
	}
}
