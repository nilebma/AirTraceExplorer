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
	
	public class ActivityRenderer extends BaseRenderer
	{
		public var drawFuturActivity:Boolean = false;
		
		
		public function ActivityRenderer()
		{
			super();

			selfSized = true;
			selfPositioned = false;
		}
	
		override public function traceDataUpdate(e:Event=null) : void
		{
			update();	
		}
		
		override public function modelUpdate(e:Event=null) : void
		{
			update();	
		}
		
		private function drawCurrentActivityRect(pos:Number,size:Number):void
		{
			if(isNaN(size))
			 	return;
			
			if(direction == "vertical")
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xD2DA9F, 0x95AD4F],null,null,verticalGradientMatrix(0,0,this.width,size));
					
				this.graphics.drawRoundRect(0,pos,this.width,size,4,4);

			}
			else
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xD2DA9F, 0x95AD4F],null,null,horizontalGradientMatrix(0,0,size,this.height));
				
				this.graphics.drawRoundRect(0,pos,size,this.height,4,4);
				
				
			}
			
			this.graphics.endFill();
			
		}
		
		private function drawPastActivityRect(pos:Number,size:Number):void
		{
			if(isNaN(size))
				return;
			
			if(direction == "vertical")
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xA4A6A8, 0x434545],null,null,verticalGradientMatrix(0,0,this.width,size));
				
				this.graphics.drawRoundRect(0,pos,this.width,size,4,4);
				
			}
			else
			{
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xA4A6A8, 0x434545],null,null,horizontalGradientMatrix(0,0,size,this.height));
				
				this.graphics.drawRoundRect(0,pos,size,this.height,4,4);
				
			}
			
			this.graphics.endFill();
		}
		
		private function drawFuturActivityRect(pos:Number,size:Number):void
		{
			if(isNaN(size))
				return;
			
			this.graphics.beginFill(0xA4A4A4);
			
			if(direction == "vertical")
			{
				this.graphics.drawRoundRect(0,pos,this.width,size,4,4);
			}
			else
			{
				this.graphics.drawRoundRect(0,pos,size,this.height,4,4);
			}
			
			this.graphics.endFill();
		}
		
		private function drawLatenessActivityRect(pos:Number,size:Number):void
		{
			if(isNaN(size))
				return;
			
			var myMatrix:Matrix = new Matrix();
			
			if(direction == "vertical")
			{
				myMatrix.createGradientBox(this.width,size,Math.PI / 4);
				
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xF2912C, 0xF2912C],[.6,.1],[50,255],horizontalGradientMatrix(0,0,this.width,size));
				
				this.graphics.drawRoundRect(0,pos,this.width,size,4,4);
			}
			else
			{
				myMatrix.createGradientBox(size,this.height,Math.PI / 4);
				
				this.graphics.beginGradientFill(GradientType.LINEAR,[0xF2912C, 0xF2912C],[.6,.1],[50,255],horizontalGradientMatrix(0,0,size,this.height));
				
				this.graphics.drawRoundRect(0,size,this.height,size,4,4);
			}
			
			this.graphics.endFill();
		}
			
		
		override public function update():void
		{
			if(model && traceData && parentLine)
			{
				this.graphics.clear();
				

				
				var futurSize:Number;
				

				//if the activity has an end (is past)
				if(isNaN(parentLine.getPosFromTime(model["currentTime"])))
				{
					if(direction == "vertical")
						this.height = 0;
					else
						this.width = 0;
				}
				if(endTraceData && !isNaN(parentLine.getPosFromTime(endTraceData["begin"])))
				{	
					var toSize:Number = parentLine.getPosFromTime(endTraceData["begin"]) - parentLine.getPosFromTime(traceData["begin"]);
					drawPastActivityRect(0, toSize - 5);
					
					this.height = toSize;
				}
				//if the activity has not been started
				else if(model["currentTime"] < traceData["begin"] && !isNaN(parentLine.getPosFromTime(model["currentTime"])))
				{
					if(drawFuturActivity)
					{
						futurSize = parentLine.getPosFromTime(traceData["begin"] + traceData.props["duration"]) - parentLine.getPosFromTime(traceData["begin"]);
						drawFuturActivityRect(0, futurSize - 5);
					}
					
				}
				else if(!isNaN(parentLine.getPosFromTime(model["currentTime"])))
				{
					futurSize = parentLine.getPosFromTime(traceData["begin"] + traceData.props["duration"]) - parentLine.getPosFromTime(traceData["begin"]);
					drawFuturActivityRect(0, futurSize - 5);
					
					var currentSize:Number = parentLine.getPosFromTime(model["currentTime"]) - parentLine.getPosFromTime(traceData["begin"]);
					drawCurrentActivityRect(0,Math.max(currentSize,0));
					
					//if the activity is nt finished and we are late 
					if( traceData.props["duration"] < model["currentTime"] - traceData["begin"])
					{
						var latePos:Number = futurSize;
						var lateSize:Number = parentLine.getPosFromTime(model["currentTime"]) - parentLine.getPosFromTime(traceData["begin"] + traceData.props["duration"]);
						drawLatenessActivityRect(latePos, lateSize);
					}
					
					if(direction == "vertical")
						this.height = Math.max(currentSize, futurSize);
					else
						this.width = Math.max(currentSize, futurSize);
				}
				
	
				if(direction == "vertical")
					this.width = parentLine.width;
				else
					this.height = parentLine.height;

				
				this.validateNow();
				
			}
		}
		
	}
}
