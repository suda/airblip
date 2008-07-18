/**
 * @author Andrew Lewisohn
 * @revision $Rev: 329 $
 * @lastmodifiedby $LastChangedBy: andrewl $
 * @lastcommitdate $LastChangedDate: 2008-03-11 15:08:16 -0400 (Tue, 11 Mar 2008) $  
 */

package com.arc90.rpc.events
{
import flash.events.Event;

/**
 * The event that indicates an RPC operation has successfully returned a result.
 */
public class ResultEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
    * The RESULT event type.
    *     
    * @eventType result      
    */
	public static const RESULT:String = "result";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 * @param type The event type; indicates the action that triggered the event.
     * @param statusCode The HTTP Status Code.
     * @param statusMessage The HTTP Status Message.
     * @param headers The HTTP Response Headers.
     * @param result The HTTP Response Body.
     */
	public function ResultEvent(type:String, statusCode:Number, statusMessage:String, headers:Object, result:Object=null)
	{
		super(type, bubbles, cancelable);
		
		_headers = headers;
		_result = result;
		_statusCode = statusCode;
		_statusMessage = statusMessage;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
		
	//----------------------------------
	//  headers
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the headers property.
	 */
	private var _headers:Object;
	
	/**
	 * The HTTP Response headers.
	 */
	public function get headers():Object
	{
		return _headers;
	}
	
	//----------------------------------
	//  result
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the result property.
	 */
	private var _result:Object;
	
	/**
	 * The HTTP Response body.
	 */
	public function get result():Object
	{
		return _result;
	}
	
	//----------------------------------
	//  statusCode
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the statusCode property.
	 */
	private var _statusCode:Number;
	
	/**
	 * The HTTP Status Code.
	 */
	public function get statusCode():Number
	{
		return _statusCode;
	}
	
	//----------------------------------
	//  statusMessage
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the statusMessage property.
	 */
	private var _statusMessage:String;
	
	/**
	 * The HTTP Status Message.
	 */
	public function get statusMessage():String
	{
		return _statusMessage;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
     * Because this event can be re-dispatched we have to implement clone to
     * return the appropriate type, otherwise we will get just the standard
     * event type.
     */
    override public function clone():Event
    {
    	return new ResultEvent(type, statusCode, statusMessage, headers, result);
    }
    
   /**
     * Returns a string representation of the ResultEvent.
     *
     * @return String representation of the ResultEvent.
     */
    override public function toString():String
    {
        return formatToString("ResultEvent", "type", "statusCode", "statusMessage");
    }	
}
}