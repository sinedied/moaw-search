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

export async function delay(time: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, time));
}
