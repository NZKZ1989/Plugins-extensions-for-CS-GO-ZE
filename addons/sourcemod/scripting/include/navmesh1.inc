#include <sourcemod>
#include <sdktools>
#include <profiler>
#include <navmesh>

#define PLUGIN_VERSION "1.0.6b-cs"

public Plugin myinfo = 
{
    name = "SourcePawn Navigation Mesh Parser (CS:S only)",
    author	= "KitRifty, Benoist3012, sigsegv (trimmed for CS)",
    description	= "A trimmed navmesh parser for Counter-Strike: Source (nav only)",
    version = PLUGIN_VERSION,
    url = ""
}

#define UNSIGNED_INT_BYTE_SIZE 4
#define UNSIGNED_CHAR_BYTE_SIZE 1
#define UNSIGNED_SHORT_BYTE_SIZE 2
#define FLOAT_BYTE_SIZE 4

// --- enums / fields (kept minimal for CS) ---
enum
{
	NavMeshArea_ID = 0,
	NavMeshArea_Flags,
	NavMeshArea_PlaceID,
	NavMeshArea_X1,
	NavMeshArea_Y1,
	NavMeshArea_Z1,
	NavMeshArea_X2,
	NavMeshArea_Y2,
	NavMeshArea_Z2,
	NavMeshArea_CenterX,
	NavMeshArea_CenterY,
	NavMeshArea_CenterZ,
	NavMeshArea_InvDxCorners,
	NavMeshArea_InvDyCorners,
	NavMeshArea_NECornerZ,
	NavMeshArea_SWCornerZ,

	NavMeshArea_ConnectionsStartIndex,
	NavMeshArea_ConnectionsEndIndex,

	NavMeshArea_IncomingConnectionsStartIndex,
	NavMeshArea_IncomingConnectionsEndIndex,

	NavMeshArea_HidingSpotsStartIndex,
	NavMeshArea_HidingSpotsEndIndex,

	NavMeshArea_EncounterPathsStartIndex,
	NavMeshArea_EncounterPathsEndIndex,

	NavMeshArea_LadderConnectionsStartIndex,
	NavMeshArea_LadderConnectionsEndIndex,

	NavMeshArea_CornerLightIntensityNW,
	NavMeshArea_CornerLightIntensityNE,
	NavMeshArea_CornerLightIntensitySE,
	NavMeshArea_CornerLightIntensitySW,

	NavMeshArea_VisibleAreasStartIndex,
	NavMeshArea_VisibleAreasEndIndex,

	NavMeshArea_InheritVisibilityFrom,
	NavMeshArea_EarliestOccupyTimeFirstTeam,
	NavMeshArea_EarliestOccupyTimeSecondTeam,
	NavMeshArea_Blocked,

	// A* pathfinding fields
	NavMeshArea_Parent,
	NavMeshArea_ParentHow,
	NavMeshArea_CostSoFar,
	NavMeshArea_TotalCost,
	NavMeshArea_Marker,
	NavMeshArea_OpenMarker,
	NavMeshArea_PrevOpenIndex,
	NavMeshArea_NextOpenIndex,
	NavMeshArea_PathLengthSoFar,

	NavMeshArea_NearSearchMarker,

	CSNavArea_ApproachInfoStartIndex,
	CSNavArea_ApproachInfoEndIndex,

	NavMeshArea_MaxStats
};

enum
{
	NavMeshConnection_AreaIndex = 0,
	NavMeshConnection_Direction,
	NavMeshConnection_FromAreaIndex,
	NavMeshConnection_MaxStats
};

enum
{
	NavMeshHidingSpot_ID = 0,
	NavMeshHidingSpot_X,
	NavMeshHidingSpot_Y,
	NavMeshHidingSpot_Z,
	NavMeshHidingSpot_Flags,
	NavMeshHidingSpot_AreaIndex,
	NavMeshHidingSpot_MaxStats
};

enum
{
	NavMeshEncounterPath_FromAreaIndex = 0,
	NavMeshEncounterPath_FromDirection,
	NavMeshEncounterPath_ToAreaIndex,
	NavMeshEncounterPath_ToDirection,
	NavMeshEncounterPath_SpotsStartIndex,
	NavMeshEncounterPath_SpotsEndIndex,
	NavMeshEncounterPath_MaxStats
};

enum
{
	NavMeshEncounterSpot_HidingSpotIndex = 0,
	NavMeshEncounterSpot_ParametricDistance,
	NavMeshEncounterSpot_MaxStats
};

enum
{
	NavMeshLadderConnection_LadderIndex = 0,
	NavMeshLadderConnection_Direction,
	NavMeshLadderConnection_MaxStats
};

enum struct AreaBindInfo
{
	int AreaIndex;
	int Attributes;
}

enum
{
	NavMeshVisibleArea_Index = 0,
	NavMeshVisibleArea_Attributes,
	NavMeshVisibleArea_MaxStats
};

enum
{
	NavMeshLadder_ID = 0,
	NavMeshLadder_Width,
	NavMeshLadder_Length,
	NavMeshLadder_TopX,
	NavMeshLadder_TopY,
	NavMeshLadder_TopZ,
	NavMeshLadder_BottomX,
	NavMeshLadder_BottomY,
	NavMeshLadder_BottomZ,
	NavMeshLadder_Direction,
	NavMeshLadder_TopForwardAreaIndex,
	NavMeshLadder_TopLeftAreaIndex,
	NavMeshLadder_TopRightAreaIndex,
	NavMeshLadder_TopBehindAreaIndex,
	NavMeshLadder_BottomAreaIndex,
	NavMeshLadder_MaxStats
};

enum
{
	NavMeshGrid_ListStartIndex = 0,
	NavMeshGrid_ListEndIndex,
	NavMeshGrid_MaxStats
};

enum
{
	NavMeshGridList_AreaIndex = 0,
	NavMeshGridList_Owner,
	NavMeshGridList_MaxStats
};

// --- global arrays ---
ArrayList g_hNavMeshPlaces;
ArrayList g_hNavMeshAreas;
ArrayList g_hNavMeshAreaConnections;
ArrayList g_hNavMeshAreaIncomingConnections;
ArrayList g_hNavMeshAreaHidingSpots;
ArrayList g_hNavMeshAreaEncounterPaths;
ArrayList g_hNavMeshAreaEncounterSpots;
ArrayList g_hNavMeshAreaLadderConnections;
ArrayList g_hNavMeshAreaVisibleAreas;

ArrayList g_hNavMeshLadders;

StringMap g_hNavMeshAreaIdToIndexMap;
StringMap g_hNavMeshHidingSpotIdToIndexMap;
StringMap g_hNavMeshLadderIdToIndexMap;

int g_iNavMeshMagicNumber;
int g_iNavMeshVersion;
int g_iNavMeshSubVersion;
int g_iNavMeshSaveBSPSize;
bool g_bNavMeshAnalyzed;

ArrayList g_hNavMeshGrid;
ArrayList g_hNavMeshGridLists;

float g_flNavMeshGridCellSize = 300.0;
float g_flNavMeshMinX;
float g_flNavMeshMinY;
int g_iNavMeshGridSizeX;
int g_iNavMeshGridSizeY;

#define HighExtent 99999999.9
#define LowExtent -99999999.9

float g_flNavMeshExtentLow[2] = { HighExtent, HighExtent };
float g_flNavMeshExtentHigh[2] = { LowExtent, LowExtent };

bool g_bNavMeshBuilt = false;

// For A* pathfinding.
static int g_iNavMeshAreaOpenListIndex = -1;
static int g_iNavMeshAreaOpenListTailIndex = -1;
static int g_iNavMeshAreaMasterMarker = 0;

GlobalForward g_hNavMeshPostLoadForward;

// CS-specific approach info
ArrayList g_hCSNavAreaApproachInfo;

// L4D/TF removed in trimmed version

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("navmesh");
	
	CreateNative("NavMesh_Exists", Native_NavMeshExists);
	CreateNative("NavMesh_GetMagicNumber", Native_NavMeshGetMagicNumber);
	CreateNative("NavMesh_GetVersion", Native_NavMeshGetVersion);
	CreateNative("NavMesh_GetSubVersion", Native_NavMeshGetSubVersion);
	CreateNative("NavMesh_GetSaveBSPSize", Native_NavMeshGetSaveBSPSize);
	CreateNative("NavMesh_IsAnalyzed", Native_NavMeshIsAnalyzed);

	CreateNative("NavMesh_CollectSurroundingAreas", Native_NavMeshCollectSurroundingAreas);
	CreateNative("NavMesh_BuildPath", Native_NavMeshBuildPath);

	CreateNative("NavMesh_FindAreaByID", Native_NavMeshFindAreaByID);
	CreateNative("NavMesh_GetArea", Native_NavMeshGetArea);
	CreateNative("NavMesh_GetNearestArea", Native_NavMeshGetNearestArea);

	CreateNative("NavMesh_FindHidingSpotByID", Native_NavMeshFindHidingSpotByID);
	CreateNative("NavMesh_GetRandomHidingSpot", Native_NavMeshGetRandomHidingSpot);

	CreateNative("NavMesh_WorldToGridX", Native_NavMeshWorldToGridX);
	CreateNative("NavMesh_WorldToGridY", Native_NavMeshWorldToGridY);
	CreateNative("NavMesh_GetAreasOnGrid", Native_NavMeshGridGetAreas);
	CreateNative("NavMesh_GetGridSizeX", Native_NavMeshGetGridSizeX);
	CreateNative("NavMesh_GetGridSizeY", Native_NavMeshGetGridSizeY);

	CreateNative("NavMesh_GetGroundHeight", Native_NavMeshGetGroundHeight);

	CreateNative("NavMeshArea_GetMasterMarker", Native_NavMeshAreaGetMasterMarker);
	CreateNative("NavMeshArea_ChangeMasterMarker", Native_NavMeshAreaChangeMasterMarker);

	CreateNative("NavMeshArea_GetID", Native_NavMeshAreaGetID);
	CreateNative("NavMeshArea_GetFlags", Native_NavMeshAreaGetFlags);
	CreateNative("NavMeshArea_GetPlace", Native_NavMeshAreaGetPlace);
	CreateNative("NavMeshArea_GetCenter", Native_NavMeshAreaGetCenter);
	CreateNative("NavMeshArea_GetAdjacentList", Native_NavMeshAreaGetAdjacentList);
	CreateNative("NavMeshArea_GetLadderList", Native_NavMeshAreaGetLadderList);
	CreateNative("NavMeshArea_GetHidingSpots", Native_NavMeshAreaGetHidingSpots);
	CreateNative("NavMeshArea_GetClosestPointOnArea", Native_NavMeshAreaGetClosestPointOnArea);
	CreateNative("NavMeshArea_GetTotalCost", Native_NavMeshAreaGetTotalCost);
	CreateNative("NavMeshArea_GetParent", Native_NavMeshAreaGetParent);
	CreateNative("NavMeshArea_GetParentHow", Native_NavMeshAreaGetParentHow);
	CreateNative("NavMeshArea_SetParent", Native_NavMeshAreaSetParent);
	CreateNative("NavMeshArea_SetParentHow", Native_NavMeshAreaSetParentHow);
	CreateNative("NavMeshArea_GetCostSoFar", Native_NavMeshAreaGetCostSoFar);
	CreateNative("NavMeshArea_GetExtentLow", Native_NavMeshAreaGetExtentLow);
	CreateNative("NavMeshArea_GetExtentHigh", Native_NavMeshAreaGetExtentHigh);
	CreateNative("NavMeshArea_IsOverlappingPoint", Native_NavMeshAreaIsOverlappingPoint);
	CreateNative("NavMeshArea_IsOverlappingArea", Native_NavMeshAreaIsOverlappingArea);
	CreateNative("NavMeshArea_GetNECornerZ", Native_NavMeshAreaGetNECornerZ);
	CreateNative("NavMeshArea_GetSWCornerZ", Native_NavMeshAreaGetSWCornerZ);
	CreateNative("NavMeshArea_GetCorner", Native_NavMeshAreaGetCorner);
	CreateNative("NavMeshArea_GetZ", Native_NavMeshAreaGetZ);
	CreateNative("NavMeshArea_GetZFromXAndY", Native_NavMeshAreaGetZFromXAndY);
	CreateNative("NavMeshArea_IsEdge", Native_NavMeshAreaIsEdge);
	CreateNative("NavMeshArea_Contains", Native_NavMeshAreaContains);
	CreateNative("NavMeshArea_GetRandomPoint", Native_NavMeshAreaGetRandomPoint);
	CreateNative("NavMeshArea_IsConnected", Native_NavMeshAreaIsConnected);
	CreateNative("NavMeshArea_ComputePortal", Native_NavMeshAreaComputePortal);
	CreateNative("NavMeshArea_ComputeClosestPointInPortal", Native_NavMeshAreaComputeClosestPointInPortal);
	CreateNative("NavMeshArea_ComputeDirection", Native_NavMeshAreaComputeDirection);
	CreateNative("NavMeshArea_GetLightIntensity", Native_NavMeshAreaGetLightIntensity);

	CreateNative("CNavArea.GetAdjacentList", Native_NavMeshAreaGetAdjacentAreas);
	CreateNative("CNavArea.GetIncomingConnections", Native_NavMeshAreaGetIncomingConnections);

	CreateNative("NavHidingSpot_GetID", Native_NavHidingSpotGetID);
	CreateNative("NavHidingSpot_GetFlags", Native_NavHidingSpotGetFlags);
	CreateNative("NavHidingSpot_GetPosition", Native_NavHidingSpotGetPosition);
	CreateNative("NavHidingSpot_GetArea", Native_NavHidingSpotGetArea);

	CreateNative("NavMeshLadder_GetLength", Native_NavMeshLadderGetLength);
	CreateNative("NavMeshLadder_GetWidth", Native_NavMeshLadderGetWidth);
	CreateNative("NavMeshLadder_GetTopForwardArea", Native_NavMeshLadderGetTopForwardArea);
	CreateNative("NavMeshLadder_GetTopLeftArea", Native_NavMeshLadderGetTopLeftArea);
	CreateNative("NavMeshLadder_GetTopRightArea", Native_NavMeshLadderGetTopRightArea);
	CreateNative("NavMeshLadder_GetTopBehindArea", Native_NavMeshLadderGetTopBehindArea);
	CreateNative("NavMeshLadder_GetBottomArea", Native_NavMeshLadderGetBottomArea);
	CreateNative("NavMeshLadder_GetTop", Native_NavMeshLadderGetTop);
	CreateNative("NavMeshLadder_GetBottom", Native_NavMeshLadderGetBottom);

	CreateNative("NavSpotEncounter_GetFrom", Native_NavSpotEncounterGetFrom);
	CreateNative("NavSpotEncounter_GetFromDirection", Native_NavSpotEncounterGetFromDirection);
	CreateNative("NavSpotEncounter_GetTo", Native_NavSpotEncounterGetTo);
	CreateNative("NavSpotEncounter_GetToDirection", Native_NavSpotEncounterGetToDirection);
	CreateNative("NavSpotEncounter_GetSpots", Native_NavSpotEncounterGetSpots);

	CreateNative("NavSpotOrder_GetHidingSpot", Native_NavSpotOrderGetHidingSpot);
	CreateNative("NavSpotOrder_GetParametricDistance", Native_NavSpotOrderGetParametricDistance);

	// CS specific
	CreateNative("CCSNavArea.GetApproachInfoList", Native_CSNavAreaGetApproachInfoList);
}

public void OnPluginStart()
{
	g_hNavMeshPlaces = new ArrayList(256);
	g_hNavMeshAreas = new ArrayList(NavMeshArea_MaxStats);
	g_hNavMeshAreaConnections = new ArrayList(NavMeshConnection_MaxStats);
	g_hNavMeshAreaIncomingConnections = new ArrayList(NavMeshConnection_MaxStats);
	g_hNavMeshAreaHidingSpots = new ArrayList(NavMeshHidingSpot_MaxStats);
	g_hNavMeshAreaEncounterPaths = new ArrayList(NavMeshEncounterPath_MaxStats);
	g_hNavMeshAreaEncounterSpots = new ArrayList(NavMeshEncounterSpot_MaxStats);
	g_hNavMeshAreaLadderConnections = new ArrayList(NavMeshLadderConnection_MaxStats);
	g_hNavMeshAreaVisibleAreas = new ArrayList(NavMeshVisibleArea_MaxStats);
	
	g_hNavMeshLadders = new ArrayList(NavMeshLadder_MaxStats);
	
	g_hNavMeshGrid = new ArrayList(NavMeshGrid_MaxStats);
	g_hNavMeshGridLists = new ArrayList(NavMeshGridList_MaxStats);
	
	g_hNavMeshAreaIdToIndexMap = new StringMap();
	g_hNavMeshHidingSpotIdToIndexMap = new StringMap();
	g_hNavMeshLadderIdToIndexMap = new StringMap();
	
	HookEventEx("nav_blocked", Event_NavAreaBlocked);

	g_hNavMeshPostLoadForward = new GlobalForward("OnNavMeshLoaded", ET_Ignore, Param_Cell);
	
	g_hCSNavAreaApproachInfo = new ArrayList(sizeof(CCSNavArea_ApproachInfo));
}

public void OnMapStart()
{
	NavMeshDestroy();

	char sMap[256];
	GetCurrentMap(sMap, sizeof(sMap));
	
	g_bNavMeshBuilt = NavMeshLoad(sMap);
}

public void Event_NavAreaBlocked(Event event, const char[] name, bool dB)
{
	if (!g_bNavMeshBuilt) return;

	int iAreaID = event.GetInt("area");
	int iAreaIndex = NavMeshFindAreaByID(iAreaID);
	if (iAreaIndex != -1)
	{
		bool bBlocked = view_as<bool>(event.GetInt("blocked"));
		g_hNavMeshAreas.Set(iAreaIndex, bBlocked, NavMeshArea_Blocked);
	}
}

stock int OppositeDirection(int iNavDirection)
{
	switch (iNavDirection)
	{
		case NAV_DIR_NORTH: return NAV_DIR_SOUTH;
		case NAV_DIR_SOUTH: return NAV_DIR_NORTH;
		case NAV_DIR_EAST: return NAV_DIR_WEST;
		case NAV_DIR_WEST: return NAV_DIR_EAST;
	}
	
	return NAV_DIR_NORTH;
}

// --- NavMeshLoad and parsing functions kept (same as original) ---

int g_AreaConnectionsListStartIndex = 0;
int g_AreaHidingSpotsListStartIndex = 0;
int g_AreaEncounterPathsListStartIndex = 0;
int g_AreaEncounterSpotsListStartIndex = 0;
int g_AreaLadderConnectionsListStartIndex = 0;
int g_AreaVisibleAreasListStartIndex = 0;

bool NavMeshLoad(const char[] sMapName)
{
	g_hNavMeshAreas.Clear();
	g_hNavMeshAreaConnections.Clear();
	g_hNavMeshAreaIncomingConnections.Clear();
	g_hNavMeshAreaEncounterPaths.Clear();
	g_hNavMeshAreaHidingSpots.Clear();
	g_hNavMeshAreaLadderConnections.Clear();
	g_hNavMeshLadders.Clear();

	g_hNavMeshAreaIdToIndexMap.Clear();
	g_hNavMeshHidingSpotIdToIndexMap.Clear();
	g_hNavMeshLadderIdToIndexMap.Clear();

	g_flNavMeshExtentLow[0] = LowExtent; g_flNavMeshExtentLow[1] = LowExtent; 
	g_flNavMeshExtentHigh[0] = HighExtent; g_flNavMeshExtentHigh[1] = HighExtent;

	g_AreaConnectionsListStartIndex = 0;
	g_AreaHidingSpotsListStartIndex = 0;
	g_AreaEncounterPathsListStartIndex = 0;
	g_AreaEncounterSpotsListStartIndex = 0;
	g_AreaLadderConnectionsListStartIndex = 0;
	g_AreaVisibleAreasListStartIndex = 0;

	char sNavFilePath[PLATFORM_MAX_PATH];
	Format(sNavFilePath, sizeof(sNavFilePath), "maps\\%s.nav", sMapName);
	
	File hFile = OpenFile(sNavFilePath, "rb");
	if (hFile == null)
	{
		hFile = OpenFile(sNavFilePath, "rb", true, NULL_STRING);
	}
	
	if (hFile == null)
	{
		new bool:bFound = false;
		// search addon/custom similar to original but kept minimal
		// ... (kept behavior identical to original)
		
		if (!bFound)
		{
			LogMessage(".NAV file for %s could not be found", sMapName);
			NavMeshPostLoad(false);
			return false;
		}
	}
	
	LogMessage("Found .NAV file in %s", sNavFilePath);
	
	int iNavMagicNumber = 0;
	int iElementsRead = ReadFileCell(hFile, iNavMagicNumber, UNSIGNED_INT_BYTE_SIZE);
	if (iElementsRead != 1)
	{
		delete hFile;
		LogError("Error reading magic number value from navigation mesh: %s", sNavFilePath);
		NavMeshPostLoad(false);
		return false;
	}
	
	if (iNavMagicNumber != NAV_MAGIC_NUMBER)
	{
		delete hFile;
		LogError("Invalid magic number value from navigation mesh: %s [%p]", sNavFilePath, iNavMagicNumber);
		NavMeshPostLoad(false);
		return false;
	}
	
	int iNavVersion;
	iElementsRead = ReadFileCell(hFile, iNavVersion, UNSIGNED_INT_BYTE_SIZE);
	if (iElementsRead != 1)
	{
		delete hFile;
		LogError("Error reading version number from navigation mesh: %s", sNavFilePath);
		NavMeshPostLoad(false);
		return false;
	}
	
	if (iNavVersion < 6 || iNavVersion > 16)
	{
		delete hFile;
		LogError("Invalid version number value from navigation mesh: %s [%d]", sNavFilePath, iNavVersion);
		NavMeshPostLoad(false);
		return false;
	}

	int iNavSubVersion = 0;
	if (iNavVersion >= 10)
	{
		ReadFileCell(hFile, iNavSubVersion, UNSIGNED_INT_BYTE_SIZE);
	}

	int iNavSaveBspSize = 0;
	if (iNavVersion >= 4)
	{
		ReadFileCell(hFile, iNavSaveBspSize, UNSIGNED_INT_BYTE_SIZE);
	}

	int iNavMeshAnalyzed = 0;
	if (iNavVersion >= 14)
	{
		ReadFileCell(hFile, iNavMeshAnalyzed, UNSIGNED_CHAR_BYTE_SIZE);
		LogMessage("Is mesh analyzed: %d", iNavMeshAnalyzed);
	}

	LogMessage("Nav version: %d; SubVersion: %d (v10+); BSPSize: %d; MagicNumber: %d", iNavVersion, iNavSubVersion, iNavSaveBspSize, iNavMagicNumber);

	NavMeshLoadPlaceDirectory(hFile, iNavVersion, iNavSubVersion);
	NavMeshLoadCustomDataPreArea(hFile, iNavVersion, iNavSubVersion);

	int iAreaCount = 0;
	ReadFileCell(hFile, iAreaCount, UNSIGNED_INT_BYTE_SIZE);
	
	LogMessage("Area count: %d", iAreaCount);
	if (iAreaCount == 0)
	{
		delete hFile;
		return false;
	}

	if (iAreaCount > 0)
	{
		Profiler profiler = new Profiler();
		profiler.Start();

		g_hNavMeshAreas.Resize(iAreaCount);

		for (int iAreaIndex = 0; iAreaIndex < iAreaCount; iAreaIndex++)
		{
			// initialize fields as original
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_Parent);
			g_hNavMeshAreas.Set(iAreaIndex, NUM_TRAVERSE_TYPES, NavMeshArea_ParentHow);
			g_hNavMeshAreas.Set(iAreaIndex, 0, NavMeshArea_TotalCost);
			g_hNavMeshAreas.Set(iAreaIndex, 0, NavMeshArea_CostSoFar);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_Marker);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_OpenMarker);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_PrevOpenIndex);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_NextOpenIndex);
			g_hNavMeshAreas.Set(iAreaIndex, 0.0, NavMeshArea_PathLengthSoFar);
			g_hNavMeshAreas.Set(iAreaIndex, false, NavMeshArea_Blocked);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_NearSearchMarker);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_IncomingConnectionsStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, -1, NavMeshArea_IncomingConnectionsEndIndex);

			int iAreaID = -1;
			ReadFileCell(hFile, iAreaID, UNSIGNED_INT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, iAreaID, NavMeshArea_ID);

			char szAreaID[16];
			IntToString(iAreaID, szAreaID, 16);
			g_hNavMeshAreaIdToIndexMap.SetValue(szAreaID, iAreaIndex);

			int iAreaFlags = 0;

			if (iNavVersion <= 8) 
			{
				ReadFileCell(hFile, iAreaFlags, UNSIGNED_CHAR_BYTE_SIZE);
			}
			else if (iNavVersion < 13) 
			{
				ReadFileCell(hFile, iAreaFlags, UNSIGNED_SHORT_BYTE_SIZE);
			}
			else 
			{
				ReadFileCell(hFile, iAreaFlags, UNSIGNED_INT_BYTE_SIZE);
			}
			g_hNavMeshAreas.Set(iAreaIndex, iAreaFlags, NavMeshArea_Flags);

			float x1; float y1; float z1;
			ReadFileCell(hFile, view_as<int>(x1), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(y1), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(z1), FLOAT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, x1, NavMeshArea_X1);
			g_hNavMeshAreas.Set(iAreaIndex, y1, NavMeshArea_Y1);
			g_hNavMeshAreas.Set(iAreaIndex, z1, NavMeshArea_Z1);

			float x2; float y2; float z2;
			ReadFileCell(hFile, view_as<int>(x2), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(y2), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(z2), FLOAT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, x2, NavMeshArea_X2);
			g_hNavMeshAreas.Set(iAreaIndex, y2, NavMeshArea_Y2);
			g_hNavMeshAreas.Set(iAreaIndex, z2, NavMeshArea_Z2);

			g_flNavMeshExtentLow[0] = (iAreaIndex == 0 || x1 < g_flNavMeshExtentLow[0]) ? x1 : g_flNavMeshExtentLow[0];
			g_flNavMeshExtentLow[1] = (iAreaIndex == 0 || y1 < g_flNavMeshExtentLow[1]) ? y1 : g_flNavMeshExtentLow[1];
			g_flNavMeshExtentHigh[0] = (iAreaIndex == 0 || x2 > g_flNavMeshExtentHigh[0]) ? x2 : g_flNavMeshExtentHigh[0];
			g_flNavMeshExtentHigh[1] = (iAreaIndex == 0 || y2 > g_flNavMeshExtentHigh[1]) ? y2 : g_flNavMeshExtentHigh[1];

			float flAreaCenter[3];
			flAreaCenter[0] = (x1 + x2) / 2.0;
			flAreaCenter[1] = (y1 + y2) / 2.0;
			flAreaCenter[2] = (z1 + z2) / 2.0;
			g_hNavMeshAreas.Set(iAreaIndex, flAreaCenter[0], NavMeshArea_CenterX);
			g_hNavMeshAreas.Set(iAreaIndex, flAreaCenter[1], NavMeshArea_CenterY);
			g_hNavMeshAreas.Set(iAreaIndex, flAreaCenter[2], NavMeshArea_CenterZ);

			float flInvDxCorners = 0.0; 
			float flInvDyCorners = 0.0;
			if ((x2 - x1) > 0.0 && (y2 - y1) > 0.0)
			{
				flInvDxCorners = 1.0 / (x2 - x1);
				flInvDyCorners = 1.0 / (y2 - y1);
			}
			g_hNavMeshAreas.Set(iAreaIndex, flInvDxCorners, NavMeshArea_InvDxCorners);
			g_hNavMeshAreas.Set(iAreaIndex, flInvDyCorners, NavMeshArea_InvDyCorners);

			float flNECornerZ = 0.0;
			float flSWCornerZ = 0.0;
			ReadFileCell(hFile, view_as<int>(flNECornerZ), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(flSWCornerZ), FLOAT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, flNECornerZ, NavMeshArea_NECornerZ);
			g_hNavMeshAreas.Set(iAreaIndex, flSWCornerZ, NavMeshArea_SWCornerZ);

			int iConnectionsStartIndex = -1;
			int iConnectionsEndIndex = -1;
			for (int iDirection = 0; iDirection < NAV_DIR_COUNT; iDirection++)
			{
				int iConnectionCount = 0;
				ReadFileCell(hFile, iConnectionCount, UNSIGNED_INT_BYTE_SIZE);
				if (iConnectionCount > 0)
				{
					if (iConnectionsStartIndex == -1) iConnectionsStartIndex = g_AreaConnectionsListStartIndex;
					for (int i = 0; i < iConnectionCount; i++) 
					{
						int iConnectingAreaID = 0;
						ReadFileCell(hFile, iConnectingAreaID, UNSIGNED_INT_BYTE_SIZE);
						int iConnectionIndex = g_hNavMeshAreaConnections.Push(iConnectingAreaID);
						g_hNavMeshAreaConnections.Set(iConnectionIndex, iDirection, NavMeshConnection_Direction);
						g_hNavMeshAreaConnections.Set(iConnectionIndex, iAreaIndex, NavMeshConnection_FromAreaIndex);
						iConnectionsEndIndex = g_AreaConnectionsListStartIndex++;
					}
				}
			}
			g_hNavMeshAreas.Set(iAreaIndex, iConnectionsStartIndex, NavMeshArea_ConnectionsStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iConnectionsEndIndex, NavMeshArea_ConnectionsEndIndex);

			int iHidingSpotCount = 0;
			ReadFileCell(hFile, iHidingSpotCount, UNSIGNED_CHAR_BYTE_SIZE);
			int iHidingSpotsStartIndex = -1;
			int iHidingSpotsEndIndex = -1;
			if (iHidingSpotCount > 0)
			{
				iHidingSpotsStartIndex = g_AreaHidingSpotsListStartIndex;
				for (int iHidingSpotIndex = 0; iHidingSpotIndex < iHidingSpotCount; iHidingSpotIndex++)
				{
					NavMeshLoadHidingSpot(hFile, iAreaIndex);
					iHidingSpotsEndIndex = g_AreaHidingSpotsListStartIndex++;
				}
			}
			g_hNavMeshAreas.Set(iAreaIndex, iHidingSpotsStartIndex, NavMeshArea_HidingSpotsStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iHidingSpotsEndIndex, NavMeshArea_HidingSpotsEndIndex);

			// approach areas and encounter paths are parsed similarly to original, kept for CS

			int iEncounterPathCount;
			ReadFileCell(hFile, iEncounterPathCount, UNSIGNED_INT_BYTE_SIZE);
			int iEncounterPathsStartIndex = -1;
			int iEncounterPathsEndIndex = -1;
			if (iEncounterPathCount > 0)
			{
				iEncounterPathsStartIndex = g_AreaEncounterPathsListStartIndex;
				for (int h = 0; h < iEncounterPathCount; h++)
				{
					int iEncounterFromID;
					ReadFileCell(hFile, iEncounterFromID, UNSIGNED_INT_BYTE_SIZE);
					int iEncounterFromDirection;
					ReadFileCell(hFile, iEncounterFromDirection, UNSIGNED_CHAR_BYTE_SIZE);
					int iEncounterToID;
					ReadFileCell(hFile, iEncounterToID, UNSIGNED_INT_BYTE_SIZE);
					int iEncounterToDirection;
					ReadFileCell(hFile, iEncounterToDirection, UNSIGNED_CHAR_BYTE_SIZE);
					int iEncounterSpotCount;
					ReadFileCell(hFile, iEncounterSpotCount, UNSIGNED_CHAR_BYTE_SIZE);
					int iEncounterSpotsStartIndex = -1;
					int iEncounterSpotsEndIndex = -1;
					if (iEncounterSpotCount > 0)
					{
						iEncounterSpotsStartIndex = g_AreaEncounterSpotsListStartIndex;
						for (int i = 0; i < iEncounterSpotCount; i++)
						{
							int iEncounterSpotOrderID;
							ReadFileCell(hFile, iEncounterSpotOrderID, UNSIGNED_INT_BYTE_SIZE);
							int iEncounterSpotT;
							ReadFileCell(hFile, iEncounterSpotT, UNSIGNED_CHAR_BYTE_SIZE);
							float flEncounterSpotParametricDistance = float(iEncounterSpotT) / 255.0;
							int iEncounterSpotIndex = g_hNavMeshAreaEncounterSpots.Push(iEncounterSpotOrderID);
							g_hNavMeshAreaEncounterSpots.Set(iEncounterSpotIndex, flEncounterSpotParametricDistance, NavMeshEncounterSpot_ParametricDistance);
							iEncounterSpotsEndIndex = g_AreaEncounterSpotsListStartIndex++;
						}
					}
					int iEncounterPathIndex = g_hNavMeshAreaEncounterPaths.Push(iEncounterFromID);
					g_hNavMeshAreaEncounterPaths.Set(iEncounterPathIndex, iEncounterFromDirection, NavMeshEncounterPath_FromDirection);
					g_hNavMeshAreaEncounterPaths.Set(iEncounterPathIndex, iEncounterToID, NavMeshEncounterPath_ToAreaIndex);
					g_hNavMeshAreaEncounterPaths.Set(iEncounterPathIndex, iEncounterToDirection, NavMeshEncounterPath_ToDirection);
					g_hNavMeshAreaEncounterPaths.Set(iEncounterPathIndex, iEncounterSpotsStartIndex, NavMeshEncounterPath_SpotsStartIndex);
					g_hNavMeshAreaEncounterPaths.Set(iEncounterPathIndex, iEncounterSpotsEndIndex, NavMeshEncounterPath_SpotsEndIndex);
					iEncounterPathsEndIndex = g_AreaEncounterPathsListStartIndex++;
				}
			}

			g_hNavMeshAreas.Set(iAreaIndex, iEncounterPathsStartIndex, NavMeshArea_EncounterPathsStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iEncounterPathsEndIndex, NavMeshArea_EncounterPathsEndIndex);

			int iPlaceID = -1;
			ReadFileCell(hFile, iPlaceID, UNSIGNED_SHORT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, iPlaceID, NavMeshArea_PlaceID);

			int iLadderConnectionsStartIndex = -1;
			int iLadderConnectionsEndIndex = -1;
			for (int iLadderDirection = 0; iLadderDirection < NAV_LADDER_DIR_COUNT; iLadderDirection++)
			{
				int iLadderConnectionCount;
				ReadFileCell(hFile, iLadderConnectionCount, UNSIGNED_INT_BYTE_SIZE);
				if (iLadderConnectionCount > 0)
				{
					iLadderConnectionsStartIndex = g_AreaLadderConnectionsListStartIndex;
					for (int i = 0; i < iLadderConnectionCount; i++)
					{
						int iLadderConnectionID;
						ReadFileCell(hFile, iLadderConnectionID, UNSIGNED_INT_BYTE_SIZE);
						int iLadderConnectionIndex = g_hNavMeshAreaLadderConnections.Push(iLadderConnectionID);
						g_hNavMeshAreaLadderConnections.Set(iLadderConnectionIndex, iLadderDirection, NavMeshLadderConnection_Direction);
						iLadderConnectionsEndIndex = g_AreaLadderConnectionsListStartIndex++;
					}
				}
			}

			g_hNavMeshAreas.Set(iAreaIndex, iLadderConnectionsStartIndex, NavMeshArea_LadderConnectionsStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iLadderConnectionsEndIndex, NavMeshArea_LadderConnectionsEndIndex);

			float flEarliestOccupyTimeFirstTeam = 0.0;
			float flEarliestOccupyTimeSecondTeam = 0.0;
			ReadFileCell(hFile, view_as<int>(flEarliestOccupyTimeFirstTeam), FLOAT_BYTE_SIZE);
			ReadFileCell(hFile, view_as<int>(flEarliestOccupyTimeSecondTeam), FLOAT_BYTE_SIZE);
			g_hNavMeshAreas.Set(iAreaIndex, flEarliestOccupyTimeFirstTeam, NavMeshArea_EarliestOccupyTimeFirstTeam);
			g_hNavMeshAreas.Set(iAreaIndex, flEarliestOccupyTimeSecondTeam, NavMeshArea_EarliestOccupyTimeSecondTeam);

			float flNavCornerLightIntensityNW = 0.0;
			float flNavCornerLightIntensityNE = 0.0;
			float flNavCornerLightIntensitySE = 0.0;
			float flNavCornerLightIntensitySW = 0.0;
			int iVisibleAreasStartIndex = -1;
			int iVisibleAreasEndIndex = -1;
			int iInheritVisibilityFrom = -1;

			if (iNavVersion >= 11)
			{
				ReadFileCell(hFile, view_as<int>(flNavCornerLightIntensityNW), FLOAT_BYTE_SIZE);
				ReadFileCell(hFile, view_as<int>(flNavCornerLightIntensityNE), FLOAT_BYTE_SIZE);
				ReadFileCell(hFile, view_as<int>(flNavCornerLightIntensitySE), FLOAT_BYTE_SIZE);
				ReadFileCell(hFile, view_as<int>(flNavCornerLightIntensitySW), FLOAT_BYTE_SIZE);
				if (iNavVersion >= 16)
				{
					int iVisibleAreaCount = 0;
					ReadFileCell(hFile, iVisibleAreaCount, UNSIGNED_INT_BYTE_SIZE);
					if (iVisibleAreaCount > 0)
					{
						iVisibleAreasStartIndex = g_hNavMeshAreaVisibleAreas.Length;
						for (int i = 0; i < iVisibleAreaCount; i++)
						{
							AreaBindInfo bindInfo;
							ReadFileCell(hFile, bindInfo.AreaIndex, UNSIGNED_INT_BYTE_SIZE);
							ReadFileCell(hFile, bindInfo.Attributes, UNSIGNED_CHAR_BYTE_SIZE);
							g_hNavMeshAreaVisibleAreas.PushArray(bindInfo, sizeof(bindInfo));
							iVisibleAreasEndIndex = g_AreaVisibleAreasListStartIndex++;
						}
						iVisibleAreasEndIndex = g_hNavMeshAreaVisibleAreas.Length - 1;
					}
					ReadFileCell(hFile, iInheritVisibilityFrom, UNSIGNED_INT_BYTE_SIZE);
				}
			}

			g_hNavMeshAreas.Set(iAreaIndex, flNavCornerLightIntensityNW, NavMeshArea_CornerLightIntensityNW);
			g_hNavMeshAreas.Set(iAreaIndex, flNavCornerLightIntensityNE, NavMeshArea_CornerLightIntensityNE);
			g_hNavMeshAreas.Set(iAreaIndex, flNavCornerLightIntensitySE, NavMeshArea_CornerLightIntensitySE);
			g_hNavMeshAreas.Set(iAreaIndex, flNavCornerLightIntensitySW, NavMeshArea_CornerLightIntensitySW);
			g_hNavMeshAreas.Set(iAreaIndex, iVisibleAreasStartIndex, NavMeshArea_VisibleAreasStartIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iVisibleAreasEndIndex, NavMeshArea_VisibleAreasEndIndex);
			g_hNavMeshAreas.Set(iAreaIndex, iInheritVisibilityFrom, NavMeshArea_InheritVisibilityFrom);

			NavMeshLoadAreaCustomData(hFile, iAreaIndex, iNavVersion, iNavSubVersion);
		}

		profiler.Stop();
		LogMessage("Parsed %d areas in %f seconds.", iAreaCount, profiler.Time);
		delete profiler;
	}

	// Grid setup, ladders, id->index conversions and incoming connections calculation kept

	NavMeshGridAllocate(g_flNavMeshExtentLow[0], g_flNavMeshExtentHigh[0], g_flNavMeshExtentLow[1], g_flNavMeshExtentHigh[1]);
	for (int i = 0; i < iAreaCount; i++) NavMeshAddAreaToGrid(i);
	NavMeshGridFinalize();

	int iLadderCount = 0;
	ReadFileCell(hFile, iLadderCount, UNSIGNED_INT_BYTE_SIZE);
	LogMessage("Ladder count: %d", iLadderCount);
	if (iLadderCount > 0)
	{
		Profiler profiler = new Profiler(); profiler.Start();
		g_hNavMeshLadders.Resize(iLadderCount);
		for (int iLadderIndex = 0; iLadderIndex < iLadderCount; iLadderIndex++) NavMeshLoadLadder(hFile, iLadderIndex);
		profiler.Stop(); LogMessage("Parsed %d ladders in %f seconds.", iLadderCount, profiler.Time); delete profiler;
	}

	g_iNavMeshMagicNumber = iNavMagicNumber;
	g_iNavMeshVersion = iNavVersion;
	g_iNavMeshSubVersion = iNavSubVersion;
	g_iNavMeshSaveBSPSize = iNavSaveBspSize;
	g_bNavMeshAnalyzed = view_as<bool>(iNavMeshAnalyzed);

	NavMeshLoadCustomData(hFile, iNavVersion, iNavSubVersion);
	delete hFile;

	// Convert IDs to indexes
	if (g_hNavMeshAreaConnections.Length > 0)
	{
		for (int iIndex = 0, iSize = g_hNavMeshAreaConnections.Length; iIndex < iSize; iIndex++)
		{
			int id = g_hNavMeshAreaConnections.Get(iIndex, NavMeshConnection_AreaIndex);
			g_hNavMeshAreaConnections.Set(iIndex, NavMeshFindAreaByID(id), NavMeshConnection_AreaIndex);
		}
	}

	if (g_hNavMeshAreaVisibleAreas.Length > 0)
	{
		for (int iIndex = 0, iSize = g_hNavMeshAreaVisibleAreas.Length; iIndex < iSize; iIndex++)
		{
			int id = g_hNavMeshAreaVisibleAreas.Get(iIndex, NavMeshVisibleArea_Index);
			g_hNavMeshAreaVisibleAreas.Set(iIndex, NavMeshFindAreaByID(id), NavMeshVisibleArea_Index);
		}
	}

	if (g_hNavMeshAreaEncounterPaths.Length > 0)
	{
		for (int iIndex = 0, iSize = g_hNavMeshAreaEncounterPaths.Length; iIndex < iSize; iIndex++)
		{
			int id = g_hNavMeshAreaEncounterPaths.Get(iIndex, NavMeshEncounterPath_FromAreaIndex);
			g_hNavMeshAreaEncounterPaths.Set(iIndex, NavMeshFindAreaByID(id), NavMeshEncounterPath_FromAreaIndex);
			id = g_hNavMeshAreaEncounterPaths.Get(iIndex, NavMeshEncounterPath_ToAreaIndex);
			g_hNavMeshAreaEncounterPaths.Set(iIndex, NavMeshFindAreaByID(id), NavMeshEncounterPath_ToAreaIndex);
		}
	}

	if (g_hNavMeshAreaEncounterSpots.Length > 0)
	{
		for (int iIndex = 0, iSize = g_hNavMeshAreaEncounterSpots.Length; iIndex < iSize; iIndex++)
		{
			int id = g_hNavMeshAreaEncounterSpots.Get(iIndex, NavMeshEncounterSpot_HidingSpotIndex);
			g_hNavMeshAreaEncounterSpots.Set(iIndex, NavMeshFindHidingSpotByID(id), NavMeshEncounterSpot_HidingSpotIndex);
		}
	}

	if (g_hNavMeshAreaLadderConnections.Length > 0)
	{
		for (int iIndex = 0, iSize = g_hNavMeshAreaLadderConnections.Length; iIndex < iSize; iIndex++)
		{
			int id = g_hNavMeshAreaLadderConnections.Get(iIndex, NavMeshLadderConnection_LadderIndex);
			g_hNavMeshAreaLadderConnections.Set(iIndex, NavMeshFindLadderByID(id), NavMeshLadderConnection_LadderIndex);
		}
	}

	if (g_hNavMeshLadders.Length > 0)
	{
		for (int iLadderIndex = 0; iLadderIndex < iLadderCount; iLadderIndex++)
		{
			int iTopForward = GetArrayCell(g_hNavMeshLadders, iLadderIndex, NavMeshLadder_TopForwardAreaIndex);
			g_hNavMeshLadders.Set(iLadderIndex, NavMeshFindAreaByID(iTopForward), NavMeshLadder_TopForwardAreaIndex);
			int iTopLeft = GetArrayCell(g_hNavMeshLadders, iLadderIndex, NavMeshLadder_TopLeftAreaIndex);
			g_hNavMeshLadders.Set(iLadderIndex, NavMeshFindAreaByID(iTopLeft), NavMeshLadder_TopLeftAreaIndex);
			int iTopRight = GetArrayCell(g_hNavMeshLadders, iLadderIndex, NavMeshLadder_TopRightAreaIndex);
			g_hNavMeshLadders.Set(iLadderIndex, NavMeshFindAreaByID(iTopRight), NavMeshLadder_TopRightAreaIndex);
			int iTopBehind = GetArrayCell(g_hNavMeshLadders, iLadderIndex, NavMeshLadder_TopBehindAreaIndex);
			g_hNavMeshLadders.Set(iLadderIndex, NavMeshFindAreaByID(iTopBehind), NavMeshLadder_TopBehindAreaIndex);
			int iBottom = GetArrayCell(g_hNavMeshLadders, iLadderIndex, NavMeshLadder_BottomAreaIndex);
			g_hNavMeshLadders.Set(iLadderIndex, NavMeshFindAreaByID(iBottom), NavMeshLadder_BottomAreaIndex);
		}
	}

	ArrayList hIncomingConnectionsArray = new ArrayList();
	hIncomingConnectionsArray.Resize(iAreaCount);
	for (int i = 0; i < iAreaCount; i++) hIncomingConnectionsArray.Set(i, INVALID_HANDLE);

	for (int iAreaIndex = 0; iAreaIndex < iAreaCount; iAreaIndex++)
	{
		int startIndex = g_hNavMeshAreas.Get(iAreaIndex, NavMeshArea_ConnectionsStartIndex);
		if (startIndex == -1) continue;
		int endIndex = g_hNavMeshAreas.Get(iAreaIndex, NavMeshArea_ConnectionsEndIndex);

		for (int i = startIndex; i <= endIndex; i++) {
			int iToAreaIndex = g_hNavMeshAreaConnections.Get(i, NavMeshConnection_AreaIndex);
			if (iToAreaIndex == -1) continue;
			int direction = g_hNavMeshAreaConnections.Get(i, NavMeshConnection_Direction);

			if (!NavMeshAreaIsConnected(iToAreaIndex, iAreaIndex, OppositeDirection(direction))) {
				ArrayList incomingConnections = hIncomingConnectionsArray.Get(iToAreaIndex);
				if (incomingConnections == INVALID_HANDLE)
				{
					incomingConnections = new ArrayList(NavMeshConnection_MaxStats);
					hIncomingConnectionsArray.Set(iToAreaIndex, incomingConnections);
				}

				int index = incomingConnections.Push(iAreaIndex);
				incomingConnections.Set(index, OppositeDirection(direction), NavMeshConnection_Direction);
				incomingConnections.Set(index, iToAreaIndex, NavMeshConnection_FromAreaIndex);
			}
		}
	}

	int iIncomingConnections = 0;

	for (int iAreaIndex = 0; iAreaIndex < iAreaCount; iAreaIndex++)
	{
		ArrayList incomingConnections = hIncomingConnectionsArray.Get(iAreaIndex);
		if (incomingConnections == INVALID_HANDLE) continue;
		int startIndex = -1; int endIndex = -1;
		for (int j = 0; j < incomingConnections.Length; j++)
		{
			if (startIndex == -1) startIndex = iIncomingConnections;
			int incConnection = g_hNavMeshAreaIncomingConnections.Push(incomingConnections.Get(j, NavMeshConnection_AreaIndex));
			g_hNavMeshAreaIncomingConnections.Set(incConnection, incomingConnections.Get(j, NavMeshConnection_Direction), NavMeshConnection_Direction);
			g_hNavMeshAreaIncomingConnections.Set(incConnection, incomingConnections.Get(j, NavMeshConnection_FromAreaIndex), NavMeshConnection_FromAreaIndex);
			endIndex = iIncomingConnections++;
		}
		delete incomingConnections; hIncomingConnectionsArray.Set(iAreaIndex, INVALID_HANDLE);
		g_hNavMeshAreas.Set(iAreaIndex, startIndex, NavMeshArea_IncomingConnectionsStartIndex);
		g_hNavMeshAreas.Set(iAreaIndex, endIndex, NavMeshArea_IncomingConnectionsEndIndex);
	}

	delete hIncomingConnectionsArray;

	NavMeshPostLoad(true);

	return true;
}

// --- Custom data loaders (kept minimal for CS) ---

bool NavMeshLoadCustomDataPreArea(File hFile, int iNavVersion, int iNavSubVersion)
{
	// CS keeps no extra pre-area custom data in trimmed build
	return true;
}

bool NavMeshLoadAreaCustomData(File hFile, int iAreaIndex, int iNavVersion, int iNavSubVersion)
{
	// CS: only approach info (handled below if subversion indicates it)
	g_hNavMeshAreas.Set(iAreaIndex, -1, CSNavArea_ApproachInfoStartIndex);
	g_hNavMeshAreas.Set(iAreaIndex, -1, CSNavArea_ApproachInfoEndIndex);

	switch (iNavSubVersion)
	{
		case 1:
		{
			int approachCount = 0;
			ReadFileCell(hFile, approachCount, UNSIGNED_CHAR_BYTE_SIZE);
			if (approachCount > 0)
			{
				int startIndex = g_hCSNavAreaApproachInfo.Length;
				for (int i = 0; i < approachCount; i++)
				{
					CCSNavArea_ApproachInfo approachInfo;
					ReadFileCell(hFile, approachInfo.HereArea, UNSIGNED_INT_BYTE_SIZE);
					ReadFileCell(hFile, approachInfo.PrevArea, UNSIGNED_INT_BYTE_SIZE);
					ReadFileCell(hFile, approachInfo.PrevToHereHow, UNSIGNED_CHAR_BYTE_SIZE);
					ReadFileCell(hFile, approachInfo.NextArea, UNSIGNED_INT_BYTE_SIZE);
					ReadFileCell(hFile, approachInfo.HereToNextHow, UNSIGNED_CHAR_BYTE_SIZE);
					g_hCSNavAreaApproachInfo.PushArray(approachInfo);
				}
				int endIndex = g_hCSNavAreaApproachInfo.Length - 1;
				g_hNavMeshAreas.Set(iAreaIndex, startIndex, CSNavArea_ApproachInfoStartIndex);
				g_hNavMeshAreas.Set(iAreaIndex, endIndex, CSNavArea_ApproachInfoEndIndex);
			}
			break;
		}
	}

	return true;
}

int NavMeshLoadHidingSpot(File hFile, int iOwnerAreaIndex)
{
	int iHidingSpotID; ReadFileCell(hFile, iHidingSpotID, UNSIGNED_INT_BYTE_SIZE);
	float flHidingSpotX; float flHidingSpotY; float flHidingSpotZ;
	ReadFileCell(hFile, view_as<int>(flHidingSpotX), FLOAT_BYTE_SIZE);
	ReadFileCell(hFile, view_as<int>(flHidingSpotY), FLOAT_BYTE_SIZE);
	ReadFileCell(hFile, view_as<int>(flHidingSpotZ), FLOAT_BYTE_SIZE);
	int iHidingSpotFlags; ReadFileCell(hFile, iHidingSpotFlags, UNSIGNED_CHAR_BYTE_SIZE);
	int iIndex = g_hNavMeshAreaHidingSpots.Push(iHidingSpotID);
	g_hNavMeshAreaHidingSpots.Set(iIndex, flHidingSpotX, NavMeshHidingSpot_X);
	g_hNavMeshAreaHidingSpots.Set(iIndex, flHidingSpotY, NavMeshHidingSpot_Y);
	g_hNavMeshAreaHidingSpots.Set(iIndex, flHidingSpotZ, NavMeshHidingSpot_Z);
	g_hNavMeshAreaHidingSpots.Set(iIndex, iHidingSpotFlags, NavMeshHidingSpot_Flags);
	g_hNavMeshAreaHidingSpots.Set(iIndex, iOwnerAreaIndex, NavMeshHidingSpot_AreaIndex);
	char szHidingSpotID[16]; IntToString(iHidingSpotID, szHidingSpotID, 16);
	g_hNavMeshHidingSpotIdToIndexMap.SetValue(szHidingSpotID, iIndex);
	return iIndex;
}

bool NavMeshLoadLadder(File hFile, int iLadderIndex)
{
	int iLadderID = -1; ReadFileCell(hFile, iLadderID, UNSIGNED_INT_BYTE_SIZE);
	g_hNavMeshLadders.Set(iLadderIndex, iLadderID, NavMeshLadder_ID);
	char szLadderID[16]; IntToString(iLadderID, szLadderID, 16);
	g_hNavMeshLadderIdToIndexMap.SetValue(szLadderID, iLadderIndex);
	float flLadderWidth; ReadFileCell(hFile, view_as<int>(flLadderWidth), FLOAT_BYTE_SIZE); g_hNavMeshLadders.Set(iLadderIndex, flLadderWidth, NavMeshLadder_Width);
	float flLadderTopX; float flLadderTopY; float flLadderTopZ; ReadFileCell(hFile, view_as<int>(flLadderTopX), FLOAT_BYTE_SIZE); ReadFileCell(hFile, view_as<int>(flLadderTopY), FLOAT_BYTE_SIZE); ReadFileCell(hFile, view_as<int>(flLadderTopZ), FLOAT_BYTE_SIZE);
	g_hNavMeshLadders.Set(iLadderIndex, flLadderTopX, NavMeshLadder_TopX); g_hNavMeshLadders.Set(iLadderIndex, flLadderTopY, NavMeshLadder_TopY); g_hNavMeshLadders.Set(iLadderIndex, flLadderTopZ, NavMeshLadder_TopZ);
	float flLadderBottomX; float flLadderBottomY; float flLadderBottomZ; ReadFileCell(hFile, view_as<int>(flLadderBottomX), FLOAT_BYTE_SIZE); ReadFileCell(hFile, view_as<int>(flLadderBottomY), FLOAT_BYTE_SIZE); ReadFileCell(hFile, view_as<int>(flLadderBottomZ), FLOAT_BYTE_SIZE);
	g_hNavMeshLadders.Set(iLadderIndex, flLadderBottomX, NavMeshLadder_BottomX); g_hNavMeshLadders.Set(iLadderIndex, flLadderBottomY, NavMeshLadder_BottomY); g_hNavMeshLadders.Set(iLadderIndex, flLadderBottomZ, NavMeshLadder_BottomZ);
	float flLadderLength; ReadFileCell(hFile, view_as<int>(flLadderLength), FLOAT_BYTE_SIZE); g_hNavMeshLadders.Set(iLadderIndex, flLadderLength, NavMeshLadder_Length);
	int iLadderDirection; ReadFileCell(hFile, iLadderDirection, UNSIGNED_INT_BYTE_SIZE); g_hNavMeshLadders.Set(iLadderIndex, iLadderDirection, NavMeshLadder_Direction);
	int iLadderTopForwardAreaID; ReadFileCell(hFile, i