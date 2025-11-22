import sharp from 'sharp';

export const compressAndResizeImage = async (imageBuffer: Buffer): Promise<string> => {
  try {
    const compressedBuffer = await sharp(imageBuffer)
      .resize(800, 600, { // Resize ke maksimal 800x600
        fit: 'inside',
        withoutEnlargement: true
      })
      .jpeg({ 
        quality: 80, // Kompres kualitas 80%
        mozjpeg: true 
      })
      .toBuffer();

    return compressedBuffer.toString('base64');
  } catch (error) {
    console.error('Image compression error:', error);
    // Jika kompresi gagal, return original base64
    return imageBuffer.toString('base64');
  }
};