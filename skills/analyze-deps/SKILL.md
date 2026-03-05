# Analyze Dependencies

Analyse automatiquement les dépendances du projet et documente leur utilisation via les MCPs disponibles.

## Invocation

Ce skill peut être invoqué manuellement ou automatiquement :

```bash
# Appel manuel avec le préfixe complet du plugin
/mon-assistant-audio:analyze-deps

# Appel manuel court (si pas de conflit)
/analyze-deps

# Déclenchement automatique via le hook SessionStart
# Se lance automatiquement au début de chaque session
```

## Fonctionnalités

### Détection automatique
- Détecte la présence de `package.json` (Node.js/npm/yarn/pnpm) ou `composer.json` (PHP/Laravel)
- Identifie le type de projet et l'écosystème concerné
- Lance l'analyse en arrière-plan pour ne pas bloquer la session

### Analyse des dépendances
- Parse le fichier de dépendances
- Extrait les dépendances principales et de développement
- Identifie les versions et les contraintes
- Détecte le framework principal (Nuxt, Vue, React, Laravel, etc.)

### Documentation via MCPs
Utilise intelligemment les MCPs disponibles pour récupérer la documentation à jour :

#### MCPs utilisés
- **browseros** : Contrôle du navigateur pour accéder à la documentation web
- **context7** : Documentation générale des bibliothèques JavaScript/PHP
- **nuxt-remote** : Documentation officielle de Nuxt.js
- **nuxt-ui-remote** : Documentation officielle de Nuxt UI
- **searxng** : Recherche internet pour la documentation manquante
- **laravel-boost** : Documentation spécifique pour les projets Laravel

### Stockage structuré
Les informations sont stockées dans le dossier `docs-claude/` à la racine du projet :

```
docs-claude/
├── README.md                 # Vue d'ensemble de la documentation
├── dependencies.json         # Liste structurée des dépendances
├── framework.md              # Documentation du framework principal
├── packages/                 # Dossiers pour les packages importants
│   ├── tailwindcss.md       # Doc Tailwind CSS
│   ├── vue.md               # Doc Vue.js
│   ├── nuxt.md              # Doc Nuxt
│   └── ...                  # Autres packages
└── patterns/                # Patterns et bonnes pratiques
    ├── testing.md           # Stratégies de test
    └── deployment.md        # Déploiement
```

### Auto-memory integration
Enrichit automatiquement la base de connaissances du projet via l'auto-memory de Claude Code :
- Crée des mémoires persistantes pour les patterns récurrents
- Stocke les décisions architecturales
- Documente les conventions du projet

## Configuration

### Variables d'environnement
Le skill utilise les variables d'environnement suivantes :
- `CLAUDE_PLUGIN_ROOT` : Chemin racine du plugin (injection automatique)
- `PROJECT_ROOT` : Chemin racine du projet (déduit du contexte)
- `DOCS_CLADE_DIR` : Chemin du dossier de documentation (par défaut `docs-claude/`)

### Logs
Les logs de l'analyse sont stockés dans `/tmp/claude-analyze-deps.log` pour le débogage.

## Exemples d'utilisation

```bash
# Appel manuel depuis Claude Code
/mon-assistant-audio:analyze-deps

# Vérifier les logs
cat /tmp/claude-analyze-deps.log

# Lancer manuellement le script (pour tests)
CLAUDE_PLUGIN_ROOT=/path/to/plugin PROJECT_ROOT=$(pwd) ./skills/analyze-deps/analyze.sh
```

## Sortie attendue

Le skill génère :

1. **Une analyse structurée** des dépendances dans `docs-claude/dependencies.json`
2. **Des fichiers de documentation** pour chaque package important
3. **Un README** dans `docs-claude/` avec une vue d'ensemble
4. **Des mémoires** dans l'auto-memory de Claude Code

## Hook associé

Ce skill est automatiquement déclenché par le hook `SessionStart` défini dans `hooks/hooks.json` :

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start-analyze.sh"
          }
        ]
      }
    ]
  }
}
```

## Compatibilité

- **Plateformes** : Linux, macOS, Windows (via WSL ou Git Bash)
- **Langages** : JavaScript, TypeScript, PHP, Vue.js, Nuxt, Laravel
- **Gestionnaires de paquets** : npm, yarn, pnpm, bun, composer
- **Claude Code** : Version 2.1.69 ou ultérieure
