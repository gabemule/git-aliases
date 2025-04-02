# Git SSH Identity Management

## Description
Permite configurar facilmente uma chave SSH específica para cada repositório, juntamente com informações de identificação personalizadas (nome/email). Isso é especialmente útil para separar identidades pessoais e organizacionais em diferentes projetos.

## Features
- Listagem interativa de chaves SSH disponíveis
- Configuração por repositório de chaves SSH específicas
- Configuração de nome/email por repositório
- Integração total com todos os comandos Git (não apenas aliases)
- Interface visual para seleção de identidade
- Persistência de configurações entre sessões

## Example Usage
```bash
# Interactive SSH key selection
$ git chronogit
1) Show all configurations
2) Set configuration
3) SSH and Identity Management
4) Exit

> Select option: 3

SSH and Identity Management:
1) List available SSH keys
2) Configure SSH key for repository
3) Configure identity (name/email)
4) Back

> Select option: 1
Available SSH keys:
1) id_rsa (Personal)
2) id_ed25519_work (Organization)
3) id_ed25519_project (Project)

> Select option: 2
Select SSH key to use for this repository:
1) id_rsa (Personal)
2) id_ed25519_work (Organization)
3) id_ed25519_project (Project)

> Select key: 2
✓ Repository configured to use ~/.ssh/id_ed25519_work

> Configure name/email for this repository? [Y/n]: Y
Name [Current User]: Organization User
Email [user@example.com]: user@organization.com
✓ Identity configured for this repository

# Direct configuration
$ git chronogit ssh-config
Select SSH key to use for this repository:
1) id_rsa (Personal)
2) id_ed25519_work (Organization)
3) id_ed25519_project (Project)

> Select key: 2
✓ Repository configured to use ~/.ssh/id_ed25519_work
```

## Pros and Cons

### Pros
- Separa claramente identidades pessoais e organizacionais
- Funciona com todos os comandos Git nativos
- Evita commits com informações de identidade incorretas
- Melhora segurança com chaves específicas por projeto
- Simplifica o gerenciamento de múltiplas identidades
- Não requer ferramentas ou configurações externas

### Cons
- Requer configuração inicial por repositório
- Pode ser confuso para usuários não familiarizados com SSH
- Exige manutenção de múltiplas chaves SSH
- Configuração local perdida se o repositório for clonado novamente

## Implementation
```bash
#!/bin/bash

# Add to chronogit.sh menu
show_ssh_menu() {
    clear
    echo -e "${BLUE}SSH and Identity Management${NC}"
    echo
    echo "1) List available SSH keys"
    echo "2) Configure SSH key for repository"
    echo "3) Configure identity (name/email)"
    echo "4) Back"
    echo
    read -p "Select option (1-4): " choice
    
    case $choice in
        1) list_ssh_keys ;;
        2) configure_ssh_key ;;
        3) configure_identity ;;
        4) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    read -p "Press Enter to continue..."
    show_ssh_menu
}

# Function to list available SSH keys
list_ssh_keys() {
    echo -e "${BLUE}Available SSH Keys:${NC}"
    echo
    
    local keys=()
    local i=1
    
    # Find all private keys in ~/.ssh
    while IFS= read -r key; do
        if [[ -f $key && ! $key =~ \.pub$ ]]; then
            local keyname=$(basename "$key")
            local comment=$(ssh-keygen -l -f "$key" 2>/dev/null | awk '{print $NF}' | tr -d '()')
            keys+=("$key")
            echo "$i) $keyname ${comment:+($comment)}"
            ((i++))
        fi
    done < <(find ~/.ssh -type f -name "id_*" | sort)
    
    if [ ${#keys[@]} -eq 0 ]; then
        echo "No SSH keys found in ~/.ssh/"
        echo "Generate a key with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        return
    fi
    
    echo
}

# Function to configure SSH key for repository
configure_ssh_key() {
    echo -e "${BLUE}Configure SSH Key for Repository${NC}"
    echo
    
    local keys=()
    local i=1
    
    # Find all private keys in ~/.ssh
    while IFS= read -r key; do
        if [[ -f $key && ! $key =~ \.pub$ ]]; then
            local keyname=$(basename "$key")
            local comment=$(ssh-keygen -l -f "$key" 2>/dev/null | awk '{print $NF}' | tr -d '()')
            keys+=("$key")
            echo "$i) $keyname ${comment:+($comment)}"
            ((i++))
        fi
    done < <(find ~/.ssh -type f -name "id_*" | sort)
    
    if [ ${#keys[@]} -eq 0 ]; then
        echo "No SSH keys found in ~/.ssh/"
        echo "Generate a key with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        return
    fi
    
    echo
    read -p "Select key (1-$((i-1))): " key_choice
    
    if [[ ! $key_choice =~ ^[0-9]+$ ]] || [ $key_choice -lt 1 ] || [ $key_choice -ge $i ]; then
        echo -e "${RED}Invalid choice${NC}"
        return
    fi
    
    local selected_key=${keys[$((key_choice-1))]}
    
    # Configure Git to use this SSH key for this repository
    git config --local core.sshCommand "ssh -i $selected_key -F /dev/null"
    echo -e "${GREEN}Repository configured to use $selected_key${NC}"
    
    # Ask if user wants to configure identity
    read -p "Configure name/email for this repository? [Y/n]: " configure_identity
    
    if [[ $configure_identity =~ ^[Yy]$ ]] || [ -z "$configure_identity" ]; then
        configure_identity
    fi
}

# Function to configure identity
configure_identity() {
    echo -e "${BLUE}Configure Identity for Repository${NC}"
    echo
    
    local current_name=$(git config --local user.name || git config --global user.name)
    local current_email=$(git config --local user.email || git config --global user.email)
    
    local new_name=$(prompt_with_default "Name" "$current_name")
    local new_email=$(prompt_with_default "Email" "$current_email")
    
    git config --local user.name "$new_name"
    git config --local user.email "$new_email"
    
    echo -e "${GREEN}Identity configured for this repository${NC}"
    echo "Name: $new_name"
    echo "Email: $new_email"
}

# Direct SSH configuration command
ssh_config_command() {
    configure_ssh_key
}
```

## Future Improvements
1. Adicionar detecção automática da organização baseada na URL do repositório
2. Adicionar perfis de identidade salvos (pessoal, trabalho, projetos específicos)
3. Integrar com sistemas de gerenciamento de chaves
4. Adicionar validação de chave SSH com o repositório remoto
5. Permitir configuração de várias chaves para diferentes hosts
6. Adicionar suporte para GPG signing key junto com SSH
7. Implementar sincronização de configurações entre computadores

## Integration
- Integra perfeitamente com o ChronoGit existente via comando `chronogit`
- Funciona com todos os comandos Git nativos (push, pull, clone, fetch)
- Complementa fluxos de trabalho em equipe com melhor identidade
- Compatível com GitHub, GitLab, Bitbucket e outros serviços Git
- Pode ser estendido para outras funcionalidades de segurança

## Configuration
```bash
# Configurações opcionais em .gitconfig
[workflow.ssh]
    # Caminho para o diretório de chaves SSH (default: ~/.ssh)
    keyDir = ~/.ssh
    # Exigir confirmação antes de mudar chaves
    confirmChange = true
    # Formato de exibição de chaves (nome, comentário, ambos)
    displayFormat = both
    # Sempre perguntar identidade ao configurar chave
    promptIdentity = true
```

## Error Handling
- Verifica permissões das chaves SSH
- Valida existência de chaves
- Testa conectividade com repositórios remotos
- Detecta configurações conflitantes
- Fornece mensagens claras de erro
- Oferece sugestões para resolução de problemas

## Best Practices
1. Usar chaves diferentes para repositórios pessoais e organizacionais
2. Proteger chaves privadas com passphrase
3. Revisar identidade antes de commits importantes
4. Configurar identidade imediatamente após clonar repositórios
5. Usar comentários descritivos ao gerar chaves SSH
6. Revisar periodicamente as configurações de identidade
7. Manter backup seguro das chaves privadas
