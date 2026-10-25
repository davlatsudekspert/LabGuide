// Ustoz Pro yozuvlarini o'chirish (0030_teacher_tests.sql). Alohida modul —
// groups.ts va auth.ts uni teachertests.ts bilan aylana importsiz chaqiradi.
// Jadvallar faqat Pro migratsiyasi qo'llangan bazada bor, shuning uchun
// chaqiruvchi har doim `billingEnabled(env)` bilan tekshiradi.

/**
 * Talaba guruhdan chiqdi yoki chiqarildi: shu guruh topshiriqlaridagi
 * urinishlari va unga shaxsan berilgan topshiriqlar o'chiriladi (ustoz
 * endi uning natijasini ko'rmaydi). ?1 — guruh, ?2 — talaba.
 */
export function teacherLeaveStatements(db: D1Database, gid: string, uid: string): D1PreparedStatement[] {
  return [
    db
      .prepare(
        `DELETE FROM teacher_test_attempts WHERE user_id = ?2
           AND assignment_id IN (SELECT id FROM teacher_test_assignments WHERE group_id = ?1)`,
      )
      .bind(gid, uid),
    db.prepare('DELETE FROM teacher_test_assignments WHERE group_id = ?1 AND user_id = ?2').bind(gid, uid),
  ];
}

/**
 * Hisob o'chirilmoqda (auth.ts `deleteUserData`): o'z urinishlari, o'zi
 * yaratgan testlar, topshiriqlar (va ulardagi BOSHQALARNING urinishlari),
 * taklifnomalar. `study_groups` / `users` qatorlaridan OLDIN bajariladi.
 */
export function teacherDeleteStatements(db: D1Database, uid: string): D1PreparedStatement[] {
  // Interpolatsiya faqat doimiy SQL bo'lagi (`owned`) — qiymat emas (security.test.ts).
  const owned = `SELECT id FROM teacher_test_assignments WHERE owner_id = ?1 OR user_id = ?1
    OR group_id IN (SELECT id FROM study_groups WHERE owner_id = ?1)`;
  return [
    `DELETE FROM teacher_test_attempts WHERE user_id = ?1 OR assignment_id IN (${owned})`,
    `DELETE FROM teacher_test_assignments WHERE id IN (${owned})`,
    'DELETE FROM teacher_invites WHERE owner_id = ?1 OR group_id IN (SELECT id FROM study_groups WHERE owner_id = ?1)',
    'DELETE FROM teacher_tests WHERE owner_id = ?1',
  ].map((q) => db.prepare(q).bind(uid));
}

/** Kunlik tozalash: vaqti tugab topshirilmagan urinish — `expired`. */
export function teacherCleanupStatements(db: D1Database, now: number, graceMs: number): D1PreparedStatement[] {
  return [
    db
      .prepare(
        `UPDATE teacher_test_attempts SET status = 'expired'
         WHERE status = 'started' AND time_up_at IS NOT NULL AND time_up_at < ?1`,
      )
      .bind(now - graceMs),
  ];
}
