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

export const _parseParisTime = (just) => (nothing) => (year) => (month) => (day) => (hour) => (minute) => {
  const dStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}T${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}:00`;
  const baseDate = new Date(`${dStr}Z`);
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Europe/Paris',
    timeZoneName: 'shortOffset'
  }).formatToParts(baseDate);
  const tzPart = parts.find(p => p.type === 'timeZoneName').value;
  
  let offsetStr = "+01:00";
  if (tzPart === "GMT+2") offsetStr = "+02:00";
  
  const finalStr = `${dStr}${offsetStr}`;
  const ms = Date.parse(finalStr);
  if (isNaN(ms)) return nothing;
  
  return just(new Date(ms).toISOString());
};
