const processId = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
let counter = 0;
export const generateLockKeyStr = () => {
    counter = (counter + 1) % 1000;
    const counterStr = counter.toString().padStart(3, '0');
    return Date.now().toString() + processId + counterStr;
};
