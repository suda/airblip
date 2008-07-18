package com.suda.AS3BlipLib.objects
{
	public class BlipShortlink
	{
		public var id:int;
		public var originalLink:String;
		public var hitCount:int;
		public var createdAt:String;
		public var shortcode:String;
		
		public function BlipShortlink(data:Object = null)
		{
			if (null != data) {
				this.id = data.id;
				this.originalLink = data.original_link;
				this.hitCount = data.hit_count;				
				this.createdAt = data.created_at;
				this.shortcode = data.shortcode;
			}
		}
	}
}