import { usePaginatedSearch } from './usePaginatedSearch';
import type { AppUser } from '../types';

export function useUsers(_page: number = 0, _search: string = '') {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  void _page;
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  void _search;
  // _page/_search retained for API compatibility; actual search/pagination is
  // managed by usePaginatedSearch and exposed via its return shape.
  return usePaginatedSearch<AppUser>({
    path: 'users',
    pageSize: 25,
    orderByField: 'createdAt',
    orderDirection: 'desc',
  });
}
