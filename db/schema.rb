# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180226094630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description"
    t.integer  "stone_id"
    t.string   "operator",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "technique_id"
    t.integer  "device_id"
  end

  add_index "analyses", ["device_id"], name: "index_analyses_on_device_id", using: :btree
  add_index "analyses", ["stone_id"], name: "index_analyses_on_stone_id", using: :btree
  add_index "analyses", ["technique_id"], name: "index_analyses_on_technique_id", using: :btree

  create_table "analysis_stones", force: :cascade do |t|
    t.integer "stone_id"
    t.integer "analysis_id"
  end

  add_index "analysis_stones", ["analysis_id"], name: "index_analysis_stones_on_analysis_id", using: :btree
  add_index "analysis_stones", ["stone_id"], name: "index_analysis_stones_on_stone_id", using: :btree

  create_table "attachings", force: :cascade do |t|
    t.integer  "attachment_file_id"
    t.integer  "attachable_id"
    t.string   "attachable_type",    limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachings", ["attachable_id"], name: "index_attachings_on_attachable_id", using: :btree
  add_index "attachings", ["attachment_file_id", "attachable_id", "attachable_type"], name: "index_on_attachings_attachable_type_and_id_and_file_id", unique: true, using: :btree
  add_index "attachings", ["attachment_file_id"], name: "index_attachings_on_attachment_file_id", using: :btree

  create_table "attachment_files", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "description"
    t.string   "md5hash",           limit: 255
    t.string   "data_file_name",    limit: 255
    t.string   "data_content_type", limit: 255
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "original_geometry", limit: 255
    t.text     "affine_matrix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "filetopic_id"
  end

  add_index "attachment_files", ["filetopic_id"], name: "index_attachment_files_on_filetopic_id", using: :btree

  create_table "authors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bib_authors", force: :cascade do |t|
    t.integer "bib_id"
    t.integer "author_id"
  end

  add_index "bib_authors", ["author_id"], name: "index_bib_authors_on_author_id", using: :btree
  add_index "bib_authors", ["bib_id"], name: "index_bib_authors_on_bib_id", using: :btree

  create_table "bibs", force: :cascade do |t|
    t.string   "entry_type",   limit: 255
    t.string   "abbreviation", limit: 255
    t.string   "name",         limit: 255
    t.string   "journal",      limit: 255
    t.string   "year",         limit: 255
    t.string   "volume",       limit: 255
    t.string   "number",       limit: 255
    t.string   "pages",        limit: 255
    t.string   "month",        limit: 255
    t.string   "note",         limit: 255
    t.string   "key",          limit: 255
    t.string   "link_url",     limit: 255
    t.text     "doi"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "box_types", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description"
  end

  create_table "boxes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "parent_id"
    t.integer  "position"
    t.string   "path",        limit: 255
    t.integer  "box_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boxes", ["box_type_id"], name: "index_boxes_on_box_type_id", using: :btree
  add_index "boxes", ["parent_id"], name: "index_boxes_on_parent_id", using: :btree

  create_table "category_measurement_items", force: :cascade do |t|
    t.integer "measurement_item_id"
    t.integer "measurement_category_id"
    t.integer "position"
  end

  add_index "category_measurement_items", ["measurement_category_id"], name: "index_category_measurement_items_on_measurement_category_id", using: :btree
  add_index "category_measurement_items", ["measurement_item_id"], name: "index_category_measurement_items_on_measurement_item_id", using: :btree

  create_table "chemistries", force: :cascade do |t|
    t.integer  "analysis_id",                     null: false
    t.integer  "measurement_item_id"
    t.string   "info",                limit: 255
    t.float    "value"
    t.string   "label",               limit: 255
    t.text     "description"
    t.float    "uncertainty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  add_index "chemistries", ["analysis_id"], name: "index_chemistries_on_analysis_id", using: :btree
  add_index "chemistries", ["measurement_item_id"], name: "index_chemistries_on_measurement_item_id", using: :btree

  create_table "classifications", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "full_name",   limit: 255
    t.text    "description"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
  end

  add_index "classifications", ["parent_id"], name: "index_classifications_on_parent_id", using: :btree

  create_table "collectionmethods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "collector",           limit: 255
    t.date     "collection_start"
    t.date     "collection_end"
    t.float    "depth_min"
    t.float    "depth_max"
    t.string   "depth_unit",          limit: 255
    t.text     "weather_conditions"
    t.text     "comment"
    t.integer  "collectionmethod_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "affiliation",         limit: 255
    t.string   "project",             limit: 255
    t.boolean  "timeseries"
    t.string   "samplingstrategy",    limit: 255
  end

  add_index "collections", ["collectionmethod_id"], name: "index_collections_on_collectionmethod_id", using: :btree

  create_table "collectors", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "affiliation", limit: 255
    t.integer  "stone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collectors", ["stone_id"], name: "index_collectors_on_stone_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filetopics", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_qrs", force: :cascade do |t|
    t.integer  "record_property_id"
    t.string   "file_name",          limit: 255
    t.string   "content_type",       limit: 255
    t.integer  "file_size"
    t.datetime "file_updated_at"
    t.string   "identifier",         limit: 255
  end

  add_index "global_qrs", ["record_property_id"], name: "index_global_qrs_on_record_property_id", using: :btree

  create_table "group_members", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "landuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurement_categories", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "description", limit: 255
    t.integer "unit_id"
  end

  create_table "measurement_items", force: :cascade do |t|
    t.string  "nickname",        limit: 255
    t.text    "description"
    t.string  "display_in_html", limit: 255
    t.string  "display_in_tex",  limit: 255
    t.integer "unit_id"
  end

  create_table "physical_forms", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description"
  end

  create_table "places", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.text     "description"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "elevation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slope_description",       limit: 255
    t.string   "landuse",                 limit: 255
    t.string   "aspect",                  limit: 255
    t.integer  "vegetation_id"
    t.integer  "landuse_id"
    t.integer  "topographic_position_id"
    t.string   "lightsituation",          limit: 255
    t.integer  "parent_id"
    t.boolean  "is_parent"
  end

  add_index "places", ["landuse_id"], name: "index_places_on_landuse_id", using: :btree
  add_index "places", ["parent_id"], name: "index_places_on_parent_id", using: :btree
  add_index "places", ["topographic_position_id"], name: "index_places_on_topographic_position_id", using: :btree
  add_index "places", ["vegetation_id"], name: "index_places_on_vegetation_id", using: :btree

  create_table "preparation_for_classifications", force: :cascade do |t|
    t.integer  "classification_id",   null: false
    t.integer  "preparation_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preparation_for_classifications", ["classification_id"], name: "index_preparation_for_classifications_on_classification_id", using: :btree
  add_index "preparation_for_classifications", ["preparation_type_id"], name: "index_preparation_for_classifications_on_preparation_type_id", using: :btree

  create_table "preparation_types", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.boolean  "creates_siblings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",        limit: 255
    t.text     "description"
    t.integer  "parent_id"
  end

  create_table "preparations", force: :cascade do |t|
    t.string   "info",                limit: 255
    t.integer  "preparation_type_id"
    t.integer  "stone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preparations", ["preparation_type_id"], name: "index_preparations_on_preparation_type_id", using: :btree
  add_index "preparations", ["stone_id"], name: "index_preparations_on_stone_id", using: :btree

  create_table "quantityunits", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_properties", force: :cascade do |t|
    t.integer  "datum_id"
    t.string   "datum_type",     limit: 255
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "global_id",      limit: 255
    t.boolean  "published",                  default: false
    t.datetime "published_at"
    t.boolean  "owner_readable",             default: true,  null: false
    t.boolean  "owner_writable",             default: true,  null: false
    t.boolean  "group_readable",             default: true,  null: false
    t.boolean  "group_writable",             default: true,  null: false
    t.boolean  "guest_readable",             default: false, null: false
    t.boolean  "guest_writable",             default: false, null: false
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "record_properties", ["datum_id"], name: "index_record_properties_on_datum_id", using: :btree
  add_index "record_properties", ["group_id"], name: "index_record_properties_on_group_id", using: :btree
  add_index "record_properties", ["user_id"], name: "index_record_properties_on_user_id", using: :btree

  create_table "referrings", force: :cascade do |t|
    t.integer  "bib_id"
    t.integer  "referable_id"
    t.string   "referable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referrings", ["bib_id", "referable_id", "referable_type"], name: "index_referrings_on_bib_id_and_referable_id_and_referable_type", unique: true, using: :btree
  add_index "referrings", ["bib_id"], name: "index_referrings_on_bib_id", using: :btree
  add_index "referrings", ["referable_id"], name: "index_referrings_on_referable_id", using: :btree

  create_table "search_maps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spots", force: :cascade do |t|
    t.integer  "attachment_file_id"
    t.string   "name",               limit: 255
    t.text     "description"
    t.float    "spot_x"
    t.float    "spot_y"
    t.string   "target_uid",         limit: 255
    t.float    "radius_in_percent"
    t.string   "stroke_color",       limit: 255
    t.float    "stroke_width"
    t.string   "fill_color",         limit: 255
    t.float    "opacity"
    t.boolean  "with_cross"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spots", ["attachment_file_id"], name: "index_spots_on_attachment_file_id", using: :btree

  create_table "stagings", force: :cascade do |t|
    t.string   "collection_name",            limit: 255
    t.string   "collection_project",         limit: 255
    t.boolean  "collection_timeseries"
    t.text     "collection_comment"
    t.string   "place_name",                 limit: 255
    t.string   "place_latitude",             limit: 255
    t.string   "place_longitude",            limit: 255
    t.float    "place_elevation"
    t.string   "place_topographic_positon",  limit: 255
    t.string   "place_slopedescription",     limit: 255
    t.string   "place_aspect",               limit: 255
    t.string   "place_vegetation",           limit: 255
    t.string   "place_landuse",              limit: 255
    t.string   "place_description",          limit: 255
    t.string   "place_lightsituation",       limit: 255
    t.string   "box_name",                   limit: 255
    t.string   "box_parent",                 limit: 255
    t.string   "box_type",                   limit: 255
    t.string   "sample_name",                limit: 255
    t.string   "sample_igsn",                limit: 255
    t.string   "sample_labname",             limit: 255
    t.date     "sample_date"
    t.string   "sample_collectionmethod",    limit: 255
    t.text     "sample_comment"
    t.string   "sample_parent",              limit: 255
    t.string   "sample_material",            limit: 255
    t.string   "sample_classification",      limit: 255
    t.string   "sample_container",           limit: 255
    t.float    "sample_quantityinitial"
    t.string   "sample_unit",                limit: 255
    t.float    "sample_quantity"
    t.string   "treatment_monitor1",         limit: 255
    t.string   "treatment_monitor2",         limit: 255
    t.string   "treatment_monitor3",         limit: 255
    t.string   "treatment_preparation1",     limit: 255
    t.string   "treatment_preparation2",     limit: 255
    t.string   "treatment_preparation3",     limit: 255
    t.string   "treatment_strategy",         limit: 255
    t.string   "treatment_analyticalmethod", limit: 255
    t.text     "treatment_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "sample_depth"
    t.string   "hidden_column",              limit: 255
    t.string   "collection_weather",         limit: 255
    t.string   "collection_group",           limit: 255
    t.string   "place_is_parent",            limit: 255
    t.string   "place_parent",               limit: 255
    t.string   "place_group",                limit: 255
    t.string   "box_group",                  limit: 255
    t.string   "sample_location",            limit: 255
    t.string   "sample_campaign",            limit: 255
    t.string   "sample_storageroom",         limit: 255
    t.string   "sample_group",               limit: 255
    t.string   "sample_collector",           limit: 255
    t.string   "sample_affiliation",         limit: 255
    t.string   "collection_strategy",        limit: 255
  end

  create_table "stonecontainer_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stones", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "stone_type",             limit: 255
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "place_id"
    t.integer  "box_id"
    t.integer  "physical_form_id"
    t.integer  "classification_id"
    t.float    "quantity"
    t.string   "quantity_unit",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "quantity_initial"
    t.string   "labname",                limit: 255
    t.string   "igsn",                   limit: 255
    t.integer  "collection_id"
    t.integer  "stonecontainer_type_id"
    t.float    "sampledepth"
    t.date     "date"
    t.integer  "quantityunit_id"
    t.integer  "collectionmethod_id"
  end

  add_index "stones", ["classification_id"], name: "index_stones_on_classification_id", using: :btree
  add_index "stones", ["collection_id"], name: "index_stones_on_collection_id", using: :btree
  add_index "stones", ["collectionmethod_id"], name: "index_stones_on_collectionmethod_id", using: :btree
  add_index "stones", ["parent_id"], name: "index_stones_on_parent_id", using: :btree
  add_index "stones", ["physical_form_id"], name: "index_stones_on_physical_form_id", using: :btree
  add_index "stones", ["quantityunit_id"], name: "index_stones_on_quantityunit_id", using: :btree
  add_index "stones", ["stonecontainer_type_id"], name: "index_stones_on_stonecontainer_type_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "techniques", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topographic_positions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversion",             null: false
    t.string   "html",       limit: 10,  null: false
    t.string   "text",       limit: 10,  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "administrator",                      default: false, null: false
    t.string   "family_name",            limit: 255
    t.string   "first_name",             limit: 255
    t.text     "description"
    t.string   "username",               limit: 255,                 null: false
    t.integer  "box_id"
    t.string   "prefix",                 limit: 255
    t.boolean  "advanced"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "vegetations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
