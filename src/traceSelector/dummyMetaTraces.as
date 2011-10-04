package traceSelector
{
	import com.ithaca.traces.Attribute;
	import com.ithaca.traces.Obsel;
	import com.ithaca.traces.ObselCollection;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	
	[Bindable]
	public class dummyMetaTraces extends ObjectProxy
	{
		public function dummyMetaTraces()
		{
			super();
		}
		
		private var _obselCollections:ObselCollection;
		
		[Bindable]
		public var mapAttributeTypesToValues:Dictionary;
		
		[Bindable]
		public var mapAttributeTypesToObsels:Dictionary;
		
		[Bindable]
		public var mapValuesToAttributeTypes:Dictionary;
		
		[Bindable]
		public var mapValuesToObsels:Dictionary;
		
		[Bindable]
		public var mapTypesToObsels:Dictionary;
		
		[Bindable]
		public var arTypes:ArrayCollection;
		
		[Bindable]
		public var arAttributeTypes:ArrayCollection;
		
		[Bindable]
		public var arValues:ArrayCollection;
		
		public function get obselCollections():ObselCollection
		{
			return _obselCollections;
		}
		
		public function set obselCollections(value:ObselCollection):void
		{
			_obselCollections = value;
			inferMetaStructures();
		}
		
		private function inferMetaStructures():void
		{
			mapAttributeTypesToValues = new Dictionary();
			mapAttributeTypesToObsels = new Dictionary();
			mapValuesToAttributeTypes = new Dictionary();
			mapValuesToObsels = new Dictionary();
			mapTypesToObsels = new Dictionary();
			arTypes = new ArrayCollection();
			arValues = new ArrayCollection();
			arAttributeTypes = new ArrayCollection();
			
			for each(var o:Obsel in _obselCollections._obsels)
				considerNewObsel(o);
		}
		
		public function considerNewObsel(o:Obsel):void
		{
			if(!mapTypesToObsels[o.obselType])
			{
				mapTypesToObsels[o.obselType] = [];
				arTypes.addItem(o.obselType);
			}
			
			(mapTypesToObsels[o.obselType] as Array).push(o);
			
			for each(var a:Attribute in o.attributes)
			{

				if(!mapAttributeTypesToValues[a.attributeType])
				{
					mapAttributeTypesToValues[a.attributeType] = [];
					mapAttributeTypesToObsels[a.attributeType] = [];
					arAttributeTypes.addItem(a.attributeType);
				}
				
				(mapAttributeTypesToValues[a.attributeType] as Array).push(a.value);
				(mapAttributeTypesToObsels[a.attributeType] as Array).push(o);
				
				if(!mapValuesToObsels[a.value])
				{
					mapValuesToObsels[a.value] = [];
					mapValuesToAttributeTypes[a.value] = [];
					arValues.addItem(a.value);
				}
				
				(mapValuesToObsels[a.value] as Array).push(o);
				(mapValuesToAttributeTypes[a.value] as Array).push(a.attributeType);
			
			}
		}
	}
}