#if defined _gz_rank_included
  #endinput
#endif
#define _gz_rank_included

/*********************************************************
 * Get's the number of a player's season points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/

native int GZ_Rank_GetSeasonPoints(int client);

/*********************************************************
 * Get's the number of a player's global points
 *
 * @param client		The client to get the points
 * @return				The number of points		
 *********************************************************/

native int GZ_Rank_GetGlobalPoints(int client);

/*********************************************************
 * Sets the number of a player's season points
 *
 * @param client		The client to set the points
 * @param points		The points to be set
 * @return					
 *********************************************************/

native bool GZ_Rank_SetSeasonPoints(int client, int points);

/*********************************************************
 * Sets the number of a player's global points
 *
 * @param client		The client to set the points
 * @param points		The points to be set
 * @return				
 *********************************************************/

native bool GZ_Rank_SetGlobalPoints(int client, int points);

/*********************************************************
 * Sets the number of a player's season kills
 *
 * @param client		The client to get the kill
 * @return				The number of kills		
 *********************************************************/

native int GZ_Rank_GetSeasonKills(int client);

/*********************************************************
 * Sets the number of a player's global kills
 *
 * @param client		The client to get the kill
 * @return				The number of kills		
 *********************************************************/

native int GZ_Rank_GetGlobalKills(int client);

/*********************************************************
 * Sets the number of a player's season deaths
 *
 * @param client		The client to get the deaths
 * @return				The number of deaths		
 *********************************************************/

native int GZ_Rank_GetSeasonDeaths(int client);

/*********************************************************
 * Sets the number of a player's global deaths
 *
 * @param client		The client to get the deaths
 * @return				The number of deaths		
 *********************************************************/

native int GZ_Rank_GetGlobalDeaths(int client);

/*********************************************************
 * Sets the number of a player's season mvps
 *
 * @param client		The client to get the mvps
 * @return				The number of mvps		
 *********************************************************/

native int GZ_Rank_GetSeasonMvps(int client);

/*********************************************************
 * Sets the number of a player's global mvps
 *
 * @param client		The client to get the mvps
 * @return				The number of mvps		
 *********************************************************/

native int GZ_Rank_GetGlobalMvps(int client);

/*********************************************************
 * Sets the number of a player's season kd
 *
 * @param client		The client to get the kd
 * @return				The number of kd		
 *********************************************************/

native float GZ_Rank_GetSeasonKD(int client);

/*********************************************************
 * Sets the number of a player's global kd
 *
 * @param client		The client to get the kd
 * @return				The number of kd		
 *********************************************************/

native float GZ_Rank_GetGlobalKD(int client);

/**********************************************************************
 * When a player has been loaded
 * *
 * @param         client        The client index of the player that has been loaded
 * @noreturn
 **********************************************************************/
forward Action GZ_OnPlayerLoaded(int client);

