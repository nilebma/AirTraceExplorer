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
package ui.trace.timeline.events
{
	import com.ithaca.traces.Obsel;
	
	import flash.events.Event;
	


	public class TimelineEvent extends Event
	{

		public static const SET_TIME: String='setTime'
		public static const START: String='start';
		public static const PLAY: String='play';
		public static const PAUSE: String='pause';
		public static const SET_MARKER: String='setMarker';
		public static const SET_COMMENT: String='setComment';
		public static const DELETE_MARKER: String='deleteMarker';
		public static const DELETE_COMMENT: String='deleteComment';
		public static const UPDATE_MARKER: String='updateMarker';
		public static const UPDATE_COMMENT: String='updateComment';
		public static const TIMELINE_CREATION_COMPLETE: String='timelineCreationComplete';
		public static const OBSEL_CLICK: String='obselClick';
		public static const OBSEL_OVER: String='obselOver';
		
		public var userId: uint;
		public var message: String;
		public var timestamp: Number;
		public var obsel:Obsel;
		public var obselSet:Array;

		public function TimelineEvent (pType:String, timestamp: Number = 0, userId:uint = 0,  message:String = null, obsel:Obsel= null, obselSet:Array = null):void
        {
			this.timestamp = timestamp;
			this.message = message;
			this.userId = userId;
			this.obsel = obsel;
			this.obselSet = obselSet;
			super(pType);
		}

		override public function clone():Event{

			return new TimelineEvent(type, timestamp);
		}
	}
}
