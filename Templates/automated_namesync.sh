

# Script Name= NameSync_TerminalSolution

#Gets and sorts logged in user
logged_in_user=$(ls -l /dev/console | awk '/ / { print $3 }')

#If the current user is NOT named root.
if [[ ! "$(ls -l /dev/console | grep 'root')" ]];then

#Set ComputerName to the name of the logged in user.    
#Change prefix for each client.
scutil --set ComputerName "$namesync-$logged_in_user"

#Sets ComputerName as var.
computer_name=$(scutil --get ComputerName)

#Gets ComputerName previously sets LocalHost accordingly.
scutil --set LocalHostName "$computer_name"

#Gets LocalHostName
local_host_name=$(scutil --get LocalHostName)

#Sets HostName to same as LocalHostName
scutil --set HostName "$local_host_name"

else
#If current user is named root.
echo "User is currently root and will not have named changed."

fi

exit 0

#V1 3/10/18 16:31
#V2 3/17/18 20:21 #Added HostName Change
#V3 4/1/18  23:15 #Added IF root conditional statement to prevent machines from being named root.