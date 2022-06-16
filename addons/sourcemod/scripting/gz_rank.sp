#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <multicolors>
#include <cstrike>

#include <gz_rank>

#pragma newdecls required;
#pragma semicolon 1;
#pragma tabsize 4;

#include "gz_rank/variables.sp"
#include "gz_rank/natives.sp"
#include "gz_rank/database.sp"
#include "gz_rank/menus.sp"
#include "gz_rank/events.sp"
#include "gz_rank/commands.sp"

public Plugin myinfo =
{
	name = "gz_rank",
	author = "JPLAYS",
	description = "Gaming Zone Ranking System.",
	version = "1.0.0",
	url = "https://github.com/jplayss/gz_rank"
};

public void OnPluginStart()
{
	DatabaseConnection();
	CreateTable(DATA_SEASON);
	CreateTable(DATA_GLOBAL);

	RegConsoleCmd("sm_rank", Command_Rank, "Shows player rank");
	RegConsoleCmd("sm_rankseason", Command_Rank, "Shows player rank");
	RegAdminCmd("sm_rankglobal", Command_GlobalRank, ADMFLAG_ROOT, "Shows player rank");
	RegConsoleCmd("sm_rank", Command_Rank, "Shows player rank");
	RegConsoleCmd("sm_top", Command_Top, "Shows Server Top");
	RegConsoleCmd("sm_topseason", Command_TopSeason, "Shows Season Top");
	RegAdminCmd("sm_topglobal", Command_TopGlobal, ADMFLAG_ROOT, "Shows Global Top");
	RegConsoleCmd("sm_pontos", Command_Pontos);

	RegAdminCmd("sm_givepoints", Command_GivePoints, ADMFLAG_ROOT);

	// forward moved to AskPluginLoad2

	HookEvents();

	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i))
			continue;

		OnClientPostAdminCheck(i);
	}
}

public void OnMapStart()
{
	CountRegistos(DATA_SEASON);
	CountRegistos(DATA_GLOBAL);

	char sBuffer[128];
	for(int i = 0; i < 18; i++)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/skillgroups/skillgroup%i.svg", 85000001 + i); //Make the clients download the files, the files required to be updated to the server & fastdl in bz2 format
		AddFileToDownloadsTable(sBuffer);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsValidClient(client))
		return;

	PlayerData[client].Reset();

	CalculatePlayers();
	
	LoadPlayerInfo(client, DATA_SEASON);
	LoadPlayerInfo(client, DATA_GLOBAL);
	
	GetMMRank(client);
}

public void UpdateData(int client)
{
	UpdatePlayerInfo(client, DATA_SEASON);
	UpdatePlayerInfo(client, DATA_GLOBAL);
}

public void OnClientDisconnect(int client)
{
	if(!IsValidClient(client))
		return;
	
	CalculatePlayers();
	UpdateData(client);
}

void CalculatePlayers()
{
	g_GZ_Rank_NumPlayers = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;

		g_GZ_Rank_NumPlayers++;
	}
	
	if(g_GZ_Rank_NumPlayers >= g_GZ_Rank_MinPlayers)
	{
		CPrintToChatAll("[ {orange}RANK{default} ] Agora existem %i jogadores dentro do servidor! O Rank foi ativado!", g_GZ_Rank_MinPlayers);
	} else
	{
		CPrintToChatAll("[ {orange}RANK{default} ] Não existem jogadores suficientes dentro do servidor! O Rank foi desativado!");
	}
}

void GetMMRank(int client)
{
	if(PlayerData[client].Season.Points < 0)
	{
		PlayerData[client].MMRank = "Unranked";
	} 
	else if (PlayerData[client].Season.Points >= 0 && PlayerData[client].Season.Points < 50) 
	{
		PlayerData[client].MMRank = "Silver 1";
	}
	else if (PlayerData[client].Season.Points >= 50 && PlayerData[client].Season.Points < 110) 
	{
		PlayerData[client].MMRank = "Silver 2";
	}
	else if (PlayerData[client].Season.Points >= 110 && PlayerData[client].Season.Points < 180) 
	{
		PlayerData[client].MMRank = "Silver 3";
	}
	else if (PlayerData[client].Season.Points >= 180 && PlayerData[client].Season.Points < 260) 
	{
		PlayerData[client].MMRank = "Silver 4";
	}
	else if (PlayerData[client].Season.Points >= 260 && PlayerData[client].Season.Points < 350) 
	{
		PlayerData[client].MMRank = "Silver Elite";
	}
	else if (PlayerData[client].Season.Points >= 350 && PlayerData[client].Season.Points < 450) 
	{
		PlayerData[client].MMRank = "Silver Master Elite";
	}
	else if (PlayerData[client].Season.Points >= 450 && PlayerData[client].Season.Points < 560) 
	{
		PlayerData[client].MMRank = "Gold 1";
	}
	else if (PlayerData[client].Season.Points >= 560 && PlayerData[client].Season.Points < 680) 
	{
		PlayerData[client].MMRank = "Gold 2";
	}
	else if (PlayerData[client].Season.Points >= 680 && PlayerData[client].Season.Points < 810) 
	{
		PlayerData[client].MMRank = "Gold 3";
	}
	else if (PlayerData[client].Season.Points >= 810 && PlayerData[client].Season.Points < 950) 
	{
		PlayerData[client].MMRank = "Gold 4";
	}
	else if (PlayerData[client].Season.Points >= 950 && PlayerData[client].Season.Points < 1100) 
	{
		PlayerData[client].MMRank = "AK 1";
	}
	else if (PlayerData[client].Season.Points >= 1100 && PlayerData[client].Season.Points < 1260) 
	{
		PlayerData[client].MMRank = "AK 2";
	}
	else if (PlayerData[client].Season.Points >= 1260 && PlayerData[client].Season.Points < 1430) 
	{
		PlayerData[client].MMRank = "AK Cruzada";
	}
	else if (PlayerData[client].Season.Points >= 1430 && PlayerData[client].Season.Points < 1610) 
	{
		PlayerData[client].MMRank = "DMG";
	}
	else if (PlayerData[client].Season.Points >= 1610 && PlayerData[client].Season.Points < 1800) 
	{
		PlayerData[client].MMRank = "LE";
	}
	else if (PlayerData[client].Season.Points >= 1800 && PlayerData[client].Season.Points < 2000) 
	{
		PlayerData[client].MMRank = "LEM";
	}
	else if (PlayerData[client].Season.Points >= 2000 && PlayerData[client].Season.Points < 2500) 
	{
		PlayerData[client].MMRank = "Supremo";
	}
	else if (PlayerData[client].Season.Points >= 2500) 
	{
		PlayerData[client].MMRank = "Global Elite";
	}
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	
	return false;
}

void CheckRanks()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsValidClient(i))
			continue;

		GetMMRank(i);
	}
}