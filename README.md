# tripaldashboard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


// This Flutter project is called "Tripal Dashboard"
// It is a companion app for the "Tripal" hotel and activity reservation app.
// The Tripal Dashboard allows places to add their photos.

// make all files organized in module screens and master data 


here is my supabase tables 
[
  {
    "table_name": "accommodation_availability",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_availability",
    "column_name": "accommodation_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_availability",
    "column_name": "start_time",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_availability",
    "column_name": "end_time",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_availability",
    "column_name": "is_available",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodation_availability",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "user_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "accommodation_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "start_time",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "end_time",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "guests",
    "data_type": "jsonb"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "total_price",
    "data_type": "numeric"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "status",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "payment_status",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "payment_method",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "special_requests",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "ticket_code",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "is_scanned",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_bookings",
    "column_name": "trip_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "accommodation_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "booking_unit",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "accommodation_types",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodations",
    "column_name": "area_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodations",
    "column_name": "type_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodations",
    "column_name": "owner_id",
    "data_type": "uuid"
  },
  {
    "table_name": "accommodations",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "capacity",
    "data_type": "integer"
  },
  {
    "table_name": "accommodations",
    "column_name": "size_sqm",
    "data_type": "numeric"
  },
  {
    "table_name": "accommodations",
    "column_name": "price",
    "data_type": "numeric"
  },
  {
    "table_name": "accommodations",
    "column_name": "discount_percent",
    "data_type": "numeric"
  },
  {
    "table_name": "accommodations",
    "column_name": "amenities",
    "data_type": "jsonb"
  },
  {
    "table_name": "accommodations",
    "column_name": "latitude",
    "data_type": "double precision"
  },
  {
    "table_name": "accommodations",
    "column_name": "longitude",
    "data_type": "double precision"
  },
  {
    "table_name": "accommodations",
    "column_name": "is_active",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodations",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "accommodations",
    "column_name": "is_featured",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodations",
    "column_name": "is_new",
    "data_type": "boolean"
  },
  {
    "table_name": "accommodations",
    "column_name": "tags",
    "data_type": "ARRAY"
  },
  {
    "table_name": "accommodations",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "accommodations",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "activities",
    "column_name": "area_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activities",
    "column_name": "type_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activities",
    "column_name": "provider_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activities",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "price_per_person",
    "data_type": "numeric"
  },
  {
    "table_name": "activities",
    "column_name": "group_price",
    "data_type": "numeric"
  },
  {
    "table_name": "activities",
    "column_name": "flat_rate",
    "data_type": "numeric"
  },
  {
    "table_name": "activities",
    "column_name": "discount_percent",
    "data_type": "numeric"
  },
  {
    "table_name": "activities",
    "column_name": "capacity",
    "data_type": "integer"
  },
  {
    "table_name": "activities",
    "column_name": "duration_minutes",
    "data_type": "integer"
  },
  {
    "table_name": "activities",
    "column_name": "is_active",
    "data_type": "boolean"
  },
  {
    "table_name": "activities",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "activities",
    "column_name": "is_featured",
    "data_type": "boolean"
  },
  {
    "table_name": "activities",
    "column_name": "is_new",
    "data_type": "boolean"
  },
  {
    "table_name": "activities",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "tags",
    "data_type": "ARRAY"
  },
  {
    "table_name": "activities",
    "column_name": "search_keywords",
    "data_type": "ARRAY"
  },
  {
    "table_name": "activities",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "activities",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "user_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "activity_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "time_slot_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "booking_date",
    "data_type": "date"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "number_of_people",
    "data_type": "integer"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "total_price",
    "data_type": "numeric"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "status",
    "data_type": "text"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "payment_status",
    "data_type": "text"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "payment_method",
    "data_type": "text"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "ticket_code",
    "data_type": "text"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "is_scanned",
    "data_type": "boolean"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "activity_bookings",
    "column_name": "trip_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_images",
    "column_name": "activity_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "activity_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "activity_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "activity_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "activity_images",
    "column_name": "display_order",
    "data_type": "integer"
  },
  {
    "table_name": "activity_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "activity_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "activity_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "activity_id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "day_of_week",
    "data_type": "integer"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "start_time",
    "data_type": "time without time zone"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "end_time",
    "data_type": "time without time zone"
  },
  {
    "table_name": "activity_time_slots",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "activity_types",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "activity_types",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "activity_types",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "activity_types",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "area_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "area_images",
    "column_name": "area_id",
    "data_type": "uuid"
  },
  {
    "table_name": "area_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "area_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "area_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "area_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "area_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "area_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "area_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "areas",
    "column_name": "sub_city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "areas",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "latitude",
    "data_type": "double precision"
  },
  {
    "table_name": "areas",
    "column_name": "longitude",
    "data_type": "double precision"
  },
  {
    "table_name": "areas",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "areas",
    "column_name": "is_featured",
    "data_type": "boolean"
  },
  {
    "table_name": "areas",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "areas",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "cities",
    "column_name": "region_id",
    "data_type": "uuid"
  },
  {
    "table_name": "cities",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "cities",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "cities",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "city_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "city_images",
    "column_name": "city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "city_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "city_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "city_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "city_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "city_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "city_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "city_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "region_id",
    "data_type": "uuid"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "region_name",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "region_name_ar",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "region_name_ku",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "region_name_bad",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_count",
    "data_type": "bigint"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_count",
    "data_type": "bigint"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "area_count",
    "data_type": "bigint"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_name",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_name_ar",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_name_ku",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_name_bad",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_sub_city_count",
    "data_type": "bigint"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "city_area_count",
    "data_type": "bigint"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_name",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_name_ar",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_name_ku",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_name_bad",
    "data_type": "text"
  },
  {
    "table_name": "location_hierarchy_stats",
    "column_name": "sub_city_area_count",
    "data_type": "bigint"
  },
  {
    "table_name": "memories",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "memories",
    "column_name": "user_id",
    "data_type": "uuid"
  },
  {
    "table_name": "memories",
    "column_name": "accommodation_booking_id",
    "data_type": "uuid"
  },
  {
    "table_name": "memories",
    "column_name": "activity_booking_id",
    "data_type": "uuid"
  },
  {
    "table_name": "memories",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "memories",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "memories",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "memories",
    "column_name": "trip_id",
    "data_type": "uuid"
  },
  {
    "table_name": "providers",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "providers",
    "column_name": "business_name",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "business_type",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "contact_person",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "phone_number",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "address",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "payment_details",
    "data_type": "jsonb"
  },
  {
    "table_name": "providers",
    "column_name": "is_verified",
    "data_type": "boolean"
  },
  {
    "table_name": "providers",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "providers",
    "column_name": "business_name_ar",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "business_name_ku",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "business_name_bad",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "address_ar",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "address_ku",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "address_bad",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "contact_person_ar",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "contact_person_ku",
    "data_type": "text"
  },
  {
    "table_name": "providers",
    "column_name": "contact_person_bad",
    "data_type": "text"
  },
  {
    "table_name": "ratings",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "ratings",
    "column_name": "user_id",
    "data_type": "uuid"
  },
  {
    "table_name": "ratings",
    "column_name": "accommodation_id",
    "data_type": "uuid"
  },
  {
    "table_name": "ratings",
    "column_name": "activity_id",
    "data_type": "uuid"
  },
  {
    "table_name": "ratings",
    "column_name": "overall_rating",
    "data_type": "numeric"
  },
  {
    "table_name": "ratings",
    "column_name": "cleanliness_rating",
    "data_type": "numeric"
  },
  {
    "table_name": "ratings",
    "column_name": "service_rating",
    "data_type": "numeric"
  },
  {
    "table_name": "ratings",
    "column_name": "location_rating",
    "data_type": "numeric"
  },
  {
    "table_name": "ratings",
    "column_name": "value_rating",
    "data_type": "numeric"
  },
  {
    "table_name": "ratings",
    "column_name": "review_text",
    "data_type": "text"
  },
  {
    "table_name": "ratings",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "region_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "region_images",
    "column_name": "region_id",
    "data_type": "uuid"
  },
  {
    "table_name": "region_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "region_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "region_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "region_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "region_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "region_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "region_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "regions",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "regions",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "regions",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "search_index",
    "column_name": "entity_id",
    "data_type": "uuid"
  },
  {
    "table_name": "search_index",
    "column_name": "entity_type",
    "data_type": "character varying"
  },
  {
    "table_name": "search_index",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "location_path",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "tags",
    "data_type": "ARRAY"
  },
  {
    "table_name": "search_index",
    "column_name": "search_vector",
    "data_type": "tsvector"
  },
  {
    "table_name": "search_index",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "search_index",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "search_index",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "sub_cities",
    "column_name": "city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "sub_cities",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "sub_cities",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "sub_cities",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "sub_city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "image_url",
    "data_type": "text"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "is_primary",
    "data_type": "boolean"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "caption",
    "data_type": "text"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "caption_ar",
    "data_type": "text"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "caption_ku",
    "data_type": "text"
  },
  {
    "table_name": "sub_city_images",
    "column_name": "caption_bad",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "trips",
    "column_name": "user_id",
    "data_type": "uuid"
  },
  {
    "table_name": "trips",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "destination",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "start_date",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "trips",
    "column_name": "end_date",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "trips",
    "column_name": "status",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "trips",
    "column_name": "updated_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "trips",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "destination_ar",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "destination_ku",
    "data_type": "text"
  },
  {
    "table_name": "trips",
    "column_name": "destination_bad",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "unified_search",
    "column_name": "entity_type",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "description",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "thumbnail_url",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "location_path",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "tags",
    "data_type": "ARRAY"
  },
  {
    "table_name": "unified_search",
    "column_name": "price",
    "data_type": "numeric"
  },
  {
    "table_name": "unified_search",
    "column_name": "rating",
    "data_type": "numeric"
  },
  {
    "table_name": "unified_search",
    "column_name": "review_count",
    "data_type": "integer"
  },
  {
    "table_name": "unified_search",
    "column_name": "search_vector",
    "data_type": "tsvector"
  },
  {
    "table_name": "unified_search",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "unified_search",
    "column_name": "region_id",
    "data_type": "uuid"
  },
  {
    "table_name": "unified_search",
    "column_name": "city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "unified_search",
    "column_name": "sub_city_id",
    "data_type": "uuid"
  },
  {
    "table_name": "unified_search",
    "column_name": "area_id",
    "data_type": "uuid"
  },
  {
    "table_name": "unified_search",
    "column_name": "name_ar",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "name_ku",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "name_bad",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "description_ar",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "description_ku",
    "data_type": "text"
  },
  {
    "table_name": "unified_search",
    "column_name": "description_bad",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "id",
    "data_type": "uuid"
  },
  {
    "table_name": "users",
    "column_name": "name",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "email",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "role",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "phone_number",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "profile_image",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "language",
    "data_type": "text"
  },
  {
    "table_name": "users",
    "column_name": "created_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "users",
    "column_name": "updated_at",
    "data_type": "timestamp with time zone"
  },
  {
    "table_name": "users",
    "column_name": "settings",
    "data_type": "jsonb"
  },
  {
    "table_name": "users",
    "column_name": "user_type",
    "data_type": "text"
  }
]

## Database Migrations

### Multilingual Support

To add multilingual support for cities and sub-cities, you need to run the following SQL script against your Supabase database:

1. Navigate to the Supabase dashboard for your project
2. Go to the SQL Editor
3. Copy the contents of the `add_city_language_fields.sql` file
4. Paste it into the SQL Editor
5. Run the query

Alternatively, you can run it using the Supabase CLI:

```bash
supabase db execute -f add_city_language_fields.sql
```

This migration adds the following language fields to both the `cities` and `sub_cities` tables:
- `name_ar` - Arabic name
- `name_ku` - Kurdish name
- `name_bad` - Badinani name
- `description_ar` - Arabic description
- `description_ku` - Kurdish description
- `description_bad` - Badinani description

### Video Support for Activities

To add video support for activities, you need to run the following SQL script against your Supabase database:

1. Navigate to the Supabase dashboard for your project
2. Go to the SQL Editor
3. Copy the contents of the `add_media_type_to_activity_images.sql` file
4. Paste it into the SQL Editor
5. Run the query

Alternatively, you can run it using the Supabase CLI:

```bash
supabase db execute -f add_media_type_to_activity_images.sql
```

This migration adds the following fields to the `activity_images` table:
- `media_type` - Type of media (image or video)
- `thumbnail_url` - URL to thumbnail image for videos

After running this migration, you'll be able to upload videos for activities in addition to images. The app will automatically generate thumbnails for videos and display them appropriately.