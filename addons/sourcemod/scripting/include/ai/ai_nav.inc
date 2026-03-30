#pragma semicolon 1
#if defined _ai_nav_included
 #endinput
#endif
#define _ai_nav_included

forward void InitAINav();
forward void UpdateBotNavigation(int bot, int player, const char[] strategy);
