import router from '@ohos.router';
import { LESSONS } from '../model/LessonData';
import { Lesson, Question } from '../model/Lesson';

interface LessonPageParams {
  lessonId: string;
}

@Entry
@Component
struct LessonPage {
  @State lesson: Lesson | null = null;
  @State currentQuestionIndex: number = 0;
  @State selectedOption: string | null = null;
  @State isCorrect: boolean | null = null;
  @State score: number = 0;

  aboutToAppear() {
    const params = router.getParams() as LessonPageParams;
    if (params && params.lessonId) {
      this.lesson = LESSONS.find(l => l.id === parseInt(params.lessonId)) || null;
    }
  }

  checkAnswer() {
    if (!this.lesson || !this.selectedOption) return;
    const currentQuestion = this.lesson.questions[this.currentQuestionIndex];
    this.isCorrect = this.selectedOption === currentQuestion.answer;
    if (this.isCorrect) {
      this.score++;
    }
  }

  nextQuestion() {
    this.selectedOption = null;
    this.isCorrect = null;
    if (this.lesson && this.currentQuestionIndex < this.lesson.questions.length - 1) {
      this.currentQuestionIndex++;
    } else {
      router.back();
    }
  }

  build() {
    Column() {
      if (this.lesson) {
        // Header
        Text(`${this.lesson.title} (${this.currentQuestionIndex + 1}/${this.lesson.questions.length})`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 40, bottom: 20 })

        // Question Prompt
        Text(this.lesson.questions[this.currentQuestionIndex].prompt)
          .fontSize(24)
          .padding(20)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)

        // Options
        Column({ space: 10 }) {
          ForEach(this.lesson.questions[this.currentQuestionIndex].options, (option: string) => {
            Button(option)
              .width('80%')
              .height(50)
              .onClick(() => {
                if (this.isCorrect === null) {
                  this.selectedOption = option;
                }
              })
              .backgroundColor(this.getOptionColor(option))
              .fontColor(this.isCorrect !== null ? Color.White : Color.Black)
          })
        }.width('100%').alignItems(HorizontalAlign.Center).padding({ bottom: 20 })

        // Footer (Check/Next Button and Feedback)
        Column() {
          if (this.isCorrect !== null) {
            Text(this.isCorrect ? 'Correct!' : `Correct answer: ${this.lesson.questions[this.currentQuestionIndex].answer}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isCorrect ? Color.Green : Color.Red)
              .padding(10)
          }

          Button(this.isCorrect === null ? 'Check' : 'Next')
            .width('80%')
            .height(50)
            .margin({ bottom: 20 })
            .onClick(() => {
              if (this.isCorrect === null) {
                this.checkAnswer();
              } else {
                this.nextQuestion();
              }
            })
            .enabled(this.isCorrect !== null || this.selectedOption !== null)

        }.height(120)

      } else {
        Text('Lesson not found.')
          .fontSize(20)
          .padding(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  getOptionColor(option: string): Color {
    if (!this.lesson) {
      return Color.White;
    }
    if (this.isCorrect === null) { // Before checking
      return this.selectedOption === option ? Color.Yellow : Color.White;
    }
    // After checking
    const currentQuestion = this.lesson.questions[this.currentQuestionIndex];
    if (option === currentQuestion.answer) {
      return Color.Green;
    }
    if (this.selectedOption === option) {
      return Color.Red;
    }
    return Color.White; // Default for non-selected, non-answer
  }
}