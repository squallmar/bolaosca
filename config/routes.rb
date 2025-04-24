Bolaosca::Application.routes.draw do
  # Rotas de preferências do usuário
  get "preferencias" => "opcaos#edit", as: :edit_preferencias
  put "preferencias" => "opcaos#update", as: :update_preferencias

  # Rotas principais do bolão
  resources :bolaos, path: "boloes" do
    get "classificacao", on: :member

    resources :rodadas do
      member do
        get "classificacao"
        get "notificar_participantes"
      end

      resources :jogos, except: [ :index ] do
        collection do
          get "editar_multiplos" => "jogos#edit_multiplos", as: :edit_multiplos
          patch "atualizar_multiplos" => "jogos#update_multiplos", as: :update_multiplos
        end
      end

      resources :palpites, except: [ :show, :destroy ] do
        collection do
          get "apostando" => "palpites#new", as: :new
          put "salvar" => "palpites#update", as: :update
          post "create", as: :create
        end
      end
    end

    # Rotas de participantes
    scope module: :bolaos do
      resources :users, only: [ :index, :show, :destroy ],
                       path: "participantes",
                       controller: "users" do
        member do
          put "inscrever"
          get "comparar"
        end
      end
    end

    get "/eu_no_bolao" => "bolaos/users#show", as: :eu_no_bolao
  end

  # Rotas do blog
  resources :posts, path: "blog" do
    resources :comentarios, only: [ :create, :destroy ]
  end

  # Rotas de álbuns e fotos
  resources :albums do
    member do
      put "tornar_capa"
    end

    resources :fotos, except: [ :show, :index ] do
      resources :comentarios, only: [ :create, :destroy ], module: :fotos
    end
  end

  # Rotas de banners
  resources :banners do
    get "link", on: :member
  end

  # Rotas de contato
  resources :contatos, only: [ :new, :create ], path: "contato",
            path_names: { new: "" }

  # Rotas estáticas
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
               sessions: "sessions"
             },
             path_names: {
               sign_in: "login",
               sign_out: "logout"
             }

  # Rotas customizadas do perfil
  as :user do
    get "perfil/alterar_senha" => "registrations#alterar_senha", as: "alterar_senha"
    get "perfil/alterar_avatar" => "registrations#alterar_avatar", as: "alterar_avatar"
    get "perfil" => "registrations#show", as: "perfil"
    get "perfil/edit" => "registrations#edit", as: "edit_perfil"
    put "perfil" => "registrations#update"
  end

  # Rota raiz
  root to: "home#index"
end
