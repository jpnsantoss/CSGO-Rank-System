void ShowRankMenu(int client)
{
	float kd = GZ_Rank_GetSeasonKD(client);
	
	Menu menu = new Menu(RankMenu_Handler);
	menu.SetTitle("%N - Pre-Season \n \n TOP ➜ %i/%i \n Pontos ➜ %d \n Rank ➜ %s \n Kills ➜ %i \n Mortes ➜ %i \n K/D ➜ %.2f \n MVPs ➜ %i \n \n ", client, g_GZ_Rank_Season_Pos, g_GZ_Rank_Season_Registos, PlayerData[client].Season.Points, PlayerData[client].MMRank, PlayerData[client].Season.Kills, PlayerData[client].Season.Deaths, kd, PlayerData[client].Season.MVPs);
	
	// char buffer[512];
	// FormatEx(buffer, sizeof(buffer), "TOP ➜ %i/%i", g_GZ_Rank_Season_Pos, g_GZ_Rank_Season_Registos);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "Pontos ➜ %d", PlayerData[client].Season.Points);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "Rank ➜ %s", PlayerData[client].MMRank);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "Kills ➜ %i | Mortes ➜ %i", PlayerData[client].Season.Kills, PlayerData[client].Season.Deaths);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "K/D ➜ %.2f | MVPs ➜ %i", kd, PlayerData[client].Season.MVPs);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	menu.AddItem("global", "Ver Rank Global", ITEMDRAW_DISABLED);
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int RankMenu_Handler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_End:delete menu;
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(index, info, sizeof(info));
			
			if (StrEqual(info, "global"))
			{
				ShowGlobalRankMenu(client);
			}
		}
	}
}

void ShowGlobalRankMenu(int client)
{
	float kd = GZ_Rank_GetGlobalKD(client);
	Menu menu = new Menu(GlobalRankMenu_Handler);
	menu.SetTitle("%N - Rank Global \n \n TOP ➜ %i/%i \n Pontos ➜ %d \n Kills ➜ %i \n Mortes ➜ %i \n KDA ➜ %.2f \n MVPs ➜ %i \n \n ", client, g_GZ_Rank_Global_Pos, g_GZ_Rank_Global_Registos, PlayerData[client].Global.Points, PlayerData[client].Global.Kills, PlayerData[client].Global.Deaths, kd, PlayerData[client].Global.MVPs);
	
	menu.AddItem("season", "Ver Rank da Season");
	
	// char buffer[512];
	// FormatEx(buffer, sizeof(buffer), "Pontos ➜ %d", PlayerData[client].Global.Points);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "Kills ➜ %i", PlayerData[client].Global.Kills);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);

	// FormatEx(buffer, sizeof(buffer), "Mortes ➜ %i", PlayerData[client].Global.Deaths);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	
	// FormatEx(buffer, sizeof(buffer), "KDA ➜ %.2f", kd);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);

	// FormatEx(buffer, sizeof(buffer), "MVPs ➜ %i", PlayerData[client].Global.MVPs);
	// menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int GlobalRankMenu_Handler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_End:delete menu;
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(index, info, sizeof(info));
			
			if (StrEqual(info, "season"))
			{
				ShowRankMenu(client);
			}
		}
	}
}

void ShowTopMenuMain(int client)
{
	Menu menu = new Menu(TopMenuMain_Handler);
	menu.SetTitle("GamingZone - TOP", client);
	
	menu.AddItem("season", "Top Pre-Season");
	menu.AddItem("global", "Top Global", ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
	
}

public int TopMenuMain_Handler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_End:delete menu;
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(index, info, sizeof(info));
			ShowTopMenu(client, StrEqual(info, "season") ? DATA_SEASON : DATA_GLOBAL);
		}
	}
}

void ShowTopMenu(int client, int datatype)
{
	char query[256];
	
	DB.Format(query, sizeof(query), "SELECT nome, steamid, pontos FROM rank_%s ORDER BY pontos DESC LIMIT 50;", datatype == DATA_SEASON ? "season" : "global");
	DB.Query(datatype == DATA_SEASON ? OnPutInfoSeasonTopMenu : OnPutInfoGlobalTopMenu, query, GetClientUserId(client));
}

void OnPutInfoSeasonTopMenu(Database db, DBResultSet results, char[] error, int userid)
{
	char buffer[256];
	char steamid[64];
	int pontos;
	char nome[256];

	int client = GetClientOfUserId(userid);

	if (db == null || results == null)
	{
		LogError(error);
		return;
	}
	if (IsValidClient(client))
	{
		Menu menu = new Menu(TopMenu_Handler);
		menu.SetTitle("TOP - Pre-Season");

		menu.ExitBackButton = false;
		menu.ExitButton = true;
		while (results.FetchRow())
		{
			
			SQL_FetchString(results, 0, nome, sizeof(nome));
			SQL_FetchString(results, 1, steamid, sizeof(steamid));
			pontos = SQL_FetchInt(results, 2);
			
			FormatEx(buffer, sizeof(buffer), "[%i] %s", pontos, nome);
			menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}

		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int TopMenu_Handler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			switch (index)
			{
				case MenuCancel_ExitBack: ShowTopMenuMain(client);
			}
		}
	}
}

void OnPutInfoGlobalTopMenu(Database db, DBResultSet results, char[] error, int userid)
{
	char buffer[256];
	char steamid[64];
	int pontos;
	char nome[256];

	int client = GetClientOfUserId(userid);

	if (db == null || results == null)
	{
		LogError(error);
		return;
	}

	if (IsValidClient(client))
	{
		Menu menu = new Menu(TopMenu_Handler);
		menu.SetTitle("TOP - Global");

		menu.ExitBackButton = true;
		menu.ExitButton = true;
		while (results.FetchRow())
		{
			
			SQL_FetchString(results, 0, nome, sizeof(nome));
			SQL_FetchString(results, 1, steamid, sizeof(steamid));
			pontos = SQL_FetchInt(results, 2);
			
			FormatEx(buffer, sizeof(buffer), "[%i] %s", pontos, nome);
			menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
		}

		menu.Display(client, MENU_TIME_FOREVER);
	}
}