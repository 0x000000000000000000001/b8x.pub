import { isNode } from '../Util.Runtime/index.js'

let driverModule;

if (isNode) driverModule = await import(/* @vite-ignore */ '../Affjax.Node/index.js');
else driverModule = await import('../Affjax.Web/index.js'); // We don't import Affjax Node in the browser (in purs or js, because xhr2 would not be accepted)

export const _driver = driverModule.driver;