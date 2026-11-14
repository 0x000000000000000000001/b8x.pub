import { V3 } from 'paseto';
import crypto from 'crypto';

export const encryptV3LocalImpl = (keyHex) => (payload) => (expiresIn) => (onError, onSuccess) => {
  const encrypt = async () => {
    const keyBuffer = Buffer.from(keyHex, 'hex');
    if (keyBuffer.length !== 32) {
      throw new Error('Paseto V3 local key must be exactly 32 bytes (64 hex characters)');
    }
    return V3.encrypt(payload, crypto.createSecretKey(keyBuffer), { expiresIn });
  };
  encrypt().then(onSuccess, onError);
  return (_reason, _onCancelerError, onCancelerSuccess) => onCancelerSuccess();
};

export const decryptV3LocalImpl = (keyHex) => (token) => (onError, onSuccess) => {
  const decrypt = async () => V3.decrypt(token, crypto.createSecretKey(Buffer.from(keyHex, 'hex')));
  decrypt().then(onSuccess, onError);
  return (_reason, _onCancelerError, onCancelerSuccess) => onCancelerSuccess();
};
