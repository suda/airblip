package com.suda
{
	import mx.collections.ArrayCollection;

	public class CustomArrayCollection extends ArrayCollection
	{
		public function CustomArrayCollection(source:Array=null)
		{
			super(source);
		}
		
		public function getBy(name:String, value:String):* {
			for each (var item:Object in this) {
				if (item.hasOwnProperty(name)) {
					if (value == item[name]) {
						return item;
					}
				}
			}
			
			return null;
		}
		
		public function getByMany(where:*):* {
			for each (var item:Object in this) {
				var hasAllProperties:Boolean = true;
				
				for each (var test:Object in where) {					
					if (!item.hasOwnProperty(test.name)) {
						hasAllProperties = false;	
					}										
				}
				
				var isOk:Boolean = true;
				if (hasAllProperties) {
					for each (var test:Object in where) {					
						if (test.value != item[test.name]) {
							isOk = false;
						}										
					}
					
					if (isOk) {
						return item;
					}
				}											
			}
			
			return null;
		}
		
		public function getAllBy(name:String, value:String):CustomArrayCollection {
			var result:CustomArrayCollection = new CustomArrayCollection();
			
			for each (var item:Object in this) {
				if (item.hasOwnProperty(name)) {
					if (value == item[name]) {
						result.addItem(item);
					}
				}
			}
			
			return result;			
		}
		
		public function setAllBy(findName:String, findValue:String, setName:String, setValue:*):void {
			for each (var item:Object in this) {
				if (item.hasOwnProperty(findName) && item.hasOwnProperty(setName)) {
					if (findValue == item[findName]) {
						item[setName] = setValue;
					}
				}
			}
		}
	}
}