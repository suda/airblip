/**
 * @author Andrew Lewisohn
 * @revision $Rev: 329 $
 * @lastmodifiedby $LastChangedBy: andrewl $
 * @lastcommitdate $LastChangedDate: 2008-03-11 15:08:16 -0400 (Tue, 11 Mar 2008) $  
 */
package com.arc90.rpc.events
{
import flash.events.Event;

import mx.rpc.Fault;

/**
 * The event that indicates an RPC operation has failed.
 */
public class FaultEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
    * The FAULT event type.
    *     
    * @eventType fault      
    */
	public static const FAULT:String = "fault";
	
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
     * @param fault The underlying Fault object.
     */
	public function FaultEvent(type:String, statusCode:Number, statusMessage:String, headers:Object, fault:Fault=null)
	{
		super(type, bubbles, cancelable);
		
		_fault = fault;
		_headers = headers;
		_statusCode = statusCode;
		_statusMessage = statusMessage;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  fault
	//----------------------------------
	
	/**
	 * @private
	 * Storage for the fault property.
	 */
	private var _fault:Fault;
	
	/**
	 * The underlying Fault object.
	 */
	public function get fault():Fault
	{
		return _fault;
	}
	
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
    	return new FaultEvent(type, statusCode, statusMessage, headers, fault);
    }
    
   /**
     * Returns a string representation of the FaultEvent.
     *
     * @return String representation of the FaultEvent.
     */
    override public function toString():String
    {
        return formatToString("FaultEvent", "type", "statusCode", "statusMessage");
    }
}
}