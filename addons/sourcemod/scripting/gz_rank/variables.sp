//Points Delivery

int g_GZ_Rank_Kill_Points = 5;
int g_GZ_Rank_HeadShot_Points = 2;
int g_GZ_Rank_Assist_Points = 2;
int g_GZ_Rank_Knife_Points = 10;
int g_GZ_Rank_Mvp_Points = 3;
int g_GZ_Rank_Bomb_Points = 2;
int g_GZ_Rank_Suicide_Points = 50;
int g_GZ_Rank_RoundWin_Points = 2;
int g_GZ_Rank_Player_Bomb_Points = 3;

int g_GZ_Rank_NumPlayers;
int g_GZ_Rank_MinPlayers = 2;

enum struct Statistics_t
{
	int Points;
	int Kills;
	int Deaths;
	int MVPs;

	void Reset()
	{
		this.Points = 0;
		this.Kills = 0;
		this.Deaths = 0;
		this.MVPs = 0;
	}
}

enum struct PlayerData_t
{
	Statistics_t Season;
	Statistics_t Global;

	char MMRank[64];

	void Reset()
	{
		this.Season.Reset();
		this.Global.Reset();

		this.MMRank[0] = '\0';
	}
}

PlayerData_t PlayerData[MAXPLAYERS + 1];

int g_GZ_Rank_Season_Registos;
int g_GZ_Rank_Global_Registos;
int g_GZ_Rank_Season_Pos;
int g_GZ_Rank_Global_Pos;

Handle g_fwdOnPlayerLoaded;

//Handle para a db
Database DB;

// Vê se é MySQL o que foi setado na databases.cfg
//bool isMySql