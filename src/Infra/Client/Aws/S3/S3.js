import {
  S3Client,
  PutObjectCommand,
  HeadObjectCommand,
} from "@aws-sdk/client-s3";
import sizeOf from "image-size";
import crypto from "node:crypto";
import sharp from "sharp";
import { JSDOM } from "jsdom";

// These SDK operations cannot be aborted through the previous Promise bridge.
const runAsync = (operation) => (onError, onSuccess) => {
  operation().then(onSuccess, onError);
  return (_cancelError, _onCancelError, onCancelSuccess) => onCancelSuccess();
};

export const _createInnerClient = (
  region,
  accessKeyId,
  secretAccessKey,
) => {
  return new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });
};

async function uploadUrlContent(
  client,
  bucket,
  isPublic,
  bucketDirectory,
  autocropBlackWhite,
  autocropTransparent,
  url,
  mimeTypeToExtension,
) {
  const response = await fetch(url, {
    headers: {
      // Emulates a browser to bypass anti-scraping protections (e.g. Cloudflare WAF)
      // that often block default requests from servers (fetch/Node.js).
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    },
  });

  if (!response.ok) {
    throw new Error(
      `Failed to fetch image from ${url}: ${response.statusText}`,
    );
  }

  const arrayBuffer = await response.arrayBuffer();
  let buf = Buffer.from(arrayBuffer);

  // We strictly target white, black, and transparent borders by specifying the background explicitly.
  // A threshold of 12 is robust enough to handle JPEG compression artifacts.
  if (autocropBlackWhite) {
    buf = await sharp(buf)
      .trim({ background: "#ffffff", threshold: 12 })
      .toBuffer();
    buf = await sharp(buf)
      .trim({ background: "#000000", threshold: 12 })
      .toBuffer();
  }
  if (autocropTransparent) {
    buf = await sharp(buf)
      .trim({ background: "rgba(0,0,0,0)", threshold: 12 })
      .toBuffer();
  }

  const dimensions = sizeOf(buf);

  let mimeType = response.headers.get("content-type");
  if (mimeType && mimeType.includes("text/html")) {
    throw new Error("Skipping HTML content for S3 upload");
  }

  if (
    !mimeType ||
    mimeType === "application/octet-stream" ||
    mimeType === "application/x-empty"
  ) {
    if (dimensions && dimensions.type) {
      if (dimensions.type === "jpg") {
        mimeType = "image/jpeg";
      } else {
        mimeType = `image/${dimensions.type}`;
      }
    }
  }

  const extension = mimeTypeToExtension(mimeType);

  const hash = crypto.createHash("sha256").update(buf).digest("hex");

  const key = `${isPublic ? "public" : "private"}/${bucketDirectory}/${hash}.${extension}`;

  const result = {
    src: key,
    hash,
    mimeType,
    size: buf.length,
    dimensions,
  };

  try {
    await client.send(new HeadObjectCommand({ Bucket: bucket, Key: key }));
    // If no exception is thrown, the object already exists!
    return result;
  } catch (e) {
    if (e.name !== "NotFound" && e.$metadata?.httpStatusCode !== 404) {
      console.error("[S3] Error during HeadObject check:", e);
      // We proceed to upload if we are not sure, but it is better to at least log it.
    }
  }

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: buf,
    ContentType: mimeType,
  });

  try {
    await client.send(command);
  } catch (e) {
    console.error("=== S3 UPLOAD FAILED ===");
    console.error("Target Bucket:", bucket);
    console.error("Target Key:", key);
    console.error("Content Type:", mimeType);
    console.error("Error Object:", e);
    if (e.$metadata)
      console.error("AWS Metadata:", JSON.stringify(e.$metadata, null, 2));
    console.error("========================");
    throw e;
  }

  return result;
}

export const _uploadUrlContentImpl =
  (client) =>
  (bucket) =>
  (isPublic) =>
  (bucketDirectory) =>
  (autocropBlackWhite) =>
  (autocropTransparent) =>
  (url) =>
  (mimeTypeToExtension) =>
    runAsync(() =>
      uploadUrlContent(
        client,
        bucket,
        isPublic,
        bucketDirectory,
        autocropBlackWhite,
        autocropTransparent,
        url,
        mimeTypeToExtension,
      ),
    );

export const _uploadHtmlUrlContentsImpl =
  (client) =>
  (bucket) =>
  (isPublic) =>
  (bucketDirectory) =>
  (mimeTypeToExtension) =>
  (shouldRelativize) =>
  (host) =>
  (legacyHost) =>
  (contentHtml) =>
    runAsync(async () => {
      if (!contentHtml) return contentHtml;

      const fragment = JSDOM.fragment(contentHtml);
      const elements = fragment.querySelectorAll("img[src], a[href]");

      for (const el of elements) {
        const isImg = el.tagName.toLowerCase() === "img";
        let url = isImg ? el.getAttribute("src") : el.getAttribute("href");

        if (!url || url.startsWith("data:") || url.startsWith("#")) {
          continue;
        }

        let urlsToTry = [url];
        if (url.startsWith("/")) {
          urlsToTry = [`${legacyHost}${url}`, `${host}${url}`];
        } else if (!url.startsWith("http")) {
          if (url.startsWith("mailto:")) continue;
          urlsToTry = [`${legacyHost}/${url}`, `${host}/${url}`];
        }

        let result = null;
        for (const testUrl of urlsToTry) {
          try {
            result = await uploadUrlContent(
              client,
              bucket,
              isPublic,
              bucketDirectory,
              false,
              false,
              testUrl,
              mimeTypeToExtension,
            );
            if (result && result.src) {
              break; // Success!
            }
          } catch (e) {
            // Ignore and try next URL
          }
        }

        if (result && result.src) {
          if (isImg) {
            el.setAttribute("src", result.src);
          } else {
            el.setAttribute("href", result.src);
          }
        }
      }

      const tempDom = new JSDOM();
      const div = tempDom.window.document.createElement("div");
      div.appendChild(fragment);
      return div.innerHTML;
    });
