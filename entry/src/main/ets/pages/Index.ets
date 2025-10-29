import router from '@ohos.router';
import { Lesson } from '../model/Lesson';
import { progressService } from '../model/ProgressService';
import { Context } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { lessonService } from '../model/LessonService';

@Entry
@Component
struct Index {
  context: Context = getContext(this);

  async aboutToAppear() {
    if (this.context) {
      await progressService.initialize(this.context as common.UIAbilityContext);
      await lessonService.loadLessons(this.context as common.UIAbilityContext);
      progressService.regenerateLives();
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
      Row() {
        Text('乐乐学')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)

        Blank()

        Row({ space: 5 }) {
          Image($r('app.media.startIcon')).width(24).height(24).fillColor(Color.Red)
          Text(`${progressService.lives}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
        }
      }
      .width('100%')
      .padding(20)

      List({ space: 10 }) {
        ForEach(lessonService.getLessons(), (lesson: Lesson) => {
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