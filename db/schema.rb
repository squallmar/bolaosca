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

ActiveRecord::Schema[8.0].define(version: 2025_04_27_002758) do
  create_table "albums", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "capa_id"
    t.string "titulo", null: false
    t.string "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_albums_on_user_id"
  end

  create_table "banners", force: :cascade do |t|
    t.string "nome", null: false
    t.integer "count_views", default: 0, null: false
    t.string "image", null: false
    t.string "link", null: false
    t.string "text"
    t.string "tipo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link"], name: "index_banners_on_link"
    t.index ["tipo"], name: "index_banners_on_tipo"
  end

  create_table "bolaos", force: :cascade do |t|
    t.string "titulo", null: false
    t.datetime "data_inicio", null: false
    t.datetime "data_final", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "slug", null: false
    t.string "status", default: "ativo", null: false
    t.index ["slug"], name: "index_bolaos_on_slug", unique: true
    t.index ["user_id"], name: "index_bolaos_on_user_id"
  end

  create_table "bolaos_users", id: false, force: :cascade do |t|
    t.integer "bolao_id", null: false
    t.integer "user_id", null: false
    t.index ["bolao_id", "user_id"], name: "index_bolaos_users_on_bolao_id_and_user_id", unique: true
    t.index ["bolao_id"], name: "index_bolaos_users_on_bolao_id"
    t.index ["user_id"], name: "index_bolaos_users_on_user_id"
  end

  create_table "comentarios", force: :cascade do |t|
    t.text "texto", null: false
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "foto_id"
    t.index ["foto_id"], name: "index_comentarios_on_foto_id"
    t.index ["post_id"], name: "index_comentarios_on_post_id"
    t.index ["user_id"], name: "index_comentarios_on_user_id"
  end

  create_table "fotos", force: :cascade do |t|
    t.string "imagem", null: false
    t.integer "album_id", null: false
    t.string "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_fotos_on_album_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 40, null: false
    t.datetime "created_at"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "jogos", force: :cascade do |t|
    t.integer "placar_home"
    t.integer "placar_away"
    t.string "time_home", null: false
    t.string "time_away", null: false
    t.integer "user_id"
    t.integer "rodada_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "times"
    t.index ["rodada_id"], name: "index_jogos_on_rodada_id"
    t.index ["user_id"], name: "index_jogos_on_user_id"
  end

  create_table "opcaos", force: :cascade do |t|
    t.boolean "notificacao_prazos", default: false, null: false
    t.boolean "notificacao_contato_geral", default: false, null: false
    t.boolean "notificacao_solicitar_cadastro", default: false, null: false
    t.boolean "notificacao_novos_boloes", default: false, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notificacao_pontuacao", default: false, null: false
    t.boolean "mostrar_email", default: false, null: false
    t.index ["user_id"], name: "index_opcaos_on_user_id"
  end

  create_table "palpites", force: :cascade do |t|
    t.integer "jogo_id", null: false
    t.string "home"
    t.string "away"
    t.string "primeiro_marcador"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rodada_id"
    t.integer "bolao_id"
    t.index ["bolao_id"], name: "index_palpites_on_bolao_id"
    t.index ["jogo_id"], name: "index_palpites_on_jogo_id"
    t.index ["rodada_id"], name: "index_palpites_on_rodada_id"
    t.index ["user_id"], name: "index_palpites_on_user_id"
  end

  create_table "pontuacaos", force: :cascade do |t|
    t.integer "rodada_id", null: false
    t.integer "user_id", null: false
    t.integer "bolao_id", null: false
    t.integer "pontos", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bolao_id"], name: "index_pontuacaos_on_bolao_id"
    t.index ["rodada_id"], name: "index_pontuacaos_on_rodada_id"
    t.index ["user_id"], name: "index_pontuacaos_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "imagem"
    t.string "titulo", null: false
    t.text "texto", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "rodadas", force: :cascade do |t|
    t.string "numero", null: false
    t.datetime "data_inicio_apostas", null: false
    t.datetime "data_final_apostas", null: false
    t.integer "user_id", null: false
    t.integer "bolao_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "aberta"
    t.string "slug"
    t.index ["bolao_id"], name: "index_rodadas_on_bolao_id"
    t.index ["slug"], name: "index_rodadas_on_slug", unique: true
    t.index ["user_id"], name: "index_rodadas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "invitation_token", limit: 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "apelido"
    t.string "sexo"
    t.string "nome"
    t.string "telefone"
    t.string "avatar"
    t.string "setor"
    t.index ["apelido"], name: "index_users_on_apelido"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["telefone"], name: "index_users_on_telefone"
  end

  add_foreign_key "albums", "users"
  add_foreign_key "bolaos", "users"
  add_foreign_key "bolaos_users", "bolaos"
  add_foreign_key "bolaos_users", "users"
  add_foreign_key "comentarios", "fotos"
  add_foreign_key "comentarios", "posts"
  add_foreign_key "comentarios", "users"
  add_foreign_key "fotos", "albums"
  add_foreign_key "jogos", "rodadas"
  add_foreign_key "jogos", "users"
  add_foreign_key "opcaos", "users"
  add_foreign_key "palpites", "bolaos"
  add_foreign_key "palpites", "jogos"
  add_foreign_key "palpites", "rodadas"
  add_foreign_key "palpites", "users"
  add_foreign_key "pontuacaos", "bolaos"
  add_foreign_key "pontuacaos", "rodadas"
  add_foreign_key "pontuacaos", "users"
  add_foreign_key "rodadas", "bolaos"
  add_foreign_key "rodadas", "users"
end
