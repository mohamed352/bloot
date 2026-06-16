function escapeCell(value: unknown): string {
  if (value === null || value === undefined) return '';
  const str = String(value).replace(/"/g, '""');
  if (str.includes(',') || str.includes('"') || str.includes('\n') || str.includes('\r')) {
    return `"${str}"`;
  }
  return str;
}

export function generateCsvContent(
  rows: Record<string, unknown>[],
  columns: { key: string; header: string }[]
): string {
  const header = columns.map((c) => escapeCell(c.header)).join(',');
  const lines = rows.map((row) =>
    columns.map((c) => escapeCell(row[c.key])).join(',')
  );
  // UTF-8 BOM for Excel Arabic support
  return '\uFEFF' + [header, ...lines].join('\r\n');
}

export function exportToCsv(
  filename: string,
  rows: Record<string, unknown>[],
  columns: { key: string; header: string }[]
): void {
  if (rows.length === 0) {
    return;
  }

  const csvContent = generateCsvContent(rows, columns);
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);

  const link = document.createElement('a');
  link.href = url;
  link.download = filename.endsWith('.csv') ? filename : `${filename}.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
