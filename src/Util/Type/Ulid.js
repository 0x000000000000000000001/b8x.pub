import { ulid, isValid } from "ulid";

export const _generateUlid = () => ulid().toLowerCase();
export const _isValid = isValid;
