// Alarm 1 — bgm_pop: stop the cutscene track after fade
// (bgm_instance is now the resumed stack track, so stop the old one separately)
// Store it before the pop to clean up here — or just stop all non-bgm audio
// simplest: find and stop any looping track that isn't bgm_instance
// (adapt to your needs)