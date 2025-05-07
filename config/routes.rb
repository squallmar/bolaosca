Bolaosca::Application.routes.draw do
  # Rotas de preferências
  get "preferencias" => "opcaos#edit", as: "preferencias"
  put "preferencias" => "opcaos#update", as: "atualizar_preferencias"

  # Rotas de bolões
  resources :bolaos, path: "boloes" do
    member do
      get "classificacao"
    end

    resources :rodadas do
      member do
        get "classificacao"
        get "notificar_participantes"
      end

      resources :jogos, except: [ :index ] do
        collection do
          get :edit_multiplos
          put :update_multiplos
        end
      end

      resources :palpites, except: [ :show, :destroy, :update, :edit, :new, :create ] do
          collection do
            get "apostando" => "palpites#new"
            post "apostando" => "palpites#create"
            get "edit"
            put "salvar" => "palpites#update"
          end
        end
    end

    resources :users, only: [ :index, :show, :destroy ], path: "participantes", module: :bolaos do
      member do
        put "inscrever"
        get "comparar"
      end
    end

    get "/eu_no_bolao" => "bolaos/users#show"
  end

  # Rotas do blog
  resources :posts, path: "blog" do
    resources :comentarios, except: [ :show, :index, :edit, :new, :update ]
  end

  # Rotas de álbuns e fotos
  resources :albums do
    resources :fotos, except: [ :show, :index ] do
      resources :comentarios, except: [ :show, :index, :edit, :new, :update ], module: :fotos
    end
    put "tornar_capa", on: :member
  end

  # Rotas de banners
  resources :banners do
    get "link", on: :member
  end

  # Rotas de contato
  resources :contatos, only: [ :new, :create ], path: "contato", path_names: { new: "", create: "enviar" }

  # Rotas da home
  get "home/index"
  get "tabela" => "home#tabela", as: "tabela"
  get "noticiasge" => "home#noticiasge", as: "noticiasge"

  # Rotas de usuários
  scope "//" do
    resources :users, except: [ :create, :new ], path: "jogadores" do
      put "alternar_super", on: :member
    end
  end

  # Rotas do Devise
  devise_for :users,
             path: "",
             controllers: {
               registrations: "registrations",
               invitations: "invitations",
               users: "users"
             },
             path_names: { sign_in: "login" }

  as :user do
    get "perfil/alterar_senha" => "registrations#alterar_senha", as: "users_alterar_senha"
    get "perfil/alterar_avatar" => "registrations#alterar_avatar", as: "users_alterar_avatar"
    get "perfil" => "registrations#show", as: "users_show"
    get "perfil/edit" => "registrations#edit", as: "edit_registration"
    put "perfil" => "registrations#update", as: "registration"
  end

  # Rota root
  root to: "home#index"
end
