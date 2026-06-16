import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Badge } from './Badge';

describe('Badge', () => {
  it('renders children', () => {
    render(<Badge>Test</Badge>);
    expect(screen.getByText('Test')).toBeInTheDocument();
  });

  it('renders live indicator', () => {
    render(<Badge variant="live">Live</Badge>);
    expect(screen.getByText('Live')).toBeInTheDocument();
  });
});
