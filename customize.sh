##########################################################################################
# Installation variables and functions for the Magisk module "MagiskHide Props Config"
# Copyright (c) 2018-2021 Didgeridoohan @ XDA Developers.
# Licence: MIT
##########################################################################################

# Load functions and variables
INSTFN=true
. $MODPATH/common/util_functions.sh

# Print module info
ui_print ""
ui_print "************************"
ui_print " Installing $MODVERSION "
ui_print "************************"
ui_print ""

# Remove module directory if it exists on a fresh install
if [ ! -d "$MODULESPATH/MagiskHidePropsConf"] && [ -d "$MHPCPATH" ]; then
  rm -rf $MHPCPATH
fi

# Create module directory
mkdir -pv $MHPCPATH

# Start module installation log
echo "***************************************************" > $LOGFILE 2>&1
echo "********* MagiskHide Props Config $MODVERSION ********" >> $LOGFILE 2>&1
echo "***************** By Didgeridoohan ***************" >> $LOGFILE 2>&1
echo "***************************************************" >> $LOGFILE 2>&1
log_print "- Starting module installation script"

# Rudimentary tamper check
log_handler "Checking module files MD5 checksum."
unzip -o "$ZIPFILE" 'META-INF/*' -d $MODPATH >> $LOGFILE 2>&1
cd $MODPATH

  # Module script installation
  script_install
  		Manufacturer=$(getprop ro.product.manufacturer)
		if [ $Manufacturer == "samsung" ] ; then
			echo "-->$Manufacturer phone, attempting to auto-set fingerprint"
			BL=$(getprop ro.boot.bootloader)
			DEVICE=${BL:0:4}
			MatchNum = "0" 	# Trap which item number matches
			MatchQty = "0" 	# How many matches were found
			MatchName = ""  # The fingerprint descriptive string
			ITEM="Samsung"
			TMPFILE=$PRINTFILES/Samsung.sh   # *** MFM - scroll throogh the Samsung-specific file, looking for a match on the 4 character Base model (e.g., G986)
			if [ -f "$TMPFILE" ] ; then      # The file exists, now open it and do the check
				. $TMPFILE
			fi
			ITEMCOUNT=1
			SAVEIFS=$IFS
			IFS=$(echo -en "\n\b")
			SearchString="SM-"
			ModelString=""
			MatchPrint=""     # The latest fingerprint for a match to the base device type
			for ITEM in $PRINTSLIST; do       # *** MFM PRINTSLIST is the array of entries in the vendor-speific file (e.g., Samsung.sh)
				if [ "$(get_first $ITEM)" == "Samsung" ] ; then
					ModelString=${ITEM#*$SearchString} # *** MFM Capture the substring starting after the "SM-"
					FingerprintBaseModelString=${ModelString:0:4} # Only want the first 4 characters
					if [ $DEVICE == $FingerprintBaseModelString ] ; then    # Have a match, e.g. G986
						MatchNum=$ITEMCOUNT
						MatchQty=$(($MatchQty + 1)) # If this ends up > 1 the user may want to choose one of the other ones via props
						MatchName=$(get_device "$ITEM")
						MatchPrint=$(get_eq_right "$ITEM")
						echo -e "$MatchNum - $MatchName"
						echo -e "***$MatchPrint***"
					fi
					ITEMCOUNT=$(($ITEMCOUNT+1))
				fi
			done
			if [ $MatchQty == "0" ] ; then
				echo "-->No matches to $DEVICE found.  Reboot, launch a superuser terminal "
				echo "    session, run 'props', then select 1 - f - 26 to pick a fingerprint"
			else                # MatchQty >= 1
				echo "-->Using fingerprint for: "
				echo "    $MatchNum - $MatchName"
				#Add lines to do the fingerprint setting
						change_print_installer "$1" "$MatchPrint"
				if [ $MatchQty -ne "1" ] ; then  # there were > 1 matches, add a warning statement	
					echo "-->There were $MatchQty total matches to $DEVICE.  If a different fingerprint"
					echo "    is desired, after rebooting, in a superuser terminal session run "
					echo "    'props', then select 1 - f - 26 to pick the fingerprint"
				fi
			fi
#			echo -e "Count of Samsung fingerprints = $(($ITEMCOUNT-1))"
		fi
  # Permission
  log_print "- Setting permissions"
  set_perm $MODPATH/system/$BIN/props 0 0 0755

  # Cleanup
  rm -rf $MODPATH/META-INF
  rm -f $MODPATH/module.md5

  log_print "- Module installation complete."
