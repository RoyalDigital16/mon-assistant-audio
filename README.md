# Mon Assistant Audio

Un plugin Claude Code qui ajoute des notifications sonores et analyse automatiquement les dépendances de votre projet.

## Fonctionnalités

### 1. Notifications Sonores

- **Interaction requise** : Un son est joué quand Claude a besoin de votre permission ou d'une interaction
- **Tâche terminée** : Un son est joué quand Claude a fini de répondre

### 2. Analyse Automatique des Dépendances

Le skill `analyze-deps` :

- Détecte automatiquement `package.json` (Node.js) ou `composer.json` (PHP/Laravel)
- Analyse toutes les dépendances du projet
- Identifie le framework principal (Nuxt, Vue, React, Laravel, etc.)
- Utilise les MCPs disponibles pour récupérer la documentation à jour :
  - `browseros` pour contrôler le navigateur
  - `context7` pour la documentation générale
  - `nuxt-remote` pour la doc Nuxt
  - `nuxt-ui-remote` pour la doc Nuxt UI
  - `searxng` pour la recherche internet
  - `laravel-boost` pour les projets Laravel
- Stocke la documentation dans `docs-claude/` à la racine du projet
- Enrichit l'auto-memory de Claude Code

## Installation

### Méthode 1: Installation locale (recommandée pour le développement)

```bash
# Clonez le repository
git clone https://github.com/votre-username/mon-assistant-audio.git
cd mon-assistant-audio

# Utilisez le plugin avec --plugin-dir
claude --plugin-dir /chemin/vers/mon-assistant-audio
```

### Méthode 2: Installation globale

```bash
# Copiez le plugin dans le dossier des plugins Claude
cp -r mon-assistant-audio ~/.claude/plugins/
```

### Méthode 3: Installation via le marketplace

```bash
# (Quand le plugin sera publié sur le marketplace)
claude plugin install mon-assistant-audio
```

## Utilisation

### Analyse automatique

L'analyse des dépendances se lance automatiquement au début de chaque session si un `package.json` ou `composer.json` est détecté.

### Appel manuel

```bash
/analyze-deps
```

### Documentation générée

Après l'analyse, vous trouverez :

```
docs-claude/
├── README.md                 # Vue d'ensemble
├── dependencies.json         # Dépendances structurées
├── framework.md              # Doc du framework principal
├── packages/                 # Documentation des packages
│   ├── tailwindcss.md
│   ├── vue.md
│   └── ...
└── patterns/                 # Patterns et bonnes pratiques
    ├── testing.md
    └── deployment.md
```

## Personnalisation

### Sons personnalisés

Remplacez les fichiers audio dans le dossier `audio/` :

- `interaction-needed.wav` : Son joué quand une interaction est nécessaire
- `task-complete.wav` : Son joué quand une tâche est terminée

**Format recommandé :**
- Codec: PCM 16-bit
- Canaux: Mono ou Stéréo
- Fréquence: 44100 Hz ou 48000 Hz
- Durée: 0.5 à 2 secondes

**Exemples de génération avec ffmpeg :**

```bash
# Son d'interaction (tonalité montante)
ffmpeg -f lavfi -i "sine=frequency=600:duration=0.5" \
       -ar 44100 -ac 1 -f wav audio/interaction-needed.wav

# Son de succès (accord simple)
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.1" \
       -af "volume=0.5" \
       -ar 44100 -ac 1 -f wav audio/task-complete.wav
```

### Désactiver les sons

Si vous ne voulez pas de notifications sonores, commentez les hooks dans `.claude-plugin/plugin.json` :

```json
{
  "capabilities": {
    "hooks": [
      // {
      //   "event": "Notification",
      //   "matcher": "permission_prompt|elicitation_dialog",
      //   "command": "${CLAUDE_PLUGIN_ROOT}/hooks/play-interaction-sound.sh"
      // },
      // {
      //   "event": "Stop",
      //   "command": "${CLAUDE_PLUGIN_ROOT}/hooks/play-task-complete-sound.sh"
      // },
      {
        "event": "SessionStart",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start-analyze.sh"
      }
    ]
  }
}
```

### Désactiver l'analyse automatique

Pour désactiver l'analyse au démarrage de session, commentez le hook `SessionStart`.

### Installation des règles MCP globales

Le plugin inclut un script pour ajouter automatiquement les règles MCP dans votre fichier `CLAUDE.md` global (`~/.claude/CLAUDE.md`). Ces règles indiquent à Claude d'utiliser les MCPs disponibles pour consulter la documentation.

```bash
# Depuis le dossier du plugin
./install-claude-md-rules.sh install

# Ou avec le chemin complet
/path/to/mon-assistant-audio/install-claude-md-rules.sh install
```

**Commandes disponibles :**

```bash
./install-claude-md-rules.sh install   # Installe les règles
./install-claude-md-rules.sh update    # Met à jour les règles existantes
./install-claude-md-rules.sh remove    # Supprime les règles
./install-claude-md-rules.sh show      # Affiche les règles actuelles
```

Le script détecte automatiquement si les règles sont déjà présentes (avec ou sans marqueurs) et évite les doublons.

## Dépendances

### MCPs (optionnels mais recommandés)

Le plugin fonctionne mieux avec ces MCPs installés :

- **browseros** : Contrôle du navigateur
- **context7** : Documentation des bibliothèques
- **nuxt-remote** : Documentation Nuxt
- **nuxt-ui-remote** : Documentation Nuxt UI
- **searxng** : Recherche internet
- **laravel-boost** : Documentation Laravel

### Outils système

Pour les sons, le plugin utilise automatiquement :

- **Linux** : `paplay` (PulseAudio), `aplay` (ALSA), `mpv`, ou `ffplay`
- **macOS** : `afplay` (inclus)
- **Windows** : PowerShell

Aucune installation requise, le plugin utilise ce qui est disponible.

## Structure du plugin

```
mon-assistant-audio/
├── .claude-plugin/
│   └── plugin.json              # Manifeste du plugin
├── skills/
│   └── analyze-deps/
│       ├── SKILL.md             # Documentation du skill
│       └── analyze.sh           # Script d'analyse
├── hooks/
│   ├── play-interaction-sound.sh
│   ├── play-task-complete-sound.sh
│   └── session-start-analyze.sh
├── audio/
│   ├── interaction-needed.wav   # Son pour interaction requise
│   └── task-complete.wav        # Son pour tâche terminée
├── install-claude-md-rules.sh   # Script d'installation des règles MCP
├── LICENSE                      # Licence MIT
└── README.md                    # Ce fichier
```

## Développement

### Rendre les scripts exécutables

```bash
chmod +x skills/analyze-deps/analyze.sh
chmod +x hooks/*.sh
```

### Tester localement

```bash
# Test du plugin
claude --plugin-dir . --test

# Test d'un hook
./hooks/play-interaction-sound.sh

# Test de l'analyse
./skills/analyze-deps/analyze.sh
```

## Publication

### Pour publier sur le marketplace

1. Assurez-vous que le repository est public sur GitHub
2. Vérifiez que `plugin.json` contient les bonnes informations
3. Soumettez le plugin au marketplace Claude Code
4. Attendez la validation

## Licence

MIT License - voir le fichier LICENSE pour plus de détails.

## Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Forker le projet
2. Créer une branche (`git checkout -b feature/ma-fonction`)
3. Commiter (`git commit -am 'Ajouter ma fonction'`)
4. Pusher (`git push origin feature/ma-fonction`)
5. Ouvrir une Pull Request

## Support

Pour les bugs ou suggestions, ouvrez une issue sur GitHub :

https://github.com/votre-username/mon-assistant-audio/issues

## Changelog

### Version 1.0.0 (2025-01-05)

- Notifications sonores pour interactions et fin de tâche
- Analyse automatique des dépendances
- Support de npm, yarn, pnpm, bun, composer
- Détection automatique des frameworks
- Génération de documentation structurée
- Integration avec l'auto-memory de Claude Code
