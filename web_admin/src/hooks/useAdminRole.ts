import { useEffect, useMemo, useState } from 'react';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import type { AdminRole, Permission } from '../types';
import { ROLE_PERMISSIONS } from '../types';

export function useAdminRole(uid: string | undefined) {
  const [role, setRole] = useState<AdminRole | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!uid) {
      setRole(null);
      setLoading(false);
      return;
    }

    let cancelled = false;
    setLoading(true);

    getDoc(doc(db, 'admins', uid))
      .then((snap) => {
        if (cancelled) return;
        if (snap.exists()) {
          setRole(snap.data().role as AdminRole);
        } else {
          setRole(null);
        }
      })
      .catch(() => setRole(null))
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [uid]);

  const hasPermission = useMemo(
    () => (permission: Permission) => role !== null && ROLE_PERMISSIONS[role].includes(permission),
    [role]
  );

  return { role, loading, hasPermission };
}
