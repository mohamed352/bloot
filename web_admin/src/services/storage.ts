import {
  ref,
  uploadBytes,
  getDownloadURL,
  type UploadMetadata,
} from 'firebase/storage';
import { storage } from './firebase';

const MAX_IMAGE_SIZE_BYTES = 2 * 1024 * 1024; // 2 MB

export async function uploadImage(
  path: string,
  file: File,
  metadata?: Record<string, string>
): Promise<string> {
  if (!file.type.startsWith('image/')) {
    throw new Error('Only image files are allowed');
  }
  if (file.size > MAX_IMAGE_SIZE_BYTES) {
    throw new Error('Image must be smaller than 2 MB');
  }

  const fileRef = ref(storage, path);
  const uploadMetadata: UploadMetadata = {
    contentType: file.type,
    customMetadata: metadata,
  };

  await uploadBytes(fileRef, file, uploadMetadata);
  return getDownloadURL(fileRef);
}
