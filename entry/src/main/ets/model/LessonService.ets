import { Lesson } from './Lesson';
import resourceManager from '@ohos.resourceManager';
import common from '@ohos.app.ability.common';

function utf8ArrayToString(array: Uint8Array): string {
  let out = '';
  let i = 0;
  while (i < array.length) {
    const c = array[i++];
    if (c >> 7 === 0) {
      out += String.fromCharCode(c);
    } else if (c >> 5 === 0x6) {
      const c2 = array[i++];
      out += String.fromCharCode(((c & 0x1f) << 6) | (c2 & 0x3f));
    } else if (c >> 4 === 0xe) {
      const c2 = array[i++];
      const c3 = array[i++];
      out += String.fromCharCode(((c & 0x0f) << 12) | ((c2 & 0x3f) << 6) | (c3 & 0x3f));
    }
  }
  return out;
}


@Observed
class LessonService {
  public lessons: Lesson[] = [];

async loadLessons(context: common.UIAbilityContext) {
    if (this.lessons.length > 0) return

    try {
      const resourceMgr = context.resourceManager
      const rawFile: Uint8Array = await resourceMgr.getRawFileContent('lessons.json') as Uint8Array

      // ✅ 使用上面定义的 UTF-8 解码函数
      const jsonString: string = utf8ArrayToString(rawFile)
      this.lessons = JSON.parse(jsonString) as Lesson[]
      console.log('LeLeLearn: Lessons loaded successfully.')
    } catch (e) {
      console.error(`LeLeLearn: Failed to load lessons. Code: ${e.code}, Message: ${e.message}`)
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
