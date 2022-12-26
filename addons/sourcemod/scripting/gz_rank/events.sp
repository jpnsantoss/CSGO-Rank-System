void HookEvents()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("bomb_planted", Event_BombPlanted, EventHookMode_Pre);
	HookEvent("bomb_defused", Event_BombDefused, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEventEx("round_mvp", Event_RoundMvp, EventHookMode_Pre); // Missing in CS:S v34.
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_GZ_Rank_NumPlayers < g_GZ_Rank_MinPlayers || GameRules_GetProp("m_bWarmupPeriod") == 1)
		return Plugin_Handled;
	
	int winner = GetEventInt(event, "winner");

	for (int i; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		if (winner == GetClientTeam(i))
		{
			PlayerData[i].Season.Points += g_GZ_Rank_RoundWin_Points;
			PlayerData[i].Global.Points += g_GZ_Rank_RoundWin_Points;
			CPrintToChat(i, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos por ganhares a ronda.", g_GZ_Rank_RoundWin_Points);
		} else if((PlayerData[i].Season.Points) >= g_GZ_Rank_RoundWin_Points) {

			PlayerData[i].Season.Points -= g_GZ_Rank_RoundWin_Points;
			PlayerData[i].Global.Points -= g_GZ_Rank_RoundWin_Points;
			CPrintToChat(i, "[ {orange}RANK{default} ] Perdeste {lightred}%i{default} pontos por perderes a ronda.", g_GZ_Rank_RoundWin_Points);
		}
			
		CheckRanks();
	}
	return Plugin_Handled;
}

public Action Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_GZ_Rank_NumPlayers < g_GZ_Rank_MinPlayers)
		return Plugin_Handled;
	
	int playerplantedbomb = GetClientOfUserId(GetEventInt(event, "userid"));

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		if (GetClientTeam(i) == CS_TEAM_T)
		{
			PlayerData[i].Season.Points += g_GZ_Rank_Bomb_Points;
			PlayerData[i].Global.Points += g_GZ_Rank_Bomb_Points;

			if (i == playerplantedbomb)
			{
				PlayerData[i].Season.Points += g_GZ_Rank_Player_Bomb_Points;
				CPrintToChat(i, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos por plantares a bomba.", g_GZ_Rank_Bomb_Points + g_GZ_Rank_Player_Bomb_Points);
			} else {
				CPrintToChat(i, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos pela tua equipa ter plantado a bomba.", g_GZ_Rank_Bomb_Points);
			}
			CheckRanks();
		}
	}
	return Plugin_Handled;
}

public Action Event_BombDefused(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_GZ_Rank_NumPlayers < g_GZ_Rank_MinPlayers)
		return Plugin_Handled;
	
	int playerdefusedbomb = GetClientOfUserId(GetEventInt(event, "userid"));
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_CT)
		{
			PlayerData[i].Season.Points += g_GZ_Rank_Bomb_Points;
			PlayerData[i].Global.Points += g_GZ_Rank_Bomb_Points;

			if(i == playerdefusedbomb)
			{
				PlayerData[i].Season.Points += g_GZ_Rank_Player_Bomb_Points;
				CPrintToChat(i, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos por defusares a bomba.", g_GZ_Rank_Bomb_Points + g_GZ_Rank_Player_Bomb_Points);
			}
			else {
				CPrintToChat(i, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos pela tua equipa ter defusado a bomba.", g_GZ_Rank_Bomb_Points);
			}
				
			CheckRanks();
		}
	}
	return Plugin_Handled;
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_GZ_Rank_NumPlayers < g_GZ_Rank_MinPlayers || GameRules_GetProp("m_bWarmupPeriod") == 1)
		return Plugin_Handled;
	
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int assist = GetClientOfUserId(GetEventInt(event, "assister"));
	
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	ReplaceString(weapon, sizeof(weapon), "weapon_", "");
	
	if (!IsValidClient(victim) || !IsValidClient(attacker))
		return Plugin_Handled;
	
	if ((victim == attacker) && (PlayerData[victim].Season.Points >= g_GZ_Rank_Suicide_Points))
	{			
	 	PlayerData[victim].Season.Points -= g_GZ_Rank_Suicide_Points;
	 	PlayerData[victim].Global.Points -= g_GZ_Rank_Suicide_Points;
	 	PlayerData[victim].Season.Deaths++;
	 	PlayerData[victim].Global.Deaths++;
	 	CPrintToChat(victim, "[ {orange}RANK{default} ] Perdeste {lightred}%i{default} pontos por te suicidares.", g_GZ_Rank_Suicide_Points);
	}
	else if (victim != attacker) {
		bool headshot = GetEventBool(event, "headshot");
		
		if (StrContains(weapon, "knife") != -1 || 
			StrEqual(weapon, "bayonet") || 
			StrEqual(weapon, "melee") || 
			StrEqual(weapon, "axe") || 
			StrEqual(weapon, "hammer") || 
			StrEqual(weapon, "spanner") || 
			StrEqual(weapon, "fists"))weapon = "knife";
		
		if (StrContains(weapon, "knife") != -1)
		{
			PlayerData[attacker].Season.Points += (g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points);
			PlayerData[attacker].Global.Points += (g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points);
			PlayerData[attacker].Global.Kills++;
			CPrintToChat(attacker, "[ {orange}RANK{default} ] Recebeste {green}%i{default} pontos por matares %N de {lightblue}faca{default}!", g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points, victim);
			
			if (PlayerData[victim].Season.Points >= (g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points))
			{

				PlayerData[victim].Season.Points -= (g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points);
				PlayerData[victim].Global.Points -= (g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points);
				PlayerData[victim].Season.Deaths++;
				PlayerData[victim].Global.Deaths++;
				CPrintToChat(victim, "[ {orange}RANK{default} ] Perdeste {lightred}%i{default} pontos por seres morto de {lightblue}faca{default}!", g_GZ_Rank_Kill_Points + g_GZ_Rank_Knife_Points);
			}
		}

		if (headshot)
		{
			PlayerData[attacker].Season.Points += (g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points);
			PlayerData[attacker].Global.Points += (g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points);
			PlayerData[attacker].Season.Kills++;
			PlayerData[attacker].Global.Kills++;
			CPrintToChat(attacker, "[ {orange}RANK{default} ] Recebeste {green}%i{default} pontos por matares %N de {lightblue}headshot{default}!", g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points, victim);
			
			if (PlayerData[victim].Season.Points >= (g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points))
			{
				PlayerData[victim].Season.Points -= (g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points);
				PlayerData[victim].Global.Points -= (g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points);
				PlayerData[victim].Season.Deaths++;
				PlayerData[victim].Global.Deaths++;
				CPrintToChat(victim, "[ {orange}RANK{default} ] Perdeste {lightred}%i{default} pontos por seres morto de {lightblue}headshot{default}!", g_GZ_Rank_Kill_Points + g_GZ_Rank_HeadShot_Points);
			}
		} else
		{
			if (assist > 0)
			{
				PlayerData[assist].Season.Points += g_GZ_Rank_Assist_Points;
				PlayerData[assist].Global.Points += g_GZ_Rank_Assist_Points;
				CPrintToChat(assist, "[ {orange}RANK{default} ] Recebeste {green}%i{default} pontos por fazeres uma assist!", g_GZ_Rank_Assist_Points);
			}
			
			PlayerData[attacker].Season.Points += g_GZ_Rank_Kill_Points;
			PlayerData[attacker].Global.Points += g_GZ_Rank_Kill_Points;
			PlayerData[attacker].Season.Kills++;
			PlayerData[attacker].Global.Kills++;
			CPrintToChat(attacker, "[ {orange}RANK{default} ] Recebeste {green}%i{default} pontos por matares %N!", g_GZ_Rank_Kill_Points, victim);
			
			if (PlayerData[victim].Season.Points >= g_GZ_Rank_Kill_Points)
			{
				PlayerData[victim].Season.Points -= g_GZ_Rank_Kill_Points;
				PlayerData[victim].Global.Points -= g_GZ_Rank_Kill_Points;
				PlayerData[victim].Season.Deaths++;
				PlayerData[victim].Global.Deaths++;
				CPrintToChat(victim, "[ {orange}RANK{default} ] Perdeste {lightred}%i{default} pontos por morreres!", g_GZ_Rank_Kill_Points);
			}
		}
	}

	CheckRanks();
	return Plugin_Handled;
}

public Action Event_RoundMvp(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsClientInGame(client) || (g_GZ_Rank_NumPlayers < g_GZ_Rank_MinPlayers) || GameRules_GetProp("m_bWarmupPeriod") == 1)
		return Plugin_Handled;
	
	PlayerData[client].Season.Points += g_GZ_Rank_Mvp_Points;
	PlayerData[client].Global.Points += g_GZ_Rank_Mvp_Points;
	
	PlayerData[client].Season.MVPs++;
	PlayerData[client].Global.MVPs++;

	CPrintToChat(client, "[ {orange}RANK{default} ] Ganhaste {green}%i{default} pontos por seres o MVP.", g_GZ_Rank_Mvp_Points);
	CheckRanks();

	return Plugin_Handled;
} 