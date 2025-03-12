-- Add language fields to accommodation_bookings table
ALTER TABLE accommodation_bookings 
ADD COLUMN special_requests_ar TEXT,
ADD COLUMN special_requests_ku TEXT,
ADD COLUMN special_requests_bad TEXT;

-- Add language fields to status fields if needed (uncomment if these need translation)
-- ALTER TABLE accommodation_bookings 
-- ADD COLUMN status_ar TEXT,
-- ADD COLUMN status_ku TEXT,
-- ADD COLUMN status_bad TEXT,
-- ADD COLUMN payment_status_ar TEXT,
-- ADD COLUMN payment_status_ku TEXT,
-- ADD COLUMN payment_status_bad TEXT,
-- ADD COLUMN payment_method_ar TEXT,
-- ADD COLUMN payment_method_ku TEXT,
-- ADD COLUMN payment_method_bad TEXT;

-- Note: The status, payment_status, and payment_method fields are likely system values
-- that would be translated in the application rather than stored in multiple languages.
-- If these are user-facing values that need translation, uncomment the above section. 