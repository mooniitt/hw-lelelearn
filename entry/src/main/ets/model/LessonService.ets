import { Lesson } from './Lesson';
import resourceManager from '@ohos.resourceManager';
import common from '@ohos.app.ability.common';

@Observed
class LessonService {
  public lessons: Lesson[] = [];

  async loadLessons(context: common.UIAbilityContext) {
    if (this.lessons.length > 0) {
      return;
    }

    try {
      const resourceMgr = context.resourceManager;
      const rawFile = await resourceMgr.getRawFileContent('lessons.json');
      // Convert Uint8Array to string without using apply
      const uint8Array: Uint8Array = new Uint8Array(rawFile);
      let jsonString: string = '';
      for (let i = 0; i < uint8Array.length; i++) {
        jsonString += String.fromCharCode(uint8Array[i]);
      }
      this.lessons = JSON.parse(jsonString) as Lesson[];
      console.log('LeLeLearn: Lessons loaded successfully.');
    } catch (e) {
      console.error(`LeLeLearn: Failed to load lessons. Code: ${e.code}, Message: ${e.message}`);
    }
  }

  getLessons(): Lesson[] {
    return this.lessons;
  }

  getLesson(id: number): Lesson | null {
    return this.lessons.find(l => l.id === id) || null;
  }
}

export const lessonService = new LessonService();
