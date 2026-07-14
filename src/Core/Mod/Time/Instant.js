export const _toIsoString = function (ms) {
  return new Date(ms).toISOString();
};

export const _parseIsoString = (just) => (nothing) => (str) => {
  const ms = Date.parse(str);
  if (isNaN(ms)) return nothing;
  return just(ms);
};

export const _toHumanParisDate = function (ms) {
  return new Intl.DateTimeFormat('fr-FR', {
    timeZone: 'Europe/Paris',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(new Date(ms));
};

export const _toSendyScheduleDate = function (ms) {
  const d = new Date(ms);
  const parts = new Intl.DateTimeFormat("fr-FR", {
    timeZone: "Europe/Paris",
    year: "numeric", month: "2-digit", day: "2-digit",
    hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false
  }).formatToParts(d);
  const get = (type) => parts.find(p => p.type === type).value;
  return `${get("year")}-${get("month")}-${get("day")} ${get("hour")}:${get("minute")}:${get("second")}`;
};
