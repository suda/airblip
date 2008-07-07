package com.suda.plugins
{
	import flash.events.Event;

	public class PluginEvent extends Event
	{
		public var data:*;
		
		public function PluginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}