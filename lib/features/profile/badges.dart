class BadgeDef {
  final String key, emoji, title, desc;
  const BadgeDef(this.key, this.emoji, this.title, this.desc);
}

const badgeDefs = [
  BadgeDef('first_trade', '🎯', 'أول صفقة', 'نفّذ أول صفقة'),
  BadgeDef('ten_trades', '🔟', 'متداول نشط', 'نفّذ 10 صفقات'),
  BadgeDef('profit_trade', '💰', 'صفقة رابحة', 'بِع سهماً بربح'),
  BadgeDef('streak_3', '🔥', '3 أيام', 'حضور 3 أيام متتالية'),
  BadgeDef('streak_7', '⚡', 'أسبوع كامل', 'حضور 7 أيام متتالية'),
  BadgeDef('streak_30', '👑', 'شهر كامل', 'حضور 30 يوماً متتالية'),
  BadgeDef('first_referral', '🤝', 'أول دعوة', 'سجّل صديق برمزك'),
  BadgeDef('referral_5', '🌟', 'سفير سهمي', 'ادعُ 5 أصدقاء'),
];

const challengeTitles = {
  'trade_today': 'نفّذ صفقة اليوم',
  'deposit_today': 'اشحن رصيدك التجريبي اليوم',
  'trades_week': 'نفّذ 5 صفقات هذا الأسبوع',
  'invite_week': 'ادعُ صديقاً هذا الأسبوع',
};
