import crypto from 'node:crypto';

export function anonymizeString(str: string): string {
  return crypto
    .createHash('md5')
    .update(str)
    .digest('hex');
}

export function createTokenCacheKey(token: string): string {
  return `token:${token}`;
}

export function createSuggestionCacheKey(token: string): string {
  return `suggestion:${token}`;
}

export async function delay(time: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, time));
}

export async function retry<T>(fn: () => Promise<T>, maxTries = 3): Promise<T> {
  try {
    return await fn();
  } catch (error: unknown) {
    if (maxTries > 0) {
      return retry(fn, maxTries - 1);
    }
    throw error;
  }
}
