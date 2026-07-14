import { isNode } from '../Util.Runtime/index.js'

const beforeOutput = import.meta.url.split('/output/')[0].replace(/\/run\/bak\/(js|php)$/, '');

export const _rootDirAbsolutePath = (isNode ? beforeOutput.split('file://')[1] : beforeOutput) + '/';
