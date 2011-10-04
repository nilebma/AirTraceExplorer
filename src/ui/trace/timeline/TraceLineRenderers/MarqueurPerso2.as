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
package ithaca.traces.timeline.TraceLineRenderers
{
	import com.ithaca.traces.Obsel;
	import ithaca.traces.timeline.events.InternalTimelineEvent;
	
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.utils.ColorUtil;
	
	[Event(name="itemZoomOn" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStartEdit" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	[Event(name="itemStopEdit" , type="ithaca.traces.timeline.events.InternalTimelineEvent")]
	
	public class MarqueurPerso2 extends BaseRenderer
	{
	
		//the subcomponents
		
		private var theCanvas:Canvas;
		
		public var theText:TextArea;
		
		public var theTools:MarqueurPerso2ToolBox;
		
		public var theCloseBtn:Button;
	
		
		//some properties
		
		private var _editMode:Boolean = false;
		
		public var deltaPos:Point = new Point(0,0);
		
		public var textBorder:Point = new Point(2,2);
		
		public var defaultOrientation:String = "top"; //or "bottom"
		
		public var autoOrientation:Boolean = true; //or "bottom"
		
		protected var currentOrientation:String;
		
		public var defaultBackgroundColor:uint = 0xFFF;
		
		
		private var editable:Boolean = true;
		
		public var oldTextValue:String;
		
		
		//Embeding assets
		[Embed(source="timeline/delete_16.png")]
		private var closeImage:Class;
	
		[Embed(source="timeline/tick_16.png")]
		private var closeAndValidateImage:Class;
		
		//indicates the gap between the timestamp line and the marker content
		public var yGap:Number = 0; 
		public var xGap:Number = 25;
		
		//indicates extra width in editMode
		public var editExtraWidth: uint = 25;
		
		public function MarqueurPerso2()
		{
			selfSized = true;
			selfPositioned = true;
			
			super();

			this.height = 30;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(MouseEvent.ROLL_OVER, showTools);
			this.addEventListener(MouseEvent.ROLL_OUT, hideTools);

			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		
		}
		
		public function onCreationComplete(e:Event = null):void
		{
			if(traceData && traceData.props && traceData.props["timestamp"] && traceData.props["userJustAdded"])
			{
				//we ask for zoom on the currentComponent
				this.dispatchEvent(new InternalTimelineEvent(
										InternalTimelineEvent.ITEM_ZOOM_ON, 
										this, 
										traceData.props["timestamp"],
										function(e:Event):void
											{
												editMode = true;
												model.onMarkerDisplayed(traceData);
											}
									));
				
				//we autosave after 2 secs
				var timer:Timer = new Timer(2000,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,
					function(e:Event):void
					{
							if(this.parent) //of the marker hasn't been deleted
						 		onSave();
					});
				timer.start();
			}
		}
			
		protected function onClick(e:MouseEvent):void
		{
			if(e.currentTarget != theTools && !editMode)
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
			
			if(theCanvas && !theText)     
			{
				
				theText = new TextArea();
				

				theText.setStyle("color",0x000000);
				
				theText.setStyle("fontWeight","bold");
				theText.setStyle("fontSize",11);
				theText.setStyle("backgroundAlpha",0);
				theText.setStyle("borderStyle","none");

				theText.text = oldTextValue;
				
				theText.editable = false;
				
				theText.addEventListener("change",onUsrTextChange);
				theText.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				
				setText();
					
				theCanvas.addChild(theText);
			}
			
			if(!theTools)
			{
				theTools = new MarqueurPerso2ToolBox();
				
				theTools.addEventListener("edit", setEdit);
				theTools.addEventListener("delete", onDelete);
				theTools.addEventListener("goto", onGoto);
				theTools.addEventListener("zoom", onZoom);
				
				theTools.model = this.model;
				theTools.traceData = this.traceData;
				theTools.setDeleteImage(true);
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
				theCloseBtn.setStyle("selectedUpSkin",closeAndValidateImage);
				theCloseBtn.setStyle("selectedOverSkin",closeAndValidateImage);
				theCloseBtn.setStyle("selectedDownSkin",closeAndValidateImage);
				theCloseBtn.useHandCursor = true;
				theCloseBtn.buttonMode = true;
				theCloseBtn.addEventListener(MouseEvent.CLICK, onSaveAndClose);
				theCloseBtn.visible = false;
				
				theCanvas.addChild(theCloseBtn);

			}
			
			
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
			var toWidth:Number = this.parentLine.width;
			
			//if the tools is showed, we add some space
			if(theCanvas.contains(theTools))
				toHeight += theTools.height;		
			
			//depending if we are in editmode or not we don't show all the text or just a preview, then the height is not the same
			var oneLineOfTextHeight: uint = theText.getStyle("fontSize") + 12;
			
			if(!_editMode || !theText)
				toHeight += Math.min(theText.textHeight + 5,
										2*(theText.getStyle("fontSize") + 7)); // 2 lines of text
			else
			{
				toHeight += Math.max(oneLineOfTextHeight, theText.textHeight) + 8 + theCloseBtn.height;
				toWidth += editExtraWidth;
			}
			
		/////////////////////////// CALCULATE POSITION //////////////////////////////////////////////////////////
			
			var futurPosition:int = parentLine.getPosFromRenderer(traceData, toHeight);
			
			//if autoOrientation is true, we check if we have enouough space to display the content in the parentline
			if(autoOrientation && editMode && parentLine)
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
				currentOrientation = defaultOrientation;
			
			/////////////////////////// APPLYING //////////////////////////////////////////////////////////
			y = futurPosition;
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
			theText.width = contentWidth - 2*textBorder.x;
			theText.height = contentHeight - 2*textBorder.y -  theToolsHeight - theCloseBtnHeight;
			theText.x = xGap + deltaPos.x + textBorder.x;
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
			
			if(currentOrientation == "top")
				theCanvas.graphics.drawRoundRectComplex(deltaPos.x + xGap, deltaPos.y + yGap + timeLineWeight/2,contentWidth,contentHeight,0,0,6,6);
			else
				theCanvas.graphics.drawRoundRectComplex(deltaPos.x + xGap, deltaPos.y + yGap + timeLineWeight/2,contentWidth,contentHeight,6,6,0,0);
			
			theCanvas.graphics.endFill();
			
			if(currentOrientation == "top")
			{
				//Drawing skin : little line that join big line and content
				theCanvas.graphics.lineStyle(timeLineWeight/2,colorDark,1,false,"normal",CapsStyle.SQUARE);
				theCanvas.graphics.moveTo(deltaPos.x + xGap - 5,deltaPos.y);
				theCanvas.graphics.lineTo(deltaPos.x + xGap - 5, deltaPos.y + yGap);
				theCanvas.graphics.lineTo(deltaPos.x + xGap, deltaPos.y + yGap);
				
				//Drawing skin : big line that shows time
				theCanvas.graphics.lineStyle(timeLineWeight,colorDark,1,false,"normal",CapsStyle.SQUARE);
				theCanvas.graphics.moveTo(deltaPos.x,deltaPos.y);
				theCanvas.graphics.lineTo(w - deltaPos.x, deltaPos.y);
			}
			else
			{
				//Drawing skin : little line that join big line and content
				theCanvas.graphics.lineStyle(timeLineWeight/2,colorDark,1,false,"normal",CapsStyle.SQUARE);
				theCanvas.graphics.moveTo(deltaPos.x + xGap - 5, h - deltaPos.y);
				theCanvas.graphics.lineTo(deltaPos.x + xGap - 5, h - deltaPos.y - yGap);
				theCanvas.graphics.lineTo(deltaPos.x + xGap, h - deltaPos.y - yGap);
				
				//Drawing skin : big line that shows time
				theCanvas.graphics.lineStyle(timeLineWeight,colorDark,1,false,"normal",CapsStyle.SQUARE);
				theCanvas.graphics.moveTo(deltaPos.x, h - deltaPos.y);
				theCanvas.graphics.lineTo(w - deltaPos.x, h - deltaPos.y);
			}
		
			//Effects
			if(_editMode)
				theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,1,10,10)];
			else
				theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,.4,5,5)];
			
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
	
		
		public function onUsrTextChange(e:Event = null):void
		{
			invalidateSize();
			theCloseBtn.selected = true;
		}
		
		public function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == 13 || e.keyCode == 27) // Return or escape
			{
				if(e.keyCode == 13) // si return
					onSaveAndClose();
				
				if(e.keyCode == 27) // if escape
				{
					//TODO
					Alert.show("TODO, escape key should close the marker edition window or delete the marker if it is blank (no text) and new (less thant 2 secs)");
				}
				
				//we stop the propagation of event then the keystrokes are not taken into account in the textArea
				e.stopImmediatePropagation(); 
				e.stopPropagation();
			}	
		}
		
		public function onDelete(e:Event = null):void
		{
			setPreview();
			if(parentLine.contains(this))
				parentLine.removeChild(this);
			
			model.deleteMarker(traceData);
		}
		
		public function onSave(e:Event = null):void
		{
			if(!oldTextValue ||  oldTextValue != theText.text)
				_model.saveMarker(traceData.props["timestamp"], theText.text, traceData);
		}
		
		public function onSaveAndClose(e:Event = null):void
		{

			setPreview();
			onSave(e);
		}
		
		protected function setPreview(e:Event = null):void
		{
			_editMode = false;

			theText.editable = false;
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			theText.removeEventListener(FocusEvent.FOCUS_OUT, onSaveAndClose);
			
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
			
			theText.editable = this.editable;
			
			this.removeEventListener(MouseEvent.CLICK,onClick);
			theText.addEventListener(FocusEvent.FOCUS_OUT, onSaveAndClose);
			focusManager.setFocus(theText);
			
			theCloseBtn.visible = false;
			theCloseBtn.selected = false;
			
			theText.verticalScrollPolicy = "auto";
			
			oldTextValue = theText.text;
			
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
			if(theText && traceData && traceData.props && traceData.props["text"])
				theText.text = traceData.props["text"];
		}
		
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
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_ZOOM_ON, this, traceData.props["timestamp"]));
		}
		
		private function onGoto(e:Event = null):void
		{
			this.dispatchEvent(new InternalTimelineEvent(InternalTimelineEvent.ITEM_GOTO_AND_PLAY, this, traceData.props["timestamp"]));
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
