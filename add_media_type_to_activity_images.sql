-- Add media_type column to activity_images table
ALTER TABLE activity_images ADD COLUMN IF NOT EXISTS media_type TEXT DEFAULT 'image';

-- Add thumbnail_url column to activity_images table
ALTER TABLE activity_images ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- Update existing records to have media_type = 'image'
UPDATE activity_images SET media_type = 'image' WHERE media_type IS NULL;

-- Add comment to explain the purpose of these columns
COMMENT ON COLUMN activity_images.media_type IS 'Type of media (image or video)';
COMMENT ON COLUMN activity_images.thumbnail_url IS 'URL to thumbnail image for videos';

-- Create an index on media_type for faster queries
CREATE INDEX IF NOT EXISTS idx_activity_images_media_type ON activity_images(media_type); 