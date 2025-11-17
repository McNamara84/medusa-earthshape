# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_11_17_155609) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "stone_id"
    t.string "operator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "technique_id"
    t.integer "device_id"
    t.index ["device_id"], name: "index_analyses_on_device_id"
    t.index ["stone_id"], name: "index_analyses_on_stone_id"
    t.index ["technique_id"], name: "index_analyses_on_technique_id"
  end

  create_table "analysis_stones", id: :serial, force: :cascade do |t|
    t.integer "stone_id"
    t.integer "analysis_id"
    t.index ["analysis_id"], name: "index_analysis_stones_on_analysis_id"
    t.index ["stone_id"], name: "index_analysis_stones_on_stone_id"
  end

  create_table "attachings", id: :serial, force: :cascade do |t|
    t.integer "attachment_file_id"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachable_id"], name: "index_attachings_on_attachable_id"
    t.index ["attachment_file_id", "attachable_id", "attachable_type"], name: "index_on_attachings_attachable_type_and_id_and_file_id", unique: true
    t.index ["attachment_file_id"], name: "index_attachings_on_attachment_file_id"
  end

  create_table "attachment_files", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "md5hash"
    t.string "data_file_name"
    t.string "data_content_type"
    t.integer "data_file_size"
    t.datetime "data_updated_at"
    t.string "original_geometry"
    t.text "affine_matrix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "filetopic_id"
    t.index ["filetopic_id"], name: "index_attachment_files_on_filetopic_id"
  end

  create_table "authors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bib_authors", id: :serial, force: :cascade do |t|
    t.integer "bib_id"
    t.integer "author_id"
    t.index ["author_id"], name: "index_bib_authors_on_author_id"
    t.index ["bib_id"], name: "index_bib_authors_on_bib_id"
  end

  create_table "bibs", id: :serial, force: :cascade do |t|
    t.string "entry_type"
    t.string "abbreviation"
    t.string "name"
    t.string "journal"
    t.string "year"
    t.string "volume"
    t.string "number"
    t.string "pages"
    t.string "month"
    t.string "note"
    t.string "key"
    t.string "link_url"
    t.text "doi"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "box_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "boxes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "position"
    t.string "path"
    t.integer "box_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["box_type_id"], name: "index_boxes_on_box_type_id"
    t.index ["parent_id"], name: "index_boxes_on_parent_id"
  end

  create_table "category_measurement_items", id: :serial, force: :cascade do |t|
    t.integer "measurement_item_id"
    t.integer "measurement_category_id"
    t.integer "position"
    t.index ["measurement_category_id"], name: "index_category_measurement_items_on_measurement_category_id"
    t.index ["measurement_item_id"], name: "index_category_measurement_items_on_measurement_item_id"
  end

  create_table "chemistries", id: :serial, force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.integer "measurement_item_id"
    t.string "info"
    t.float "value"
    t.string "label"
    t.text "description"
    t.float "uncertainty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "unit_id"
    t.index ["analysis_id"], name: "index_chemistries_on_analysis_id"
    t.index ["measurement_item_id"], name: "index_chemistries_on_measurement_item_id"
  end

  create_table "classifications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "full_name"
    t.text "description"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.index ["parent_id"], name: "index_classifications_on_parent_id"
  end

  create_table "collectionmethods", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "collector"
    t.date "collection_start"
    t.date "collection_end"
    t.float "depth_min"
    t.float "depth_max"
    t.string "depth_unit"
    t.text "weather_conditions"
    t.text "comment"
    t.integer "collectionmethod_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "affiliation"
    t.string "project"
    t.boolean "timeseries"
    t.string "samplingstrategy"
    t.index ["collectionmethod_id"], name: "index_collections_on_collectionmethod_id"
  end

  create_table "collectors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "affiliation"
    t.integer "stone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["stone_id"], name: "index_collectors_on_stone_id"
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filetopics", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_qrs", id: :serial, force: :cascade do |t|
    t.integer "record_property_id"
    t.string "file_name"
    t.string "content_type"
    t.integer "file_size"
    t.datetime "file_updated_at"
    t.string "identifier"
    t.index ["record_property_id"], name: "index_global_qrs_on_record_property_id"
  end

  create_table "group_members", id: :serial, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "landuses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurement_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "unit_id"
  end

  create_table "measurement_items", id: :serial, force: :cascade do |t|
    t.string "nickname"
    t.text "description"
    t.string "display_in_html"
    t.string "display_in_tex"
    t.integer "unit_id"
  end

  create_table "physical_forms", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "latitude"
    t.float "longitude"
    t.float "elevation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slope_description"
    t.string "landuse"
    t.string "aspect"
    t.integer "vegetation_id"
    t.integer "landuse_id"
    t.integer "topographic_position_id"
    t.string "lightsituation"
    t.integer "parent_id"
    t.boolean "is_parent"
    t.index ["landuse_id"], name: "index_places_on_landuse_id"
    t.index ["parent_id"], name: "index_places_on_parent_id"
    t.index ["topographic_position_id"], name: "index_places_on_topographic_position_id"
    t.index ["vegetation_id"], name: "index_places_on_vegetation_id"
  end

  create_table "preparation_for_classifications", id: :serial, force: :cascade do |t|
    t.integer "classification_id", null: false
    t.integer "preparation_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["classification_id"], name: "index_preparation_for_classifications_on_classification_id"
    t.index ["preparation_type_id"], name: "index_preparation_for_classifications_on_preparation_type_id"
  end

  create_table "preparation_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "creates_siblings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "full_name"
    t.text "description"
    t.integer "parent_id"
  end

  create_table "preparations", id: :serial, force: :cascade do |t|
    t.string "info"
    t.integer "preparation_type_id"
    t.integer "stone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["preparation_type_id"], name: "index_preparations_on_preparation_type_id"
    t.index ["stone_id"], name: "index_preparations_on_stone_id"
  end

  create_table "quantityunits", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_properties", id: :serial, force: :cascade do |t|
    t.integer "datum_id"
    t.string "datum_type"
    t.integer "user_id"
    t.integer "group_id"
    t.string "global_id"
    t.boolean "published", default: false
    t.datetime "published_at"
    t.boolean "owner_readable", default: true, null: false
    t.boolean "owner_writable", default: true, null: false
    t.boolean "group_readable", default: true, null: false
    t.boolean "group_writable", default: true, null: false
    t.boolean "guest_readable", default: false, null: false
    t.boolean "guest_writable", default: false, null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["datum_id"], name: "index_record_properties_on_datum_id"
    t.index ["group_id"], name: "index_record_properties_on_group_id"
    t.index ["user_id"], name: "index_record_properties_on_user_id"
  end

  create_table "referrings", id: :serial, force: :cascade do |t|
    t.integer "bib_id"
    t.integer "referable_id"
    t.string "referable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bib_id", "referable_id", "referable_type"], name: "index_referrings_on_bib_id_and_referable_id_and_referable_type", unique: true
    t.index ["bib_id"], name: "index_referrings_on_bib_id"
    t.index ["referable_id"], name: "index_referrings_on_referable_id"
  end

  create_table "search_maps", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spots", id: :serial, force: :cascade do |t|
    t.integer "attachment_file_id"
    t.string "name"
    t.text "description"
    t.float "spot_x"
    t.float "spot_y"
    t.string "target_uid"
    t.float "radius_in_percent"
    t.string "stroke_color"
    t.float "stroke_width"
    t.string "fill_color"
    t.float "opacity"
    t.boolean "with_cross"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachment_file_id"], name: "index_spots_on_attachment_file_id"
  end

  create_table "stagings", id: :serial, force: :cascade do |t|
    t.string "collection_name"
    t.string "collection_project"
    t.boolean "collection_timeseries"
    t.text "collection_comment"
    t.string "place_name"
    t.string "place_latitude"
    t.string "place_longitude"
    t.float "place_elevation"
    t.string "place_topographic_positon"
    t.string "place_slopedescription"
    t.string "place_aspect"
    t.string "place_vegetation"
    t.string "place_landuse"
    t.string "place_description"
    t.string "place_lightsituation"
    t.string "box_name"
    t.string "box_parent"
    t.string "box_type"
    t.string "sample_name"
    t.string "sample_igsn"
    t.string "sample_labname"
    t.date "sample_date"
    t.string "sample_collectionmethod"
    t.text "sample_comment"
    t.string "sample_parent"
    t.string "sample_material"
    t.string "sample_classification"
    t.string "sample_container"
    t.float "sample_quantityinitial"
    t.string "sample_unit"
    t.float "sample_quantity"
    t.string "treatment_monitor1"
    t.string "treatment_monitor2"
    t.string "treatment_monitor3"
    t.string "treatment_preparation1"
    t.string "treatment_preparation2"
    t.string "treatment_preparation3"
    t.string "treatment_strategy"
    t.string "treatment_analyticalmethod"
    t.text "treatment_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "sample_depth"
    t.string "hidden_column"
    t.string "collection_weather"
    t.string "collection_group"
    t.string "place_is_parent"
    t.string "place_parent"
    t.string "place_group"
    t.string "box_group"
    t.string "sample_location"
    t.string "sample_campaign"
    t.string "sample_storageroom"
    t.string "sample_group"
    t.string "sample_collector"
    t.string "sample_affiliation"
    t.string "collection_strategy"
  end

  create_table "stonecontainer_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stones", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "stone_type"
    t.text "description"
    t.integer "parent_id"
    t.integer "place_id"
    t.integer "box_id"
    t.integer "physical_form_id"
    t.integer "classification_id"
    t.float "quantity"
    t.string "quantity_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "quantity_initial"
    t.string "labname"
    t.string "igsn"
    t.integer "collection_id"
    t.integer "stonecontainer_type_id"
    t.float "sampledepth"
    t.date "date"
    t.integer "quantityunit_id"
    t.integer "collectionmethod_id"
    t.index ["classification_id"], name: "index_stones_on_classification_id"
    t.index ["collection_id"], name: "index_stones_on_collection_id"
    t.index ["collectionmethod_id"], name: "index_stones_on_collectionmethod_id"
    t.index ["parent_id"], name: "index_stones_on_parent_id"
    t.index ["physical_form_id"], name: "index_stones_on_physical_form_id"
    t.index ["quantityunit_id"], name: "index_stones_on_quantityunit_id"
    t.index ["stonecontainer_type_id"], name: "index_stones_on_stonecontainer_type_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "techniques", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topographic_positions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "conversion", null: false
    t.string "html", limit: 10, null: false
    t.string "text", limit: 10, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "administrator", default: false, null: false
    t.string "family_name"
    t.string "first_name"
    t.text "description"
    t.string "username", null: false
    t.integer "box_id"
    t.string "prefix"
    t.boolean "advanced"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "vegetations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
