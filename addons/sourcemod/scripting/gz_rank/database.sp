#define DATA_SEASON 0
#define DATA_GLOBAL 1

void DatabaseConnection()
{
	char dbError[256];
	DB = SQL_Connect("rank", true, dbError, sizeof(dbError));
	
	if (DB == INVALID_HANDLE)
	{
		PrintToServer("[ RANK ] Erro ao ligar à base de dados: %s", dbError);
		SetFailState("[ RANK ] Erro ao ligar à base de dados: %s", dbError);
	} else
	{
		PrintToServer("[ RANK ] Conexão à base de dados estabelecida com sucesso");
	}
}

void CreateTable(int datatype)
{
	char query[512];
	
	DB.Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS rank_%s (ID INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(128) NOT NULL, steamid VARCHAR(64) NOT NULL UNIQUE KEY, pontos INT(6) NOT NULL, kills INT(6) NOT NULL, mortes INT(6) NOT NULL, mvps INT(6) NOT NULL);", datatype == DATA_SEASON ? "season" : "global");
	DB.Query(OnTablesCreated, query);
}

void OnTablesCreated(Database db, DBResultSet results, const char[] error, int finished)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	if(finished == 1)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if(!IsValidClient(client))
				continue;

			OnClientPostAdminCheck(client);
		}		
	}
}

void LoadPlayerInfo(int client, int datatype)
{
	char szSteamId[65];
	GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

	char query[256];
	DB.Format(query, sizeof(query), "SELECT * FROM rank_%s WHERE steamid = '%s';", datatype == DATA_SEASON ? "season" : "global", szSteamId);
	DB.Query(datatype == DATA_SEASON ? OnPlayerInfoLoadedSeason : OnPlayerInfoLoadedGlobal, query, GetClientUserId(client));
}

void OnPlayerInfoLoadedSeason(Database db, DBResultSet results, const char[] error, int userid)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
		return;
	
	if (results.RowCount == 0)
	{
		char szSteamId[65];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

		char szName[MAX_NAME_LENGTH + 1];
		GetClientName(client, szName, sizeof(szName));

		char queryInsert[512];
		DB.Format(queryInsert, sizeof(queryInsert), "INSERT INTO `rank_season` (nome, steamid, pontos, kills, mortes, mvps) VALUES ('%s', '%s', '%i', '%i', '%i', '%i') ON DUPLICATE KEY UPDATE ID = ID;", szName, szSteamId, PlayerData[client].Season.Points, PlayerData[client].Season.Kills, PlayerData[client].Season.Deaths, PlayerData[client].Season.MVPs);
		DB.Query(OnPlayerInfoLoadedSeason, queryInsert);

		// reload data..
		LoadPlayerInfo(client, DATA_SEASON);
		return;
	} else
	{
		// if the rows can be uniquely identified then it will run only once
		while(results.FetchRow())
		{
			PlayerData[client].Season.Points = 	results.FetchInt(3);
			PlayerData[client].Season.Kills = results.FetchInt(4);
			PlayerData[client].Season.Deaths = results.FetchInt(5);
			PlayerData[client].Season.MVPs = results.FetchInt(6);
		}
	}
	
	Action fResult;
	Call_StartForward(g_fwdOnPlayerLoaded);
	Call_PushCell(client);
	int fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
}

void OnPlayerInfoLoadedGlobal(Database db, DBResultSet results, const char[] error, int userid)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
		return;
	
	if (results.RowCount == 0)
	{
		char szSteamId[65];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

		char szName[MAX_NAME_LENGTH + 1];
		GetClientName(client, szName, sizeof(szName));

		char queryInsert[512];
		DB.Format(queryInsert, sizeof(queryInsert), "INSERT INTO `rank_global` (nome, steamid, pontos, kills, mortes, mvps) VALUES ('%s', '%s', '%i', '%i', '%i', '%i') ON DUPLICATE KEY UPDATE ID = ID;", szName, szSteamId, PlayerData[client].Global.Points, PlayerData[client].Global.Kills, PlayerData[client].Global.Deaths, PlayerData[client].Global.MVPs);
		DB.Query(OnPlayerInfoLoadedGlobal, queryInsert);

		// reload data..
		LoadPlayerInfo(client, DATA_GLOBAL);
		return;
	} else
	{
		// if the rows can be uniquely identified then it will run only once
		while(results.FetchRow())
		{
			PlayerData[client].Global.Points = 	results.FetchInt(3);
			PlayerData[client].Global.Kills = results.FetchInt(4);
			PlayerData[client].Global.Deaths = results.FetchInt(5);
			PlayerData[client].Global.MVPs = results.FetchInt(6);
		}
	}

	Action fResult;
	Call_StartForward(g_fwdOnPlayerLoaded);
	Call_PushCell(client);
	int fError = Call_Finish(fResult);
	
	if (fError != SP_ERROR_NONE)
	{
		ThrowNativeError(fError, "Forward failed");
	}
}

void UpdatePlayerInfo(int client, int datatype)
{
	char szSteamId[65];
	GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

	char szName[MAX_NAME_LENGTH + 1];
	GetClientName(client, szName, sizeof(szName));

	char query[512];
	DB.Format(query, sizeof(query), "UPDATE rank_%s SET nome = '%s', steamid = '%s', pontos = '%i', kills = '%i', mortes = '%i', mvps = '%i' WHERE steamid = '%s';", datatype == DATA_SEASON ? "season" : "global", szName, szSteamId, PlayerData[client].Season.Points, PlayerData[client].Season.Kills, PlayerData[client].Season.Deaths, PlayerData[client].Season.MVPs, szSteamId);
	DB.Query(OnUpdatePlayerInfo, query);
}

stock void OnUpdatePlayerInfo(Database db, DBResultSet results, const char[] error, any data)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}
}

void CountRegistos(int datatype)
{
	char query[256];
	DB.Format(query, sizeof(query), "SELECT ID FROM rank_%s;", datatype == DATA_SEASON ? "season" : "global");
	DB.Query(OnCountRegistos, query, datatype);
}

void OnCountRegistos(Database db, DBResultSet results, const char[] error, int datatype)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}
	
	results.FetchRow();

	if(datatype == DATA_SEASON)
	{
		g_GZ_Rank_Season_Registos = results.RowCount;
	} else {
		g_GZ_Rank_Global_Registos = results.RowCount;
	}
}

void ListaTop(int client, int datatype)
{
	char query[256];
	DB.Format(query, sizeof(query), "SELECT nome, steamid FROM rank_%s ORDER BY pontos;", datatype == DATA_SEASON ? "season" : "global");
	DB.Query(datatype == DATA_SEASON ? OnListaTopSeason : OnListaTopGlobal, query, GetClientUserId(client));
}

void OnListaTopSeason(Database db, DBResultSet results, const char[] error, int userid)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
		return;
	
	int player_pos = 0;

	while(results.FetchRow())
	{
		player_pos++;
		char szSteamIdTemp[65];

		char szSteamId[65];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

		SQL_FetchString(results, 1, szSteamIdTemp, sizeof(szSteamIdTemp));
	
		if(StrEqual(szSteamIdTemp, szSteamId))
		{
			g_GZ_Rank_Season_Pos = player_pos;
		}
	}
}

void OnListaTopGlobal(Database db, DBResultSet results, const char[] error, int userid)
{
	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
		return;
	
	int player_pos = 0;

	while(results.FetchRow())
	{
		player_pos++;
		char szSteamIdTemp[65];

		char szSteamId[65];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));

		SQL_FetchString(results, 1, szSteamIdTemp, sizeof(szSteamIdTemp));
	
		if(StrEqual(szSteamIdTemp, szSteamId))
		{
			g_GZ_Rank_Global_Pos = player_pos;
		}
	}
}