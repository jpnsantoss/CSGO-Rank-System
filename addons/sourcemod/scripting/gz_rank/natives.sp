public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int errMax)
{
	CreateNative("GZ_Rank_GetSeasonPoints", Native_Rank_GetSeasonPoints);
	CreateNative("GZ_Rank_GetGlobalPoints", Native_Rank_GetGlobalPoints);
	CreateNative("GZ_Rank_SetSeasonPoints", Native_Rank_SetSeasonPoints);
	CreateNative("GZ_Rank_SetGlobalPoints", Native_Rank_SetGlobalPoints);
	CreateNative("GZ_Rank_GetSeasonKills", Native_Rank_GetSeasonKills);
	CreateNative("GZ_Rank_GetGlobalKills", Native_Rank_GetGlobalKills);
	CreateNative("GZ_Rank_GetSeasonDeaths", Native_Rank_GetSeasonDeaths);
	CreateNative("GZ_Rank_GetGlobalDeaths", Native_Rank_GetGlobalDeaths);
	CreateNative("GZ_Rank_GetSeasonMvps", Native_Rank_GetSeasonMvps);
	CreateNative("GZ_Rank_GetGlobalMvps", Native_Rank_GetGlobalMvps);
	CreateNative("GZ_Rank_GetSeasonKD", Native_Rank_GetSeasonKD);
	CreateNative("GZ_Rank_GetGlobalKD", Native_Rank_GetGlobalKD);

	RegPluginLibrary("gz_rank");

    g_fwdOnPlayerLoaded = CreateGlobalForward("GZ_OnPlayerLoaded", ET_Hook, Param_Cell);

	return APLRes_Success;
}

public int Native_Rank_GetSeasonPoints(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    /*
    if(client == 0 || !IsClientInGame(client)
    {
        ThrowNativeError("Invalid client index or not in game.");
        return;
    }
    */

    return PlayerData[client].Season.Points;
}

public int Native_Rank_GetGlobalPoints(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Global.Points;
}

public int Native_Rank_SetSeasonPoints(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int points = GetNativeCell(2);
    PlayerData[client].Season.Points = points;
    return true;
}

public int Native_Rank_SetGlobalPoints(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    int points = GetNativeCell(2);
    PlayerData[client].Global.Points = points;
    return true;
}

public int Native_Rank_GetSeasonKills(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Season.Kills;
}

public int Native_Rank_GetGlobalKills(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Global.Kills;
}

public int Native_Rank_GetSeasonDeaths(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Season.Deaths;
}

public int Native_Rank_GetGlobalDeaths(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Global.Deaths;
}

public int Native_Rank_GetSeasonMvps(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Season.MVPs;
}

public int Native_Rank_GetGlobalMvps(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    return PlayerData[client].Global.MVPs;
}

public int Native_Rank_GetSeasonKD(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (PlayerData[client].Season.Deaths > 0)
    {
        return PlayerData[client].Season.Kills / PlayerData[client].Season.Deaths;
    } else {
        return PlayerData[client].Season.Kills;
    }
}

public int Native_Rank_GetGlobalKD(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (PlayerData[client].Global.Deaths > 0)
    {
        return PlayerData[client].Global.Kills / PlayerData[client].Global.Deaths;
    } else {
        return PlayerData[client].Global.Kills;
    }
}