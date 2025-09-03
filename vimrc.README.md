# Configuration Vim moderne

Cette configuration Vim fusionne une base solide avec des outils modernes de développement.

## Installation sécurisée

### 1. Sauvegarde
```bash
cp ~/.vimrc ~/.vimrc.backup
```

### 2. Installation de vim-plug (gestionnaire de plugins)
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 3. Copier la configuration
```bash
cp vimrc ~/.vimrc
```

### 4. Installer les plugins
```bash
vim
:PlugInstall
```

### 5. Installer les dépendances système

#### Ruby LSP et outils
```bash
gem install ruby-lsp rubocop
```

#### Recherche rapide (choisir selon votre OS)
```bash
# Ubuntu/Debian
sudo apt install silversearcher-ag

# macOS
brew install the_silver_searcher

# Arch Linux
sudo pacman -S the_silver_searcher
```

### 6. Configuration CoC pour Ruby

Créer `~/.vim/coc-settings.json` :
```json
{
  "languageserver": {
    "ruby": {
      "command": "ruby-lsp",
      "filetypes": ["ruby"],
      "rootPatterns": ["Gemfile", ".git/"]
    }
  }
}
```

## Fonctionnalités

### Raccourcis (leader = `,`)
- `,s` : Recharger .vimrc
- `,v` : Éditer .vimrc
- `,t` : Nouveau tab
- `,w` : Fermer tab
- `,p` : Navigation rapide fichiers (fzf)
- `,f` : Recherche dans fichiers
- `gd` : Aller à la définition (LSP)
- `gr` : Voir les références (LSP)

### Auto-validation
Support automatique pour : Ruby, Python, JavaScript, JSON, YAML, etc.

### Formatage
- Ruby : rufo
- JS/TS/CSS : prettier

## Vérifications de sécurité

Cette configuration évite :
- Les téléchargements automatiques
- L'exécution de code non vérifié
- Les installations automatiques

Toutes les installations sont manuelles et transparentes.
