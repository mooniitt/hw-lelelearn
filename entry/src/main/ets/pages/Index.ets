import router from '@ohos.router';
import { LESSONS } from '../model/LessonData';
import { Lesson } from '../model/Lesson';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('LeLeLearn')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .padding(20)

      List({ space: 10 }) {
        ForEach(LESSONS, (lesson: Lesson) => {
          ListItem() {
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
            .padding(15)
            .borderRadius(10)
            .backgroundColor(Color.White)
            .shadow({ radius: 5, color: '#e0e0e0', offsetX: 2, offsetY: 2 })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/LessonPage',
              params: { lessonId: lesson.id.toString() }
            });
          })
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

