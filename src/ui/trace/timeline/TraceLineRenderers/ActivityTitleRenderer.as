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
	
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	import mx.utils.ObjectProxy;
	
	public class ActivityTitleRenderer extends BaseRenderer
	{
		public var drawFuturActivity:Boolean = false;
		
		private var theCanvas:Canvas;
		
		public function ActivityTitleRenderer()
		{
			selfSized = true;
			selfPositioned = false;
			
			super();
			
			theCanvas = new Canvas();
			theCanvas.verticalScrollPolicy = "off";
			theCanvas.horizontalScrollPolicy = "off";
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,drawTitle);
		}
		
		public function drawTitle(e:Event = null):void
		{
			if(traceData && traceData.props["label"] && parentLine)
			{
				
				theCanvas.height = this.height = 18;
				theCanvas.width = this.width = parentLine.width;
				
				/*theCanvas.setStyle("backgroundAlpha", .7);
				theCanvas.setStyle("backgroundColor", 0x000000);
				theCanvas.setStyle("cornerRadius",10);*/
			
				var myMatrix:Matrix = new Matrix();
				myMatrix.createGradientBox(this.width,this.height,0);
				
				theCanvas.drawRoundRect(0,0,this.width,this.height,{ tl: 4, tr: 4, bl: 0, br: 0 },
												[0x000000,0x000000],[.7,.1],myMatrix
												);
				
				var label:Label = new Label();
				label.setStyle("color",0xFFFFFF);
				label.setStyle("fontWeight","bold");
				label.setStyle("fontSize",11);
				//label.setStyle("fontFamily","Arial");
				label.text = traceData.props["label"]
				
				
				theCanvas.addChild(label);
				this.addChild(theCanvas);
			}
			
		}
		
		override public function set traceData(value:Obsel):void
		{
			_traceData = value;
			drawTitle();
		}
		
		override public function modelUpdate(e:Event = null):void
		{
			if(model["currentTime"] < model["startTime"] && !drawFuturActivity)
				this.visible = false;
			else
				this.visible = true;
		}
	}
}
