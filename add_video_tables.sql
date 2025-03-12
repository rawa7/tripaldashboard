-- Create area_videos table
CREATE TABLE IF NOT EXISTS area_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE CASCADE,
    video_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    title_ar TEXT,
    description_ar TEXT,
    title_ku TEXT,
    description_ku TEXT,
    title_bad TEXT,
    description_bad TEXT,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create accommodation_videos table
CREATE TABLE IF NOT EXISTS accommodation_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    accommodation_id UUID NOT NULL REFERENCES accommodations(id) ON DELETE CASCADE,
    video_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    title_ar TEXT,
    description_ar TEXT,
    title_ku TEXT,
    description_ku TEXT,
    title_bad TEXT,
    description_bad TEXT,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create activity_videos table
CREATE TABLE IF NOT EXISTS activity_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    video_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    title_ar TEXT,
    description_ar TEXT,
    title_ku TEXT,
    description_ku TEXT,
    title_bad TEXT,
    description_bad TEXT,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_area_videos_area_id ON area_videos(area_id);
CREATE INDEX IF NOT EXISTS idx_accommodation_videos_accommodation_id ON accommodation_videos(accommodation_id);
CREATE INDEX IF NOT EXISTS idx_activity_videos_activity_id ON activity_videos(activity_id);

-- Add triggers to ensure only one primary video per entity
CREATE OR REPLACE FUNCTION ensure_single_primary_video() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_primary THEN
        CASE
            WHEN TG_TABLE_NAME = 'area_videos' THEN
                UPDATE area_videos SET is_primary = false
                WHERE area_id = NEW.area_id AND id != NEW.id;
            WHEN TG_TABLE_NAME = 'accommodation_videos' THEN
                UPDATE accommodation_videos SET is_primary = false
                WHERE accommodation_id = NEW.accommodation_id AND id != NEW.id;
            WHEN TG_TABLE_NAME = 'activity_videos' THEN
                UPDATE activity_videos SET is_primary = false
                WHERE activity_id = NEW.activity_id AND id != NEW.id;
        END CASE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_single_primary_area_video
BEFORE INSERT OR UPDATE ON area_videos
FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_video();

CREATE TRIGGER ensure_single_primary_accommodation_video
BEFORE INSERT OR UPDATE ON accommodation_videos
FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_video();

CREATE TRIGGER ensure_single_primary_activity_video
BEFORE INSERT OR UPDATE ON activity_videos
FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_video(); 