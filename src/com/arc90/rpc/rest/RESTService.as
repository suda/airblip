/**
 * @author Andrew Lewisohn
 * @revision $Rev: 329 $
 * @lastmodifiedby $LastChangedBy: andrewl $
 * @lastcommitdate $LastChangedDate: 2008-03-11 15:08:16 -0400 (Tue, 11 Mar 2008) $  
 */
package com.arc90.rpc.rest
{
import com.adobe.net.URI;
import com.adobe.serialization.json.*;
import com.adobe.utils.StringUtil;
import com.arc90.rpc.events.FaultEvent;
import com.arc90.rpc.events.ResultEvent;
import com.hurlant.crypto.tls.TLSSocket;
import com.hurlant.util.Base64;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.Socket;
import flash.net.URLVariables;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.Timer;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.CursorManager;
import mx.rpc.Fault;

//----------------------------------
//  Events
//----------------------------------
	
/**
 * Dispatched when a RESTService call fails.
 * 
 * @eventType com.arc90.rpc.events.FaultEvent
 */
[Event(name="fault", type="com.arc90.rpc.events.FaultEvent")]

/**
 * Dispatched when a RESTService call returns successfully.
 * 
 * @eventType com.arc90.rpc.events.ResultEvent
 */
[Event(name="result", type="com.arc90.rpc.events.ResultEvent")]

/**
 * RESTService makes fully aware HTTP service calls. Fault and Result events contain
 * all response headers and status messages, as well as the response body.
 * 
 * <p><b>Note: </b> Due to Flash Player security restrictions, the RESTService class will only work under
 * very specific conditions when delivered via the Web. However, an AIR application should not be subject
 * to the same restrictions.
 */
public class RESTService extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
     * Indicates that the data being sent by the RESTService is encoded as application/x-www-form-urlencoded.
     */
    public static const CONTENT_TYPE_FORM:String = "application/x-www-form-urlencoded";
    
	/**
     * Indicates that the data being sent by the RESTService is encoded as multipart/form-data.
     */
    public static const CONTENT_TYPE_MULTIPART:String = "multipart/form-data";
	
	/**
     * Indicates that the data being sent by the RESTService is encoded as application/xml.
     */
    public static const CONTENT_TYPE_XML:String = "application/xml";
    
    /**
     * Indicates that the data being sent by the RESTService is encoded as application/json.
     */
    public static const CONTENT_TYPE_JSON:String = "application/json";    
        
	/**
	 * The result format "binary" specifiec the value returned is of type <code>flash.utils.ByteArray</code>.
	 */	
	public static const RESULT_FORMAT_BINARY:String = "binary";
	
	/**
     * The result format "flashvars" specifies that the value returned is text containing name=value pairs
     * separated by ampersands, which is parsed into an ActionScript object.
     */	
	public static const RESULT_FORMAT_FLASHVARS:String = "flashvars";
	
	/**
     * The result format "text" specifies that the RESTService result text should be an unprocessed String.
     */
    public static const RESULT_FORMAT_TEXT:String = "text";

    /**
     * The result format "xml" specifies that the value returned is an XML instance, which can be accessed using ECMAScript for XML (E4X) expressions.
     */
    public static const RESULT_FORMAT_XML:String = "xml";
	
	/**
     * The result format "xml" specifies that the value returned is an XML instance, which can be accessed using ECMAScript for XML (E4X) expressions.
     */
    public static const RESULT_FORMAT_JSON:String = "json";
	
	/**
	 * @private
	 * A generic error message for display when we don't know what happened.
	 */
	private static const GENERIC_SERVER_ERROR:String = "An unknown error occurred.";
	
	/**
	 * @private
	 * Boundary used in multipart/form-data posts.
	 */
	private static const MULTIPART_BOUNDARY:String = "------------Ij5Ef1Ef1Ij5Ij5cH2ei4gL6KM7KM7";

	/**
	 * @private
	 * Separator character string.
	 */
	private static const SEPARATOR:String = "\r\n";
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	private static var logger:ILogger = Log.getLogger("com.arc90.rpc.rest.RESTService");
		
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
		
	private var headersAvailable:Boolean = false;
	
	private var insecureSocket:Socket;
	
	private var contentIsChunked:Boolean = false;
	
	private var contentLength:Number;
	
	private var contentStart:Number;
	
	private var credentials:String;
	
	private var requestTimer:Timer;
	
	private var responseData:RESTResponse;
	
	private var secureSocket:TLSSocket;
	
	private var socket:IDataInput;
	
	private var socketData:ByteArray;
	
	private var timedOut:Boolean = false;
	
	private var uri:URI;
		
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     * Constructor.
     * 
     * @param rootURL The base url to use in all service calls.
     * @param port The port to use in all service calls.
	 */	
	public function RESTService(rootURL:String="", port:int=80)
	{
		this.port = port;
		this.rootURL = rootURL;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  contentType
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the contentType property.
	 */
	private var _contentType:String = CONTENT_TYPE_XML;
	
	[Inspectable(enumeration="application/x-www-form-urlencoded,application/xml,multipart/form-data,application/json", defaultValue="application/xml", category="General")]
    /**
     * Type of content for service requests. 
     * The default is <code>application/xml</code> which sends requests as XML.
     * 
     * @default <code>application/xml</code>
     */
	public function get contentType():String
	{
		return _contentType;
	}
	
	/**
	 * @private
	 */
	public function set contentType(value:String):void
	{
		if(value != RESTService.CONTENT_TYPE_FORM
			&& value != RESTService.CONTENT_TYPE_MULTIPART
			&& value != RESTService.CONTENT_TYPE_XML
			&& value != RESTService.CONTENT_TYPE_JSON)
			throw new Error("com.arc90.rpc.rest.RESTService: " + value + " is not a valid content type.");
			
		_contentType = value;	
	}
	
	//----------------------------------
	//  headers
	//----------------------------------	
	
	[Inspectable(defaultValue="undefined", category="General")]
    /**
     * Custom HTTP headers to be sent to the third party endpoint. If multiple headers need to
     * be sent with the same name the value should be specified as an Array.
     */
	public var headers:Object;
	
	//----------------------------------
	//  lastRequest
	//----------------------------------
	
	/**
	 * The result of the last RESTService operation.
	 * 
	 * <p>The value returned is a generic object with the following properties:</p>
     *  <ul>
     *  <li><code>headers</code> Object Name/Value pairs</li>
     *  <li><code>response</code> Untyped response body.</li>
     *  <li><code>statusCode</code> Number HTTP Response Code</li>
     *  <li><code>statusMessage</code> String HTTP Response Message</li>
     *  <li><code>version</code> String HTTP Version</li>
     *  </ul>
     */
	public function get lastRequest():Object
	{
		return responseData;
	}
	
	//----------------------------------
	//  method
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the method property.
	 */
	private var _method:String = RESTServiceMethod.GET;
	
	[Inspectable(enumeration="GET,get,POST,post,HEAD,head,OPTIONS,options,PUT,put,TRACE,trace,DELETE,delete", defaultValue="GET", category="General")]
    /**
     * HTTP method for sending the request. Permitted values are <code>GET</code>, <code>POST</code>, <code>HEAD</code>,
     * <code>OPTIONS</code>, <code>PUT</code>, <code>TRACE</code> and <code>DELETE</code>.
     * Lowercase letters are converted to uppercase letters.
     * 
     * @default <code>GET</code>.
     */
	public function get method():String
	{
		return _method;
	}
	
	/**
	 * @private
	 */
	public function set method(value:String):void
	{
		if(!RESTServiceMethod[value])
			throw new Error("com.arc90.rpc.rest.RESTService: " + value + " is not a valid method.");
			
		_method = value.toUpperCase();
	}
	
	//----------------------------------
	//  port
	//----------------------------------
	
	private var explicitPortSet:Boolean = false;
	
	private var _port:int = 80;
	
	/**
	 * @private
	 * Storage for the port property.
	 */
	public function get port():int
	{
		return _port;
	}
	
	/**
	 * @private
	 */
	public function set port(value:int):void
	{
		if(_port == value)
			return;
			
		_port = value;
		explicitPortSet = true;
	}
	
	//----------------------------------
	//  request
	//----------------------------------
	
	[Inspectable(defaultValue="undefined", category="General")]
    /**
     * Object of name-value pairs used as parameters to the URL. If
     * the <code>contentType</code> property is set to <code>application/xml</code>, it should be an XML document.
     */
	public var request:Object;
	
	//----------------------------------
	//  requestTimeout
	//----------------------------------
	
	[Inspectable(category="General")]
    /**
     * Provides access to the request timeout in seconds for sent messages. 
     * A value less than or equal to zero prevents request timeout.
     * 
     * @default 0
     */ 
	public var requestTimeout:int = 0;

	//----------------------------------
	//  resultFormat
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the resultFormat property.
	 */
	private var _resultFormat:String = RESULT_FORMAT_XML;
	
	[Inspectable(enumeration="xml,flashvars,text,binary,json", defaultValue="object", category="General")]
    /**
     * Value that indicates how you want to deserialize the result
     * returned by the HTTP call.
     * 
     * @default <code>xml</code>
     */
	public function get resultFormat():String
	{
		return _resultFormat;
	}
	
	/**
	 * @private
	 */
	public function set resultFormat(value:String):void
	{
		if(value != RESTService.RESULT_FORMAT_BINARY
			&& value != RESTService.RESULT_FORMAT_FLASHVARS
			&& value != RESTService.RESULT_FORMAT_TEXT
			&& value != RESTService.RESULT_FORMAT_XML
			&& value != RESTService.RESULT_FORMAT_JSON)
			throw new Error("com.arc90.rpc.rest.RESTService: " + value + " is not a valid result format.");
			
		_resultFormat = value;
	}
		
	//----------------------------------
	//  rootURL
	//----------------------------------
	
	/**
	 * The base url for service calls.
	 */
	public var rootURL:String;
	
	//----------------------------------
	//  resource
	//----------------------------------
	
	/**
	 * The resource appended to base url for service calls.
	 */
	public var resource:String;
	
	public var eventName:String;
	
	public var userAgent:String;
	
	//----------------------------------
	//  showBusyCursor
	//----------------------------------
	
	/**
	 * If <code>true</code>, show the busy cursor while executing service calls.
	 * 
	 * @default <code>false</code>
	 */
	public var showBusyCursor:Boolean = false;
	
	//----------------------------------
	//  url
	//----------------------------------
	
	/**
	 * The URL to use for the service call.
	 */
	public var url:String;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Cancels the currently executing request.
	 */
	public function cancel():void
	{
		close();
	} 
	
	/**
	 * Clears the user credentials set by <code>setCredentials</code>.
	 */
	public function clearCredentials():void
	{
		credentials = null;
	}
	
	private function close():void
	{
		if(socket["connected"])
		{
			if(socket is TLSSocket)
			{
				secureSocket.removeEventListener(Event.CLOSE, socket_closeHandler);
				secureSocket = null;
			}
			else if(socket is Socket)
			{
				insecureSocket.close();
			}
		}
		
		EventDispatcher(insecureSocket).dispatchEvent(new Event(Event.CLOSE));
	}

	private function constructData(boundary:String):ByteArray
	{
		var data:ByteArray = new ByteArray();
		
		if(request)
		{
			switch(contentType)
			{
				case CONTENT_TYPE_MULTIPART:
					if(request is Object)
					{
						for(var prop:String in request)
						{
							data.writeUTFBytes("--" + boundary + SEPARATOR);
							data.writeUTFBytes("Content-Disposition: form-data; name=\"" + prop + "\"" + SEPARATOR);
							data.writeUTFBytes(SEPARATOR);
							data.writeUTFBytes(request[prop] + SEPARATOR);
							data.writeUTFBytes("--" + boundary + "--" + SEPARATOR);
						}
					}
					break;
					
				case CONTENT_TYPE_XML:
					data.writeUTFBytes(request.toString());
					break;
					
				default:
				case CONTENT_TYPE_FORM:
					var vars:String = "";
					
					if(request is String)
						vars = request.toString();
					else
					{
						for(var urlvar:String in request)
							vars += urlvar + "=" + escape(request[urlvar]) + "&";
							
						// trim last ampersand
						vars = vars.substring(0, vars.length - 1);
					}
					
					data.writeUTFBytes(vars);
					break;
					
				case CONTENT_TYPE_JSON:
					var vars:String = "";
					
					if(request is String)
						vars = request.toString();
					else
					{
						vars = JSON.encode(request);
					}
					
					data.writeUTFBytes(vars);
					break;
			}
		}
		
		return data;	
	}
	
	private function constructHeaders(contentLength:Number, boundary:String=null):ByteArray
	{
		var bytes:ByteArray = new ByteArray();
		var header:String = "";
		
		// Init to just the path
		var fullURL:String = uri.path;
		
		// Check for query string and fragment
		if(uri.query)
			fullURL += "?" + uri.query;
			
		if(uri.fragment)
			fullURL += "#" + uri.fragment;			
		
		// Method Path and Protocol/Version
		header += method + " " + fullURL + " HTTP/1.1" + SEPARATOR;
		
		// Host
		header += "Host: " + uri.authority + SEPARATOR;
		
		// User-Agent
		if ('' != userAgent) {
			header += "User-Agent: " + userAgent + SEPARATOR;
		} else {
			header += "User-Agent: Flash Player; " + Capabilities.version + "; " + Capabilities.playerType + "; " + Capabilities.os + SEPARATOR;
		}		
		
		// Content-Length
		if(contentLength)
			header += "Content-Length: " + contentLength + SEPARATOR;
			
		// ContentType
		header += "Content-Type: " + contentType;
			
		if(contentType == CONTENT_TYPE_MULTIPART)
			header += "; boundary=" + MULTIPART_BOUNDARY;
				
		header += SEPARATOR;	
		
		// Authorization
		if(credentials)
			header += "Authorization: Basic " + credentials + SEPARATOR;	
		
		// Request Headers
		for(var prop:String in headers)
		{
			// Don't set authorization if credentials were supplied via setCredentials
			if(prop == "Authorization" && credentials)
				continue;
				
			header += prop + ": " + headers[prop] + SEPARATOR;
		}
		
		// Finalize Header Area
		header += SEPARATOR;
		
		// Write Bytes to array
		bytes.writeUTFBytes(header)
		
		return bytes;
	}
	
	private function constructRequest():void
	{
		var request:ByteArray;
		
		if(method == RESTServiceMethod.POST || method == RESTServiceMethod.PUT)
		{
			if (contentType == CONTENT_TYPE_JSON) {
				var data:ByteArray = constructData(CONTENT_TYPE_JSON);
			} else {
				var data:ByteArray = constructData(MULTIPART_BOUNDARY);	
			}
			
			var contentLength:Number = data.length;
			
			if(contentType == CONTENT_TYPE_MULTIPART)
				contentLength -= 4;
			
			if (contentType == CONTENT_TYPE_JSON) {	
				request = constructHeaders(contentLength, CONTENT_TYPE_JSON);
			} else {
				request = constructHeaders(contentLength, MULTIPART_BOUNDARY);
			}
			request.writeBytes(data, 0, data.length);
		}
		else
		{
			request = constructHeaders(0);
		}
		
		IDataOutput(socket).writeBytes(request);
	}
	
	private function parseChunkedData():void
	{
		var data:ByteArray;
		
		// We don't know the contentLength yet
		if(isNaN(contentLength))
		{
			if(socketData.bytesAvailable < 3)
				return;
			
			var temp:String = "";
			while(socketData.readUTFBytes(2) != SEPARATOR)
			{
				socketData.position -= 2;
				temp += socketData.readUTFBytes(1);
				
				if(socketData.bytesAvailable < 3)
					return;
			}
			
			contentStart = socketData.position;
			contentLength = parseInt(temp, 16);
		}
		
		// There is no content
		if(!contentLength)
		{
			if(responseData.response)
			{
				data = responseData.response as ByteArray;
				data.position = 0;
				
				switch(resultFormat)
				{
					case RESTService.RESULT_FORMAT_FLASHVARS:
						responseData.response = new URLVariables(data.readUTFBytes(data.bytesAvailable));
						break;
						
					case RESTService.RESULT_FORMAT_BINARY:
						// data is already binary
						break;
						
					case RESTService.RESULT_FORMAT_TEXT:
						responseData.response = data.readUTFBytes(data.bytesAvailable);
						break;
						
					case RESTService.RESULT_FORMAT_XML:
						responseData.response = XML(data.readUTFBytes(data.bytesAvailable));
						break;	
						
					case RESTService.RESULT_FORMAT_JSON:
						responseData.response = JSON.decode(data.readUTFBytes(data.bytesAvailable));
						break;		
				}	
			}	
			
			close();
			
			return;
		}
		
		if(contentLength < socketData.bytesAvailable)
		{
			if(!responseData.response)
				responseData.response = new ByteArray();
			
			data = responseData.response as ByteArray;	
			socketData.readBytes(data, data.length, contentLength);
			
			// Advance to the next content length indicator
			socketData.readUTFBytes(2);
				
			contentLength = NaN;
			contentStart = socketData.position;
			
			parseChunkedData();
		}
	}
	
	private function parseData():void
	{
		if(contentLength == socketData.bytesAvailable)
		{
			switch(resultFormat)
			{
				case RESTService.RESULT_FORMAT_FLASHVARS:
					responseData.response = new URLVariables(socketData.readUTFBytes(contentLength));
					break;
					
				case RESTService.RESULT_FORMAT_BINARY:
					responseData.response = new ByteArray();
					socketData.readBytes(responseData.response, 0, contentLength);
					break;
					
				case RESTService.RESULT_FORMAT_TEXT:
					responseData.response = socketData.readUTFBytes(contentLength);
					break;
					
				case RESTService.RESULT_FORMAT_XML:
					responseData.response = XML(socketData.readUTFBytes(contentLength));
					break;	
					
				case RESTService.RESULT_FORMAT_JSON:
					responseData.response = JSON.decode(socketData.readUTFBytes(contentLength));
					break;		
			}
			
			close();
		}
	}
	
	private function parseHeaders():void
	{
		socketData.position = 0;
		var response:String = socketData.readUTFBytes(socketData.bytesAvailable);
		var index:int = response.indexOf(SEPARATOR + SEPARATOR);
		
		if(index > -1)
		{
			headersAvailable = true;
			
			var meta:String = response.split(SEPARATOR + SEPARATOR)[0];
			var parts:Array = meta.split("\r\n");
			var info:Array = parts.shift().toString().split(" ");
			var version:String = info.shift();
			var status:Number = Number(info.shift());
			var message:String = info.join(" ");
			var responseHeaders:Object = {};
			
			while(parts.length != 0)
			{
				var header:String = parts.shift();
				var headerParts:Array = header.split(":");
				var name:String = headerParts.shift();
				var value:String = StringUtil.trim(headerParts.join(":"));
				responseHeaders[name.toLowerCase()] = value;
			}
			
			if(responseHeaders.hasOwnProperty("content-length"))
			{
				contentLength = Number(responseHeaders["content-length"]);
			}
			else if(responseHeaders.hasOwnProperty("transfer-encoding") 
					&& responseHeaders["transfer-encoding"] == "chunked")
			{
				contentIsChunked = true;	
			}
			
			contentStart = index + 4;
			responseData = new RESTResponse(version, status, message, responseHeaders, null);			
		}
	}
	
	private function readResponse():void 
    {
    	socket.readBytes(socketData, socketData.length, socket.bytesAvailable);
    	
    	if(!headersAvailable)
    	{
    		parseHeaders();
    	}
    	
    	if(headersAvailable)
    	{
    		socketData.position = contentStart;
    		
    		if(contentIsChunked)
    			parseChunkedData();
    		else
    			parseData();
    	}        
    }
	
	private function selectSocket():IDataInput
	{
		if(!insecureSocket)
		{
			insecureSocket = new Socket();
			insecureSocket.addEventListener(Event.CLOSE, socket_closeHandler);
			insecureSocket.addEventListener(Event.CONNECT, socket_connectHandler);
			insecureSocket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioErrorHandler);
			insecureSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityErrorHandler);
			insecureSocket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketDataHandler);	
		}
		
		if(!secureSocket)
		{
			secureSocket = new TLSSocket();	
			secureSocket.addEventListener(Event.CLOSE, socket_closeHandler);
			secureSocket.addEventListener(Event.CONNECT, socket_connectHandler);
			secureSocket.addEventListener(IOErrorEvent.IO_ERROR, socket_ioErrorHandler);
			secureSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_securityErrorHandler);
			secureSocket.addEventListener(ProgressEvent.SOCKET_DATA, socket_socketDataHandler);	
		}
		
		var socket:IDataInput = insecureSocket;
		
		if(uri.port == "443" || uri.scheme == "https")
			socket = secureSocket;
		
		return socket;
	}	
	    
	/**
	 * Executes a RESTService request.
	 */
	public function send():void
	{
		// Breakup the url
		url = rootURL+resource;
		uri = new URI(url);
		
		// Manage explicitly set port		
		if(!explicitPortSet)
			uri.port = uri.scheme == "https" ? "443" : "80";
		else
			uri.port = port.toString();
		
		if(showBusyCursor)
			CursorManager.setBusyCursor();
		
		logger.debug("Starting send using " + method + " on " + uri.toDisplayString());
		
		socket = selectSocket();
		
		logger.debug("Host: " + uri.authority + " Port: " + uri.port + " using " + socket);
		
		requestTimer = new Timer(requestTimeout * 1000, 1);
		
		if(requestTimeout > 0)
        {
        	requestTimer.addEventListener(TimerEvent.TIMER_COMPLETE, requestTimer_timerCompleteHandler);
        	requestTimer.start();	
        }
                
		socket["connect"](uri.authority, uri.port);
	}
	
	private function sendRequest():void 
	{
		// Clear last response
		contentIsChunked = false;
		contentLength = NaN;
		contentStart = NaN;
		headersAvailable = false;
	   	responseData = null;
	   	socketData = new ByteArray();
		
		// Write Request to Socket
		constructRequest();
        
        // Send the data to the secureSocket
        socket["flush"]();
        
    }
	
	/**
	 * Sets credentials to be passed to the service on all service calls. Credentials are passed
	 * using Basic HTTP Authentication.
	 * 
	 * @param username The username
	 * @param password The password
	 */
	public function setCredentials(username:String, password:String):void
	{
		credentials = Base64.encode(username + ":" + password);	
	}
	
	//--------------------------------------------------------------------------
	//
	//  Asset event handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Closes the connection when a <code>requestTimeout</code> was set
	 * and expires before the current request completes.
	 * 
	 * @eventType <code>TimerEvent.TIMER_COMPLETE</code>.
	 */
    private function requestTimer_timerCompleteHandler(event:TimerEvent):void
	{
		timedOut = true;
		
		close();	
	}
	
	/**
	 * @private
	 * @eventType <code>Event.CLOSE</code>.
	 */
    private function socket_closeHandler(event:Event):void 
	{
		//logger.debug(event.toString());
    	
		if(requestTimer.running)
			requestTimer.stop();	
		
		if(showBusyCursor)
			CursorManager.removeBusyCursor();
				
		var dispatch:Event;
		var fault:Fault;
		
		if(responseData && !timedOut)
		{	
			if(responseData.statusCode >= 200 && responseData.statusCode < 300)
			{
				dispatch = new ResultEvent(ResultEvent.RESULT, responseData.statusCode, responseData.statusMessage, responseData.headers, responseData.response);	
			}
			else
			{
				fault = new Fault(responseData.statusCode.toString(), responseData.statusMessage, responseData.response);
				dispatch = new FaultEvent(FaultEvent.FAULT, responseData.statusCode, responseData.statusMessage, responseData.headers, fault);
			}
		}
		else
		{
			var message:String = GENERIC_SERVER_ERROR;
			
			if(timedOut)
			{
				timedOut = false;
				message = "The request timed out.";
			}
				
			fault = new Fault("500", message);
			dispatch = new FaultEvent(FaultEvent.FAULT, 500, message, {}, fault);
		}	
		
		dispatchEvent(dispatch);
    }

    /**
	 * @private
	 * @eventType <code>Event.CONNECT</code>.
	 */
    private function socket_connectHandler(event:Event):void 
    {
    	//logger.debug(event.toString());
    	
    	sendRequest();
    }

    /**
	 * @private
	 * @eventType <code>IOErrorEvent.IO_ERROR</code>.
	 */
    private function socket_ioErrorHandler(event:IOErrorEvent):void 
    {
    	//logger.debug(event.toString());
    	
    	if(requestTimer.running)
			requestTimer.stop();	
			
    	if(showBusyCursor)
			CursorManager.removeBusyCursor();
		
		var fault:Fault = new Fault("500", event.text);
		var faultEvent:FaultEvent = new FaultEvent(FaultEvent.FAULT, 500, GENERIC_SERVER_ERROR, {}, fault);
		dispatchEvent(faultEvent);
    }

    /**
	 * @private
	 * @eventType <code>SecurityErrorEvent.SECURITY_ERROR</code>.
	 */
    private function socket_securityErrorHandler(event:SecurityErrorEvent):void 
    {
    	//logger.debug(event.toString());
    	
    	if(requestTimer.running)
			requestTimer.stop();	
			
    	if(showBusyCursor)
			CursorManager.removeBusyCursor();
			
        var fault:Fault = new Fault("500", event.text);
		var faultEvent:FaultEvent = new FaultEvent(FaultEvent.FAULT, 500, GENERIC_SERVER_ERROR, {}, fault);
		dispatchEvent(faultEvent);
    }

	/**
	 * @private
	 * @eventType <code>ProgressEvent.SOCKET_DATA</code>.
	 */
    private function socket_socketDataHandler(event:ProgressEvent):void 
    {
    	//logger.debug(event.toString());
    	
    	readResponse();
    }
}
}

class RESTResponse
{
	public function RESTResponse(version:String, statusCode:Number, statusMessage:String, headers:Object, response:*=null)
	{
		this.version = version;
		this.statusCode = statusCode;
		this.statusMessage = statusMessage;
		this.headers = headers;
		this.response = response;
	}
	
	public var headers:Object;
	
	public var response:*;
	
	public var statusCode:Number;
	
	public var statusMessage:String;
	
	public var version:String;
}