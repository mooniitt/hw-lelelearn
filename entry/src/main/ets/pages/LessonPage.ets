import router from '@ohos.router';
import { LESSONS } from '../model/LessonData';
import { Lesson, Question, QuestionFillInBlank, QuestionMultipleChoice } from '../model/Lesson';
import { progressService } from '../model/ProgressService';

// Define interface for router parameters
interface RouterParams {
  lessonId: string;
}

@Entry
@Component
struct LessonPage {
  @State lesson: Lesson | null = null;
  @State currentQuestionIndex: number = 0;
  @State selectedOption: string | null = null;
  @State fillInBlankAnswer: string = ''; // State for the text input
  @State isCorrect: boolean | null = null;
  @State score: number = 0;

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.lessonId) {
      this.lesson = LESSONS.find(l => l.id === parseInt(params.lessonId)) || null;
    }
  }

  checkAnswer() {
    if (!this.lesson) return;
    const question = this.lesson.questions[this.currentQuestionIndex];

    if (question.type === 'multiple-choice') {
      if (!this.selectedOption) return;
      this.isCorrect = this.selectedOption === question.answer;
    } else if (question.type === 'fill-in-the-blank') {
      this.isCorrect = this.fillInBlankAnswer.trim().toLowerCase() === question.answer.toLowerCase();
    }

    if (this.isCorrect) {
      this.score++;
    }
  }

  nextQuestion() {
    this.selectedOption = null;
    this.fillInBlankAnswer = '';
    this.isCorrect = null;
    if (this.lesson && this.currentQuestionIndex < this.lesson.questions.length - 1) {
      this.currentQuestionIndex++;
    } else {
      if (this.lesson) {
        progressService.completeLesson(this.lesson.id);
      }
      router.back();
    }
  }

  // Builder for Multiple Choice Question UI
  @Builder
  MultipleChoiceBody(question: QuestionMultipleChoice) {
    Column({ space: 10 }) {
      ForEach(question.options, (option: string) => {
        Button(option)
          .width('80%')
          .height(50)
          .onClick(() => {
            if (this.isCorrect === null) {
              this.selectedOption = option;
            }
          })
          .backgroundColor(this.getOptionColor(option, question))
          .fontColor(this.isCorrect !== null ? Color.White : Color.Black)
          .animation({ duration: 300, curve: Curve.EaseInOut })
      })
    }.width('100%').alignItems(HorizontalAlign.Center).padding({ bottom: 20 })
  }

  // Builder for Fill-in-the-Blank Question UI
  @Builder
  FillInTheBlankBody(question: QuestionFillInBlank) {
    Row({ space: 5 }) {
      ForEach(question.promptParts, (part: string | null) => {
        if (part === null) {
          TextInput({
            text: this.fillInBlankAnswer,
            placeholder: 'type here'
          })
            .onChange((value) => { this.fillInBlankAnswer = value; })
            .height(50)
            .layoutWeight(1)
            .backgroundColor(this.isCorrect === null ? Color.White : (this.isCorrect ? Color.Green : Color.Red))
            .fontColor(this.isCorrect !== null ? Color.White : Color.Black)
            .animation({ duration: 300, curve: Curve.EaseInOut })

        } else {
          Text(part).fontSize(24)
        }
      })
    }
    .width('90%')
    .padding(20)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  QuestionContent() {
    if (this.lesson) {
      // Header
      Text(this.lesson.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 40, bottom: 10 })

      // Progress Bar
      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.lesson.questions.length,
        type: ProgressType.Linear
      })
        .width('90%')
        .padding({ bottom: 20 })

      // Question Area
      Column() {
        if (this.lesson.questions[this.currentQuestionIndex].type === 'multiple-choice') {
          Text((this.lesson.questions[this.currentQuestionIndex] as QuestionMultipleChoice).prompt).fontSize(24).padding(20).textAlign(TextAlign.Center)
          this.MultipleChoiceBody(this.lesson.questions[this.currentQuestionIndex] as QuestionMultipleChoice)
        } else if (this.lesson.questions[this.currentQuestionIndex].type === 'fill-in-the-blank') {
          this.FillInTheBlankBody(this.lesson.questions[this.currentQuestionIndex] as QuestionFillInBlank)
        }
      }.layoutWeight(1).justifyContent(FlexAlign.Center)

      // Footer (Check/Next Button and Feedback)
      Column() {
        if (this.isCorrect !== null) {
          Text(this.isCorrect ? 'Correct!' : this.getCorrectAnswerText())
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
          .enabled(this.isCorrect !== null || this.selectedOption !== null || this.fillInBlankAnswer !== '')

      }.height(120)
    } else {
      Text('Lesson not found.').fontSize(20).padding(20)
    }
  }

  build() {
    Column() {
      this.QuestionContent()
    }
    .width('100%')
    .height('100%')
  }

  getCorrectAnswerText(): string {
    if (!this.lesson) return '';
    const question = this.lesson.questions[this.currentQuestionIndex];
    const correctAnswer = question.type === 'multiple-choice' ? question.answer : (question as QuestionFillInBlank).answer;
    return `Correct answer: ${correctAnswer}`;
  }

  getOptionColor(option: string, question: QuestionMultipleChoice): Color {
    if (this.isCorrect === null) { // Before checking
      return this.selectedOption === option ? Color.Yellow : Color.White;
    }
    // After checking
    if (option === question.answer) {
      return Color.Green;
    }
    if (this.selectedOption === option) {
      return Color.Red;
    }
    return Color.White;
  }
}