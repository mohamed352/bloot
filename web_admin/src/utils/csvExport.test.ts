import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { generateCsvContent, exportToCsv } from './csvExport';

describe('generateCsvContent', () => {
  it('exports rows with correct headers', () => {
    const content = generateCsvContent([{ name: 'Alice', age: 30 }], [
      { key: 'name', header: 'Name' },
      { key: 'age', header: 'Age' },
    ]);
    expect(content).toContain('Name,Age');
    expect(content).toContain('Alice,30');
  });

  it('escapes commas and quotes', () => {
    const content = generateCsvContent([{ value: 'Hello, "world"' }], [{ key: 'value', header: 'Value' }]);
    expect(content).toContain('"Hello, ""world"""');
  });

  it('handles null values', () => {
    const content = generateCsvContent([{ value: null }], [{ key: 'value', header: 'Value' }]);
    expect(content).toContain('Value\r\n');
  });

  it('adds UTF-8 BOM', () => {
    const content = generateCsvContent([{ value: 'test' }], [{ key: 'value', header: 'Value' }]);
    expect(content.charCodeAt(0)).toBe(0xfeff);
  });
});

describe('exportToCsv', () => {
  const createObjectURL = vi.fn(() => 'blob:url');
  const revokeObjectURL = vi.fn();

  beforeEach(() => {
    global.URL.createObjectURL = createObjectURL;
    global.URL.revokeObjectURL = revokeObjectURL;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('creates a blob and triggers download', () => {
    const clickSpy = vi.fn();
    const mockLink = document.createElement('a');
    mockLink.click = clickSpy;
    vi.spyOn(document, 'createElement').mockReturnValue(mockLink);
    vi.spyOn(document.body, 'appendChild').mockImplementation(() => mockLink);
    vi.spyOn(document.body, 'removeChild').mockImplementation(() => mockLink);

    exportToCsv('test.csv', [{ name: 'Alice' }], [{ key: 'name', header: 'Name' }]);

    expect(createObjectURL).toHaveBeenCalled();
    expect(mockLink.download).toBe('test.csv');
    expect(clickSpy).toHaveBeenCalled();
  });

  it('adds .csv extension if missing', () => {
    const mockLink = document.createElement('a');
    vi.spyOn(document, 'createElement').mockReturnValue(mockLink);
    vi.spyOn(document.body, 'appendChild').mockImplementation(() => mockLink);
    vi.spyOn(document.body, 'removeChild').mockImplementation(() => mockLink);

    exportToCsv('test', [{ name: 'Alice' }], [{ key: 'name', header: 'Name' }]);
    expect(mockLink.download).toBe('test.csv');
  });

  it('does nothing when rows are empty', () => {
    exportToCsv('test.csv', [], [{ key: 'x', header: 'X' }]);
    expect(createObjectURL).not.toHaveBeenCalled();
  });
});
