import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

const PREFS_NAME = 'lelelearn_prefs';
const COMPLETED_LESSONS_KEY = 'completed_lessons';
const LIVES_KEY = 'user_lives';
const MAX_LIVES = 5;

@Observed
class ProgressService {
  public completedLessons: Set<number> = new Set();
  public lives: number = MAX_LIVES;
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
      this.saveProgress();
    }
  }

  resetLives() {
    this.lives = MAX_LIVES;
    this.saveProgress();
  }

  isCompleted(lessonId: number): boolean {
    return this.completedLessons.has(lessonId);
  }
}

export const progressService = new ProgressService();
