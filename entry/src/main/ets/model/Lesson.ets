
export interface Question {
  type: 'multiple-choice';
  prompt: string;
  options: string[];
  answer: string;
}

export interface Lesson {
  id: number;
  title: string;
  description: string;
  questions: Question[];
}
