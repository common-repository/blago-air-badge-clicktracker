=== blago AIR Badge Clicktracker ===
Contributors: Hanneke Hoogstrate - BlagoWorks
Donate link: http://www.blagoworks.nl/donate/
Tags: Adobe AIR badge, track clicks, track downloads, jQuery
Requires at least: 2.7
Tested up to: 2.8.4
Stable tag: 1.1

Inserts a custom AIR Install Badge in your post or page content, and displays user click counts on its configuration page. 


== Description ==

Inserts the code needed for a custom AIR Install Badge that will track user clicks in real time. The total number of download/installs will be displayed in a dashboard widget.

There are four kinds of user clicks that are being tracked, corresponding to the function that the Badge button has at the moment it's clicked: "install", "try again," "upgrade", and "launch". Of these, "install" is of course the most interesting; "try again" could be an aborted install attempt, or impatient users; with "upgrade" the user already has an older version of your app installed; and with "launch", the app is already up-to-date and installed - this is usually yourself clicking to see if it works :-) 

Note: works with a customized Adobe AIR badge, jQuery, and an older version of swfObject (1.5).

To make it work, you need to add an External Interface call to your AIR Badge. There's a set of sample files in the zip, or you could follow the Installation notes.

For more info, please visit the [AIR Badge plugin](http://www.blagoworks.nl/telexer/wordpress/track-clicks-on-air-badge-wordpress-plugin) page, or an overview of my [other plugins](http://www.blagoworks.nl/telexer/category/wordpress/)


== Installation ==

*1* prepare the AIR badge (or look at the sample actionscript file in folder airbadge-source): 
In the AIRInstallBadge.as, add: import flash.external.ExternalInterface; to the package.
Declare two vars in the class:

	//count clicks

	protected var siteUrl:String;

	protected var clicksObj:Object;


Add the variable needed to send the jQuery get request; place this in the function that receives the flashvars on init:

     siteUrl = validateString(params.siteurl);

Next, find the function that handles the click (handleActionClick()), and add this call on the events that you'd like to track clicks for:

     addDownloadCount(action);

this calls:

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

*2* install the plugin:
- unzip the files to a local folder 
- copy the AIR Badge folder to your WP plugin folder

*3* activate:
- activate the plugin on your WP admin > plugins page
- make sure you visit the Settings page to configure the plugin.
Set the location to your AIRInstallBadge_hh.swf, and add values for your *appid* and the *pubid* here. The *appid* corresponds with the ID you put in while publishing your AIR file. Grant Skinner's Badger app will easily get the *pubid* for you.
IMPORTANT: You need to disable the inclusion of the javascript libraries swfObject and/or jQuery, if other plugins are already adding those to the head of your pages. It's not a good idea to have them twice in your header, but not much will happen without them. 
You can also customize some badge colors in Settings. The Button label color is the one you see in the word "install". 

*4* add tag to page or post:
- add this to your page where you want your custom Air Badge to appear:

	[airbadge]0[/airbadge]
	
This is backwards compatible with the AirBadge plugin 1.0, but ready to be used for tracking more badges in a blog:

	[airbadge]blago Telexer, http://www.blagoworks.nl/telexer/update/install_blagoTelexer_209.air, 2.09, http://www.blagoworks.nl/telexer/update/badge_img.jpeg [/airbadge]


To see if everything is working, click on your newly-placed AIR Badge and then visit the Settings page to see if the numbers have changed. 

If you decide to uninstall the plugin, you can clear the counts and options the plugin has saved: you need to set a check before de-activating. The counts are only removed if you set this check, so you have the option to leave the counts in the database, if you need to de-activate and then want to activate again.



== Frequently Asked Questions ==

= I'm using swfObject 2 and this won't work! =

If you know how your AIR Badge object code should look for swfObject 2, you could change the php code that writes the object. It's in airbadge.php.

= But I'd rather use Google Analytics! =

Change the javascript function in airdlcounter.js to point to the Google tracker, and the following day you'll see your AIR Badge clicks tracked there.
For ga.js, use the "pageTracker._trackEvent(category, action, opt_label, opt_value)" call, where category would be "myAIRBadge", action would be the clickType variable (i.e. tracking "install" or "try again" clicks), and opt_labe/opt_value are optional values to send.

= I have more than one AIR Badge I want to track! =

Sorry, that's not possible yet in this version; the numbers will be lumped together...



== Screenshots ==

1. After activating, go to the Settings page to edit the options there. This is also where the click counts will be displayed.

2. The panel with the tracked user clicks on the Dashboard.


== Changelog ==

= 1.1 =
* simplified the tag that is used to place the AirBadge on the page - ready for multiple badge support
* added management of hardcoded values (air url, appid, pubid) to Settings page
* both tag and value input changes made to be backwards compatible with v1.0!
* moved tracked clicks display to Dashboard
* added css in admin header
* pre-2.7 versions still get clicks display on the Settings page

= 1.0 =
* pristine version


== Credits ==

This plugin uses the Sample AIR Badge that was made by Grant Skinner (see Adobe's [DevNet page](http://www.adobe.com/devnet/air/articles/badge_for_air.html) for more), with the addition of an ExternalInterface call to make the click visible.

Of course, all kudos go to Peter Elst for the original [AIR Badge plugin](http://www.peterelst.com/blog/2008/04/19/air-badge-wordpress-plugin/). I reworked his idea into a php-class, added the count display on the configuration page and some garbage disposal for when you de-activate the plugin.
