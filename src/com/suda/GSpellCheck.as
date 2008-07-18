package com.suda
{
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	
	import mx.controls.List;
	import mx.controls.RichTextEditor;
	import mx.events.ListEvent;	
	import mx.collections.ArrayCollection;
	
	public class GSpellCheck extends EventDispatcher
	{
		public static const LANG_ENGLISH:String = "en";
		public static const LANG_DANISH:String = "da";
		public static const LANG_GERMAN:String = "de";
		public static const LANG_SPANISH:String = "es";
		public static const LANG_FRENCH:String = "fr";
		public static const LANG_ITALIAN:String = "it";
		public static const LANG_DUTCH:String = "nl";
		public static const LANG_POLISH:String = "pl";
		public static const LANG_PORTUGEAS:String = "pt";
		public static const LANG_FINNISH:String = "fi";
		public static const LANG_SWEDISH:String = "sv";				
				
		private var _lang:String;	
		public var isChecking:Boolean;
		
		private var noProxy:Boolean = true;
		private var prefixText:String = "<font color='#ff0000'>";
		private var endText:String = "</font>";
		private var list:List;
		private var listOpen:Boolean = false;
		
		/**
		* URL to a file on your server to be used as the proxy for connecting
		* to the Google Spell checker Service. 
		*/
		private var _urlString : String = "https://www.google.com/tbproxy/spell?lang=";			
		
		/**
		* Reference to a Text field, TextArea or RichTextEditor that will use this component for checking it's spelling
		*/
		private var _inputTA:*;
		public function set	inputTA(textControl:*):void{
			_inputTA = textControl;
			if(textControl is RichTextEditor){
				_inputTA = textControl.textArea;
			}											
		}
							
		public function GSpellCheck(lang:String = LANG_ENGLISH)
		{
			this._lang = lang;
		}
		
		public function spellCheck():void{
			if(isChecking){
				if(listOpen){
					showList(false);
				}	
				cleanupWorkingText();				
				_inputTA.text = workingText;
				_inputTA.editable = true;
				isChecking = false;
				return;
			}
		
			_inputTA.editable = false;
			__origText = _inputTA.text;
			workingText = __origText;
			requestXML = <spellrequest textalreadyclipped="0" ignoredups="0" ignoredigits="1" ignoreallcaps="1">{__origText}</spellrequest>
			isChecking = true;
			doSpellCheck();
		}
		
		private function doSpellCheck(text:String = ''):void {
			
			var variables:URLVariables = new URLVariables();
			var request:URLRequest = new URLRequest ();
			if(noProxy) {
				request.url = _urlString+_lang;
				request.contentType = "text/xml";
				request.data = requestXML.toXMLString();					
				
			} else {
				request.url = _urlString;
        		variables.lang = lang;
        		variables.requesttext = __origText;
        		request.data = variables;					
			}
			request.method = URLRequestMethod.POST;
			dataLoader = new URLLoader();
			dataLoader.addEventListener ("complete", onDataLoad);
			dataLoader.addEventListener(IOErrorEvent.IO_ERROR,dataloaderIOEventHandler);
			dataLoader.addEventListener ("securityError", onSecurityError);
			dataLoader.load (request);
		}
		
		private function onDataLoad (event : Event) : void{
			var XMLResult:XML = new XML(event.target.data);
			corrections = XMLResult.children();
			if(!corrections.length()){
				// EVENT: Nie odnaleziono błędów
				return;					
			}
			
			var i:int = 1;
			var additionalOffsetLength:int = 0;
			var item:XML;
			for each( item in corrections){
				var textToChange:String = __origText.substring(item.attribute("o"),(Number(item.attribute("o"))+Number(item.attribute("l"))));
				item.@id = i;
				var replacementText:String = "<a href='event:makeSugList,"+item.attribute('id')+"'>"+prefixText+textToChange+endText+"</a>";
				var replacementTextLength:int = replacementText.length;
				item.@newword = replacementText;
				item.@origword = textToChange; 
				item.@newlength = replacementTextLength;
				item.@deleted = 0;
				if(additionalOffsetLength){
					item.@newoffset = Number(item.attribute("o"))+additionalOffsetLength;
				}else{
					item.@newoffset = Number(item.attribute("o"));
				}
				workingText = replaceAt(workingText,textToChange,replacementText,item.@newoffset);
				additionalOffsetLength += replacementTextLength - textToChange.length;
				i++
			}
			_inputTA.addEventListener("link",linkListener,false,0,true);
			_inputTA.htmlText = workingText;
			// EVENT: Znaleziono błędy
		}
		
		private function linkListener(e:TextEvent):void {
			var linkArray:Array = e.text.split(","); 
			makeSuggestionList(linkArray[1]);
		}	
		
		private function makeSuggestionList(linkID:int):void {
			var item:XMLList = corrections.(@id == linkID);
			if(listOpen){
				showList(false);
				_inputTA.removeEventListener("click",stageClickedHandler);
			}
			list = new List();
			list.setStyle("fontSize",9);
			list.x = _inputTA.contentMouseX;
			list.y = _inputTA.contentMouseY+3;
			var listItems:Array = item.text().split("\t");
			
			var listArray:Array = new Array();
			for(var i:int=0;i<listItems.length;i++){
				listArray[i] = {label:listItems[i],data:item.attribute("id")};
			}
			list.dataProvider = new ArrayCollection(listArray);
			list.addEventListener("creationComplete",listCreatedHandler,false,0,true);
			list.addEventListener(ListEvent.ITEM_CLICK,listItemClickedHandler);
			showList(true);		
		}
		
		/** 
		* This is a workaround - Called when the creationComplete event fires in the List component.
		* Measures the max width and height of items in the list and sets
		* the width and height of the list manually.
		* Documentation says that this should occure when the list is instantiated, but it don't :-)
		*/
		private function listCreatedHandler(e:Event):void{
			var widthOfList:int = list.measureWidthOfItems(0,list.rowCount);
			list.width = widthOfList+3;
			var heightOfList:int = list.measureHeightOfItems(0,list.rowCount);
			list.height = heightOfList+3;
			_inputTA.addEventListener("click",stageClickedHandler,false,0,true);
		}	
		
		private function listItemClickedHandler(e:ListEvent):void{
			showList(false);
			var target:List = List(e.target);
			if(target.selectedItem.label == "CLOSE"){
				return;
			}				
			var itemToCorrect:XMLList = corrections.(@id == target.selectedItem.data);
			var itemReplaceString:String = target.selectedItem.label;
			var itemReplaceStringLength:int = itemReplaceString.length;
			var textToChange:String = itemToCorrect.attribute("newword");
			var itemNewOffset:int = itemToCorrect.attribute("newoffset");
			var itemNewLength:int = itemToCorrect.attribute("newlength");
			var diffLength:int = itemReplaceStringLength-itemNewLength;
			workingText = replaceAt(workingText,textToChange,itemReplaceString,itemNewOffset);
			_inputTA.htmlText = workingText;
			itemToCorrect.@deleted = 1;
			changeOffsets(diffLength,itemNewOffset);
		}
		
		private function changeOffsets(diffLength:int,offset:int):void{
			var item:XML;
			for each(item in corrections){
				if(item.attribute("newoffset")>offset && item.attribute("deleted")==0){
					item.@newoffset = Number(item.attribute("newoffset"))+ diffLength;
				}	
			}			
		}
		
		private function cleanupWorkingText():void{
			var item:XML
			for each( item in corrections){
				if(item.attribute("deleted") == 0){
					var itemID:Number = item.attribute("id");
					var textToChange:String = item.attribute("newword");
					var itemReplaceString:String = item.attribute("origword");
					var itemNewOffset:int = item.attribute("newoffset");
					var diffLength:int = item.attribute("l")-item.attribute("newlength");	
					workingText = replaceAt(workingText,textToChange,itemReplaceString,itemNewOffset);
					_inputTA.htmlText = workingText;
					item.@deleted = 1;
					changeOffsets(diffLength,itemNewOffset);
				}					
			}
		}
		
		private function showList(show:Boolean):void{
			if(show){_inputTA.addChild(list);listOpen = true;}
			if(!show){_inputTA.removeChild(list);listOpen = false;}				
		}			
		private function onSecurityError(e:Event):void{
			trace("dataLoader security error");
		}
		private function dataloaderIOEventHandler(e:IOErrorEvent):void{		
			// EVENT: Błąd IO
		}
		private function stageClickedHandler(e:MouseEvent):void{
			if(listOpen){
				showList(false);
			}
			_inputTA.removeEventListener("click",stageClickedHandler);
		}
		
		/**
		*	Replaces string in the input string
		*	with the replaceWith string at position offset.
		* 
		*/
		private function replaceAt(input:String, replace:String, replaceWith:String, offset:int):String
		{
			var sb:String = new String();
			var c:int = 0;
			var sLen:Number = input.length;
			var rLen:Number = replace.length;
			//place chars before offset into returned string
			while (c < offset){
				sb += input.charAt(c);
				c++;
			}
			//put the replaceWith string in the returned string 
			sb += replaceWith;
			//move offset to end of replace string
			c += rLen;
			//insert remainder of main text string into returned string
			while (c <= sLen){
				sb += input.charAt(c);
				c++;
			}
			return sb;
		}
		
		

	}
}