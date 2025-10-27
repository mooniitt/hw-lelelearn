
export interface QuestionMultipleChoice {
  type: 'multiple-choice';
  prompt: string;
  options: string[];
  answer: string;
}

export interface QuestionFillInBlank {
  type: 'fill-in-the-blank';
  promptParts: (string | null)[]; // e.g., ["The sky is ", null, "."]
  answer: string;
}

export type Question = QuestionMultipleChoice | QuestionFillInBlank;

export interface Lesson {
  id: number;
  title: string;
  description: string;
  questions: Question[];
}
