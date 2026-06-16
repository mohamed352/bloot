import { useEffect, useState, useRef } from 'react';
import { Button } from './Button';

interface ImageUploadProps {
  id?: string;
  label?: string;
  previewUrl?: string;
  onFileSelect: (file: File | null) => void;
  accept?: string;
  maxSizeMB?: number;
}

export function ImageUpload({
  id,
  label,
  previewUrl,
  onFileSelect,
  accept = 'image/*',
  maxSizeMB = 2,
}: ImageUploadProps) {
  const [preview, setPreview] = useState<string | undefined>(previewUrl);
  const [error, setError] = useState<string | null>(null);
  const [objectUrl, setObjectUrl] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!objectUrl) {
      setPreview(previewUrl);
    }
  }, [previewUrl, objectUrl]);

  useEffect(() => {
    return () => {
      if (objectUrl) {
        URL.revokeObjectURL(objectUrl);
      }
    };
  }, [objectUrl]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    setError(null);

    if (!file) {
      setPreview(previewUrl);
      onFileSelect(null);
      return;
    }

    if (!file.type.startsWith('image/')) {
      setError('Please select an image file');
      onFileSelect(null);
      return;
    }

    if (file.size > maxSizeMB * 1024 * 1024) {
      setError(`Image must be smaller than ${maxSizeMB} MB`);
      onFileSelect(null);
      return;
    }

    if (objectUrl) {
      URL.revokeObjectURL(objectUrl);
      setObjectUrl(null);
    }

    onFileSelect(file);

    if (typeof URL !== 'undefined' && URL.createObjectURL) {
      const url = URL.createObjectURL(file);
      setObjectUrl(url);
      setPreview(url);
    } else {
      const reader = new FileReader();
      reader.onloadend = () => setPreview(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  const handleClear = () => {
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl);
      setObjectUrl(null);
    }
    setPreview(previewUrl);
    setError(null);
    onFileSelect(null);
    if (inputRef.current) inputRef.current.value = '';
  };

  return (
    <div>
      {label && (
        <label className="block text-xs text-b-on-surface-muted mb-1">{label}</label>
      )}
      <input
        ref={inputRef}
        id={id}
        data-testid="image-upload-input"
        type="file"
        accept={accept}
        onChange={handleChange}
        className="hidden"
      />
      <div className="flex items-center gap-4">
        {preview ? (
          <div className="relative">
            <img
              src={preview}
              alt="Preview"
              className="w-20 h-20 object-cover rounded-lg border border-b-border"
            />
            <button
              type="button"
              onClick={handleClear}
              className="absolute -top-2 -right-2 w-5 h-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center"
            >
              ×
            </button>
          </div>
        ) : (
          <div className="w-20 h-20 rounded-lg border border-dashed border-b-border bg-b-surface flex items-center justify-center text-b-on-surface-muted text-xs text-center">
            No image
          </div>
        )}
        <Button
          type="button"
          variant="secondary"
          size="sm"
          onClick={() => inputRef.current?.click()}
        >
          Choose File
        </Button>
      </div>
      {error && <p className="text-xs text-red-400 mt-1">{error}</p>}
    </div>
  );
}
