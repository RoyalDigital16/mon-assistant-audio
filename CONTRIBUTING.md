# Contribuer à Mon Assistant Audio

Merci de votre intérêt pour contribuer à ce plugin Claude Code !

## Guide de développement

### Structure du plugin

```
mon-assistant-audio/
├── .claude-plugin/
│   ├── plugin.json          # Métadonnées du plugin (requis)
│   └── marketplace.json     # Configuration marketplace (distribution)
├── hooks/
│   ├── hooks.json           # Configuration des hooks (requis)
│   ├── play-interaction-sound.sh
│   ├── play-task-complete-sound.sh
│   └── session-start-analyze.sh
├── skills/
│   └── analyze-deps/
│       ├── SKILL.md         # Documentation du skill (requis)
│       └── analyze.sh       # Script principal
├── audio/
│   ├── interaction-needed.wav
│   └── task-complete.wav
├── install-claude-md-rules.sh
├── LICENSE
├── README.md
└── CONTRIBUTING.md
```

### Fichiers requis

#### `.claude-plugin/plugin.json`

Métadonnées du plugin (format standard Claude Code) :

```json
{
  "name": "mon-assistant-audio",
  "version": "1.0.0",
  "description": "...",
  "author": {
    "name": "Your Name"
  },
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/owner/repo.git"
  },
  "homepage": "https://github.com/owner/repo#readme",
  "keywords": ["audio", "dependencies"]
}
```

**Important** : Ne pas inclure `capabilities`, `skills`, ou `hooks` dans ce fichier. Les skills sont découverts automatiquement et les hooks sont définis dans `hooks/hooks.json`.

#### `hooks/hooks.json`

Configuration des hooks (format standard) :

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/script.sh"
          }
        ]
      }
    ]
  }
}
```

**Événements disponibles** :
- `SessionStart` : Au démarrage d'une session
- `Stop` : Quand Claude a fini de répondre
- `PermissionRequest` : Quand une permission est demandée

#### `skills/your-skill/SKILL.md`

Documentation du skill (format markdown) :

```markdown
# Skill Name

Description du skill.

## Invocation

```bash
/plugin-name:skill-name
```

## Fonctionnalités

...
```

### Tester localement

```bash
# Cloner le repository
git clone https://github.com/RoyalDigital16/mon-assistant-audio.git
cd mon-assistant-audio

# Rendre les scripts exécutables
chmod +x skills/analyze-deps/analyze.sh
chmod +x hooks/*.sh
chmod +x install-claude-md-rules.sh

# Tester le plugin
claude --plugin-dir .

# Tester un hook spécifique
CLAUDE_PLUGIN_ROOT=$(pwd) ./hooks/play-interaction-sound.sh

# Tester l'analyse des dépendances
CLAUDE_PLUGIN_ROOT=$(pwd) PROJECT_ROOT=$(pwd) ./skills/analyze-deps/analyze.sh

# Vérifier les logs
cat /tmp/claude-analyze-deps.log
```

### Vérifier la conformité

```bash
# Vérifier la structure du plugin
cat .claude-plugin/plugin.json
cat hooks/hooks.json

# Vérifier que le skill est reconnu
/plugin
# Aller dans l'onglet "Installed"
```

### Ajouter un nouveau hook

1. Créer le script dans `hooks/your-hook.sh`
2. Le rendre exécutable : `chmod +x hooks/your-hook.sh`
3. Ajouter la configuration dans `hooks/hooks.json`
4. Documenter le hook dans `README.md`

### Ajouter un nouveau skill

1. Créer le dossier `skills/your-skill/`
2. Créer `skills/your-skill/SKILL.md` avec la documentation
3. Créer le script principal `skills/your-skill/script.sh` (ou autre langage)
4. Le rendre exécutable : `chmod +x skills/your-skill/script.sh`
5. Documenter dans `README.md`

### Conventions de code

#### Scripts Bash

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Toujours vérifier les variables d'environnement
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    echo "Erreur: CLAUDE_PLUGIN_ROOT n'est pas défini" >&2
    exit 1
fi

# Utiliser des variables explicites
readonly PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
readonly PROJECT_ROOT="${PWD}"

# Gérer les erreurs proprement
handle_error() {
    echo "Erreur: $1" >&2
    exit 1
}

# Main code
...

exit 0
```

#### JSON

Utiliser 2 espaces pour l'indentation, pas de tabulations.

#### Documentation

- Écrire en français (ou anglais selon le public)
- Inclure des exemples d'utilisation
- Documenter les variables d'environnement
- Inclure une section "Sortie attendue"

### Tests

Avant de soumettre une contribution :

1. ✅ Les scripts sont exécutables (`chmod +x`)
2. ✅ Le plugin se charge correctement (`claude --plugin-dir .`)
3. ✅ Les hooks se déclenchent comme attendu
4. ✅ Les skills sont invoqués correctement
5. ✅ La documentation est à jour
6. ✅ Le code suit les conventions

### Soumettre une contribution

1. Forker le projet
2. Créer une branche : `git checkout -b feature/ma-fonction`
3. Commiter : `git commit -am 'Ajouter ma fonction'`
4. Pusher : `git push origin feature/ma-fonction`
5. Ouvrir une Pull Request

### Messages de commit

Utiliser des messages de commit clairs et descriptifs :

```
feat: add support for Python projects
fix: resolve audio playback issue on macOS
docs: update installation instructions
refactor: simplify hook configuration
```

### Ressources

- [Documentation Claude Code](https://code.claude.com/docs)
- [Spécifications des plugins](https://code.claude.com/docs/plugins-reference)
- [Marketplaces de plugins](https://code.claude.com/docs/plugin-marketplaces)

### Questions

Pour toute question, ouvrez une issue sur GitHub avec le tag `question`.
