let zipModule;
let xxHashAPI;
const loadCache = new Map();
const htmlCache = new WeakMap();

async function loadZip(zipContent) {
  if (!zipModule) {
    // The distribution path is also available in browser builds.
    zipModule = await import('../../node_modules/jszip/dist/jszip.js');
  }
  if (!xxHashAPI) {
    const xxhashModule = await import('../../node_modules/xxhash-wasm/esm/xxhash-wasm.js');
    xxHashAPI = await xxhashModule.default();
  }
  const bytes = new Uint8Array(zipContent);
  const cacheKey = xxHashAPI.h32Raw(bytes);
  if (!loadCache.has(cacheKey)) {
    const JSZip = zipModule.default || window.JSZip;
    loadCache.set(cacheKey, await new JSZip().loadAsync(bytes, { base64: false }));
  }
  return loadCache.get(cacheKey);
}

async function extractHtml(filename, zipContent) {
  const zip = await loadZip(zipContent);
  const targetName = filename + '.html';
  const targetFile = Object.keys(zip.files).find((name) =>
    filename ? name === targetName : name.endsWith('.html'),
  );
  if (!targetFile) {
    throw new Error(
      filename ? `File '${targetName}' not found in ZIP` : 'No HTML file found in ZIP',
    );
  }
  if (!htmlCache.has(zip)) htmlCache.set(zip, new Map());
  const files = htmlCache.get(zip);
  if (!files.has(targetFile)) files.set(targetFile, await zip.files[targetFile].async('string'));
  return files.get(targetFile);
}

async function extractDirectory(outputPath, zipContent) {
  const { mkdir, writeFile } = await import(/* @vite-ignore */ 'fs/promises');
  const path = await import(/* @vite-ignore */ 'path');
  const zip = await loadZip(zipContent);
  await mkdir(outputPath, { recursive: true });
  for (const [filename, file] of Object.entries(zip.files)) {
    const filePath = path.join(outputPath, filename);
    if (file.dir) {
      await mkdir(filePath, { recursive: true });
    } else {
      await mkdir(path.dirname(filePath), { recursive: true });
      await writeFile(filePath, await file.async('nodebuffer'));
    }
  }
}

export const _unzipGoogleSheetAndExtractHtml =
  (filename) => (zipContent) => (onError, onSuccess) => {
    extractHtml(filename, zipContent).then(onSuccess, onError);
    return (_reason, _onCancelerError, onCancelerSuccess) => onCancelerSuccess();
  };

export const _unzipToDirectory = (outputPath) => (zipContent) => (onError, onSuccess) => {
  extractDirectory(outputPath, zipContent).then(onSuccess, onError);
  return (_reason, _onCancelerError, onCancelerSuccess) => onCancelerSuccess();
};
