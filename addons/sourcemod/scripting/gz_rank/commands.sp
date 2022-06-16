public Action Command_Rank(int client, int args)
{
	if(IsValidClient(client))
	{
		UpdateData(client);
		CheckRanks();
		ListaTop(client, DATA_SEASON);
		ListaTop(client, DATA_GLOBAL);
		CountRegistos(DATA_SEASON);
		CountRegistos(DATA_GLOBAL);
		ShowRankMenu(client);
	}

	return Plugin_Handled;
}

public Action Command_GlobalRank(int client, int args)
{
	if(IsValidClient(client))
	{
		ShowGlobalRankMenu(client);
	}

	return Plugin_Handled;
}

public Action Command_Top(int client, int args)
{
	if(IsValidClient(client))
	{
		for(int i = 0; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				UpdateData(i);
			}
		}

		ListaTop(client, DATA_SEASON);
		ListaTop(client, DATA_GLOBAL);
		CountRegistos(DATA_SEASON);
		CountRegistos(DATA_GLOBAL);
		ShowTopMenu(client, DATA_SEASON);
	}

	return Plugin_Handled;
}

public Action Command_TopSeason(int client, int args)
{
	if(IsValidClient(client))
	{
		ShowTopMenu(client, DATA_SEASON);
	}

	return Plugin_Handled;
}

public Action Command_TopGlobal(int client, int args)
{
	if(IsValidClient(client))
	{
		ShowTopMenu(client, DATA_GLOBAL);
	}

	return Plugin_Handled;
}

public Action Command_Pontos(int client, int args)
{
	if(IsValidClient(client))
	{
		CPrintToChat(client, "[ \x10RANK\x01 ] Tens \x03%d\x01 pontos. [\x05%i\x01 / \x05%i\x01]", PlayerData[client].Season.Points, g_GZ_Rank_Season_Pos, g_GZ_Rank_Season_Registos);
	}

	return Plugin_Handled;
}

public Action Command_GivePoints(int client, int args)
{
	if(args < 2)
	{
		CReplyToCommand(client, "[ {orange}RANK{default} ] Usa: sm_givepoints <nome> <quantidade>");
		return Plugin_Handled;
	}

	char name[32];
	int target = -1;
	char number[8];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, number, sizeof(number));

	int amount = StringToInt(number);

	for(int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i))
			continue;

		char other[32];
		GetClientName(i, other, sizeof(other));

		if (StrEqual(name, other))
		{
			target = i;
		}
	}

	if (target == -1)
	{
		CReplyToCommand(client, "Não encontramos nenhum jogador com o nome: \"%s\"", name);
		return Plugin_Handled;
	}

	if(amount < 0)
	{
		CReplyToCommand(client, "Valor colocado inválido.");
		return Plugin_Handled;
	}

	PlayerData[target].Season.Points += amount;
	PlayerData[target].Global.Points += amount;

	CPrintToChat(client, "[ {orange}RANK{default} ] Recebeste {lime}%i{default} pontos!", amount);
	return Plugin_Handled;
}