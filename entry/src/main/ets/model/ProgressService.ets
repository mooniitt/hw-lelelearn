import preferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

const PREFS_NAME = 'lelelearn_prefs';
const COMPLETED_LESSONS_KEY = 'completed_lessons';

@Observed
class ProgressService {
  public completedLessons: Set<number> = new Set();
  private prefs: preferences.Preferences | null = null;

  constructor() {
    // Delay initialization until context is available
    // We'll load progress when save is first called or via a separate init method
  }

  async initialize(context: common.UIAbilityContext) {
    try {
      this.prefs = await preferences.getPreferences(context, { name: PREFS_NAME });
      const completedStr = await this.prefs.get(COMPLETED_LESSONS_KEY, '[]') as string;
      const completedIds = JSON.parse(completedStr) as number[];
      this.completedLessons = new Set(completedIds);
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
      const completedStr = JSON.stringify(Array.from(this.completedLessons));
      await this.prefs.put(COMPLETED_LESSONS_KEY, completedStr);
      await this.prefs.flush(); // Ensure data is written to disk
      console.log('LeLeLearn: Progress saved successfully.');
    } catch (e) {
      const err = e as BusinessError;
      console.error(`LeLeLearn: Failed to save progress. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  completeLesson(lessonId: number) {
    if (this.completedLessons.has(lessonId)) {
      return; // No need to save if already completed
    }
    this.completedLessons.add(lessonId);
    this.saveProgress();
  }

  isCompleted(lessonId: number): boolean {
    return this.completedLessons.has(lessonId);
  }
}

// Export a singleton instance so the state is shared across the app
export const progressService = new ProgressService();
