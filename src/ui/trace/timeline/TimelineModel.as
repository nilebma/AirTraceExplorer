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
package ui.trace.timeline
{
	import com.ithaca.traces.Obsel;
	import com.ithaca.traces.Trace;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.styles.StyleManager;
	import mx.utils.ObjectProxy;
	
	import ui.trace.timeline.events.TimelineEvent;
	
    [Event(name=TimelineEvent.SET_TIME     , type="TimelineEvent.Event")]
	[Event(name=TimelineEvent.START        , type="TimelineEvent.Event")]
	[Event(name=TimelineEvent.PLAY         , type="TimelineEvent.Event")]
	[Event(name=TimelineEvent.PAUSE        , type="TimelineEvent.Event")]
	[Event(name=TimelineEvent.SET_MARKER   , type="TimelineEvent.Event")]
	[Event(name=TimelineEvent.DELETE_MARKER, type="TimelineEvent.Event")]
    public class TimelineModel extends EventDispatcher
	{
		[Bindable]
		private var _visutrace:Trace;
		
		///////////////////////////////////////////////////////////
		/*						CONST							*/
		///////////////////////////////////////////////////////////
		public static const MODE_STOP: String='stop'
		public static const MODE_RECORD: String='record';
		public static const MODE_REPLAY: String='replay';

		
		///////////////////////////////////////////////////////////
		/*						MODEL							*/
		///////////////////////////////////////////////////////////
		
	    [Bindable]
	    private var _traceData:ArrayCollection;

	    [Bindable]
	    public var currentUserId: uint;
		
	    [Bindable]
	    public var markerData:ArrayCollection;
	
	    [Bindable]
	    public var usersData:ArrayCollection;
		
	    [Bindable]
	    public var commentData:ArrayCollection;
		
	    [Bindable]
	    private var timer:Timer;
		
	    [Bindable]
	    public var startTime:Number = 0;
		
	    [Bindable]
	    public var stopTime:Number = 600000; //default duration is set to 10 minutes
		
	    [Bindable]
	    public var duration:Number = 600000; //default duration is set to 10 minutes
		
        // Current session time, in ms since 1970
	    [Bindable]
	    public var currentTime: Number = 0;
		
        private var _modeReplay:Boolean = false;
		
		private var _modeRecord:Boolean = false;
		
		private var _modeMoveTextComment:Boolean = false;
		
		[Bindable]
		public var isPlaying:Boolean = false;
		private var _lastObselComment:Obsel;
		private var _obselStartSession:Obsel;

		///////////////////////////////////////////////////////////
		/*						GENERAL							*/
		///////////////////////////////////////////////////////////
 		public function getLastEditObselComment():Obsel{
			return _lastObselComment;
		}
		public function setLastEditObselComment(value:Obsel):void{
			_lastObselComment = value;
		} 
		public function getStartSessionObsel():Obsel{
			return _obselStartSession;
		}
		[Bindable]
		public function get traceData():ArrayCollection
		{
			return _traceData;
		}

		public function set traceData(value:ArrayCollection):void
		{
			_traceData = value;
			markerData = new ArrayCollection();
			
			processObsels(value as Array);
		}

        /**
         * Set current relative time, in ms from the session start.
         */
		public function set currentSessionTime(t: Number): void
        {
            currentTime = t + startTime;
        }

        /**
         * Get current relative time, in ms from the session start.
         */
		public function get currentSessionTime(): Number
        {
            return currentTime - startTime;
        }

		[Bindable(event="changeMyProp")]
		public function get modeRecord():Boolean
		{
			return _modeRecord;
		}

		public function set modeRecord(value:Boolean):void
		{
			_modeRecord = value;
			
			if(value)
				_modeReplay = false;
			
			dispatchEvent(new Event("changeMyProp"));
		}
		
		[Bindable(event="changeMyProp")]
		public function get modeReplay():Boolean
		{
			return _modeReplay;
		}

		public function set modeReplay(value:Boolean):void
		{
			_modeReplay = value;
			
			if(value)
				_modeRecord = false;
			
			dispatchEvent(new Event("changeMyProp"));
		}

		public function get visutrace():Trace
		{
			return _visutrace;
		}

		public function set visutrace(value:Trace): void
		{
			_visutrace = value;
            traceData = value.getObselsAsArayCollection();
			traceData.addEventListener(CollectionEvent.COLLECTION_CHANGE, onTraceUpdate);
		}
		
		/**
		 * This function is called when the traceData (Obsels ArrayCollection) is changed.
		 * It could be use to update data or graphical component based on this the Traces.
		 * 
		 * @param e A CollectionEvent dispatched by an obsels ArrayCollection
		 * 
		 * */
		public function onTraceUpdate(e: CollectionEvent): void
		{
			if(e.kind == CollectionEventKind.ADD)
			{
                processObsels(e.items);
			}
		}
		
		public function presentUserIdOnSeance(value:String):Boolean
		{
			/*var listPresentIdUser:Array =  _obselStartSession.props["presentids"] as Array; 
			if (listPresentIdUser != null)
			{
				var nbrUser:uint = listPresentIdUser.length;
				for(var nUser:uint; nUser < nbrUser; nUser++)
				{
					var userId:String = listPresentIdUser[nUser];
					if(userId == value)
						return true;
				}
				return false;
			} else return true; */
			return false;
		}
        /**
         * Process an array of Obsels.
         *
         * @param obsels an Array of Obsels
         */
		public function processObsels(obsels: Array): void
        {
			/*for each (var item: Obsel in obsels)
			{
                // When a SessionStart obsel is added
                if(item.type == TraceModel.SessionStart)
                {
                    // have to save obsel, need info about uri the trace for adding the obsel type "TextComment"  
                    _obselStartSession = item;
                    if (!modeReplay)
					    modeRecord = true;
					setUsersFromSessionStartObsel(item);
					setTimingFromSessionStartObsel(item);					
				}
				
				// When a SessionEnd obsel is added
				if(item.type == TraceModel.SessionEnd)
				{
                    if (!modeReplay)
					    modeRecord = false;
					stopTime = item.begin;
					duration = stopTime - startTime;
					
					stopTimer();
				}
				
				//FIXME : add the capabilities to handle more than one session
				
				// When a setMarker is added
				if(item.type == TraceModel.ReceiveMark || item.type == TraceModel.SetMark)
				{
					treatMarkerObsel(item);				
				}
				
				// When a setMarker is deleted
				if(item.type == TraceModel.DeleteMark)
				{
					treatMarkerObsel(item);				
				}
				
				// When a setMarker is deleted
				if(item.type == TraceModel.RoomEnter || item.type == TraceModel.RoomExit)
				{
					treatUserPresence(item);				
				}

			}*/
			if (obsels != null){
				dispatchEvent(new Event("endProssesObsel"));
			}
        }
		

		/*private function orderUsersDataByStatus():void
		{
			for(var i:int = usersData.length - 1; i >= 0; i--)
			{
				var usr:ObjectProxy = usersData[i];
				if(usr.online == true)
				{
					usersData.removeItemAt(i);
				
					usersData.addItemAt(usr,0);
				}
			}
		}
		
		private function treatUserPresence(item:Obsel):void
		{
			if(item.props && item.props.hasOwnProperty("uid"))
			{
				var userId:int = int(item.props["uid"]);
				
				for each(var usr:ObjectProxy in usersData)
				{
					if(usr.id == userId)
					{
						if(item.type == TraceModel.RoomEnter)
						{
							usr.online = true;
						}
						
						if(item.type == TraceModel.RoomExit)
						{
							usr.online = false;
						}
						
						orderUsersDataByStatus();
					}

				}
			}
			
		}
		
		private function treatMarkerObsel(item:Obsel):void
		{
			var userId: uint;
			
			if(item.type  == TraceModel.SetMark)
				userId = item.uid;
			else if(item.type == TraceModel.ReceiveMark || item.type == TraceModel.DeleteMark)
				userId = item.props["sender"];
			
			var existingObsel: Obsel = getMarkerDataFromUserAndTimestamp( userId, Number(item.props["timestamp"]));
			
			if(item.type == TraceModel.SetMark || item.type == TraceModel.ReceiveMark)
			{
				if(existingObsel)
					existingObsel.props["text"] = item.props["text"];
				else
					markerData.addItem(item);
			} 
			
			if(item.type == TraceModel.DeleteMark)
			{
				if(existingObsel)
					deleteMarker(existingObsel);
			}
			
		}
		
		public function getMarkerDataFromUserAndTimestamp(userId:int, timestamp:Number):Obsel
		{
			for each(var m:Obsel in markerData)
			{
				if(m.type == TraceModel.SetMark && m.uid == userId && m.props["timestamp"] == timestamp)
					return m;
				
				if(m.type == TraceModel.ReceiveMark && m.props["sender"] == userId && m.props["timestamp"] == timestamp)
					return m;
			}
			return null;
		}
		
		private function setUsersFromSessionStartObsel(item:Obsel):void
		{
			if(!(item.type == TraceModel.SessionStart))
				return;
			
            // Old trace format
            if(! item.props["userids"])
                return;

			usersData = new ArrayCollection();
			
			for(var i:int = 0; i < (item.props["userids"] as Array).length; i++)
			{
				// FIXME : in the trace the etudiant property 'presentids' is empty,
				//         can't use it with model the trace version Visu 1.5
				//if ((presentUserIdOnSeance(item.props["userids"][i]))){
					
					var objectUser:ObjectProxy = new ObjectProxy();
					
					objectUser.id = item.props["userids"][i];
					objectUser.name = item.props["usernames"][i];
					
					objectUser.color = StyleManager.getColorName(item.props["usercolors"][i]);
					
					objectUser.online = isUserOnline(int(item.props["userids"][i])); //TODO : parse traceData and RoomEnter/RoomExit trace to know if the user is online or not
						
					objectUser.visible = true;
					
					usersData.addItem(objectUser);
				//}
			}
			
			orderUsersDataByStatus();
			
		}
				
		public function isUserOnline(userId:int):Boolean
		{
			var lastRoomEnter:Number = -2;
			var lastRoomExit:Number = -1;
			
			for each(var t:Obsel in traceData)
			{
				if(t.props && t.props.hasOwnProperty("uid") && int(t.props["uid"]) == userId)
				{
					var time:Number = t.begin;
					
					if(String(t.type) == TraceModel.RoomEnter)
						lastRoomEnter = time;
					
					if(String(t.type) == TraceModel.RoomExit)
						lastRoomExit = time;
				}
			}
			
			return (lastRoomEnter > lastRoomExit);
		}
		
		private function setTimingFromSessionStartObsel(obsel:Obsel):void
		{
			if(obsel.type == TraceModel.SessionStart)
			{
				startTime = obsel.begin;
				currentTime = startTime;
                if (obsel.props.duration != null)
                {
				    duration = obsel.props.duration;
                }
                else
                {
                    // Old trace format.
                    // Fallback to a default 40 minute session.
                    duration = 40 * 60 * 1000;
                }
				stopTime = startTime + duration;
				
				if(modeRecord)
					startTimer();
			}
		}*/

		
		
		public function TimelineModel(visutrace: Trace, uid: uint): void
		{
			if(visutrace)
            	this.visutrace = visutrace;
            // FIXME: this could be extracted from the PresenceStart obsel
			this.currentUserId = uid;
			markerData = new ArrayCollection();
			usersData = new ArrayCollection();
			commentData = new ArrayCollection();
		}
		
        /*public function setCommentData(traceComment:Trace):void
        {
            if(traceComment.obsels.source.length > 0)
            {
                var tempTraceUriComment:String = traceComment.obsels.source[0].traceUri as String;
                VisuModelLocator.getInstance().setTraceUriComment(tempTraceUriComment);
                for each(var obsel:Obsel in traceComment.obsels.source)
                {
                    this.commentData.addItem(obsel);
			    } 
			    this.dispatchEvent(new Event("textCommentObselComplet"));
            }else
            {
                VisuModelLocator.getInstance().setTraceUriComment("");
            } 
		}
		public function setModeMoveTextComment(value:Boolean):void
		{
			_modeMoveTextComment = value;
		}
		public function getModeMoveTextComment():Boolean
		{
			return _modeMoveTextComment;
		}*/
		
		///////////////////////////////////////////////////////////
		/*						MODEL HELPER					*/
		///////////////////////////////////////////////////////////
		
		/*public function getUserFromName(userName:String):User
		{
			if(usersData)
			{
				for each(var usr:User in usersData)
					if(usr.id == Number(userName))
						return usr;
			}
			
			return null;
		}*/
		
		
		public function updateTime(e:TimerEvent):void
		{
			currentTime = new Date().time;
		}
		
		
		/*public function setUserVisibility(userId:int, isVisible:Boolean):void
		{
			for each(var item:ObjectProxy in usersData)
				if(item["id"] == userId)
					item["visible"] = isVisible;
		}
		
		public function getUserVisibility(userId:int):Boolean
		{
			for each(var item:ObjectProxy in usersData)
				if(item["id"] == userId)
					return item["visible"];
				
			return true;
		}*/
		
		public function getUserColor(userId:int):uint
		{
			/*for each(var item:ObjectProxy in usersData)
				if(item["id"] == userId)
					return item["color"];*/
			
            // Fallback for old traces
			return 0x4444ff;
		}
		
		
		///////////////////////////////////////////////////////////
		/*						INTERFACE WITH VIEWS			*/
		///////////////////////////////////////////////////////////

		
		///////////////////////////////////////////////////////////
		/*						CONTROLS				 		*/
		///////////////////////////////////////////////////////////
		
		/**
		 * lancement de session :
		 * 	- dessin de l'activité en cours
		 *  - lancement du timer "de rafraichissement"
		 * */
		private function startTimer():void
		{
			if(!timer)
			{
				timer = new Timer(200,0);
				timer.addEventListener(TimerEvent.TIMER, updateTime);
			}
			timer.start();
		}
		
		/**
		 * Fin de session :
		 * 	- arret du timer
		 *  - finalisation activité en cours
		 * */
		
		private function stopTimer():void
		{
			if (timer)
				timer.stop();
		}
		
		/**
		 * ajout d'une activité
		 * - si timeStamp est null alors on rajoute au temps courant
		 * */
		/*public function addActivity( title:String, duration:Number = 12000, timeStamp:Number = NaN ):void
		{
			if(isNaN(timeStamp))
				timeStamp = currentTime;
			
			//traceData.addItem({"type":"activity", "startTime":timeStamp,"stopTime":-1, "duration":duration, "title":title});
		}*/
		
		
		/**
		 * ajoute un item "marqueur"
		 * - si timeStamp est null alors on rajoute le marqueur au temps courant
		 * */
		/*public function addMarqueur( user:String , pText : String = "", timeStamp:Number = NaN, userJustAdded:Boolean = false ):void
		{
			if(isNaN(timeStamp))
				timeStamp = currentTime;
			
			if(user)
			{
				var newObs:Obsel = new Obsel(TraceModel.SetMark, Number(user), "",{"text":pText, "timestamp":timeStamp, "userJustAdded": userJustAdded }, timeStamp, timeStamp);
				markerData.addItem(newObs);
			}
		}
		
		public function addMarqueurFromCurrentUserNow():void
		{
			addMarqueur(currentUserId.toString(), "", NaN, true);
		}
		
		public function onMarkerDisplayed(targetObsel:Obsel):void
		{
			if(targetObsel)
			{
				//If the obsel bleong to temporary trace data
				if(markerData.contains(targetObsel))
				{
					//We update it
					var i:int = markerData.getItemIndex(targetObsel);
					markerData.getItemAt(i)["props"]["userJustAdded"] = false;	
				}
			}
		}
		

		public function saveMarker(timestamp: Number, text: String, targetObsel: Obsel = null):void
		{
			var e:TimelineEvent = new TimelineEvent(TimelineEvent.SET_MARKER, timestamp, currentUserId, text);

			this.dispatchEvent(e);
			trace("setMarker event sent with " + timestamp + " timestamp");
			
			if(targetObsel)
			{
				//If the obsel bleong to temporary trace data
				if(markerData.contains(targetObsel))
				{
					//We update it
					var i:int = markerData.getItemIndex(targetObsel);
					markerData.getItemAt(i)["props"]["text"] = text;	
				}
			}
		}
		public function saveTextCommentObselPossitionBeginEnd(timeStampBegin:Number, targetObsel:Obsel, timeStampEnd:Number, update:Boolean=false):void
		{
			if(targetObsel)
			{
				if(commentData.contains(targetObsel))
				{
					//Update timeStamp
					var i:int = commentData.getItemIndex(targetObsel);
					commentData.getItemAt(i)["begin"] = timeStampBegin;	
					commentData.getItemAt(i)["end"] = timeStampEnd;	
					
				}
			}
			if ( targetObsel.sgbdobsel != null  && update)
			{
				// Update obsel
				var eventUpdateMarker:TimelineEvent = new TimelineEvent(TimelineEvent.UPDATE_COMMENT, 0 , 0, "", targetObsel );
				this.dispatchEvent(eventUpdateMarker);
				trace("updateMarker event sent with new timeStampBegin = " + timeStampBegin.toString());
				trace("updateMarker event sent with new timeStampEnd = " + timeStampEnd.toString());
			}
			
		}
		public function saveComment(text:String, targetObsel:Obsel = null):void
		{
			if(targetObsel)
			{
				if(commentData.contains(targetObsel))
				{
					//We update text
					var i:int = commentData.getItemIndex(targetObsel);
					commentData.getItemAt(i)["props"]["text"] = text;	
				}
			}
			// If obsel existe in BD
			if ( targetObsel.sgbdobsel != null  )
			{
				// Update obsel
				var eventUpdateMarker:TimelineEvent = new TimelineEvent(TimelineEvent.UPDATE_COMMENT, 0 , 0, text, targetObsel );
				this.dispatchEvent(eventUpdateMarker);
				trace("updateMarker event sent with text = " + text);
			}else
			{
				// Add obsel
				var eventSetMarker:TimelineEvent = new TimelineEvent(TimelineEvent.SET_COMMENT, 0, 0, text, targetObsel);
				this.dispatchEvent(eventSetMarker);
				trace("setMarker event sent with text = " + text );
			}
		}
		public function deleteMarker(targetObsel:Obsel):void
		{
			if(targetObsel)
			{
				//If the obsel bleong to temporary trace data
				if(markerData.contains(targetObsel))
				{
					//We remove it from the temporary trace data
					var i:int = markerData.getItemIndex(targetObsel);
					markerData.removeItemAt(i);	
					//We send a event to the application
					var e:TimelineEvent = new TimelineEvent(TimelineEvent.DELETE_MARKER,targetObsel.props["timestamp"],currentUserId);
					this.dispatchEvent(e);
					trace("delete event sent with " + targetObsel.props["timestamp"] + " timestamp");
				}
			}
		}
        
        public function deleteComment(targetObsel:Obsel):void
        {
            if(targetObsel)
            {
                if(commentData.contains(targetObsel))
                {
                    //We remove it from the comment trace data
                    var i:int = commentData.getItemIndex(targetObsel);
                    commentData.removeItemAt(i);	
                    // If obsel existe in BD
                    if(targetObsel.sgbdobsel != null)
                    {
                        //We send a event to the application
                        var e:TimelineEvent = new TimelineEvent(TimelineEvent.DELETE_COMMENT,targetObsel.sgbdobsel.id,currentUserId,"", targetObsel);
                        this.dispatchEvent(e);
                        trace("delete event sent with id = " + targetObsel.sgbdobsel.id.toString());
                    }
                }
            }
        }*/
		
		public function firePauseEvent():void
		{
			var e:TimelineEvent = new TimelineEvent(TimelineEvent.PAUSE, currentTime, currentUserId);
			this.dispatchEvent(e);
		}
		
		public function firePlayEvent():void
		{
			var e:TimelineEvent = new TimelineEvent(TimelineEvent.PLAY, currentTime, currentUserId);
			this.dispatchEvent(e);
		}

		/**
         * Seek 
         */
		public function setCurrentTime(t:Number):void
		{
			var e:TimelineEvent = new TimelineEvent(TimelineEvent.SET_TIME, t, currentUserId);
			this.dispatchEvent(e);
		}
		
		
	}
}
