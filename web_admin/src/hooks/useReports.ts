import { where } from 'firebase/firestore';
import { usePaginatedSearch } from './usePaginatedSearch';
import type { Report } from '../types';

export function useReports(status?: Report['status'], _search: string = '') {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  void _search;
  // _search retained for API compatibility; actual search is managed by
  // usePaginatedSearch and exposed via its return shape.
  return usePaginatedSearch<Report>({
    path: 'reports',
    baseConstraints: status ? [where('status', '==', status)] : [],
    pageSize: 25,
    orderByField: 'createdAt',
    orderDirection: 'desc',
  });
}
