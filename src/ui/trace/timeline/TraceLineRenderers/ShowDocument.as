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
package TraceUI.timeline.TraceLineRenderers
{
	import com.ithaca.traces.Obsel;
	import com.lyon2.visu.model.TraceModel;
	import ithaca.traces.timeline.Utils.ColorShowDocument;
	
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.utils.ColorUtil;
	
	public class ShowDocument extends BaseRenderer
	{
	
		//the subcomponents
		
		private var theCanvas:Canvas;
		
		public var theText:TextArea;
		
		public var theMedia:ColorShowDocument;
		
		public var theCloseBtn:Button;
	
		
		//some properties
		
		private var viewMode:Boolean = false;
		
		public var deltaPos:Point = new Point(3,6);
		
		public var textBorder:Point = new Point(2,2);
		
		public var viewWidth:Number = 90;
		
		//Embeding assets
		[Embed(source="timeline/delete_16.png")]
		private var closeImage:Class;
		
		private var popupShowDocument:WindowShowDocument;
		private static var DELTA_X_SHOW_DOCUMENT:Number = - 10;
		private static var DELTA_Y_SHOW_DOCUMENT:Number = 0;
		
		
		public function ShowDocument()
		{
			selfSized = true;
			selfPositioned = false;
			
			super();

			this.height = 30;
			this.addEventListener(MouseEvent.MOUSE_OVER , onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT , onMouseOut);
		}
		private function onMouseOver(event:MouseEvent):void
		{
				popupShowDocument = new WindowShowDocument();
				popupShowDocument.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplet);
                Application.application.vManager.addChild(popupShowDocument);
 		}
		private function onCreationComplet(event:FlexEvent):void
		{
			popupShowDocument.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplet);	
			var uriMedia:String = traceData.props["url"];
			popupShowDocument.addEventListener("EndResize" , onEndResizeShowDocument);
			popupShowDocument.setMedia(uriMedia);
			
		}
		private function onEndResizeShowDocument(event:Event):void
		{
			popupShowDocument.removeEventListener("EndResize" , onEndResizeShowDocument);	
			var pointISD:Point = this.parent.localToGlobal(new Point(this.x , this.y))
			// show image close to obsel
            popupShowDocument.x = pointISD.x-popupShowDocument.width+DELTA_X_SHOW_DOCUMENT;
            popupShowDocument.y = pointISD.y-popupShowDocument.height/2+DELTA_Y_SHOW_DOCUMENT;			
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			if(Application.application.vManager.contains(popupShowDocument))
			{
				Application.application.vManager.removeChild(popupShowDocument);
			}
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
				
				setText();
				
				theText.editable = false;
			}
			
			if(!theCloseBtn)
			{
				theCloseBtn = new Button();
				theCloseBtn.setStyle("upSkin",closeImage);
				theCloseBtn.setStyle("overSkin",closeImage);
				theCloseBtn.setStyle("downSkin",closeImage);
				theCloseBtn.useHandCursor = true;
				theCloseBtn.buttonMode = true;
				theCloseBtn.addEventListener(MouseEvent.CLICK, hideText);
				theCloseBtn.visible = false;
				
				theCanvas.addChild(theCloseBtn);

			}
			
			if(!theMedia)
			{
				theMedia = new ColorShowDocument()
				theMedia.useHandCursor = true;
				theMedia.buttonMode = true;
				theMedia.addEventListener(MouseEvent.CLICK, showText);
				theMedia.visible = true;
				theCanvas.addChild(theMedia);
				setPencilColor();
			}
		}
		
		public function showText(e:Event = null):void
		{
			//changing some properties
			viewMode = true;
			theCanvas.addChild(theText);
			
			theCloseBtn.visible = true;
			// hide the image of the resived document
			onMouseOut(null);
			//Putting the component on the top
			var toPoint:Point = this.parent.localToGlobal(new Point(this.x,this.y).add(deltaPos));
			
			theCanvas.x = toPoint.x;
			theCanvas.y = toPoint.y;
			
			if(this.contains(theCanvas))
			{
				this.removeChild(theCanvas);
			}
			
			Application.application.addChild(theCanvas);
			
			theText.addEventListener(FocusEvent.FOCUS_OUT, hideText);
			focusManager.setFocus(theText);
			
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		public function hideText(e:Event = null):void
		{
			viewMode = false;
			
			theCloseBtn.visible = false;
			
			if(theCanvas.contains(theText))
				theCanvas.removeChild(theText);
			
			//removing the component from the top
			theText.removeEventListener(FocusEvent.FOCUS_OUT, hideText);
			this.addChild(theCanvas);
			
			
			invalidateSize();
			invalidateDisplayList();
		}

		
		override protected function measure() : void
		{
			super.measure();
			
			//We determine the height & width to set
			var toHeight:Number = 40;//this.parentLine.width;
			var toWidth:Number = 40;//this.parentLine.width;	
			
			if(viewMode)
			{	
				toHeight += theText.textHeight + 12 + theCloseBtn.height;
				toWidth = viewWidth;
			}
			
			//applying height & width
			measuredMinWidth = toWidth;
			measuredWidth = toWidth;
			explicitHeight = toHeight;

		}
		
		override protected function updateDisplayList(w:Number, h:Number):void 
		{
			super.updateDisplayList(w,h);
			
			//some internal properties
			var darkenValue: uint = 0;
			if(viewMode)
				darkenValue = 20;
			
			var timeLineWeight:Number = 4;
			
			var theCloseBtnHeight:Number = 0;
			if(viewMode)
				theCloseBtnHeight = theCloseBtn.height - 3;
			
			//We set the dimensions & positions of the canvas
			theCanvas.height = h - 2*deltaPos.y;
			theCanvas.width = w - 2*deltaPos.x;
			if(!viewMode)
			{
				theCanvas.x = deltaPos.x;
				theCanvas.y = deltaPos.y;
			}
			theCanvas.validateNow();
			
			//we calculate the space available for content
			var contentHeight:Number = h - 2*deltaPos.y;
			var contentWidth:Number = w - 2*deltaPos.x;
			
			theCanvas.graphics.clear();
			
			if(viewMode)
			{
				theCloseBtn.x = w - deltaPos.y - theCloseBtn.width; 	
				theCloseBtn.y = deltaPos.x + 2;
			
				//We set the dimensions & positions of the text
				theText.width = contentWidth - 2*textBorder.x;
				theText.height = contentHeight - 2*textBorder.y - theCloseBtnHeight;
				theText.x = deltaPos.x + textBorder.x;
				theText.y = theCloseBtnHeight + deltaPos.y + textBorder.y;
			
				//Setting colors
				var color:uint = getUsrColor();
				color = ColorUtil.adjustBrightness(color,-darkenValue);
				var colorDark:uint = ColorUtil.adjustBrightness(color,-30-darkenValue);
				var colorBright:uint = ColorUtil.adjustBrightness(color,40);
			
				//Drawing skin
				
				 
				//Drawing skin : background
				var myMatrix:Matrix = new Matrix();
				myMatrix.createGradientBox(contentWidth,contentHeight, Math.PI / 2);
				theCanvas.graphics.lineStyle(1,colorDark);
				theCanvas.graphics.beginGradientFill(GradientType.LINEAR, [colorBright, color], null, null, myMatrix);
				theCanvas.graphics.drawRoundRectComplex(deltaPos.x, deltaPos.y + timeLineWeight/2,contentWidth,contentHeight,0,0,6,6);
				theCanvas.graphics.endFill();
			
				//Effects
				if(viewMode)
					theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,1,10,10)];
				else
					theCanvas.filters = [new DropShadowFilter(0, 45,0x000000,.4,5,5)];
			
			}
		}	
		
		override public function set traceData(value:Obsel):void
		{
			super.traceData = value;

		 	setText();
			setPencilColor();
			
			invalidateDisplayList();
			invalidateSize(); 
		}
		
		override public function traceDataUpdate(e:Event = null):void
		{
 			setText();
			setPencilColor(); 
			
			invalidateDisplayList();
			invalidateSize();
		}
		
		private function setText():void
		{
			if(theText && traceData && traceData.props)
				theText.text = traceData.props["url"];
		}

		private function setPencilColor():void
		{
			if(theMedia && traceData && traceData.type && traceData.props)
			{
					var uriMedia:String = traceData.props["url"];
					theMedia.setUrlMedia(uriMedia);
			}
		}
		
		private function getUsrColor():uint
		{
			if(theMedia && traceData && traceData.type && traceData.props)
			{	
				if(traceData.type == TraceModel.ShowDocument && traceData.props["sender"])
					return model.getUserColor(Number(traceData.props["sender"]));
			}
			
			return null;
		}
		
		private function onZoom(e:Event = null):void
		{
			//TODO
			Alert.show("zoom pas encore intégré");
		}

	}
}
