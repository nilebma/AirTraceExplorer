package services
{
	import com.ithaca.traces.Base;
	import com.ithaca.traces.Ktbs;
	import com.ithaca.traces.Model;
	import com.ithaca.traces.Resource;
	import com.ithaca.traces.utils.RDFconverter;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectProxy;
	
	import valueObjects.Ttl;
	

	
	public class TtlLoader extends ObjectProxy
	{
		
		public var theKtbs:Ktbs = new Ktbs("uriKtbs", Resource.RESOURCE_URI_ATTRIBUTION_POLICY_CLIENT_IS_KING);
		public var theBase:Base;
		public var theModel:Model;
		
		protected var arTtl:Array = [];
		
		[Bindable]
		public var loading:Boolean = false;
		
		[Bindable]
		public var loadedTraces:Array = null;
		
		protected var mapLoaderToUrl:Dictionary = new Dictionary();
		
		protected var nbLoading:uint = 0;
		
		protected var loadingTtl:ArrayCollection = new ArrayCollection();
		
		public function TtlLoader()
		{
			super();
		}
		
		public function loadTTL(pTtl:Ttl, pBase:Base):void
		{
			arTtl.push(pTtl);
			this.theBase = pBase;
			
			if(pTtl && theBase && (loadingTtl.getItemIndex(pTtl) < 0))
			{
				var loader:URLLoader = new URLLoader();
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, onCallComplete);
				loader.load(new URLRequest(pTtl.url));
				this.loading = true;
				mapLoaderToUrl[loader] = pTtl.url;
				nbLoading++;
				loadingTtl.addItem(pTtl);
			}
			
		}
		
		private function onCallComplete(event:Event):void 
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var trace_ttl:String = loader.data;
			
			loadedTraces =  RDFconverter.updateTraceBaseFromTurtle(trace_ttl, theBase);				
			
			
			var theTtl:Ttl = null;
			for each(var t:Ttl in arTtl)
			{
				if(t.url == mapLoaderToUrl[loader])
				{
					theTtl = t;
					break;		
				}
			}
			
			var re:ResultEvent = new ResultEvent(ResultEvent.RESULT,false,true,{"loadedTraces":loadedTraces,"theTtl":theTtl});
			this.dispatchEvent(re);
			
			if(loadingTtl.getItemIndex(theTtl) >= 0)
				loadingTtl.removeItemAt(loadingTtl.getItemIndex(theTtl));
			
			nbLoading--;
			
			if(nbLoading == 0)
				loading = false;
			
			//we create a new subtrace that will contain LDTSession Obsel, this obsel correspond to the different trace we have in the TTL
			/*var globalBegin:Number = subTraces[0]["begin"];
			var globalEnd:Number = subTraces[0]["end"];
			var sessionSubTraceUri:String = encodeURI("Sessions");
			for each(var subTrace:Object in subTraces)
			{
			var subTraceUri:String = (subTrace["uri"] as String);
			var theObsel:Obsel = new Obsel("sessionLDT",0,"",{"traceUid":subTraceUri.substr(1,subTraceUri.length-2)}, subTrace["begin"], subTrace["end"]);
			theObsel.traceUriFromRdf = sessionSubTraceUri;
			
			theTrace.addObsel(theObsel);
			}
			
			subTraces.addItem({"uri":sessionSubTraceUri, "activated":true, "begin":globalBegin, "end":globalEnd});*/
			
		}
	}

}