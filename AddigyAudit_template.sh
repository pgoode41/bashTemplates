######################################################################################################################################################
#                                                               BASH TEMPLATE START
######################################################################################################################################################


######################################################################################################################################################
#                                                               FUNCTION ZONE
######################################################################################################################################################


function addigy_enrollcmd {

#Checking to see if Addigy is installed.
if [[ -d /Library/Addigy ]];then
	
	echo "####################################################################################"
	echo "$date_stamp"
	echo "Addigy IS ALREADY installed."
	echo "####################################################################################"
elif [[ ! -d /Library/Addigy ]];then

	#Installs Addigy if it isn't installed already.
	echo "####################################################################################"
	echo "$date_stamp"
	echo "Addigy is not installed"
	echo "Attempting to install Addigy..."
	sudo curl -o /tmp/macinstall https://agents.addigy.com/agent-install &&
 	sudo chmod +x /tmp/macinstall &&
  	sudo /tmp/macinstall realm=prod orgid=282f0e29-edfc-423c-a5da-abb9ed687946 policy_id="$addigy_policy"
  	#Checking to see if install was sucessful.
  	if [[ ! -d /Library/Addigy ]];then

	echo "####################################################################################"
	echo "$date_stamp"
	echo "Adiggy could not be installed. Please Cunsult a TSDev-Ops Engineer!!!"
	echo "####################################################################################"
	

	elif [[ -d /Library/Addigy ]];then
	echo "####################################################################################"
	echo "$date_stamp"
	echo "Addigy Was installed Sucessfully!:D"
	echo "####################################################################################"
	

fi

fi

}

echo "After Addigy Func"

function sendtolog {
#Sets log file.

tee -a "$log_path"

}

function ard_enable() {
#Enables ARD for specified user.
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -privs -all -users
"$account_name" -restart -agent -menu

}

function ScreenConnect_Custom_Install {

	echo "ScreenConnect_Audit_Start"

 if [[ $(ls /opt/ | grep "screenconnect" | wc -l) -gt 0 ]];then

 	echo "Screenconnect is Alredy installed."
 	installed=$(ls /opt/ | grep "screenconnect" | awk '{print$1}')
 	echo "Installed Version(s):$installed"
 else

 	echo "ScreenConnect is NOT currently installed."
 	echo "Attempting to install custom ScreenConnect.."
 	echo "Attempting..."
 	chmod +x "$client_screenconncet_install_location" && echo "chmod worked if this is here"
 	bash $client_screenconncet_install_location
 	echo "Checking to see if install was sucesslful"
 	
 fi


if [[ ! $(ls /opt/ | grep "screenconnect" | wc -l) -gt 0 ]]; then
	
	echo "ScreenConnect install was NOT sucesslful :("
	echo "Please try again."
	echo "If this is your 2nd attempt intalling, contact a TS DEV-OPS engineer."

fi

echo "ScreenConnect_Audit_End"

}

function watchman_function {


#Fucnction Start.
echo "####################################################################################"
echo "Watchman Audit Start."
wantchman_current=$(defaults read /Library/MonitoringClient/ClientSettings.plist ClientGroup)
#Checking to see if Watchman is installed and output print ClientGroup key and value, to logs.
if [[ ! $(ls /Library | grep "MonitoringClient" | wc -l) -gt 0 ]];then

    echo "####################################################################################"
	echo "Watchman is not currently installed."
	echo "Attempting to install Watchman, now..."
	echo "Installing..."
	/usr/bin/defaults write /Library/MonitoringClient/ClientSettings ClientGroup -string "$watchman_group_name" && \
	/usr/bin/curl -L1 https://terminal.monitoringclient.com/downloads/MonitoringClient.pkg > /tmp/MonitoringClient.pkg && \
	/usr/sbin/installer -target / -pkg /tmp/MonitoringClient.pkg && \
	/bin/rm /tmp/MonitoringClient.pkg
	echo "Done!"
    echo "####################################################################################"

elif [[ $(ls /Library | grep "MonitoringClient" | wc -l) -gt 0 ]];then

    echo "####################################################################################"
	echo "Watchman is currently installed."
    echo "Printing current Watchman ClientGroup value"
    defaults read /Library/MonitoringClient/ClientSettings.plist ClientGroup
    echo "####################################################################################"

fi

if [[ $(defaults read /Library/MonitoringClient/ClientSettings.plist ClientGroup) == "$watchman_group_name" ]];then

    echo "####################################################################################"
    echo "Machine is enrolled in correct policy."
    echo "####################################################################################"

else

    echo "####################################################################################"
    echo "Machine is currently enrolled in the wrong group!!!"
    echo "Current enrolled policy is:"
    defaults read /Library/MonitoringClient/ClientSettings.plist ClientGroup
    echo "Correct policy is: $watchman_group_name"
    echo "attempting to force into correct policy"
	defaults read /Library/MonitoringClient/ClientSettings.plist ClientGroup
	echo "Forcing to specified group..."
    echo "Removing from incorrect policy"
    /Library/MonitoringClient/Utilities/RemoveClient -F
    echo "Enrolloing into correct Watchman group."
	/usr/bin/defaults write /Library/MonitoringClient/ClientSettings ClientGroup -string "$watchman_group_name" && \
	/usr/bin/curl -L1 https://terminal.monitoringclient.com/downloads/MonitoringClient.pkg > /tmp/MonitoringClient.pkg && \
	/usr/sbin/installer -target / -pkg /tmp/MonitoringClient.pkg && \
	/bin/rm /tmp/MonitoringClient.pkg
	echo "Done!"
    echo "####################################################################################"

fi

if [[ $(ls /Library | grep "MonitoringClient" | wc -l) -gt 0 ]];then

echo "####################################################################################"
echo "Watchman Audit End."
echo "####################################################################################"

elif [[ ! $(ls /Library | grep "MonitoringClient" | wc -l) -gt 0 ]];then

    echo "WATCHMAN COULD NOT BE INSTALLED!"
    echo "Please Consult TS DEV-OPS Engineer"
fi

}

function admin_account {
if [[ ! "$(dscl . list /Users | grep "$account_name")" ]];then


	
	echo "####################################################################################"
	echo "$account_name NOT Found..Attempting to create one.."
	echo "Creating $account_name account"
	dscl . -create /Users/$account_name
	dscl . -create /Users/$account_name UserShell /bin/bash
	dscl . -create /Users/$account_name RealName $account_name
	dscl . -create /Users/$account_name UniqueID 719
	dscl . -create /Users/$account_name PrimaryGroupID 80
	dscl . -create /Users/$account_name NFSHomeDirectory /$account_name
	#Testing with temp admin password.. admin account in addigy profile should overwrite(More Secure).
	dscl . -passwd /Users/$account_name $password
	dscl . append /Groups/admin GroupMembership $account_name
	echo "####################################################################################"

else

	echo "####################################################################################"
	echo "$date_stamp"
	echo "$account_name account already exists."
	echo "####################################################################################"

fi

if [[ ! "$(dscl . list /Users | grep "$account_name")" ]];then

	echo "$account_name could not be created. Please consult a TSDEV-OPS Engineer!"

else

	echo "$account_name was sucessfully created!"
	
fi

}


######################################################################################################################################################
#                                                               FUNCTION ZONE
######################################################################################################################################################


######################################################################################################################################################
#                                                               EXECUTION ZONE
######################################################################################################################################################

if [[ ! -e "$log_path" ]];then
	echo "####################################################################################"
	echo "Creating Log File."
	touch "$log_path"
	echo "####################################################################################" | sendtolog
	echo "####################################################################################" | sendtolog
	echo "Job Started at:$date_stamp" | sendtolog
	echo "####################################################################################" | sendtolog

else

	echo "####################################################################################" | sendtolog
	echo "clearing old logs." | sendtolog
	rm -rfv "$log_path" | sendtolog
	echo "Creating NEW Log File." | sendtolog
 	touch "$log_path" | sendtolog
 	echo "####################################################################################" | sendtolog
 	echo "####################################################################################" | sendtolog
	echo "Job Started at:$date_stamp" | sendtolog
	echo "####################################################################################" | sendtolog

fi


chmod 755 $log_path


########################################################################################################
#Creates admin account if it doesn't already exist.
echo "####################################################################################" | sendtolog
echo "$date_stamp" | sendtolog
addigy_enrollcmd | sendtolog
echo "####################################################################################" | sendtolog
########################################################################################################


########################################################################################################
#Creates admin account if it doesn't already exist.
echo "####################################################################################" | sendtolog
echo "$date_stamp" | sendtolog
admin_account | sendtolog
echo "####################################################################################" | sendtolog
########################################################################################################


########################################################################################################
#Remote Access Enable for admin
#ONLY ENABLE WHEN PUSHING FROM FLASH DRIVE
echo "####################################################################################" | sendtolog
echo "$date_stamp" | sendtolog
ard_enable | sendtolog
echo "####################################################################################" | sendtolog
########################################################################################################


########################################################################################################
#Watchman Monitoring Audit/Installer Function execution.
echo "####################################################################################" | sendtolog
echo "$date_stamp" | sendtolog
watchman_function | sendtolog
echo "####################################################################################" | sendtolog
########################################################################################################

########################################################################################################
#ScreenConnect Audit/Installer Function execution.
echo "####################################################################################" | sendtolog
echo "$date_stamp" | sendtolog
ScreenConnect_Custom_Install | sendtolog
echo "####################################################################################" | sendtolog
########################################################################################################
#Checks to see if admin was installed and reboots if it was created sucessfully.
if [[ ! "$(dscl . list /Users | grep "$account_name" )" ]];then

	echo "####################################################################################" | sendtolog
	echo "$date_stamp" | sendtolog
	echo "$admin_account account was not created." | sendtolog
	echo "####################################################################################" | sendtolog
	

 elif [[ "$(dscl . list /Users | grep "$account_name" )" ]];then


    echo "####################################################################################" | sendtolog
	echo "$date_stamp" | sendtolog
	echo "$admin_account verified. Rebooting to apply changes." | sendtolog
	echo "Job Finished at:$date_stamp" | sendtolog
	echo "####################################################################################" | sendtolog
	shutdown -r now
	echo "Command post reboot(assume reboot is commented out.)"

 fi

echo "Job Finished at:$date_stamp" | sendtolog

exit 0
