
import { Lesson } from './Lesson';

export const LESSONS: Lesson[] = [
  {
    id: 1,
    title: 'Lesson 1: Greetings',
    description: 'Learn basic greetings in English.',
    questions: [
      {
        type: 'multiple-choice',
        prompt: 'Which one is \'Hello\ ચ?',
        options: ['你好', '再见', '谢谢', '不客气'],
        answer: '你好'
      },
      {
        type: 'multiple-choice',
        prompt: 'Which one is \'Goodbye\ ચ?',
        options: ['你好', '再见', '谢谢', '不客气'],
        answer: '再见'
      }
    ]
  },
  {
    id: 2,
    title: 'Lesson 2: Numbers',
    description: 'Learn numbers from 1 to 2.',
    questions: [
      {
        type: 'multiple-choice',
        prompt: 'Which one is \'One\ ચ?',
        options: ['一', '二', '三', '四'],
        answer: '一'
      },
      {
        type: 'multiple-choice',
        prompt: 'Which one is \'Two\ ચ?',
        options: ['一', '二', '三', '四'],
        answer: '二'
      }
    ]
  }
];
