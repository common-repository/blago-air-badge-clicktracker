<?php
	if (isset($_POST['action'])){
		$action = $_POST['action'];
		$bAirBadge->save_option_changes();
?>
	<div class="updated fade" id="message" style="background-color: rgb(255, 251, 204);"><p><strong>Settings saved.</strong></p></div>	
<?php
	}
?>

<style type="text/css">	
#airbadge-box 	{ width:100%; }
.metabox-holder	{ margin:0 0 14px 0 !important; }
#airbadge-box .postbox-container { width:545px; }
#airbadge-box,
#airbadge-box .postbox-container,
#airbadge-box .meta-box,
#airbadge-box .postbox	{ height:auto !important; padding:0; margin:0;  }
#airbadge-box .inside 	{ height:85px; padding:0; margin:0 10px 10px 10px !important; }
#airbadge-box .inside p.sub 	{ display:block; clear:both; font-style:italic; padding:5px 0 !important; margin:0 !important; color:#777; font-size:13px; 
	font-family:Georgia, "Times New Roman", "Bitstream Charter", Times, serif; }
#airbadge-box .inside .table 	{ background:#f9f9f9; border-top:#ececec 1px solid; border-bottom:#ececec 1px solid; margin:0 -9px 5px -9px; padding:0 10px; }
#airbadge-box .inside table 	{ width:100%; padding:0; margin:0; }
#airbadge-box .inside .table,
#airbadge-box .inside table 	{ height:53px; }
#airbadge-box .inside table td 	{ border-top:#ececec 1px solid; padding:3px 0; white-space:nowrap; }
#airbadge-box .inside table tr.first td { border-top:none; }
#airbadge-box .inside table td.b 		{ padding-right:6px; text-align:right; font-size:16px; 
	font-family:Georgia, "Times New Roman", "Bitstream Charter", Times, serif; }
#airbadge-box .inside table td.t 	{ font-size:12px; padding-right:12px; padding-top:6px; color:#777; }
#airbadge-box .inside table td.ab-installed	{ color:green; font-size:18px; font-weight:bold; }
#airbadge-box .inside table td.first,
#airbadge-box .inside table td.last 	{ width:10px; }
</style>

<div class="wrap">
	<h2>blago AirBadge</h2>
		<p>To add your Air Badge to a page, use this tag in your content: <code>[airbadge] application name, full URL to yourapplication.air, application version, badge_img.jpeg[/airbadge]</code>. <br/>
        Make sure you add the ExternalInterface call to your AirBadge's AIRInstallBadge.as as well. For more info, please visit the <a href="http://www.blagoworks.nl/telexer/category/wordpress/">blago AIR Badge page</a></p>
        
    <div id="airbadge-box" class="metabox-holder">    
    	<div class="postbox-container">
			<div class="meta-box">
				<div class="postbox">
                	<h3 class="hndle"><span>Download count</span></h3>
                    <div class="inside">
                    	<p class="sub">tracking clicks on AirBadge since <?php echo $bAirBadge->option['airapp_plugin_date'] ?>:</p>
                        <div class="table">
                             <table>
                             	<tr class="first">
                                    <td class="first b ab-installed"><?php echo $bAirBadge->option['airapp_count_install'] ?></td>
                                    <td class="t">clicked "install" (new)</td>
                                    <td class="b"><?php echo $bAirBadge->option['airapp_count_tryagain'] ?></td>
                                    <td class="last t">clicked "try again" (after attempted install)</td>
                                </tr>
                                <tr>
                                    <td class="first b"><?php echo $bAirBadge->option['airapp_count_upgrade'] ?></td>
                                    <td class="t">clicked "upgrade"</td>
                                    <td class="b"><?php echo $bAirBadge->option['airapp_count_launch'] ?></td>
                                    <td class="last t">clicked "launch" (previously installed app)</td>
                                </tr>
                             </table>
                        </div>
                        
                	</div>
                </div>
            </div>
        </div>
      	<br class="clear" />
    </div>
   
    
    <div id="airbadge-config" class="metabox-holder">	
        <h3>Configuration</h3>   
        <form method="post" action="">
    
            <table class="form-table" cellspacing="2">
                <tr>
                    <th scope="row"><label for="airbadge_swfobject">swfObject toggle</label></th>
                    <td><label for="airbadge_swfobject"><input type="checkbox" name="airbadge_swfobject" id="airbadge_swfobject" value="true" <?php echo $bAirBadge->option['airbadge_swfobject'] ? "checked=\"checked\"" : ""?>/> Check to include the swfObject library</label>
                        <br/><span class="description">You should uncheck this option if the swfObject library is already included in your template (i.e. added by other plugins).</span>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_jquery">jQuery toggle</label></th>
                    <td><label for="airbadge_jquery"><input type="checkbox" name="airbadge_jquery" id="airbadge_jquery" value="true" <?php echo $bAirBadge->option['airbadge_jquery'] ? "checked=\"checked\"" : ""?>/> Check to include the jQuery library</label>
                        <br/><span class="description">You should uncheck this option if the jQuery library is already included in your template (i.e. added by other plugins).</span>
                    </td>
                </tr>
                
                <tr>
                    <th scope="row"><label for="airbadge_playermsg">Flash not installed message</label></th>
                    <td><span class="description">Customize the text that appears when the correct version of the Flash player is not installed.</span><br/>
                    <textarea class="regular-text" name="airbadge_playermsg" id="airbadge_playermsg" rows="4" cols="50"><?php echo $bAirBadge->option['airbadge_playermsg']?></textarea>
                        <br/>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_skiptransition">Skip transition ani</label></th>
                    <td><label for="airbadge_skiptransition"><input type="checkbox" name="airbadge_skiptransition" id="airbadge_skiptransition" value="false" <?php echo $bAirBadge->option['airbadge_skiptransition'] ? "checked=\"checked\"" : "" ?>/> Check to skip the fade-in intro ani</label>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_titlecolor">Air Badge title color</label></th>
                    <td><input class="regular-text code" type="text" name="airbadge_titlecolor" value="<?php echo $bAirBadge->option['airbadge_titlecolor']?>" size="18"/>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_buttonlabelcolor">Button label color</label></th>
                    <td><input class="regular-text code" type="text" name="airbadge_buttonlabelcolor" value="<?php echo $bAirBadge->option['airbadge_buttonlabelcolor']?>" size="18"/>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_appnamecolor">Air app name color</label></th>
                    <td><input class="regular-text code" type="text" name="airbadge_appnamecolor" value="<?php echo $bAirBadge->option['airbadge_appnamecolor']?>" size="18"/>
                    </td>
                </tr>
                <tr>
                    <th scope="row"><label for="airbadge_uninstall">Uninstall: clear options</label></th>
                    <td><span class="description">Before you deactivate this plugin, check the box below to clear the values stored by the AIR Badge from the database.</span><br/>
                    <label for="airbadge_uninstall"><input type="checkbox" name="airbadge_uninstall" id="airbadge_uninstall" value="false" <?php echo $bAirBadge->option['airbadge_uninstall'] ? "checked=\"checked\"" : "" ?>/> Check to permanently remove AIR Badge counts and settings from Wordpress (no undo!)</label>
                    </td>
                </tr>
            </table>
            <input type="hidden" name="action" value="update" />
			<input type="hidden" name="page_options" value="airbadge_swfobject,airbadge_jquery,airbadge_playermsg,airbadge_skiptransition,airbadge_titlecolor,airbadge_buttonlabelcolor,airbadge_appnamecolor,airbadge_uninstall" />
            <p class="submit"><input type="submit" value="Save Changes" class="button-primary" /></p>
        </form>
        
	</div>
        
</div>