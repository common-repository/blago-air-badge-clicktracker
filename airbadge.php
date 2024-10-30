<?php
/*
Plugin Name: blago AIR Badge
Plugin URI:  http://www.blagoworks.nl/telexer/wordpress/track-clicks-on-air-badge-wordpress-plugin
Plugin Description: Places a custom AIR Install Badge in WP, and tracks user clicks on its <a href="options-general.php?page=blago-airbadge/options.php">configuration page</a>. For more info, please visit the <a href="http://www.blagoworks.nl/telexer/wordpress/track-clicks-on-air-badge-wordpress-plugin">blago AIR Badge page</a>
Version: 1.0
Author: Hanneke / BlagoWorks
Author URI: http://www.blagoworks.nl/
All kudos to Peter Elst for the original AIR Badge: http://www.peterelst.com/blog/2008/04/19/air-badge-wordpress-plugin/

*/

/* class */
if (!class_exists("bAirBadge")) {
	class bAirBadge {
		public $plugin_name    = 'blago AIR Badge';
		public $option_key     = 'bab_options';	
		public $plugin_directory;
		public $plugin_options_path;
		public $swfobject_path;
		public $jquery_path;
		public $ajax_path;
		
		public $option;
		public $default_option;
	
		/* constructor */
		function __construct(){
			$this->plugin_directory 	= get_bloginfo('wpurl').'/'.PLUGINDIR.'/'.dirname(plugin_basename(__FILE__));
			$this->plugin_options_path 	= dirname(plugin_basename(__FILE__)) . '/options.php';
			$this->swfobject_path		= get_bloginfo('wpurl').'/'.PLUGINDIR.'/'.dirname(plugin_basename(__FILE__)) . '/swfobject.js';
			$this->jquery_path 			= get_bloginfo('wpurl').'/wp-includes/js/jquery/jquery.js';
			$this->ajax_path			= "'".preg_replace('/([^:]:\/\/)[^\/]+(\/.*)?/i', "$1".$_SERVER['HTTP_HOST']."$2", get_bloginfo('wpurl'))."'";
			
			//init options on plugin activation
			register_activation_hook(__FILE__, array(&$this, 'init_airbadge_options'));
			register_deactivation_hook(__FILE__, array(&$this, 'unset_airbadge_options'));
			//add options page
			add_action('admin_menu', 	array(&$this, 'set_airbadge_optionspage'));
			//add code to post or page
			add_action('wp_head', 		array(&$this, 'add_airbadge_headcode'));	//add js script tags
			add_filter('the_content', 	array(&$this, 'get_airbadge_customtag'));

			$this->get_option();
			$this->ajax_process();
		}


		/* --- options --- */
		function init_airbadge_options(){
			//add default options to wp_options
			$installDate = date("F j, Y"); //"August 1, 2009"
			$this->default_option = 
				array(
					'airapp_plugin_date' => "August 1, 2009",
					'airapp_count_install' => 0,
					'airapp_count_upgrade' => 0,
					'airapp_count_tryagain' => 0,
					'airapp_count_launch' => 0,
					'airbadge_swfobject' => true,
					'airbadge_jquery' => true,
					'airbadge_playermsg' => "<b>Please upgrade your Flash Player</b> This installer and the application require Flash Player 9.0.115 or higher installed.",
					'airbadge_titlecolor' => "#ff9900",
					'airbadge_buttonlabelcolor' => "#ff9900",
					'airbadge_appnamecolor' => "#f7f7f2",
					'airbadge_skiptransition' => false,
					'airbadge_uninstall' => false
					);
			$this->do_merge_option($this->option, $this->default_option);
		}
		function do_merge_option(&$src_arr, &$dst_arr){
			if (!is_array($src_arr)){ $src_arr = array(); }
			$keyArr = array_keys($dst_arr);
			foreach($keyArr as $key){
				if (!isset($src_arr[$key])){
					$src_arr[$key] = $dst_arr[$key];
				}else{
					if (is_array($src_arr[$key])){
						$this->do_merge_option($src_arr[$key], $dst_arr[$key]);
					}
				}
			}
		}
		//clean up db on deactivate
		function unset_airbadge_options(){
			//delete_option('airapp_count_install');
			if($this->option['airbadge_uninstall']){
				$keyArr = array_keys($this->option);
				foreach($keyArr as $key){
					delete_option($this->option_key);
				}
			}
		}
		function get_option(){
			$this->option = get_option($this->option_key);	
			$has_been_added = is_array($this->option);
			$this->init_airbadge_options();
			if (!$has_been_added){
				$this->update_option();
			}
		}
		function update_option(){
			if (!add_option($this->option_key, $this->option)){
				update_option($this->option_key, $this->option);
			}
		}
		//called from options.php
		function save_option_changes(){
			$this->option['airbadge_swfobject'] 		= isset($_POST['airbadge_swfobject']);
			$this->option['airbadge_jquery'] 			= isset($_POST['airbadge_jquery']);
			$this->option['airbadge_playermsg'] 		= $_POST['airbadge_playermsg'];
			$this->option['airbadge_titlecolor'] 		= $_POST['airbadge_titlecolor'];
			$this->option['airbadge_buttonlabelcolor'] 	= $_POST['airbadge_buttonlabelcolor'];
			$this->option['airbadge_appnamecolor'] 		= $_POST['airbadge_appnamecolor'];
			$this->option['airbadge_skiptransition'] 	= isset($_POST['airbadge_skiptransition']);
			$this->option['airbadge_uninstall'] 		= isset($_POST['airbadge_uninstall']);
			$this->update_option();
		}
		

		/* --- display: actions and filters --- */
		function set_airbadge_optionspage(){
			//page title, link label, access level, path
			add_options_page("blago AIR Badge settings", "blago AIR Badge", 10, $this->plugin_options_path);
		}
		function add_airbadge_headcode() {
			//make conditional - if meta is set? if page is nr?
			echo "\n<!-- blago AIR Badge -->\n";
			if ($this->option['airbadge_swfobject']) {
				echo '<script type="text/javascript" src="'.$this->swfobject_path.'"></script>' ."\n";
			}
			if ($this->option['airbadge_jquery']) {
				echo '<script type="text/javascript" src="'.$this->jquery_path.'"></script>' ."\n";
			}
			echo '<script type="text/javascript" src="'.$this->plugin_directory.'/airdlcounter.js"></script>' ."\n";
		}

		//look for [airbadge] tag in content and replace it with the badge code
		function get_airbadge_customtag($content) {			
    		return preg_replace_callback('|\[airbadge\](.+?),(.+?),(.+?),(.+?)\[/airbadge\]|i', array(&$this,'get_airbadge_snippet'), $content);
		}
		function get_airbadge_snippet($match) {	
			$uniqsuffix = substr(uniqid(rand(), true),0,4);
				// note: get_option('airbadge_playermsg') doesn't work
			$code = "<div class=\"airbadgediv\" id=\"swfholder".$uniqsuffix."\" style=\"width:215px; height:180px;\">".$this->option['airbadge_playermsg']."</div> \n";
			$code .= "<script type=\"text/javascript\"> \n";
			$code .= "<!-- //<![CDATA[\n";
			$code .= "var so = new SWFObject(\"http://EDIT_HERE/AIRInstallBadge_hh.swf\", \"Badge\", \"215\", \"180\", \"9.0.115\", \"#FFFFFF\");\n";
			
			$code .= "so.useExpressInstall(\"".$this->plugin_directory."/expressinstall.swf\");\n";
			$code .= "so.addVariable(\"airversion\", \"1.5\");\n";
			$code .= "so.addVariable(\"appname\", \"".urlencode(trim($match[1]))."\");\n";
			$code .= "so.addVariable(\"appurl\", \"".trim($match[2])."\");\n";
			$code .= "so.addVariable(\"appid\", \"EDIT_HERE\");\n";  //\"".urlencode(trim($match[1]))."\");\n";
			$code .= "so.addVariable(\"pubid\", \"EDIT_HERE\");\n";
			$code .= "so.addVariable(\"appversion\", \"".urlencode(trim($match[3]))."\");\n";
			$code .= "so.addVariable(\"image\", \"".trim($match[4])."\");\n";
			$code .= "so.addVariable(\"hidehelp\", \"false\");\n";
			$code .= "so.addVariable(\"str_close\", \"Back\");\n";
			//set the badge options
			$code .= "so.addVariable(\"skiptransition\", \"".$this->option['airbadge_skiptransition']."\");\n"; 
			$code .= "so.addVariable(\"titlecolor\", \"".$this->option['airbadge_titlecolor']."\");\n";  	//#ff9900
			$code .= "so.addVariable(\"buttonlabelcolor\", \"".$this->option['airbadge_buttonlabelcolor']."\");\n"; 
			$code .= "so.addVariable(\"appnamecolor\", \"".$this->option['airbadge_appnamecolor']."\");\n";
			$code .= "so.addVariable(\"str_err_airswf\", \"<u>Running locally?</u><br/><br/>The AIR proxy swf won't load properly when this is run from the local file system.\");\n";
			//add vars for download counter
			$code .= "so.addVariable(\"siteurl\", \"".$this->ajax_path."\");\n";
			
			$code .= "so.write(\"swfholder".$uniqsuffix."\");\n";
			$code .= "//]]> -->\n";
			$code .= "</script>\n";
		
			return $code;		
		}
	
		
		//todo: widget
		function display_airbadge_widget() {
			//add widget code
		}

		//counts	
		function increase_counts($clicktype){
			//$installType ["install" || "upgrade" || "tryagain" || "launch"]
			if($clicktype=="install"){
				$this->option['airapp_count_install'] = $this->option['airapp_count_install']+1;
			}
			if($clicktype=="upgrade"){
				$this->option['airapp_count_upgrade'] = $this->option['airapp_count_upgrade']+1;
			}
			if($clicktype=="tryagain"){
				$this->option['airapp_count_tryagain'] = $this->option['airapp_count_tryagain']+1;
			}
			if($clicktype=="launch"){
				$this->option['airapp_count_launch'] = $this->option['airapp_count_launch']+1;
			}
			$this->update_option();
		}

		//--- gets airbadge_post_id from js jquery get(); updates count ---//
		function ajax_process(){
			if( isset($_GET['airbadge_clicktype']) ){
				//increase count for each install type
				$installType = $_GET['airbadge_clicktype'];
				$this->increase_counts($installType);
				echo "php received: ".$installType;
				exit();		
			}
		}
		
	}
}


/* create instance */
if (class_exists("bAirBadge")) {
	$bAirBadge = new bAirBadge();
}


/* called from template 
function display_AirBadgeCount() {
	global $bAirBadge;
	if (isset($bAirBadge)) {		
		$bAirBadge->display_airbadge_widget();
	} 
}
*/
?>
