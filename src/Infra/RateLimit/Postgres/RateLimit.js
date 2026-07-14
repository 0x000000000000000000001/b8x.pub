import rlf from 'rate-limiter-flexible';

const { RateLimiterPostgres } = rlf;

let limiters = {};

export const _consume = (client) => (key) => (points) => (durationSec) => async () => {
  let limiterKey = points + '_' + durationSec;
  if (!limiters[limiterKey]) {
    limiters[limiterKey] = new RateLimiterPostgres({
      storeClient: client,
      tableName: 'rate_limit',
      tableCreated: true,
      points: points,
      duration: durationSec,
    });
  }
  
  try {
    await limiters[limiterKey].consume(key, 1);
    return true;
  } catch (res) {
    if (res instanceof Error) {
      throw res;
    }
    return false;
  }
};
