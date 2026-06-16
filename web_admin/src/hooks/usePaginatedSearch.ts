import { useCallback, useEffect, useRef, useState } from 'react';
import {
  collection,
  query,
  orderBy,
  limit,
  startAfter,
  where,
  getDocs,
  type QueryConstraint,
  type QueryDocumentSnapshot,
  type DocumentData,
} from 'firebase/firestore';
import { db } from '../services/firebase';

interface UsePaginatedSearchOptions {
  path: string;
  baseConstraints?: QueryConstraint[];
  pageSize?: number;
  orderByField?: string;
  orderDirection?: 'asc' | 'desc';
  searchField?: string; // defaults to 'searchKeywords'
  debounceMs?: number;
}

interface UsePaginatedSearchResult<T> {
  items: T[];
  isLoading: boolean;
  isLoadingMore: boolean;
  hasMore: boolean;
  search: string;
  setSearch: (value: string) => void;
  loadMore: () => void;
  refresh: () => void;
}

export function usePaginatedSearch<T>({
  path,
  baseConstraints = [],
  pageSize = 25,
  orderByField = 'createdAt',
  orderDirection = 'desc',
  searchField = 'searchKeywords',
  debounceMs = 300,
}: UsePaginatedSearchOptions): UsePaginatedSearchResult<T> {
  const [items, setItems] = useState<T[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(false);
  const [search, setSearchState] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');

  const lastDocRef = useRef<QueryDocumentSnapshot<DocumentData> | null>(null);
  const currentSearchRef = useRef(debouncedSearch);
  const debounceTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    currentSearchRef.current = debouncedSearch;
  }, [debouncedSearch]);

  useEffect(() => {
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }
    debounceTimerRef.current = setTimeout(() => {
      setDebouncedSearch(search.trim().toLowerCase());
    }, debounceMs);
    return () => {
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }
    };
  }, [search, debounceMs]);

  const buildConstraints = useCallback(
    (forNextPage = false): QueryConstraint[] => {
      const constraints: QueryConstraint[] = [
        ...baseConstraints,
        orderBy(orderByField, orderDirection),
        limit(pageSize),
      ];

      const term = currentSearchRef.current;
      if (term) {
        // Firestore only supports a single array-contains per query.
        // We search for the first token; client-side filtering can refine further.
        const token = term.split(/\s+/)[0];
        constraints.unshift(where(searchField, 'array-contains', token));
      }

      if (forNextPage && lastDocRef.current) {
        constraints.push(startAfter(lastDocRef.current));
      }

      return constraints;
    },
    [baseConstraints, orderByField, orderDirection, pageSize, searchField]
  );

  const fetchPage = useCallback(
    async (forNextPage: boolean) => {
      const q = query(collection(db, path), ...buildConstraints(forNextPage));
      const snap = await getDocs(q);
      const docs = snap.docs.map((d) => ({ id: d.id, ...(d.data() as T) }));
      lastDocRef.current = snap.docs[snap.docs.length - 1] || null;
      setHasMore(snap.docs.length === pageSize);
      return docs;
    },
    [buildConstraints, path, pageSize]
  );

  const runSearch = useCallback(async () => {
    setIsLoading(true);
    lastDocRef.current = null;
    try {
      const docs = await fetchPage(false);
      setItems(docs);
    } finally {
      setIsLoading(false);
    }
  }, [fetchPage]);

  useEffect(() => {
    runSearch();
  }, [debouncedSearch, runSearch]);

  const loadMore = useCallback(async () => {
    if (isLoadingMore || !hasMore) return;
    setIsLoadingMore(true);
    try {
      const docs = await fetchPage(true);
      setItems((prev) => [...prev, ...docs]);
    } finally {
      setIsLoadingMore(false);
    }
  }, [fetchPage, hasMore, isLoadingMore]);

  const setSearch = useCallback((value: string) => {
    setSearchState(value);
  }, []);

  const refresh = useCallback(() => {
    runSearch();
  }, [runSearch]);

  return {
    items,
    isLoading,
    isLoadingMore,
    hasMore,
    search,
    setSearch,
    loadMore,
    refresh,
  };
}
