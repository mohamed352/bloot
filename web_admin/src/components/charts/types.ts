import type { ChartData, ChartOptions, ChartTypeRegistry } from 'chart.js';

export interface ChartProps<T extends keyof ChartTypeRegistry> {
  data: ChartData<T>;
  options?: ChartOptions<T>;
  height?: number;
}
