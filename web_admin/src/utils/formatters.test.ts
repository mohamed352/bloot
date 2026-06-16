import { describe, it, expect } from 'vitest';
import { formatNumber, formatCurrency, formatDate, formatRelativeTime } from './formatters';

describe('formatters', () => {
  it('formats numbers with commas', () => {
    expect(formatNumber(1234567)).toBe('1,234,567');
    expect(formatNumber(0)).toBe('0');
  });

  it('formats currency', () => {
    expect(formatCurrency(99.99)).toBe('$99.99');
  });

  it('formats Firestore timestamps', () => {
    const ts = { seconds: 1700000000, nanoseconds: 0 };
    expect(formatDate(ts)).toContain('2023');
  });

  it('formats relative time', () => {
    const now = Date.now();
    expect(formatRelativeTime(now - 60 * 1000)).toBe('1m ago');
    expect(formatRelativeTime(now - 2 * 60 * 60 * 1000)).toBe('2h ago');
  });
});
