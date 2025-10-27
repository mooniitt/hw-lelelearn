import router from '@ohos.router';
import { LESSONS } from '../model/LessonData';
import { Lesson } from '../model/Lesson';
import { progressService } from '../model/ProgressService';
import common from '@ohos.app.ability.common';
import { Context } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  context: Context = getContext(this);

  aboutToAppear() {
    if (this.context) {
      progressService.initialize(this.context as common.UIAbilityContext);
    }
  }

  @Builder
  LessonRow(lesson: Lesson) {
    ListItem() {
      Row() {
        Column() {
          Text(lesson.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(lesson.description)
            .fontSize(16)
            .fontColor(Color.Gray)
            .width('100%')
        }
        .layoutWeight(1)

        if (progressService.isCompleted(lesson.id)) {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor(Color.Green)
            .margin({ left: 10 })
        }
      }
      .padding(15)
      .borderRadius(10)
      .backgroundColor(Color.White)
      .shadow({ radius: 5, color: '#e0e0e0', offsetX: 2, offsetY: 2 })
      .opacity(progressService.isCompleted(lesson.id) ? 0.5 : 1.0)
    }
    .onClick(() => {
      router.pushUrl({
        url: 'pages/LessonPage',
        params: { lessonId: lesson.id.toString() }
      });
    })
  }

  build() {
    Column() {
      Text('LeLeLearn')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .padding(20)

      List({ space: 10 }) {
        ForEach(LESSONS, (lesson: Lesson) => {
          this.LessonRow(lesson)
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 10, right: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

