package traceSelector
{
	import com.ithaca.traces.Attribute;
	import com.ithaca.traces.AttributeType;
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
		public var mapAttributeTypesToObselTypes:Dictionary;
		
		[Bindable]
		public var mapValuesToAttributeTypes:Dictionary;
		
		[Bindable]
		public var mapValuesToObsels:Dictionary;
		
		[Bindable]
		public var mapValuesToObselTypes:Dictionary;
		
		[Bindable]
		public var mapTypesToObsels:Dictionary;
		
		[Bindable]
		public var mapTypesToAttributeTypes:Dictionary;
		
		[Bindable]
		public var mapTypesToValues:Dictionary;
		
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
		
		public function reset():void
		{
			mapAttributeTypesToValues = new Dictionary();
			mapAttributeTypesToObsels = new Dictionary();
			mapAttributeTypesToObselTypes = new Dictionary();
			mapValuesToAttributeTypes = new Dictionary();
			mapValuesToObsels = new Dictionary();
			mapValuesToObselTypes = new Dictionary();
			mapTypesToObsels = new Dictionary();
			mapTypesToAttributeTypes = new Dictionary();
			mapTypesToValues = new Dictionary();
			arTypes = new ArrayCollection();
			arValues = new ArrayCollection();
			arAttributeTypes = new ArrayCollection();
		}
		
		private function inferMetaStructures():void
		{

			for each(var o:Obsel in _obselCollections._obsels)
				considerNewObsel(o);
		}
		

		
		public function considerNewObsel(o:Obsel):void
		{
			if(!mapTypesToObsels[o.obselType])
			{
				mapTypesToObsels[o.obselType] = [];
				mapTypesToAttributeTypes[o.obselType] = [];
				mapTypesToValues[o.obselType] = [];
				arTypes.addItem(o.obselType);
			}
			
			(mapTypesToObsels[o.obselType] as Array).push(o);
			
			for each(var a:Attribute in o.attributes)
			{
				if((mapTypesToAttributeTypes[o.obselType] as Array).indexOf(a.attributeType) < 0)
					(mapTypesToAttributeTypes[o.obselType] as Array).push(a.attributeType);
				
				if((mapTypesToValues[o.obselType] as Array).indexOf(a.value) < 0)
					(mapTypesToValues[o.obselType] as Array).push(a.value);
				
				if(!mapAttributeTypesToValues[a.attributeType])
				{
					mapAttributeTypesToValues[a.attributeType] = [];
					mapAttributeTypesToObsels[a.attributeType] = [];
					mapAttributeTypesToObselTypes[a.attributeType] = []
					arAttributeTypes.addItem(a.attributeType);
				}
				
				if((mapAttributeTypesToObselTypes[a.attributeType] as Array).indexOf(o.obselType) < 0)
					(mapAttributeTypesToObselTypes[a.attributeType] as Array).push(o.obselType);
				
				if((mapAttributeTypesToValues[a.attributeType] as Array).indexOf(a.value) < 0)
					(mapAttributeTypesToValues[a.attributeType] as Array).push(a.value);
				
				if((mapAttributeTypesToObsels[a.attributeType] as Array).indexOf(o) < 0)
					(mapAttributeTypesToObsels[a.attributeType] as Array).push(o);
					
				if(!mapValuesToObsels[a.value])
				{
					mapValuesToObsels[a.value] = [];
					mapValuesToAttributeTypes[a.value] = [];
					mapValuesToObselTypes[a.value] = [];
					arValues.addItem(a.value);
				}
				
				if((mapValuesToObsels[a.value] as Array).indexOf(o) < 0)
					(mapValuesToObsels[a.value] as Array).push(o);
				
				if((mapValuesToAttributeTypes[a.value] as Array).indexOf(a.attributeType) < 0)
					(mapValuesToAttributeTypes[a.value] as Array).push(a.attributeType);
				
				if((mapValuesToObselTypes[a.value] as Array).indexOf(o.obselType) < 0)
					(mapValuesToObselTypes[a.value] as Array).push(o.obselType);
			}
		}
	}
}