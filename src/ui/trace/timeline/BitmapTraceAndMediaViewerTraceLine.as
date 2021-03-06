
package ui.trace.timeline
{
	import com.greensock.easing.*;
	import com.ithaca.traces.AttributeType;
	import com.ithaca.traces.Obsel;
	import com.ithaca.traces.ObselCollection;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
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
	import mx.graphics.BitmapSmoothingQuality;
	import mx.utils.ColorUtil;
	import mx.utils.object_proxy;
	
	import spark.components.Group;
	import spark.primitives.BitmapImage;
	import spark.primitives.Graphic;
	
	import traceSelector.dummyTraceSelector;
	
	import ui.timeline.TimeRange;
	import ui.trace.timeline.TraceLineRenderers.GenericRenderer;
	import ui.trace.timeline.TraceLineRenderers.ITraceRenderer;
	import ui.trace.timeline.events.InternalTimelineEvent;
	import ui.trace.timeline.events.TimelineEvent;

	// --- end import for trace improvement
	
	[Event(name="itemRendererCreated" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemRendererCreationComplete" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemZoomOn" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStartEdit" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStopEdit" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="itemGotoAndPlay" , type="ui.trace.timeline.events.InternalTimelineEvent")]
	[Event(name="obselClick" , type="ui.trace.timeline.events.TimelineEvent")]
	[Event(name="obselOver" , type="ui.trace.timeline.events.TimelineEvent")]
	
	public class BitmapTraceAndMediaViewerTraceLine extends TraceLineBase
	{
		
		private var bitmapData:BitmapData;
		private var bitmapImage:BitmapImage;
		private var bitmapImageWrapper:Group;
		public var rendererFunctionParams:Object = null;
		public var rendererFunctionData:Object = null;
		private const BITMAPSIZE:Number = 4000;
		[Bindable]
		public var maxMediaTime:Number;
		[Bindable]
		protected var _forceMaxMediaTime:Boolean = false;
		[Bindable]
		protected var _forcedMaxMediaTime:Number;
		// Vars for trace improvement
		private var mediaCurrentTime:Number; // Quelle valeur pour le debut??
		private var isMediaPlaying:Boolean;
		private var currentIdMedia:String;
		private var videoObselTypes:Array=["lectureVideo","stopVideo","pauseVideo","finVideo"];	
		private var previousObselBegin:Number;
		// --- end of trace improvement vars
		private var currentTT:ObselPreviewer;
		
		public function BitmapTraceAndMediaViewerTraceLine()
		{
			super();
			
			
			this.addEventListener(MouseEvent.CLICK,onMouseClick);	
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseOver);

			bitmapImage = new BitmapImage();
			bitmapImage.x=0;
			bitmapImage.y = 0;
			bitmapImage.width = BITMAPSIZE;
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
		
		
		public function get forceMaxMediaTime():Boolean
		{
			return _forceMaxMediaTime;
		}
		
		public function set forceMaxMediaTime(value:Boolean):void
		{
			_forceMaxMediaTime = value;
            
            //TODO : We should reinit display here if forcedMaxMediaTime is true

		}		
		
		public function get forcedMaxMediaTime():Number
		{
			return _forcedMaxMediaTime;
		}
		
		public function set forcedMaxMediaTime(value:Number):void
		{
			_forcedMaxMediaTime = value;
			
            //TODO : We should reinit display here if a forceMaxMediaTime is set
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
			trace("initDisplay");
			if(filteredTrace){
				completeTraceWithcalculatedMediaTime("Player1",filteredTrace);
				if (forceMaxMediaTime==false){
					maxMediaTime=getMaxCalculatedMediaTimeFromObsels(filteredTrace);
				} else {
					maxMediaTime=_forcedMaxMediaTime;
				}
				
				/*
				// 5 minutes graduation
				var ind:Number=0;
				
				var graduation:Number= getVerticalPosFromMediaTime(300000);
				trace("graduation: "+graduation);
				
				for (ind;ind<(this.height/graduation);ind++){
					var gradline:Rectangle = new Rectangle(0,graduation*ind,100,200);
					//bitmapData.fillRect(theRect,argb);
					var col:uint=0x00FF00;
					bitmapData.fillRect(gradline,returnARGB(col, 1));
					trace(ind);
				}	
				*/
				constructBitmapData();
			}
			invalidateDisplayList();

		}
		
		private function constructBitmapData():void
		{
			bitmapData = new BitmapData(BITMAPSIZE,BITMAPSIZE,true,0x00000000);
			
			
			renderingFunctionReset();
			
			bitmapImage.smooth = true;
			bitmapImage.clearOnLoad = true;
			
			if(timeRange)
			{
				
				for each(var obs:Obsel in filteredTrace._obsels)
				if((obs.begin >= timeRange.begin && obs.begin <= timeRange.end)
					|| (obs.end >= timeRange.begin && obs.end <= timeRange.end)){
					renderObsel(obs);
				}
				
				// Ici pour chaque obsel de la map on les relit		
				if(rendererFunctionData && rendererFunctionData["obsAndRect"])
				{
					var previousObsBottomRight:Point=null;
					for each(var or:Object in rendererFunctionData["obsAndRect"]){
						var rect:Rectangle=or["rect"] as Rectangle;
						if (previousObsBottomRight){
							var topLeft:Point=null;
							var bottomRight:Point=null;
							topLeft=rect.topLeft;
							bottomRight=rect.bottomRight;

							var shape:Shape = new Shape();
							var graphics:Graphics = shape.graphics;
							graphics.lineStyle(10, 0xff7f00, 1);
							graphics.moveTo(previousObsBottomRight.x,previousObsBottomRight.y);
							graphics.lineTo(topLeft.x, bottomRight.y);
							bitmapData.draw(shape);
						}
						previousObsBottomRight=rect.bottomRight;
						
					}
				}
			}
			
			bitmapImage.source = bitmapData;
			bitmapImage.smooth = true;
			
		}
		
		
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			if(_traceData && timeRange)
			{
				
				
				var beginX:Number = timeRange.timeToPosition(_startTime,BITMAPSIZE);
				var endX:Number = timeRange.timeToPosition(_stopTime,BITMAPSIZE);

				//var beginY:Number = timeRange.timeToPosition(mediastartTime,BITMAPSIZE);
				//var endY:Number = timeRange.timeToPosition(mediastopTime,BITMAPSIZE);
				
				var coeff:Number = this.width / (endX - beginX);
				bitmapImage.width = BITMAPSIZE * coeff;
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
		
		override protected function renderObsel(obs:Obsel):void
		{
			//If the obsel is (event partly) in the time window to display
			if(!isNaN(getPosFromTime(Number(obs["begin"]))) || !isNaN(getPosFromTime(Number(obs["end"]))))
			{
				//We deal with renderinfFunctionParams Object
				var bgColor:uint = 0x00FF00;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("color"))
					bgColor = rendererFunctionParams["color"];
				
				var minSize:Number = 8;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("minSize"))
					minSize = rendererFunctionParams["minSize"];
				
				var bgAlpha:Number = 1;
				if(rendererFunctionParams && rendererFunctionParams.hasOwnProperty("alpha"))
					bgAlpha = rendererFunctionParams["alpha"];
				
				
				var argb:uint = returnARGB(bgColor, 1);
				
				
				// Color : one color per obsel type
				var ind:Number=0;
				var colorVal:Number=0;
				for (ind;ind<obs.obselType.label.length;ind++){
					colorVal=colorVal+(obs.obselType.label.charCodeAt(ind)*100);
				}
				var colorArgb:uint=0x00FF00;
				colorArgb=returnARGB(colorVal, 1);
				
				
				//We set the values we will use to draw
				var posDebut:Number = timeRange.timeToPosition(Number(obs["begin"]),BITMAPSIZE);
				
				if(isNaN(posDebut) || posDebut < 0) //if the begin of the obsel is not in the time window to displau
					posDebut = 0;
				
				var size:Number;
				if(!isNaN(getPosFromTime(Number(obs["end"]))))
					size = timeRange.timeToPosition(Number(obs["end"]),BITMAPSIZE) - posDebut;
				else
					size = this.width;
				
				size = Math.max(size,minSize);
				//posDebut -= size/2;
				
				// bitmapData.fillRect(new Rectangle(posDebut,0,size,this.height),argb);
				
				//we draw
				/*if(!isNaN(posDebut) && !isNaN(size))
				{
					for(var i:int = posDebut; i < Math.min(posDebut+size,BITMAPSIZE); i++)
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
					
				}	*/
				
				//we save the rectange coordinates and map it with the obsel (useful for mouse interaction amongst other things)
				var theRect:Rectangle;		
				if(direction == "vertical")
					theRect = new Rectangle(0,posDebut,this.width,size);
				else{
					
					if (maxMediaTime>0){
						if(!isNaN(obs.getAttributeValueByLabel("calculatedMediaTime"))){
							theRect = new Rectangle(posDebut,getVerticalPosFromMediaTime(obs.getAttributeValueByLabel("calculatedMediaTime")),size,100);
							//bitmapData.fillRect(theRect,argb);
							bitmapData.fillRect(theRect,colorArgb);
						}
					}
				}
				

				
				
				(rendererFunctionData["obsAndRect"] as ArrayCollection).addItem({"obs":obs,"rect":theRect});
			}
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
				var coeff = BITMAPSIZE / bitmapImage.width;
				var coeffy = BITMAPSIZE / bitmapImage.height;
				var gx:Number = (p.x - bitmapImage.x)*coeff;
				var gy:Number = (p.y - bitmapImage.y)*coeffy;
				
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
					obsPreview.x = e.stageX-280;
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
		
		[Bindable]
		// Function returning the highest calculatedMediaTime attribute value from an ObselCollection
		public function getMaxCalculatedMediaTimeFromObsels(value:ObselCollection):Number{
			var maxTime:Number=0;
			for each(var obs:Obsel in value._obsels){
				if (obs.getAttributeValueByLabel("calculatedMediaTime")>maxTime){
					maxTime=obs.getAttributeValueByLabel("calculatedMediaTime");
				}
			}
			return maxTime;
		}
		
		// Function returning the vertical position in px for the media time given in param
		private function getVerticalPosFromMediaTime(mediaTime:Number):Number{
			return ((mediaTime/maxMediaTime)*BITMAPSIZE);
		}
		
		override public function onTraceDataCollectionChange(e:CollectionEvent):void
		{
			if(e.kind == CollectionEventKind.ADD)
			{
				for each(var item:Obsel in e.items)
				{
					if(filterObsel(item))
					{
						filteredTrace.push(item); //we add the obs to a filteredTrace Collection	

						listenObsels(item);
						
					}
					
				}
				initDisplay();
			}
			else
				super.onTraceDataCollectionChange(e);
		}
		
		// Fonction d'enrichissement de la trace
		public function completeTraceWithcalculatedMediaTime(selectedPlayer:String, collect:ObselCollection):void
		{
			// Dans les tests on appellera la fonction avec "Player1"
			if(collect){
				
				//var currentIdPlayer:String;
				// todo : test pour s'assurer que la trace est dans l'ordre du temps. Doit être triée
				// ici
				
				
				// Premiere boucle pour trouver le premier temps et initialiser mediaCurrentTime
				var foundTimeObsel:Boolean=false;
				for each(var obs:Obsel in collect._obsels){
					if(updateTimeDataFromObsel(obs,selectedPlayer)){
						foundTimeObsel=true;
						break;
					}	
				}
				
				if(foundTimeObsel){
					
					// Principe : on veut enrichir TOUS les obsels avec calculatedMediaTime (donc necessite de partir avec une valeur de CurrentTime) et calculatedMediaId
					for each(var obs:Obsel in collect._obsels){
						
						//TODO : a optimiser car appeller pour chaque obsel
						var calculatedMediaTimeAttributeType:AttributeType;
						var calculatedMediaIDAttributeType:AttributeType;
						
						if(!obs.trace.model.get("calculatedMediaTime")){
							calculatedMediaTimeAttributeType=obs.trace.model.createAttributeType("calculatedMediaTime");	
						} else {
							calculatedMediaTimeAttributeType=obs.trace.model.getAttributeTypesByName("calculatedMediaTime",false)[0];
						}
						
						if(!obs.trace.model.get("calculatedMediaID")){
							calculatedMediaIDAttributeType=obs.trace.model.createAttributeType("calculatedMediaID");	
						} else {
							calculatedMediaIDAttributeType=obs.trace.model.getAttributeTypesByName("calculatedMediaID", false)[0];
						}								
						
						updateTimeDataFromObsel(obs, selectedPlayer);
						if(isMediaPlaying){
							obs.setAttributeValue(calculatedMediaTimeAttributeType,(obs.begin-previousObselBegin)+mediaCurrentTime);
						} else {
							obs.setAttributeValue(calculatedMediaTimeAttributeType, mediaCurrentTime);							
						}
						obs.setAttributeValue(calculatedMediaIDAttributeType, currentIdMedia);				
						
					}
				}
			}
		}
		
		// Function updating obsels' time data 
		private function updateTimeDataFromObsel(obs:Obsel,selectedPlayer:String):Boolean{
			var updated:Boolean=false;
			if ((obs.obselType.label=="changementPositionVideo") && (obs.getAttributeValueByLabel("IdPlayer")==selectedPlayer)){
				mediaCurrentTime=obs.getAttributeValueByLabel("NouvellePosition");
				isMediaPlaying=(obs.getAttributeValueByLabel("Lecture")=="true"); // a debugger pour verifier que c'est bien un string				
				updated=true;
			} else if((videoObselTypes.indexOf(obs.obselType.label)>=0) && (obs.getAttributeValueByLabel("IdPlayer")==selectedPlayer)){
				mediaCurrentTime=obs.getAttributeValueByLabel("PositionTemps");
				if(obs.obselType.label=="lectureVideo"){
					isMediaPlaying="true"; // a debugger pour verifier que c'est bien un string
				} else {
					isMediaPlaying="false";
				}
				updated=true;
			}
			if(updated){
				currentIdMedia=obs.getAttributeValueByLabel("IdMedia");	
				previousObselBegin=obs.begin;
			}
			
			return updated;
		}					

		
		
		[Bindable]
		// Function returning the media time from an activity time
		public function getMediaTimeFromActivityTime(value:Number):Number{
			var previousObs:Obsel;

			if (_traceData){
				for each(var obs:Obsel in _traceData._obsels){
					if (obs.begin){
						trace(obs.begin);
						trace(value);
						if (obs.begin<value){
							previousObs=obs;
						}
						else {
							trace("break");
							break;
						}
					}
				}
				if (previousObs){
					//On retourne en arriere jusqu'a ce que retourne true updateTime
					// On se place sur le dernier obs précédent le temps de l'activite
                    var currentObsIndex:Number =_traceData.getItemIndex(previousObs);
                    
                    while (currentObsIndex >= 0 && !updateTimeDataFromObsel(_traceData.getItemAt(currentObsIndex) as Obsel,"Player1"))
                        currentObsIndex--;
                    
						if (currentObsIndex < 0){
							return (obs.getAttributeValueByLabel("calculatedMediaTime"));
						}
						//On renvoie le calculatedMediaTime de l'obsel previousObs
						if (isMediaPlaying){
							trace(obs.getAttributeValueByLabel("calculatedMediaTime")+(value-obs.begin));
							return (obs.getAttributeValueByLabel("calculatedMediaTime")+(value-obs.begin))
						} else {
							return (obs.getAttributeValueByLabel("calculatedMediaTime"));
						}

				} else {
					return 0;
				}
				
			}
			return NaN;
		}				
		
	}
}
