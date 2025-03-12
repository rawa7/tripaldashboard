-- Add media_type column to accommodation_images table
ALTER TABLE accommodation_images ADD COLUMN IF NOT EXISTS media_type text DEFAULT 'image';

-- Add thumbnail_url column for videos
ALTER TABLE accommodation_images ADD COLUMN IF NOT EXISTS thumbnail_url text;

-- Add display_order column for ordering media items
ALTER TABLE accommodation_images ADD COLUMN IF NOT EXISTS display_order integer DEFAULT 0;

-- Add comments to explain the new columns
COMMENT ON COLUMN accommodation_images.media_type IS 'Type of media (image or video)';
COMMENT ON COLUMN accommodation_images.thumbnail_url IS 'URL to thumbnail image for videos';
COMMENT ON COLUMN accommodation_images.display_order IS 'Order in which to display the media (lower numbers first)';

-- Update existing rows to have image media type
UPDATE accommodation_images SET media_type = 'image' WHERE media_type IS NULL; 