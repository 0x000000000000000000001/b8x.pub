import { V3 } from "paseto";
import crypto from "crypto";

export const encryptV3LocalImpl = function (keyStr) {
  return function (payload) {
    return function (expiresInStr) {
      return function () {
        return new Promise(function (resolve, reject) {
          try {
            // keyStr should be a 64-character hex string (32 bytes)
            const keyBuffer = Buffer.from(keyStr, 'hex');
            if (keyBuffer.length !== 32) {
              throw new Error("Paseto V3 local key must be exactly 32 bytes (64 hex characters)");
            }
            const secretKey = crypto.createSecretKey(keyBuffer);
            V3.encrypt(payload, secretKey, { expiresIn: expiresInStr })
              .then(resolve)
              .catch(reject);
          } catch (e) {
            reject(e);
          }
        });
      };
    };
  };
};

export const decryptV3LocalImpl = function (keyStr) {
  return function (token) {
    return function () {
      return new Promise(function (resolve, reject) {
        try {
          const keyBuffer = Buffer.from(keyStr, 'hex');
          const secretKey = crypto.createSecretKey(keyBuffer);
          V3.decrypt(token, secretKey)
            .then(resolve)
            .catch(reject);
        } catch (e) {
          reject(e);
        }
      });
    };
  };
};
