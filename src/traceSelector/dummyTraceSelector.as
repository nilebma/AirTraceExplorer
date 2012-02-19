package traceSelector
{
	import com.ithaca.traces.Attribute;
	import com.ithaca.traces.AttributeType;
	import com.ithaca.traces.Obsel;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;

	[Bindable]
	public class dummyTraceSelector extends ObjectProxy
	{
		//This dummy selector can be used to filter a set of obsels : 
		//   - (optionnal) by specifying ono or more types for these obsels 
		// 	 - (optionnal) by specifying a set of attributes type these obsels should hold (all the specified attributes has to be hold)
		//	 	- (optionnal) for each attribute types, it is possible to specify a set of values the obsels should hold for this attribute type
		// 	 - (optionnal) by specifying a set of values should hold (all the specified values has to be hold)
		//	 	- (optionnal) for each values, it is possible to specify a set of attribute types the obsels has to hold the value with
		//	 - these are cumulative constraints (AND operator)
		
		[Bindable]
		public var name:String = "noname";
		
		[Bindable]
		public var _delete:Boolean = false;
		
		[Bindable]
		public var metaTrace:dummyMetaTraces;
		
		[Bindable]
		public var arTypes:ArrayCollection;
		
		[Bindable]
		public var arAttributesAndValues:ArrayCollection; //format : ObjectProxy({type:AttributeType, values:ArrayCollection([*])})
		
		[Bindable]
		public var arValuesAndAttributes:ArrayCollection; //format : ObjectProxy({value:*, attributeTypes:ArrayCollection([AttributeType])})
		
		public function dummyTraceSelector( typeFilter:ArrayCollection = null, attributesAndValuesFilter:ArrayCollection = null, valuesAndAttributesFilter:ArrayCollection = null)
		{
			if(typeFilter)
				arTypes = typeFilter;
			else
				arTypes = new ArrayCollection();
			
			if(attributesAndValuesFilter)
				arAttributesAndValues = attributesAndValuesFilter;
			else
				arAttributesAndValues = new ArrayCollection();
			
			if(valuesAndAttributesFilter)
				arValuesAndAttributes = valuesAndAttributesFilter;
			else
				arAttributesAndValues = new ArrayCollection();
		}
		
		public function testObsel(o:Obsel):Boolean
		{
			var testOK:Boolean = true;
			
			if(arTypes.length == 0 || arTypes.contains(o.obselType))
			{
				
				//Here we have two way to test the obsel, a perfomant one if a meteTrace objet has been constructed for the collection where the obsel belongs, or a slower way else 
				
				//THE PERFOMANT WAY (based on a metaTrace object)
				if(metaTrace && metaTrace.obselCollections.contains(o))
				{
					//TODO
				}
				else //THE SLOWER WAY 
				{
					for each(var atav:Object in arAttributesAndValues) //no test on attribute types if arAttributesAndValues is empty
					{
				
						if(testOK == false)
							return false;
						
						testOK = false;
						
						for each(var a:Attribute in o.attributes)
						{
							if(	atav.type == a.attributeType 
								&& ( (atav.values as ArrayCollection).length == 0 || (atav.values as ArrayCollection).contains(a.value) )
							)
								testOK= true;
						}
					}
					
					for each(var avat:Object in arValuesAndAttributes) //no test on attribute types if arAttributesAndValues is empty
					{
						if(testOK == false)
							return false;
						
						testOK = false;
						
						for each(var a:Attribute in o.attributes)
						{
							if(	avat.value == a.value )
							{
								if((avat.attributeTypes as ArrayCollection).length == 0)
									testOK= true;
								else if((avat.attributeTypes as ArrayCollection).contains(a.attributeType))
									testOK= true;
							}
						}		
					}
				}
			}
			else
				return false;
			
			return testOK;
			
		}
		
		public function toJSon():String
		{
			//Todo
			return null;
		}
		
		public function fromJSon(jsonString:String):void
		{
			//Todo
		}		
		
	}
}