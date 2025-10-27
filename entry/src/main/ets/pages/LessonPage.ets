import router from '@ohos.router';
import { Lesson, Question, QuestionFillInBlank, QuestionMultipleChoice } from '../model/Lesson';
import { progressService } from '../model/ProgressService';
import prompt from '@ohos.promptAction';
import { lessonService } from '../model/LessonService';
import { Context } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';

interface LessonPageParams {
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
  context: Context = getContext(this);

  async aboutToAppear() {
    // Ensure lessons are loaded
    if (lessonService.getLessons().length === 0 && this.context) {
      await lessonService.loadLessons(this.context as common.UIAbilityContext);
    }
    
    const params = router.getParams() as LessonPageParams;
    if (params && params.lessonId) {
      this.lesson = lessonService.getLesson(parseInt(params.lessonId));
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
    } else {
      // Decrement life on wrong answer
      progressService.decrementLife();
      // Check for game over
      if (progressService.lives <= 0) {
        prompt.showToast({
          message: 'You have run out of lives!',
          duration: 2000
        });
        // Navigate back after a short delay
        setTimeout(() => {
          router.back();
        }, 2000);
      }
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
  LessonContent() {
    if (this.lesson) {
      // Header
      Row() {
        Text(this.lesson.title)
          .fontSize(20)
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
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)
      .shadow({ radius: 5, color: '#e0e0e0', offsetY: 2 })

      // Progress Bar
      Progress({
        value: this.currentQuestionIndex + 1,
        total: this.lesson.questions.length,
        type: ProgressType.Linear
      })
        .width('90%')
        .padding({ top: 10, bottom: 20 })

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
          Text(this.getFeedbackText())
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

  getFeedbackText(): string {
    if (!this.lesson) return '';
    const question = this.lesson.questions[this.currentQuestionIndex];
    const correctAnswer = question.type === 'multiple-choice' ? question.answer : (question as QuestionFillInBlank).answer;
    return this.isCorrect ? 'Correct!' : `Correct answer: ${correctAnswer}`;
  }

  build() {
    Column() {
      this.LessonContent()
    }
    .width('100%')
    .height('100%')
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