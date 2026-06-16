import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
} from 'chart.js';
import { Doughnut } from 'react-chartjs-2';
import type { ChartProps } from './types';

ChartJS.register(
  ArcElement,
  Tooltip,
  Legend
);

export default function LazyDoughnut(props: ChartProps<'doughnut'>) {
  return <Doughnut {...props} />;
}
