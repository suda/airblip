package com.suda.AS3BlipLib.objects
{
	public class BlipUpdate
	{
		public var id:int;
		[Bindable]
		public var type:String;
		[Bindable]
		public var createdAt:String;
		[Bindable]
		public var transport:BlipTransport;
		[Bindable]
		public var body:String;
		[Bindable]
		public var htmlBody:String = '';
		[Bindable]
		public var userPath:String;
		
		public var picturesPath:String;
		[Bindable]
		public var pictures:Array;
		
		public var recordingPath:String;
		[Bindable]
		public var recording:BlipRecording;
		
		public var moviePath:String;
		[Bindable]
		public var movie:BlipMovie;
		
		[Bindable]
		public var user:BlipUser;
		
		public static const UPDATE_TYPE_STATUS:String = "Status";
		public static const UPDATE_TYPE_DM:String = "DirectedMessage";
		
		public function BlipUpdate(data:Object = null)
		{
			if (null != data) {
				this.id = data.id;
				this.type = data.type;
				this.createdAt = data.created_at;
				this.transport = new BlipTransport(data.transport);				
				this.body = data.body;
				this.htmlBody = this.body;
				this.userPath = data.user_path;
				
				this.picturesPath = (data.hasOwnProperty('pictures_path')) ? data.pictures_path : '';				
				if (data.hasOwnProperty('pictures')) {
					this.pictures = new Array();
					for each (var picture in data.pictures) {
						this.pictures.push(new BlipPicture(picture));						
					}
				}
				
				this.recordingPath = (data.hasOwnProperty('recording_path')) ? data.recording_path : '';
				if (data.hasOwnProperty('recording')) {
					this.recording = new BlipRecording(data.recording);					
				}
				
				this.moviePath = (data.hasOwnProperty('movie_path')) ? data.movie_path : '';
				if (data.hasOwnProperty('movie')) {
					this.movie = new BlipMovie(data.movie);					
				}
			}
		}

	}
}