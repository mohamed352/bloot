import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ImageUpload } from './ImageUpload';

describe('ImageUpload', () => {
  it('renders label and choose file button', () => {
    render(<ImageUpload label="Avatar" onFileSelect={vi.fn()} />);
    expect(screen.getByText('Avatar')).toBeInTheDocument();
    expect(screen.getByText('Choose File')).toBeInTheDocument();
  });

  it('shows error for non-image file', () => {
    const onFileSelect = vi.fn();
    render(<ImageUpload onFileSelect={onFileSelect} />);

    const input = screen.getByTestId('image-upload-input') as HTMLInputElement;
    const file = new File(['content'], 'doc.txt', { type: 'text/plain' });
    fireEvent.change(input, { target: { files: [file] } });

    expect(screen.getByText('Please select an image file')).toBeInTheDocument();
    expect(onFileSelect).toHaveBeenCalledWith(null);
  });

  it('shows error for oversized image', () => {
    const onFileSelect = vi.fn();
    render(<ImageUpload onFileSelect={onFileSelect} maxSizeMB={0.001} />);

    const input = screen.getByTestId('image-upload-input') as HTMLInputElement;
    const file = new File(['x'.repeat(2048)], 'big.png', { type: 'image/png' });
    fireEvent.change(input, { target: { files: [file] } });

    expect(screen.getByText('Image must be smaller than 0.001 MB')).toBeInTheDocument();
    expect(onFileSelect).toHaveBeenCalledWith(null);
  });

  it('calls onFileSelect with image file', () => {
    const onFileSelect = vi.fn();
    render(<ImageUpload onFileSelect={onFileSelect} />);

    const input = screen.getByTestId('image-upload-input') as HTMLInputElement;
    const file = new File(['content'], 'avatar.png', { type: 'image/png' });
    fireEvent.change(input, { target: { files: [file] } });

    expect(onFileSelect).toHaveBeenCalledWith(file);
  });
});
