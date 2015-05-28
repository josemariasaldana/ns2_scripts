 This NS2 script generates these traffics:
 - World of Warcraft traffic, from client to server and vice versa
 - FTP traffic
 - cbr traffic

 It has been developed by Jose Saldana+ and Mirko Suznjevic*
 + EINA, University of Zaragoza, Spain
 * FER, University of Zagreb, Croatia

 This script can be freely used for Research and Academic purposes

 If you use this script, please cite the next open-source paper:

 Mirko Suznjevic, Jose Saldana, Maja Matijasevic, Julián Fernández-Navajas, and José Ruiz-Mas, 
 “Analyzing the Effect of TCP and Server Population on Massively Multiplayer Games,” 
 International Journal of Computer Games Technology, vol. 2014, Article ID 602403, 17 pages, 2014. doi:10.1155/2014/602403
 http://dx.doi.org/10.1155/2014/602403


 The Word of Warcraft player behaviour is modeled as exchanging between six different activities: dungeons, pvp, questing, raiding, trading, uncategorized

 The script includes statistical models for

 - First activity of the player

 - Duration of each activity
		- If the activity is "raiding", then the duration depends on the hour of the day

 - Probability of exchange from one activity to other, depending on the hour of the day

 - IAT (Inter Arrival Time) and APDU (Application Payload Data Unit), for client-to-server and server-to-client traffic, depending on the activity

 - The APDU of Trading depends on the number of players in the server: numplayers_($connection_id_)

 - The APDU and IAT of PvP depend on the subactivity

 The script also simulates the hour of the day advance. Every 3600 seconds, the hour increases and the parameters which control the 
 activity exachange are modified

 ----------------------------------------------------------------------------------------------------------------------------
 The script uses this network scheme:

   node0 o-------o node8                 o node1		- a "number_of_wow_connections_0_1_" of WoW are set from node0 (client) to node1 (server)
                  \                     /
            node9  \ node4      node5  / 
   node6 o-----o----o-----------------o-----o node7	- a "number_of_wow_connections_6_7_" of WoW are set from node6 (client) to node7 (server)
            node10/ |                 | \
  node2  o------o  /                  |  o node3		- a "number_of_FTP_upload_" FTP background connections are set from node2 (origin) to node3 (destination)
				   /				    \				- a "number_of_FTP_download_" FTP background connections are set from node3 (origin) to node2 (destination)
  node12 o-------o						 o node13		- three UDP flows go from node2 to node3. The size of the packets of each flow can be defined
				node11									- three UDP flows go from node3 to node2. The size of the packets of each flow can be defined

														- a "number_of_FTP_upload_" FTP background connections are set from node12 (origin) to node13 (destination)
														- a "number_of_FTP_download_" FTP background connections are set from node13 (origin) to node12 (destination)

   the link between node4 and node5 is the bottleneck

	optionally, an additional multiplexing delay is added from node8 to node4, from node9 to node4, from node10 to node4 and from node11 to node4