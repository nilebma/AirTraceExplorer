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
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class RectangleRenderer extends BaseRenderer
	{

		public function RectangleRenderer()
		{
			super();

			selfSized = true;
			selfPositioned = false;
			height = 20;
		}
	
		override public function traceDataUpdate(e:Event=null) : void
		{
			update();	
		}
		
		override public function modelUpdate(e:Event=null) : void
		{
			update();	
		}
		
		
		private function drawRect(pos:Number,size:Number):void
		{
			if(isNaN(size))
				return;
			
			if(direction == "vertical")
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xA4A6A8, 0x434545],null,null,verticalGradientMatrix(0,0,parentLine.width,size));
				
				this.graphics.drawRoundRect(0,pos,parentLine.width,size,4,4);
				
			}
			else
			{
				//this.graphics.beginGradientFill(GradientType.LINEAR,[0xA4A6A8, 0x434545],null,null,horizontalGradientMatrix(0,0,size,parentLine.height));
				
				this.graphics.beginFill(0xFF0000);
				this.graphics.drawRect(0,0,size,10);
				//this.graphics.drawRoundRect(0,pos,size,20,4,4);
				
				
			}
			
			this.graphics.endFill();
		}
			
		
		override public function update():void
		{
			if(traceData && parentLine)
			{
				/*if(direction == "vertical")
					this.width = parentLine.width;
				else
					this.height = 20;
				*/
				
				
				this.graphics.clear();
				
				var toSize:Number;
				
				var beginPos:Number = parentLine.getPosFromTime(traceData["begin"]);
				var endPos:Number;
				
				if(endTraceData)
					endPos = parentLine.getPosFromTime(endTraceData["begin"]);
				else
					endPos = parentLine.getPosFromTime(traceData["end"]);
								
				
				drawRect(beginPos, Math.max(1,endPos - beginPos));
				
				//this.validateNow();
	

			}
		}
		
	}
}
