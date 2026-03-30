#if defined _grenade_effects_included
 #endinput
#endif
#define _grenade_effects_included

/**
 * Called when a flashbang explodes and light effect is triggered.
 *
 * @param origin     The explosion position (float[3])
 * @param attacker   The client index who threw the grenade
 * @noreturn
 */
forward OnFlashLightExplode(const float origin[3], int attacker);

public SharedPlugin:__pl_grenade_effects = 
{
    name = "grenade_effects",
    file = "grenade_effects.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
