import sharp from "sharp";

const width = 1200;
const height = 630;

export const _watermarkImage = position => scalePct => showLogo => imageBuffer => logoPath => async () => {
    try {
        const image = sharp(imageBuffer);
        const metadata = await image.metadata();
        
        const originalRatio = metadata.width / metadata.height;
        const isLandscape = originalRatio >= 1.2;

        const stats = await image.stats();
        const r = stats.channels[0].mean;
        const g = stats.channels[1].mean;
        const b = stats.channels[2].mean;
        // Standard perceived luminance formula
        const luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        const isDark = luminance < 100; // Threshold for considering the image 'dark'
        
        let backgroundBuffer;
        let foregroundBuffer;

        if (isLandscape) {
            // For landscape images, a simple cover crop is usually perfect
            backgroundBuffer = await sharp(imageBuffer)
                .resize({ width, height, fit: 'cover' })
                .toBuffer();
            foregroundBuffer = null; // No foreground needed, background is the image
        } else {
            // 1. Premium background: blurred 'cover' version of the image
            backgroundBuffer = await sharp(imageBuffer)
                .resize({ width, height, fit: 'cover' })
                .blur(45) // heavy blur
                .toBuffer();

            // 2. Foreground: the actual image 'contained' without clipping, on a transparent background
            // MUST be saved as PNG to preserve transparency (alpha: 0), otherwise JPEG saves it as black.
            foregroundBuffer = await sharp(imageBuffer)
                .resize({ width, height, fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
                .png()
                .toBuffer();
        }

        const compositeOperations = [];
        
        if (foregroundBuffer) {
            // Adapt the frosted glass effect to the image's brightness
            const overlayColor = isDark ? "rgba(0, 0, 0, 0.5)" : "rgba(255, 255, 255, 0.4)";
            const frostedOverlay = `<svg width="${width}" height="${height}"><rect width="${width}" height="${height}" fill="${overlayColor}"/></svg>`;
            compositeOperations.push({ input: Buffer.from(frostedOverlay), top: 0, left: 0 });
            
            compositeOperations.push({ input: foregroundBuffer });
        }

        if (showLogo) {
            const logoWidth = Math.round(250 * (scalePct / 100)); // Fixed width, scaled by scalePct
            
            const logoMetadata = await sharp(logoPath).metadata();
            const logoRatio = logoMetadata.height / logoMetadata.width;
            const logoHeight = Math.round(logoWidth * logoRatio);
            
            // The SVG has massive internal margins
            // We use natural spacing on sides, and slightly decrease top and bottom.
            const trimLeft = 0;
            const trimRight = 0;
            const trimTop = Math.round(logoHeight * 0.07);
            const trimBottom = Math.round(logoHeight * 0.07);

            const rectWidth = logoWidth - trimLeft - trimRight;
            const rectHeight = logoHeight - trimTop - trimBottom;
            const rx = Math.round(rectHeight * 0.15); // 15% of height for the rounded corner
            
            const rectX = position === "BottomRight" ? width - rectWidth : position === "BottomCenter" ? Math.round((width - rectWidth) / 2) : 0;
            const rectY = position === "TopLeft" ? 0 : height - rectHeight;
            
            const logoX = position === "BottomRight" ? rectX - trimLeft : position === "BottomCenter" ? rectX - trimLeft : -trimLeft;
            const logoY = position === "TopLeft" ? -trimTop : rectY - trimTop;

            const svgPath = 
                position === "TopLeft" ? `
                    M 0 0
                    L ${rectWidth} 0
                    L ${rectWidth} ${rectHeight - rx}
                    A ${rx} ${rx} 0 0 1 ${rectWidth - rx} ${rectHeight}
                    L 0 ${rectHeight}
                    Z
                ` : position === "BottomRight" ? `
                    M ${width} ${height}
                    L ${rectX} ${height}
                    L ${rectX} ${rectY + rx}
                    A ${rx} ${rx} 0 0 1 ${rectX + rx} ${rectY}
                    L ${width} ${rectY}
                    Z
                ` : position === "BottomCenter" ? `
                    M ${rectX} ${height}
                    L ${rectX} ${rectY + rx}
                    A ${rx} ${rx} 0 0 1 ${rectX + rx} ${rectY}
                    L ${rectX + rectWidth - rx} ${rectY}
                    A ${rx} ${rx} 0 0 1 ${rectX + rectWidth} ${rectY + rx}
                    L ${rectX + rectWidth} ${height}
                    Z
                ` : `
                    M 0 ${height}
                    L 0 ${rectY}
                    L ${rectWidth - rx} ${rectY}
                    A ${rx} ${rx} 0 0 1 ${rectWidth} ${rectY + rx}
                    L ${rectWidth} ${height}
                    Z
                `;

            const svg = `
                <svg width="${width}" height="${height}">
                    <path 
                        d="${svgPath}" 
                        fill="rgba(255, 255, 255, 0.65)" 
                    />
                </svg>
            `;

            const resizedLogo = await sharp(logoPath)
                .resize({ 
                    width: logoWidth,
                    kernel: sharp.kernel.lanczos3
                })
                .toBuffer();

            compositeOperations.push({ input: Buffer.from(svg), top: 0, left: 0 });
            compositeOperations.push({ input: resizedLogo, top: Math.round(logoY), left: Math.round(logoX) });
        }

        const finalImage = await sharp(backgroundBuffer)
            .composite(compositeOperations)
            .jpeg({ quality: 95, chromaSubsampling: '4:4:4' })
            .toBuffer();

        return finalImage;
    } catch (e) {
        console.error("Watermark generation error:", e);
        throw e;
    }
};

export const _sendImage = res => buffer => () => {
    res.statusCode = 200;
    res.setHeader("Content-Type", "image/jpeg");
    res.setHeader("Cache-Control", "public, max-age=86400");
    res.end(buffer);
};

import fs from "fs";

export const _defaultImage = logoPath => async () => {
    try {
        return await fs.promises.readFile(logoPath);
    } catch (e) {
        console.error("Default image read error:", e);
        throw e;
    }
};
