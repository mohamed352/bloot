// حالة الواجهة المشتركة بين اللعب المحلي والأونلاين — كائن وحيد بدل متغيرات معزولة بكل وحدة
export const S = {
  match: null,
  players: null,
  mySeat: 0,
  safeMode: true,
  speed: "normal",
  online: null, // null = لعب محلي؛ غير null = {code, seat, isHost, actionBuffer, unsubs, started, hostPump, syncSnapshot}
  awaitingServerAck: false, // عميل أونلاين: يمنع سبام/دبل-تاب يدفع نفس الحركة مرتين قبل ما توصل لقطة جديدة
};

export const botDelay = () => (S.speed === "fast" ? 150 : 350) + Math.random() * (S.speed === "fast" ? 100 : 200);
