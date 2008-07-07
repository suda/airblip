/**
 * @author Andrew Lewisohn
 * @revision $Rev: 328 $
 * @lastmodifiedby $LastChangedBy: andrewl $
 * @lastcommitdate $LastChangedDate: 2008-03-11 14:59:32 -0400 (Tue, 11 Mar 2008) $  
 */
package com.arc90.rpc.rest
{
/**
 * The RESTServiceMethod class provides values that specify what method should be used when making requests to a server. 
 */
public class RESTServiceMethod
{
	/**
	 * The request method "DELETE".
	 */
	public static const DELETE:String = "DELETE";
	
	/**
	 * The request method "GET".
	 */
	public static const GET:String = "GET";
	
	/**
	 * The request method "HEAD".
	 */
	public static const HEAD:String = "HEAD";
	
	/**
	 * The request method "OPTIONS".
	 */
	public static const OPTIONS:String = "OPTIONS";
	
	/**
	 * The request method "POST".
	 */
	public static const POST:String = "POST";
	
	/**
	 * The request method "PUT".
	 */
	public static const PUT:String = "PUT";
	
	/**
	 * The request method "TRACE".
	 */
	public static const TRACE:String = "TRACE";
}
}