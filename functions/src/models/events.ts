import { GameEvent } from './game';

export function createEvent(
  type: GameEvent['type'],
  seatIndex: number,
  data: Record<string, unknown> = {},
): Omit<GameEvent, 'timestamp'> {
  return {
    type,
    seatIndex,
    data,
  };
}
