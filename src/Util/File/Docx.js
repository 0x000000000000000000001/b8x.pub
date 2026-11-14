let mammothModule;

// mammoth is loaded lazily: the library is heavy and only .docx URLs need it.
const loadMammoth = async () => {
  if (!mammothModule) mammothModule = await import("mammoth");
  return mammothModule.default ?? mammothModule;
};

// Embedded pictures are dropped until the upload pipeline supports them.
const dropImage = () => Promise.resolve({});

export const _docxToHtml = (arrayBuffer) => async () => {
  const mammoth = await loadMammoth();

  const result = await mammoth.convertToHtml(
    { buffer: Buffer.from(arrayBuffer) },
    { convertImage: mammoth.images.imgElement(dropImage) },
  );

  return result.value.replace(/<img\b[^>]*>/gi, "");
};
