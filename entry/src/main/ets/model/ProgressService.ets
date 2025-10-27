import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

const PREFS_NAME = 'lelelearn_prefs';
const COMPLETED_LESSONS_KEY = 'completed_lessons';
const LIVES_KEY = 'user_lives';
const LAST_LIFE_DECREMENT_KEY = 'last_life_decrement_time';
const MAX_LIVES = 5;
const LIFE_REGEN_TIME_MS = 30 * 60 * 1000; // 30 minutes

@Observed
class ProgressService {
  public completedLessons: Set<number> = new Set();
  public lives: number = MAX_LIVES;
  public lastLifeDecrementTime: number | null = null;
  private prefs: preferences.Preferences | null = null;

  constructor() {
    // Delay initialization
  }

  async initialize(context: common.UIAbilityContext) {
    try {
      this.prefs = await preferences.getPreferences(context, { name: PREFS_NAME });
      // Load completed lessons
      const completedStr = await this.prefs.get(COMPLETED_LESSONS_KEY, '[]') as string;
      this.completedLessons = new Set(JSON.parse(completedStr) as number[]);
      // Load lives
      this.lives = await this.prefs.get(LIVES_KEY, MAX_LIVES) as number;
      // Load last life decrement time
      const lastDecrementValue = await this.prefs.get(LAST_LIFE_DECREMENT_KEY, '0') as string;
      if (lastDecrementValue === '0') {
        this.lastLifeDecrementTime = null;
      } else {
        this.lastLifeDecrementTime = parseInt(lastDecrementValue, 10);
      }

      console.log('LeLeLearn: Progress loaded successfully.');
    } catch (e) {
      const err = e as BusinessError;
      console.error(`LeLeLearn: Failed to load progress. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  private async saveProgress() {
    if (!this.prefs) {
      console.error('LeLeLearn: Preferences not initialized, cannot save progress.');
      return;
    }
    try {
      // Save completed lessons
      const completedStr = JSON.stringify(Array.from(this.completedLessons));
      await this.prefs.put(COMPLETED_LESSONS_KEY, completedStr);
      // Save lives
      await this.prefs.put(LIVES_KEY, this.lives);
      // Save last life decrement time as string
      if (this.lastLifeDecrementTime !== null) {
        await this.prefs.put(LAST_LIFE_DECREMENT_KEY, this.lastLifeDecrementTime.toString());
      } else {
        await this.prefs.delete(LAST_LIFE_DECREMENT_KEY);
      }

      await this.prefs.flush();
      console.log('LeLeLearn: Progress saved successfully.');
    } catch (e) {
      const err = e as BusinessError;
      console.error(`LeLeLearn: Failed to save progress. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  completeLesson(lessonId: number) {
    if (this.completedLessons.has(lessonId)) {
      return;
    }
    this.completedLessons.add(lessonId);
    this.saveProgress();
  }

  decrementLife() {
    if (this.lives > 0) {
      this.lives--;
      if (this.lives < MAX_LIVES) { // Start timer only when lives are not full
        this.lastLifeDecrementTime = Date.now();
      }
      this.saveProgress();
    }
  }

  regenerateLives() {
    if (this.lives >= MAX_LIVES || this.lastLifeDecrementTime === null) {
      return;
    }

    const now = Date.now();
    const timeDiff = now - this.lastLifeDecrementTime;
    const livesToRegen = Math.floor(timeDiff / LIFE_REGEN_TIME_MS);

    if (livesToRegen > 0) {
      this.lives = Math.min(MAX_LIVES, this.lives + livesToRegen);
      if (this.lives < MAX_LIVES) {
        this.lastLifeDecrementTime = this.lastLifeDecrementTime + livesToRegen * LIFE_REGEN_TIME_MS;
      } else {
        this.lastLifeDecrementTime = null; // All lives regenerated
      }
      this.saveProgress();
    }
  }

  resetLives() {
    this.lives = MAX_LIVES;
    this.lastLifeDecrementTime = null;
    this.saveProgress();
  }

  isCompleted(lessonId: number): boolean {
    return this.completedLessons.has(lessonId);
  }
}

export const progressService = new ProgressService();
