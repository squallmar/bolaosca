# db/seeds.rb
# Este arquivo é executado com `rails db:seed` (ou durante `rails db:setup`).
# Cuidado: executar este script em produção pode sobrescrever dados existentes.

# Método seguro para criar ou atualizar usuários
def create_or_update_user(attributes)
    user = User.find_or_initialize_by(email: attributes[:email])
    user.assign_attributes(attributes)

    if user.save!
      puts "Usuário #{user.email} criado/atualizado com sucesso!"
      user
    else
      puts "Erro ao criar usuário #{user.email}: #{user.errors.full_messages.join(', ')}"
      nil
    end
  end

  # Criação dos usuários administradores
  puts "Criando usuários administradores..."

  superadmin = create_or_update_user(
    email: "maas@petrobras.com.br",
    password: "12345678",
    password_confirmation: "12345678",
    nome: "Marco Antonio",
    apelido: "Marco Antonio",
    telefone: "(22) 99831-1321",
    admin: true,
    invitation_accepted_at: Time.current
  )

  if superadmin
    superadmin.create_opcao(
      notificacao_contato_geral: true,
      notificacao_novos_boloes: true,
      notificacao_prazos: true,
      notificacao_solicitar_cadastro: true,
      notificacao_pontuacao: true
    )
  end

  devsquall = create_or_update_user(
    email: "marcelmendes05@gmail.com",
    password: "mM3038@",
    password_confirmation: "mM3038@",
    nome: "Marcel Mendes",
    apelido: "Marcel",
    telefone: "(22) 998550450",
    admin: true,
    invitation_accepted_at: Time.current
  )

  if devsquall
    devsquall.create_opcao(
      notificacao_contato_geral: true,
      notificacao_novos_boloes: true,
      notificacao_prazos: true,
      notificacao_solicitar_cadastro: true,
      notificacao_pontuacao: true
    )
  end

  puts "Seed concluído com sucesso!"
