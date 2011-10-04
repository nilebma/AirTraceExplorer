package ithaca.traces.timeline.TraceLineRenderers
{
	import com.ithaca.traces.Obsel;
	import com.lyon2.visu.views.newTimeline.CurseurBase;
	import com.lyon2.visu.views.newTimeline.Utils.ColorCrayon;
	import com.lyon2.visu.views.newTimeline.events.InternalTimelineEvent;
	
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.utils.ColorUtil;
	
	[Event(name="itemZoomOn" , type="com.lyon2.visu.views.newTimeline.events.InternalTimelineEvent")]
	[Event(name="itemStartEdit" , type="com.lyon2.visu.views.newTimeline.events.InternalTimelineEvent")]
	[Event(name="itemStopEdit" , type="com.lyon2.visu.views.newTimeline.events.InternalTimelineEvent")]
	
	public class GenericRendererWithDuration extends BaseRenderer
	{
		
		//the subcomponents
		
		private var theCanvas:Canvas;
		
		public var theText:TextArea;
		
		public var theTools:MarqueurPerso2ToolBox;
		
		public var theCloseBtn:Button;
		
		public var theIcon:DisplayObject;
		
		public var theIconWrapper:UIComponent; 
		
		public var theTimeBar:TimeBar;
		
		
		//some properties
		
		private var _editMode:Boolean = false;
		
		public var deltaPos:Point = new Point(0,0);
		
		public var textBorder:Point = new Point(2,2);
		
		public var previewWidth:int = 90;

		public var editWidth:int = 130;
		
		public var iconClass:Class = ColorCrayon;
		
		public var iconSize:int = 26;
		
		public var dataField:String;
		
		public var defaultBackgroundColor:uint = 0xFFF;
		
		/*
		public var defaultOrientation:String = "top"; //or "bottom"
		
		public var autoOrientation:Boolean = true; //or "bottom"
		
		protected var currentOrientation:String;
		*/
		
		private var editable:Boolean = true;
		
		//Embeding assets
		[Embed(source="newTimeline/delete_16.png")]
		private var closeImage:Class;
		
		//indicates the gap between the timestamp line and the marker content
		public var yGap:Number = 0; 
		public var xGap:Number = 0;
		
		public function GenericRendererWithDuration()
		{
			selfSized = true;
			selfPositioned = true;
			
			super();
			
			this.height = 30;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.ROLL_OVER, showTools);
			this.addEventListener(MouseEvent.ROLL_OUT, hideTools);
			
		}
		

		
		protected function onClick(e:MouseEvent):void
		{
			if(e.currentTarget != theTools && !theTools.contains(e.currentTarget as DisplayObject) && !editMode)
				setEdit();
		}
		
		
		public function get editMode():Boolean
		{
			return _editMode;
		}
		
		public function set editMode(value:Boolean):void
		{	
			if(value)
				setEdit();
			else
				setPreview();
		}
		
		override public function update() : void
		{
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			if(!theCanvas)
			{	
				theCanvas = new Canvas();
				theCanvas.verticalScrollPolicy = "off";
				theCanvas.horizontalScrollPolicy = "off";
				theCanvas.x = 0;
				theCanvas.y = 0;
				
				this.addChild(theCanvas);
			}
			
			if(theCanvas && !theIcon)
			{
				theIcon = new iconClass() as DisplayObject;
				
				theIconWrapper = new UIComponent();
				
				theIconWrapper.addChild(theIcon);
				
				theCanvas.addChild(theIconWrapper);
			}
			
			if(theCanvas && !theText)     
			{
				
				theText = new TextArea();
				
				
				theText.setStyle("color",0x000000);
				
				theText.setStyle("fontWeight","bold");
				theText.setStyle("fontSize",11);
				theText.setStyle("backgroundAlpha",0);
				theText.setStyle("borderStyle","none");
				
				theText.text = " ";
				
				theText.editable = false;
				
				
				setText();
				
				theCanvas.addChild(theText);
			}
			
			if(!theTools)
			{
				theTools = new MarqueurPerso2ToolBox();
				
				theTools.addEventListener("edit", setEdit);
				//theTools.addEventListener("delete", onDelete);
				theTools.addEventListener("goto", onGoto);
				theTools.addEventListener("zoom", onZoom);
				
				theTools.model = this.model;
				theTools.traceData = this.traceData;
				
				BindingUtils.bindProperty(theTools,"model",this,"model");
				BindingUtils.bindProperty(theTools,"traceData",this,"traceData");
				
			}
			
			if(!theCloseBtn)
			{
				theCloseBtn = new Button();
				theCloseBtn.toggle = true;
				theCloseBtn.setStyle("upSkin",closeImage);
				theCloseBtn.setStyle("overSkin",closeImage);
				theCloseBtn.setStyle("downSkin",closeImage);
				theCloseBtn.setStyle("selectedUpSkin",closeImage);
				theCloseBtn.setStyle("selectedOverSkin",closeImage);
				theCloseBtn.setStyle("selectedDownSkin",closeImage);
				theCloseBtn.useHandCursor = true;
				theCloseBtn.buttonMode = true;
				theCloseBtn.addEventListener(MouseEvent.CLICK, onClose);
				theCloseBtn.visible = false;
				
				theCanvas.addChild(theCloseBtn);
				
			}	
			
			if(!theTimeBar)
			{
				theTimeBar = new TimeBar();
				theTimeBar.startEdge = -this.x;
				theTimeBar.endEdge = parent.width - this.x;
				theTimeBar.addEventListener(CurseurBase.ZOOM_CHANGE_EVENT, onTimeBarChange);
				theTimeBar.startTime = parentLine.startTime;
				theTimeBar.stopTime = parentLine.stopTime;
				theCanvas.addChild(theTimeBar);
				
			}
			
		}
		
		public function onTimeBarChange(e:Event = null):void
		{
			var toX:int = theTimeBar.getRect(parent).x;
			theTimeBar.startEdge = -toX;
			theTimeBar.endEdge = parent.width - toX;
			this.x = toX;
			this.width = Math.max(theTimeBar.width, editWidth);	
		}

		public function showTools(e:Event = null):void
		{
			theCanvas.addChild(theTools);
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function hideTools(e:Event = null):void
		{
			if(theCanvas.contains(theTools) && !editMode)
				theCanvas.removeChild(theTools);
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		override protected function measure() : void //also handle position
		{
			super.measure();
			
			//////////////////////// CALCULATE SIZE //////////////////////////////////////////////////////////
			
			//We determine the height & width to set
			var toHeight:Number = yGap + 2*deltaPos.y + 2*textBorder.y;
			var toWidth:Number = editMode ? editWidth : previewWidth;
			
			//if the tools is showed, we add some space
			if(theCanvas.contains(theTools))
				toHeight += theTools.height;		
			
			//depending if we are in editmode or not we don't show all the text or just a preview, then the height is not the same
			var oneLineOfTextHeight: uint = theText.getStyle("fontSize") + 12;
			
			if(!_editMode || !theText)
				toHeight += 2*(theText.getStyle("fontSize") + 9); // 2 lines of text
			else
			{
				toHeight += Math.max(oneLineOfTextHeight, theText.textHeight) + 8 + theCloseBtn.height;
			}
			
			/////////////////////////// CALCULATE POSITION //////////////////////////////////////////////////////////
			
			var futurPosition:int = parentLine.getPosFromRenderer(traceData, toWidth);
			
			//if autoOrientation is true, we check if we have enouough space to display the content in the parentline
			/*if(autoOrientation && editMode && parentLine)
			{
				var spaceUp:int = futurPosition - 10;
				var spaceDown:int = parentLine.height - (futurPosition+ toHeight) - 10; 
				
				//iF default orientation is top and we don't have enough space down (but enough up)
				if(defaultOrientation == "top" && spaceDown < 0 && spaceUp > toHeight) 
				{
					//we flip the renderer
					currentOrientation = "bottom";	
					if(parentLine.renderAlign == "top")
						futurPosition -= toHeight;
				}
					//iF default orentientation is bottom and we don't have enough space up (but enough down)
				else if(defaultOrientation == "bottom" && spaceUp < 0 && spaceDown > toHeight) 
				{
					//we flip the renderer
					currentOrientation = "top";
					if(parentLine.renderAlign == "bottom")
						futurPosition += toHeight;
				}
				else
					currentOrientation = defaultOrientation;
				
				//trace("spaceUp:",spaceUp,"spaceDown",spaceDown);
				
			}
			else
				currentOrientation = defaultOrientation;*/
			
			/////////////////////////// APPLYING //////////////////////////////////////////////////////////
			x = futurPosition;
			measuredMinWidth = toWidth;
			measuredWidth = toWidth;
			explicitHeight = toHeight;
			
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void 
		{
			super.updateDisplayList(w,h);
			
			//some internal properties
			var darkenValue: uint = 0;
			if(editMode)
				darkenValue = 20;
			
			var timeLineWeight:Number = 4;
			
			//depending on editmode or if the toolsbox is visible, we reserve some space in these variables
			
			var theToolsHeight:Number = 0;
			if(theCanvas.contains(theTools))
				theToolsHeight = theTools.height;
			
			var theCloseBtnHeight:Number = 0;
			if(editMode)
				theCloseBtnHeight = theCloseBtn.height - 3;
			
			//We set the dimensions & positions of the canvas
			theCanvas.height = h - 2*deltaPos.y;
			theCanvas.width = w - 2*deltaPos.x;
			if(editMode)
			{
				theCanvas.x = this.localToGlobal(deltaPos).x;
				theCanvas.y = this.localToGlobal(deltaPos).y;
			}
			else
			{
				theCanvas.x = deltaPos.x;
				theCanvas.y = deltaPos.y;
			}
			
			theCanvas.validateNow();
			
			
			//we calculate the space available for content
			var contentHeight:Number = h - 2*deltaPos.y - yGap - timeLineWeight/2;
			var contentWidth:Number = w - 2*deltaPos.x - xGap;
			
			//We set the Position of the icon
			theIconWrapper.x = deltaPos.x + 4;
			theIconWrapper.y = deltaPos.y + 4;
			theIconWrapper.width = theIcon.width = iconSize;
			theIconWrapper.height = theIcon.height = iconSize;
			
			//We set the eventual position of the Tools
			if(theCanvas.contains(theTools))
			{
				theTools.y = h - deltaPos.x - theTools.height - 5;
				theTools.x = w - deltaPos.y - theTools.width; 
			}
			
			//We set the eventual position of the closeBtn
			if(editMode)
			{
				theCloseBtn.x = w - deltaPos.y - theCloseBtn.width; 	
				theCloseBtn.y = deltaPos.x + 2;
			}
			
			//We set the dimensions & positions of the text
			theText.width = contentWidth - 2*textBorder.x - iconSize;
			theText.height = contentHeight - 2*textBorder.y -  theToolsHeight - theCloseBtnHeight;
			theText.x = xGap + deltaPos.x + textBorder.x + iconSize;
			theText.y = theCloseBtnHeight + yGap + deltaPos.y + textBorder.y;
			
			//Setting colors
			var color:int = getUsrColor();
			
			if(color == -1)
				color = defaultBackgroundColor;
			
			color = ColorUtil.adjustBrightness(color,-darkenValue);
			var colorDark:uint = ColorUtil.adjustBrightness(color,-30-darkenValue);
			var colorBright:uint = ColorUtil.adjustBrightness(color,20);
			
			//Drawing skin
			theCanvas.graphics.clear();
			
			//Drawing skin : background
			var myMatrix:Matrix = new Matrix();
			myMatrix.createGradientBox(contentWidth,contentHeight, Math.PI / 2);
			theCanvas.graphics.lineStyle(1,colorDark);
			theCanvas.graphics.beginGradientFill(GradientType.LINEAR, [colorBright, color], null, null, myMatrix);
			

			theCanvas.graphics.drawRoundRectComplex(deltaPos.x + xGap, deltaPos.y + yGap + timeLineWeight/2,contentWidth,contentHeight,0,6,0,6);
			
			theCanvas.graphics.endFill();

			
			//Drawing skin : big line that shows time
			theCanvas.graphics.lineStyle(timeLineWeight,colorDark,1,false,"normal",CapsStyle.SQUARE);
			theCanvas.graphics.moveTo(deltaPos.x,deltaPos.y);
			theCanvas.graphics.lineTo(deltaPos.x, h - deltaPos.y);
		
			
			//Effects
			if(_editMode)
				theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,1,10,10,1)];
			else
				theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,.6,8,8,1)];
			
			//Text Style dependuing on editMode
			if(_editMode)
			{
				theText.setStyle("fontWeight","bold");
				theText.setStyle("fontSize",11);
			}
			else
			{
				theText.setStyle("fontStyle","italic");
				theText.setStyle("fontSize",10);
			}
			
		}
		
		public function drawTimeBar():void
		{
			
		}

		public function onClose(e:Event = null):void
		{
			
			setPreview();
		}
		
		protected function setPreview(e:Event = null):void
		{
			_editMode = false;
			
			theText.editable = false;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			theText.removeEventListener(FocusEvent.FOCUS_OUT, onClose);
			
			//if(Application.application.contains(theCanvas))
			//Application.application.removeChild(theCanvas);
			
			this.addChild(theCanvas);
			
			hideTools();	
			
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_EDIT_STOP,this));
			
			theCloseBtn.visible = false;
			
			theText.verticalScrollPolicy = "off";
			
			invalidateDisplayList();
			invalidateSize();
			validateNow();
		}
		
		protected function setEdit(e:Event = null):void
		{
			if(!this.parent)
				return;
			
			_editMode = true;
			
			var toPoint:Point = this.parent.localToGlobal(new Point(this.x,this.y).add(deltaPos));
			
			theCanvas.x = toPoint.x;
			theCanvas.y = toPoint.y;
			
			if(this.contains(theCanvas))
			{
				this.removeChild(theCanvas);
			}
			
			Application.application.addChild(theCanvas);
			
			this.removeEventListener(MouseEvent.CLICK,onClick);
			theText.addEventListener(FocusEvent.FOCUS_OUT, onClose);
			focusManager.setFocus(theText);
			
			theCloseBtn.visible = true;
			theCloseBtn.selected = false;
			
			theText.verticalScrollPolicy = "auto";
			
			showTools();
			
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_EDIT_START,this));
			
			invalidateDisplayList();
			invalidateSize();
			validateNow();
			theText.validateNow();
			
		}	
		
		override public function set traceData(value:Obsel):void
		{
			_traceData = value;
			
			setText();
			
			invalidateDisplayList();
			invalidateSize();
		}
		
		private function setText():void
		{
			if(theText && traceData)
			{
				if(traceData.props && dataField && traceData.props[dataField])
					theText.text = traceData.props[dataField];
				else if(traceData.hasOwnProperty(dataField))
					theText.text = traceData[dataField];
			}
					
		}
		
		/**
		 * 
		 * Return the color for the curent user based on its id
		 * Return -1 if no color found
		 * */
		private function getUsrColor():int
		{
			if(traceData)
			{	
				if( traceData.props && traceData.props["sender"])
					return model.getUserColor(Number(traceData.props["sender"]));
				
				if(traceData.uid)
					return model.getUserColor(traceData.uid);
			}
			
			return -1;
		}
		
		private function onZoom(e:Event = null):void
		{
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_ZOOM_ON, this, traceData.begin));
			if(e)
				e.stopPropagation();
		}
		
		private function onGoto(e:Event = null):void
		{
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_GOTO_AND_PLAY, this, traceData.begin));
			if(e)
				e.stopPropagation();
		}
		
		override public function modelUpdate(e:Event = null):void
		{
			if(!model || !traceData)
				return;
			
			/*if(model.getUserVisibility(traceData.uid))
			this.visible = true;
			else
			this.visible = false;*/
		}
		
		
	}
}