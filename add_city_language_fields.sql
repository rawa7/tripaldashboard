-- Add language fields to cities table
ALTER TABLE cities 
ADD COLUMN name_ar TEXT,
ADD COLUMN name_ku TEXT,
ADD COLUMN name_bad TEXT,
ADD COLUMN description_ar TEXT,
ADD COLUMN description_ku TEXT,
ADD COLUMN description_bad TEXT;

-- Add language fields to sub_cities table
ALTER TABLE sub_cities 
ADD COLUMN name_ar TEXT,
ADD COLUMN name_ku TEXT,
ADD COLUMN name_bad TEXT,
ADD COLUMN description_ar TEXT,
ADD COLUMN description_ku TEXT,
ADD COLUMN description_bad TEXT; 