import { Suspense, lazy } from 'react';
import { Spinner } from '../Spinner';
import type { ChartProps } from './types';

const LazyLine = lazy(() => import('./LazyLine'));
const LazyBar = lazy(() => import('./LazyBar'));
const LazyDoughnut = lazy(() => import('./LazyDoughnut'));

function ChartWrapper({ children }: { children: React.ReactNode }) {
  return (
    <Suspense fallback={<Spinner className="py-4" />}>
      {children}
    </Suspense>
  );
}

export function LineChart(props: ChartProps<'line'>) {
  return (
    <ChartWrapper>
      <LazyLine {...props} />
    </ChartWrapper>
  );
}

export function BarChart(props: ChartProps<'bar'>) {
  return (
    <ChartWrapper>
      <LazyBar {...props} />
    </ChartWrapper>
  );
}

export function DoughnutChart(props: ChartProps<'doughnut'>) {
  return (
    <ChartWrapper>
      <LazyDoughnut {...props} />
    </ChartWrapper>
  );
}
