﻿/*
ADOBE SYSTEMS INCORPORATED
Copyright © 2008 Adobe Systems Incorporated. All Rights Reserved.
 
NOTICE:  This software code file is provided by Adobe as a Sample
under the terms of the Adobe AIR SDK license agreement.  Adobe permits
you to use, modify, and distribute this file only in accordance with
the terms of that agreement.  You may have received this file from a
source other than Adobe.  Nonetheless, you may use, modify, and/or
distribute this file only in accordance with the Adobe AIR SDK license
agreement. 
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

Note: added External Interface call to count clicks. 
To test locally, publish swf for "access local files only", else ExtIntf will not call the javascript
*/

package  {
	import adobe.utils.ProductManager;
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.system.Capabilities;
	
	public class AIRInstallBadge extends MovieClip {
		
	// Constants:
		public static const AIR_SWF_URL:String = "http://airdownload.adobe.com/air/browserapi/air.swf";
		public static const VALID_PROTOCOLS:Array = ["http","https"];
		
	// Public Properties:
		// ui:
		public var imageHolder:MovieClip;
		public var dialog:MovieClip;
		public var distractor:MovieClip;
		public var light:MovieClip;
		public var imageAltFld:TextField;
		public var actionBtn:SimpleButton;
		public var actionFld:TextField;
		public var helpBtn:SimpleButton;
	
	// Private Properties:
		// parameters:
		protected var airVersion:String;
		protected var appInstallArg:Array;
		protected var appLaunchArg:Array;
		protected var appID:String;
		protected var appName:String;
		protected var appURL:String;
		protected var appVersion:String;
		protected var helpURL:String;
		protected var hideHelp:Boolean;
		protected var image:String;
		protected var pubID:String;
		protected var skipTransition:Boolean;
		//count clicks
		protected var siteUrl:String;
		protected var clicksObj:Object;
		//
		protected var installedAIRVersion:String;
		protected var airSWFLoader:Loader;
		protected var airSWF:Object;
		protected var action:String;
		protected var prevAction:String;
		protected var timer:Timer;
		protected var productManager:ProductManager;
	
	// Initialization:
		public function AIRInstallBadge() {
			configUI();
			
			// set up the timer that will be used to check for installation progress:
			timer = new Timer(10000,0);
			timer.addEventListener(TimerEvent.TIMER,handleTimer);
			
			// set up a product manager for AIR:
			productManager = new ProductManager('airappinstaller' );
			
			// read params (except strings) from FlashVars:
			var params:Object = loaderInfo.parameters;
			airVersion = validateString(params.airversion);
			appInstallArg = (validateString(params.appinstallarg)==null) ? null : [params.appinstallarg];
			appLaunchArg = (validateString(params.applauncharg)==null) ? null : [params.applauncharg];
			appID = validateString(params.appid);
				appName = validateString(params.appname);
				appURL = validateURL(params.appurl);
				appVersion = validateString(params.appversion);
			helpURL = validateURL(params.helpurl);
			hideHelp = (params.hidehelp != null && params.hidehelp.toLowerCase() == "true");
			image = validateURL(params.image);
			pubID = validateString(params.pubid);
			skipTransition = (params.skiptransition != null && params.skiptransition.toLowerCase() == "true");
			dialog.titleFld.textColor = (params.titlecolor != null) ? parseInt(params.titlecolor.replace(/[^0-9A-F]*/ig,""),16) : 0xff0000;
			actionFld.textColor = (params.buttonlabelcolor != null) ? parseInt(params.buttonlabelcolor.replace(/[^0-9A-F]*/ig,""),16) : 0xffffff;
			imageAltFld.textColor = (params.appnamecolor != null) ? parseInt(params.appnamecolor.replace(/[^0-9A-F]*/ig,""),16) : 0xffffff;
			siteUrl = validateString(params.siteurl);			
			
			// verify all required params are accounted for:
			if (!verifyParams()) {
				showDialog(getText("error"),getText("err_params"));
				actionFld.text = "";
				return;
			}
			
			// strip tags out of the appName:
			appName = appName.replace(/(<.*?>|<)/g,"");
			
			// load the image:
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,handleImageError);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,handleImageLoadComplete);
			try {
				imageLoader.load(new URLRequest(image));
				imageHolder.addChild(imageLoader);
			} catch (e:*) {
				handleImageError(null);
			}
			
			// load the AIR proxy swf:
			airSWFLoader = new Loader();
			airSWFLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,handleAIRSWFError);
			airSWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleAIRSWFInit);
			try {
				airSWFLoader.load(new URLRequest(AIR_SWF_URL)); //, loaderContext);
			} catch (e:*) {
				handleAIRSWFError(null);
			}
		}

		
		// called when there is an error loading the application image. Displays alt text (app name and version) instead.
		protected function handleImageError(evt:IOErrorEvent):void {
			imageAltFld.text = (appVersion != null && appVersion != "") ? appName+" v"+appVersion : appName;
			distractor.visible = false;
		}
		
		// called when the application image loads. Displays the image and begins the transition.
		protected function handleImageLoadComplete(evt:Event):void {
			imageHolder.visible = true;
			distractor.visible = false;
			if (skipTransition) {
				gotoAndPlay("transitionEnd");
			} else {
				play();
			}
		}
		
		// called when there is an error loading the airSWF
		protected function handleAIRSWFError(evt:IOErrorEvent):void {
			showDialog(getText("error"),getText("err_airswf"));
			actionFld.text = "";
		}
		
		// called when the airSWF loads and inits
		protected function handleAIRSWFInit(evt:Event):void {
			airSWF = airSWFLoader.content;
			if (airSWF.getStatus() == "unavailable") {
				showDialog(getText("error"),getText("err_airunavailable"));
				return;
			}
			var version:String = null;
			if (appID && pubID) {
				// check if the application is already installed:
				try {
					airSWF.getApplicationVersion(appID, pubID, appVersionCallback);
					return;
				} catch (e:*) {}
			}
			enableAction("install");
			helpBtn.visible = !hideHelp;
		}
		
		// callback from the airSWF when requesting application version
		protected function appVersionCallback(version:String):void {
			if (version == null) {
				// application is not installed
				enableAction("install");
			} else if (appVersion && (checkVersion(appVersion,version)==1)) {
				// old version is installed
				enableAction("upgrade");
			} else {
				// current version is probably installed
				enableAction("launch");
			}
			helpBtn.visible = !hideHelp;
		}
		
		// handles clicks on the action button
		private function handleActionClick(evt:MouseEvent):void {
						
			//do actions
			if (action == "close") {
				hideDialog();
				enableAction(prevAction);
			} else if (action == "install" || action == "upgrade" || action == "tryagain") {
				//count clicks per type
				addDownloadCount(action);
				
				showDialog(getText("installing"),getText("installingtext"));
				disableAction();
				// check if it's installed every 5 seconds:
				timer.reset();
				timer.start();
				airSWF.installApplication(appURL, airVersion, appInstallArg);
			} else if (action == "launch") {
				addDownloadCount(action);
				airSWF.launchApplication(appID, pubID, appLaunchArg);
				showDialog(getText("launching"),getText("launchingtext"));
				enableAction("close");
			}
		}
		
		//---process download clicks in WordPress---
		protected function addDownloadCount($action:String):void {
			var clickType:String = $action;
			if(!clicksObj) clicksObj = new Object();

			try{ 
				if(ExternalInterface.available) {
					clicksObj.siteurl = siteUrl;
					clicksObj.clicktype = clickType;
					ExternalInterface.call("count_airbadge_click", clicksObj);
				}
			}catch( e:Error ){}
		}
		
		// triggered  every 5 seconds after installing or upgrading.
		// checks to see if the expected version of the application was successfully installed.
		protected function handleTimer(evt:TimerEvent):void {
			try {
				airSWF.getApplicationVersion(appID, pubID, tryAgainVersionCallback);
			} catch (e:*) {
				enableAction("tryagain");
			}
		}
		
		// call back from version check in handleTimer
		// verifies that version is appVersion, and provides option to launch the app if it is.
		protected function tryAgainVersionCallback(version:String):void {
			if (version != null && (appVersion == null || !(checkVersion(appVersion,version)==1))) {
				// current version is probably installed
				timer.stop();
				enableAction("launch");
			} else {
				enableAction("tryagain");
			}
		}
		
		// show help
		protected function handleHelpClick(evt:MouseEvent):void {
			showDialog(getText("help"),getText("helptext"));
			enableAction("close");
		}
		
		// enables the action button with the appropriate label, and sets the action property
		protected function enableAction(action:String):void {
			if (action == null) {
				disableAction();
				actionFld.text = getText("loading");
				prevAction = null;
			} else {
				if (this.action != "close") { prevAction = this.action; }
				actionBtn.addEventListener(MouseEvent.CLICK,handleActionClick);
				actionBtn.enabled = true;
				actionFld.alpha = 1;
				actionFld.text = getText(action);
			}
			this.action = action;
		}
		
		// disables the action button
		protected function disableAction():void {
			actionBtn.removeEventListener(MouseEvent.CLICK,handleActionClick);
			actionBtn.enabled = false;
			actionFld.alpha = 0.2;
		}
		
		// shows the dialog, and hides the help button
		protected function showDialog(title:String,content:String):void {
			dialog.titleFld.text = title;
			dialog.contentFld.htmlText = content;
			dialog.visible = true;
			helpBtn.visible = false;
		}
		
		// hides the dialog, and shows the help button
		protected function hideDialog():void {
			dialog.visible = false;
			helpBtn.visible = !hideHelp;
		}
		
		// return if all required parameters are present, false if not:
		protected function verifyParams():Boolean {
			return !(appName == null || appURL == null || airVersion == null);
		}
		
		// return null if not a valid URL, only allow HTTP, HTTPS scheme or relative path
		protected function validateURL(url:String):String {
			if (url == null) { return null; }
			var markerIndex:int = url.search(/:|%3a/i);
			if (markerIndex > 0) {
				var scheme:String = url.substr(0, markerIndex).toLowerCase();
				if (VALID_PROTOCOLS.indexOf(scheme) == -1) { return null; }
			}
			if (url.indexOf("<") >= 0 || url.indexOf(">") >= 0) {
				return null;
			}
			return url;
		}
		
		// returns null if the string is empty or null.
		protected function validateString(str:String):String {
			return (str == null || str.length < 1 || str.indexOf("<") >= 0 || str.indexOf(">") >= 0) ? null : str;
		}
		
		// returns the specified string from FlashVars (passed as "str_strcode") if available, or the default string if not.
		protected function getText(strCode:String):String {
			var str:String = loaderInfo.parameters["str_"+strCode];
			if (str != null && str.length > 1) {
				return str;
			}
			switch (strCode) {
				case "error": return "Error!";
				case "err_params": return "Invalid installer parameters.";
				case "err_airunavailable": return "Adobe® AIR™ is not available for your system.";
				case "err_airswf": return "Unable to load the Adobe® AIR™ Browser API swf.";
				case "loading": return "Loading...";
				case "install": return "Install Now";
				case "launch": return "Launch Now";
				case "upgrade": return "Upgrade Now";
				case "close": return "Close";
				case "launching": return "Launching Application";
				case "launchingtext": return "Please wait while the application launches.";
				case "installing": return "Installing Application";
				case "installingtext": return "Please wait while the application installs.";
				case "tryagain": return "Try Again";
				case "help": return "Help";
				case "helptext": return getHelpText();
			}
			return "";
		}
		
		// assembles help text based on the current badge state.
		// ex. Click the 'Install Now' button to install My Fun Application. The Adobe® AIR™ runtime will be installed automatically.
		protected function getHelpText():String {
			var helpText:String = "Click the '"+getText(action)+"' button to "+action+" "+appName;
			if (action == "upgrade") { helpText += " to version "+appVersion; }
			else if (action == "install") { helpText += " trial.<br>If needed, the Adobe AIR player will be installed as well."; }
			helpText += ".";
			if (helpURL != null) { helpText += "\n<a href='"+helpURL+"'><font color='#2288FF'>Click here for additional help</font></a>"; }
			return helpText;
		}
		
		// returns true if the first version number is greater than the second, or false if it is lesser or indeterminate:
		// works with most common versions strings: ex. 1.0.2.27 < 1.0.3.2, 1.0b3 < 1.0b5, 1.0a12 < 1.0b7, 1.0b3 < 1.0
		protected function checkVersion(v1:String,v2:String):int {
			var arr1:Array = v1.replace(/^v/i,"").match(/\d+|[^\.,\d\s]+/ig);
			var arr2:Array = v2.replace(/^v/i,"").match(/\d+|[^\.,\d\s]+/ig);
			var l:uint = Math.max(arr1.length,arr2.length);
			for (var i:uint=0; i<l; i++) {
				var sub:int = checkSubVersion(arr1[i],arr2[i])
				if (sub == 0) { continue; }
				return sub;
			}
			return 0;
		}
		
		// return 1 if the sub version element v1 is greater than v2, -1 if v2 is greater than v1, and 0 if they are equal
		protected function checkSubVersion(v1:String,v2:String):int {
			v1 = (v1 == null) ? "" : v1.toUpperCase();
			v2 = (v2 == null) ? "" : v2.toUpperCase();
			
			if (v1 == v2) { return 0; }
			var num1:Number = parseInt(v1);
			var num2:Number = parseInt(v2);
			if (isNaN(num2) && isNaN(num1)) {
				return (v1 == "") ? 1 : (v2 == "") ? -1 : (v1 > v2) ? 1 : -1;
			}
			else if (isNaN(num2)) { return 1; }
			else if (isNaN(num1)) { return -1; }
			else { return (num1 > num2) ? 1 : -1; }
		}
		
		
	// ** this is the public API we expose so the badge configuration application can work with this badge **
		
		// returns an object containing the basic properties of the badge. The configurator expects minWidth, maxWidth, minHeight and maxHeight.
		public function getProps():Object {
			return {minWidth:215,maxWidth:430,minHeight:180,maxHeight:320};
		}
		
		// returns an array of objects describing the parameters supported by this badge.
		// parameters will be displayed in the configurator in the same order they are in the array.
		// If you add a toolTip paramater, that value will be used as the paramaters label toolTip, otherwise the label will be used.
		// supported parameter types and associated properties:
		// - string (name, label, default, maxChars, toolTip)
		// - boolean (name, label, default, toolTip)
		// - color (name, label, default, toolTip)
		// - number (name, label, default, required, minValue, maxValue, toolTip)
		// - image (name, label, default, toolTip) - Creates an image browse field. Types are restricted to png, gif, and jpeg
		// - heading (label) – displays a heading above a parameter group
		public function getParams():Array {
			var params:Array = [
								{name:"helpurl",label:"help url",type:"string",maxChars:200,def:"help.html"},
								{name:"hidehelp",label:"hide help?",type:"boolean",def:false},
								{name:"skiptransition",label:"skip transition?",type:"boolean",def:false},
								{name:"titlecolor",label:"title color",type:"color",def:"FF0000"},
								{name:"buttonlabelcolor",label:"button label color",type:"color",def:"FFFFFF"},
								
								{label:"Strings",type:"heading"},
								{name:"str_error",label:"error title",type:"string",def:getText("error")},
								{name:"str_err_params",label:"invalid params error",type:"string",def:getText("err_params")},
								{name:"str_err_airunavailable",label:"AIR unavailable error",type:"string",def:getText("err_airunavailable")},
								{name:"str_err_airswf",label:"loading AIR swf failed error",type:"string",def:getText("err_airswf")},
								{name:"str_loading",label:"loading label",type:"string",def:getText("loading")},
								{name:"str_install",label:"install button label",type:"string",def:getText("install")},
								{name:"str_launch",label:"launch button label",type:"string",def:getText("launch")},
								{name:"str_upgrade",label:"upgrade button label",type:"string",def:getText("upgrade")},
								{name:"str_close",label:"close button label",type:"string",def:getText("close")},
								{name:"str_tryagain",label:"try again button label",type:"string",def:getText("tryagain")},
								{name:"str_launching",label:"launching title",type:"string",def:getText("launching")},
								{name:"str_launchingtext",label:"launching text",type:"string",def:getText("launchingtext")},
								{name:"str_installing",label:"installing title",type:"string",def:getText("installing")},
								{name:"str_installingtext",label:"installing text",type:"string",def:getText("installingtext")},
								{name:"str_help",label:"help title",type:"string",def:getText("help")},
								{name:"str_helptext",label:"help text",type:"string",def:""},
								];
			return params;
		}
		
		// return an object representing the dimensions of the image to export for this badge.
		// This is called when the badge is exported by the configurator so that it can vary dynamically depending on the badge's current dimensions.
		public function getImageSize():Object {
			return {width:205,height:170};
		}
		
		// handles initial UI setup.
		protected function configUI():void {
			stop();
			
			actionFld.text = getText("loading");
			actionFld.mouseEnabled = false;
			disableAction();
			hideDialog();
			helpBtn.addEventListener(MouseEvent.CLICK,handleHelpClick);
			
			// allow clicks to pass through the light overlay:
			light.mouseEnabled = false;
			
			// get rid of the default frame for imageHolder:
			imageHolder.removeChildAt(0);
			
			// and hide it until the image is loaded:
			imageHolder.visible = false;
			
			// hide the help button until the air proxy swf is loaded:
			helpBtn.visible = false;
		}
		
	}
}