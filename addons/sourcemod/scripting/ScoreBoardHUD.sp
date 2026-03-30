#pragma semicolon 1

#define PLUGIN_AUTHOR "NZ"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

Handle synchud, gTimer;
bool OnTab[MAXPLAYERS + 1] = {false, ...};
int JoinTime[MAXPLAYERS + 1]; // время входа игрока

public Plugin myinfo = {
    name = "ScoreBoardHUD",
    author = PLUGIN_AUTHOR,
    description = "ScoreBoard HUD",
    version = PLUGIN_VERSION,
}

public void OnPluginStart() {
    synchud = CreateHudSynchronizer();
    HookEvent("round_start", RoundStart);
}

public void RoundStart(Event event, char[] name, bool dontBroadcast) {
    // нет статистики для сброса
}

public void OnClientPutInServer(int client) {
    if (IsClientInGame(client) && !IsFakeClient(client)) {
        JoinTime[client] = GetTime(); // фиксируем время входа
    }
}

public void OnClientDisconnect(int client) {
    JoinTime[client] = 0;
}

public void OnMapStart() {
    gTimer = CreateTimer(1.0, ShowOnScoreBoard, _, TIMER_REPEAT);
}

public void OnMapEnd() {
    delete gTimer;
}   

public Action OnPlayerRunCmd(int client) {
    if (!IsClientInGame(client) || IsFakeClient(client)) {
        return Plugin_Continue;
    }

    int pressed = GetEntProp(client, Prop_Data, "m_afButtonPressed");
    int released = GetEntProp(client, Prop_Data, "m_afButtonReleased");

    if (pressed & IN_SCORE) {
        OnTab[client] = true;
    }
    else if (released & IN_SCORE) {
        OnTab[client] = false; 
    }
    return Plugin_Continue;
}

public Action ShowOnScoreBoard(Handle timer) {
    int timeleft;
    char print[270], minutes[5], seconds[5], nextmap[64], timeOrMap[64];

    GetMapTimeLeft(timeleft);
    GetNextMap(nextmap, sizeof(nextmap));
    FormatEx(minutes, sizeof(minutes), "%s%i", ((timeleft / 60) < 10) ? "0" : "", timeleft / 60);
    FormatEx(seconds, sizeof(seconds), "%s%i", ((timeleft % 60) < 10) ? "0" : "", timeleft % 60);

    if (timeleft >= 0) {
        Format(timeOrMap, sizeof(timeOrMap), "%s:%s", minutes, seconds);
    } else {
        strcopy(timeOrMap, sizeof(timeOrMap), nextmap);
    }

    // считаем игроков
    int inGameCount = 0;
    int specCount = 0;

    for (int j = 1; j <= MaxClients; j++) {
        if (IsClientInGame(j) && !IsFakeClient(j)) {
            int team = GetClientTeam(j);
            if (team == 1) {
                specCount++;
            } else {
                inGameCount++;
            }
        }
    }

    int totalCount = inGameCount + specCount;

    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i)) {
            continue;
        }

        if (OnTab[i]) {
            // считаем время игрока на сервере
            int played = GetTime() - JoinTime[i];
            int hours = played / 3600;
            int mins = (played % 3600) / 60;
            int secs = played % 60;

            char playtime[32];
            if (hours > 0) {
                Format(playtime, sizeof(playtime), "%02i:%02i:%02i", hours, mins, secs);
            } else {
                Format(playtime, sizeof(playtime), "%02i:%02i", mins, secs);
            }

            Format(print, sizeof(print), "-|Time/Map: %s\n-|Players In Game: %i\n-|Spectators: %i\n-|Total Online: %i\n-|Your PlayTime: %s",
                timeOrMap, inGameCount, specCount, totalCount, playtime);

            SetHudTextParams(-0.95, -0.42, 1.1, 1, 100, 255, 255, 0, 0.0, 0.0, 0.0);
            ShowSyncHudText(i, synchud, print);
        }
    }
    return Plugin_Continue;
}
