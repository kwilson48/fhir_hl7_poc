/// One line of encouragement per day. Indexed by day number so everyone on
/// day N sees the same message, and the message never changes mid-day.
const List<String> kDailyQuotes = [
  'Day one is the bravest day. You already did the hardest part: starting.',
  'You don\'t have to do 30 days today. Just today.',
  'Cravings are waves. They rise, they crest, they always pass.',
  'Your future self is watching you right now — and cheering.',
  'Rough sleep tonight is your brain rewiring. It gets better fast.',
  'Notice one thing that feels better today. Write it down.',
  'One week. Your body has already noticed, even if the mirror hasn\'t yet.',
  'Discipline is choosing what you want most over what you want now.',
  'The urge to drink is not an emergency. Breathe. Wait it out.',
  'Double digits tomorrow. Momentum is on your side.',
  'You are not giving something up. You are getting yourself back.',
  'Habits are votes for the person you\'re becoming. Today: one more vote.',
  'Hard days don\'t erase progress. They prove it.',
  'Two weeks in — your liver is literally repairing itself tonight.',
  'Halfway. Look back at day one. Look how far that person came.',
  'Clarity is the reward. Enjoy how sharp today feels.',
  'Tell someone your streak today. Pride shared is pride doubled.',
  'The evening routine is new now. New can feel odd. Odd is fine.',
  'You\'ve handled every craving so far. That\'s a 100% success rate.',
  'Twenty days. This isn\'t luck — it\'s you, twenty times in a row.',
  'Three weeks: your heart, your sleep, your skin — all voting yes.',
  'Boredom is not a reason. Call, walk, shower, snack. The wave passes.',
  'You sleep better, you save money, you remember your evenings. Keep going.',
  'A week from now you\'ll have done the whole thing. Picture that morning.',
  'Twenty-five. Your immune system is running at full strength again.',
  'Nothing you can pour in a glass beats waking up proud.',
  'Almost there. Decide today how you\'ll celebrate — you\'ve earned it.',
  'Four weeks of proof that you can trust yourself.',
  'Tomorrow is day 30. Tonight, sleep like someone who kept a promise.',
  'Thirty days. You did the thing. Whatever comes next, you choose it.',
];

/// Quote for a given day of the challenge (1-based). Days beyond the list
/// wrap around so post-30-day streaks still get a fresh line each day.
String quoteForDay(int day) {
  if (day < 1) day = 1;
  return kDailyQuotes[(day - 1) % kDailyQuotes.length];
}
