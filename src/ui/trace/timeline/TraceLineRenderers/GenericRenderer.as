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
package ui.trace.timeline.TraceLineRenderers
{

	
	import com.ithaca.traces.Obsel;
	import com.ithaca.traces.utils.RDFconverter;
	
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
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.utils.ColorUtil;
	
	import ui.trace.timeline.Utils.ColorCrayon;
	import ui.trace.timeline.events.InternalTimelineEvent;
	
	[Event(name="itemZoomOn" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStartEdit" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStopEdit" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	
	public class GenericRenderer extends BaseRenderer
	{
		
		//the subcomponents
		
		private var theCanvas:Canvas;
		
		public var theText:TextArea;
		
		public var theTools:MarqueurPerso2ToolBox;
		
		public var theCloseBtn:Button;
		
		public var theIcon:DisplayObject;
		
		public var theIconWrapper:UIComponent; 
		
		
		//some properties
		
		private var _editMode:Boolean = false;
		
		public var deltaPos:Point = new Point(0,0);
		
		public var textBorder:Point = new Point(2,2);
		
		public var previewWidth:int = 90;

		public var editWidth:int = 330;
		
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
		[Embed(source="assets/timeline/delete_16.png")]
		private var closeImage:Class;
		
		//indicates the gap between the timestamp line and the marker content
		public var yGap:Number = 0; 
		public var xGap:Number = 0;
		
		public function GenericRenderer()
		{
			selfSized = true;
			selfPositioned = true;
			
			super();
			
			this.height = 30;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.ROLL_OVER, showTools);
			this.addEventListener(MouseEvent.ROLL_OUT, hideTools); 
			this.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			
		}
		

		
		protected function onClick(e:MouseEvent):void
		{
			if(e.currentTarget != theTools && !theTools.contains(e.currentTarget as DisplayObject) && !editMode)
				setEdit();
		}
		
		protected function onDrag(event:MouseEvent):void
		{
			//if(!model.getModeMoveTextComment())
			//{
				var ds:DragSource = new DragSource();
				var beginTimeObsel:Number = traceData.begin;
				ds.addData(  beginTimeObsel , 'beginTimeObsel' );
				var typeObsel:String = traceData.obselType.uri;
				// If obsel type "Marquer" will get the text of the obsel
				/*if (typeObsel == TraceModel.SetMark || typeObsel == TraceModel.ReceiveMark )
				{
					var textObsel:String = traceData.props["text"];
					ds.addData(  textObsel , 'textObsel'); 
				}*/
				
				DragManager.doDrag( event.currentTarget as UIComponent, ds , event );
				
			//}
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
				theTools.setDeleteImage(false);
				
				BindingUtils.bindProperty(theTools,"model",this,"model");
				BindingUtils.bindProperty(theTools,"traceData",this,"traceData");
				
				theCanvas.addChild(theTools);
				theTools.visible = false;
				
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
			
		}
		

		public function showTools(e:Event = null):void
		{
/* 			theCanvas.addChild(theTools);
			
			invalidateSize();
			invalidateDisplayList(); */
			theTools.visible = true;
		}
		
		public function hideTools(e:Event = null):void
		{
			if(theCanvas.contains(theTools) && !editMode)
				theTools.visible = false;
/* 			
			invalidateSize();
			invalidateDisplayList(); */
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
				toHeight += 2*(theText.getStyle("fontSize") + 7); // 2 lines of text
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
			
			//theCanvas.validateNow();
			
			
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
				theTools.y = h - deltaPos.y - theTools.height - 7;
				theTools.x = w - deltaPos.x - theTools.width; 
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

		public function onClose(e:Event = null):void
		{
				setPreview();
		}
		
		public function onFocusLoose(e:Event):void
		{
			if(e.target == theText || e.target.parent == theText)
				setPreview();
		}		
		
		protected function setPreview(e:Event = null):void
		{
			_editMode = false;
			
			theText.editable = false;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusLoose);
			
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
			
			//Application.application.addElement(theCanvas);
			Application.application.addChild(theCanvas);
			
			this.removeEventListener(MouseEvent.CLICK,onClick);
			theText.addEventListener(FocusEvent.FOCUS_OUT, onFocusLoose);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusLoose);
			
			//this.addEventListener(FlexEvent.INVALID,  onFocusLoose);

			focusManager.setFocus(theText);
			
			
			theCloseBtn.visible = false;
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

				theText.text = traceData.getAttributeValueByTypeUri(dataField);
				
				if(!theText.text)
				{
					theText.text = RDFconverter.toRDF(traceData);
				}
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
				if(traceData.getAttributeValueByTypeUri("sender"))
					return model.getUserColor(traceData.getAttributeValueByTypeUri("sender"));
				
				if(traceData.subject)
					return model.getUserColor(parseInt(traceData.subject));
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
