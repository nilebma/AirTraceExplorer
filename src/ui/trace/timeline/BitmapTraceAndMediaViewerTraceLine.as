
package ui.trace.timeline
{
	import com.greensock.easing.*;
	import com.ithaca.traces.AttributeType;
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
		public var maxMediaTime:Number;
		[Bindable]
		protected var _forceMaxMediaTime:Boolean;
		[Bindable]
		protected var _forcedMaxMediaTime:Number;
		// Vars for trace improvement
		private var mediaCurrentTime:Number; // Quelle valeur pour le debut??
		private var isMediaPlaying:Boolean;
		private var currentIdMedia:String;
		private var videoObselTypes:Array=["lectureVideo","stopVideo","pauseVideo","finVideo"];	
		private var previousObselBegin:Number;
		// --- end of trace improvement vars
		
		
		public function BitmapTraceAndMediaViewerTraceLine()
		{
			super();
			
			
			this.addEventListener(MouseEvent.CLICK,onMouseClick);	
			
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

		}		
		
		public function get forcedMaxMediaTime():Number
		{
			return _forcedMaxMediaTime;
		}
		
		public function set forcedMaxMediaTime(value:Number):void
		{
			_forcedMaxMediaTime = value;
			
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
				if (forceMaxMediaTime=="false"){
					maxMediaTime=getMaxCalculatedMediaTimeFromObsels(filteredTrace);
				} else {
					maxMediaTime=_forcedMaxMediaTime;
				}
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
					|| (obs.end >= timeRange.begin && obs.end <= timeRange.end))
					renderObsel(obs);
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
				
				
				var argb:uint = returnARGB(bgColor, bgAlpha);
				
				
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
							theRect = new Rectangle(posDebut,getVerticalPosFromMediaTime(obs.getAttributeValueByLabel("calculatedMediaTime")),size,15);
							bitmapData.fillRect(theRect,0xFFFF0000);
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
		
		
		// Function returning the highest calculatedMediaTime attribute value from an ObselCollection
		private function getMaxCalculatedMediaTimeFromObsels(value:ObselCollection):Number{
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

		
	}
}
