import crypto from 'crypto';

export const _md5 = (str) => crypto.createHash('md5').update(str).digest('hex');

export const _sha256 = (str) => crypto.createHash('sha256').update(str).digest('hex');

let xxHashAPI = null;

export const _xxhash64 = (str) => async () => {
  if (!xxHashAPI) {
    const xxhashModule = await import('xxhash-wasm');
    xxHashAPI = await xxhashModule.default();
  }
  return xxHashAPI.h64(str).toString(16);
};

export const hmacSha256 = secret => message => crypto.createHmac('sha256', secret).update(message).digest('hex');
