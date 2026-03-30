#if defined _ai_flank_included
  #endinput
#endif
#define _ai_flank_included

/**
 * Инициализация flank-модуля
 */
native void InitAIFlank();

/**
 * Вычисляет flank-цель для бота
 *
 * @param bot     ID бота
 * @param player  ID цели
 * @param target  [out] координаты цели
 */
native void GetFlankTarget(int bot, int player, float target[3]);
