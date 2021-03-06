package services
{
	import com.ithaca.traces.Base;
	import com.ithaca.traces.Ktbs;
	import com.ithaca.traces.Model;
	import com.ithaca.traces.Resource;
	import com.ithaca.traces.utils.RDFconverter;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectProxy;

	
	
	

	
	public class TtlLoader extends ObjectProxy
	{
		
		protected var arTtl:Array = [];
		
		[Bindable]
		public var loading:Boolean = false;
		
		[Bindable]
		public var loadedTraces:Array = null;
		
		protected var mapLoaderToUrlAndBase:Dictionary = new Dictionary();
		
		protected var mapUrlToLoadedTraces:Dictionary = new Dictionary();
		
		protected var nbLoading:uint = 0;
		
		protected var loadingTtl:ArrayCollection = new ArrayCollection();
        
        private var nbParsing:Number = 0;
        
        private var nbRequest:Number = 0;
		
		
		public function TtlLoader()
		{
			super();
		}
		
		public function loadTTL(url:String, pBase:Base,  pModel:Model, forceReload:Boolean = false):void
		{
			arTtl.push(url);

			if(url && pBase && (loadingTtl.getItemIndex(url) < 0) && (forceReload || mapUrlToLoadedTraces[url] == null) )
			{
                trace("ttlloader", "request", nbRequest++, url);
				var loader:URLLoader = new URLLoader();
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, onCallComplete);
				loader.load(new URLRequest(url));
				this.loading = true;
				mapLoaderToUrlAndBase[loader] = {"url":url,"base":pBase,"model":pModel};
				nbLoading++;
				loadingTtl.addItem(url);
			}
			
		}
		
		public function getLoadedTraceFromUrl(ttlUrl:String)
		{
			return mapUrlToLoadedTraces[ttlUrl];
		}
		
		private function onCallComplete(event:Event):void 
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var trace_ttl:String = loader.data;
			
			var urlTtl:String = null;
			var theBase:Base= null;
            var theModel:Model= null;
			
			for each(var t:String in arTtl)
			{
				if(t == mapLoaderToUrlAndBase[loader]["url"])
				{
					urlTtl = mapLoaderToUrlAndBase[loader]["url"];
					theBase = mapLoaderToUrlAndBase[loader]["base"];
                    theModel = mapLoaderToUrlAndBase[loader]["model"];
					break;		
				}
			}
            
            trace("ttlloader", "parsing", nbParsing++, urlTtl);
			
            
            var parsingResult:Object;
            
            // Get hte correct path
            var file:File = File.documentsDirectory.resolvePath(encodeURIComponent(urlTtl));
            
            // read the file if it exists
            if(file.exists)
            {
                // FileStream for reading the file
                var fileStream:FileStream = new FileStream();
                // Open the file in read mode
                fileStream.open(file, FileMode.READ);
                // Read the ArrayCollection object of persons from the file
                
                
                var trace_json:String = fileStream.readObject() as String;
                //var trace_objects:Array = fileStream.readObject() as Array;
                
                var dp:Number = new Date().time;                
                var trace_objects:Array = JSON.parse(trace_json) as Array;
                
                var timeParsing:Number = new Date().time - dp;
                
                // Close the FileStream
                trace("parsing",timeParsing);
                
                fileStream.close();
                parsingResult =  RDFconverter.updateTraceBaseFromObjects(trace_objects, theBase, theModel);
            }
            else
                parsingResult =  RDFconverter.updateTraceBaseFromTurtle(trace_ttl, theBase, theModel);
            
            loadedTraces = parsingResult.traces;

			var re:ResultEvent = new ResultEvent(ResultEvent.RESULT,false,true,{"loadedTraces":parsingResult.traces,"theTtl":urlTtl,"objectified":parsingResult.object});
			mapUrlToLoadedTraces[urlTtl] = loadedTraces.traces;
			this.dispatchEvent(re);
			
			if(loadingTtl.getItemIndex(urlTtl) >= 0)
				loadingTtl.removeItemAt(loadingTtl.getItemIndex(urlTtl));
			
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