import {
  collection,
  query,
  orderBy,
  limit,
  startAfter,
  getDocs,
  getDoc,
  doc,
  onSnapshot,
  type QueryConstraint,
  type QuerySnapshot,
  type DocumentData,
  type QueryDocumentSnapshot,
  type CollectionReference,
  type DocumentReference,
} from 'firebase/firestore';
import { db } from './firebase';

export interface PaginatedResult<T> {
  items: T[];
  lastDoc: QueryDocumentSnapshot<DocumentData> | null;
  hasMore: boolean;
}

export function getCollectionRef<T = DocumentData>(path: string): CollectionReference<T> {
  return collection(db, path) as CollectionReference<T>;
}

export function getDocRef<T = DocumentData>(path: string, id: string): DocumentReference<T> {
  return doc(db, path, id) as DocumentReference<T>;
}

export async function fetchCollection<T>(
  path: string,
  constraints: QueryConstraint[] = []
): Promise<T[]> {
  const q = query(collection(db, path), ...constraints);
  const snap = await getDocs(q);
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as T) }));
}

export async function fetchPaginated<T>(
  path: string,
  constraints: QueryConstraint[] = [],
  pageSize: number = 25,
  lastDoc?: QueryDocumentSnapshot<DocumentData>
): Promise<PaginatedResult<T>> {
  const pagination: QueryConstraint[] = lastDoc ? [startAfter(lastDoc)] : [];
  const q = query(collection(db, path), ...constraints, ...pagination, limit(pageSize));
  const snap = await getDocs(q);
  const items = snap.docs.map((d) => ({ id: d.id, ...(d.data() as T) }));
  return {
    items,
    lastDoc: snap.docs[snap.docs.length - 1] || null,
    hasMore: snap.docs.length === pageSize,
  };
}

export async function fetchDocument<T>(path: string, id: string): Promise<T | null> {
  const snap = await getDoc(doc(db, path, id));
  if (!snap.exists()) return null;
  return { id: snap.id, ...(snap.data() as T) };
}

export function subscribeToCollection<T>(
  path: string,
  constraints: QueryConstraint[] = [],
  onData: (items: T[]) => void,
  onError?: (err: Error) => void
): () => void {
  const baseQuery = query(collection(db, path), ...constraints);
  return onSnapshot(
    baseQuery,
    (snap: QuerySnapshot<DocumentData>) => {
      const items = snap.docs.map((d) => ({ id: d.id, ...(d.data() as T) }));
      onData(items);
    },
    (err) => onError?.(err)
  );
}

export function subscribeToDocument<T>(
  path: string,
  id: string,
  onData: (item: T | null) => void,
  onError?: (err: Error) => void
): () => void {
  return onSnapshot(
    doc(db, path, id),
    (snap) => {
      if (!snap.exists()) {
        onData(null);
        return;
      }
      onData({ id: snap.id, ...(snap.data() as T) });
    },
    (err) => onError?.(err)
  );
}

export const defaultOrder = orderBy('createdAt', 'desc');
