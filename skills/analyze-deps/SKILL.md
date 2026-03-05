# Analyze Dependencies

Analyse automatiquement les dépendances du projet et documente leur utilisation via les MCPs disponibles.

## Déclencheur

Ce skill est invoqué automatiquement par Claude lorsqu'il détecte un package.json ou composer.json à la racine du projet, ou peut être appelé manuellement avec `/analyze-deps`.

## Fonctionnalités

### Détection automatique
- Détecte la présence de `package.json` (Node.js/npm/yarn/pnpm) ou `composer.json` (PHP/Laravel)
- Identifie le type de projet et l'écosystème concerné

### Analyse des dépendances
- Parse le fichier de dépendances
- Extrait les dépendances principales et de développement
- Identifie les versions et les contraintes

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

## Exemples d'utilisation

```bash
# Appel manuel
/analyze-deps

# Déclenchement automatique
# Dès que Claude détecte package.json ou composer.json
```

## Sortie attendue

Le skill génère :

1. **Une analyse structurée** des dépendances dans `docs-claude/dependencies.json`
2. **Des fichiers de documentation** pour chaque package important
3. **Un README** dans `docs-claude/` avec une vue d'ensemble
4. **Des mémoires** dans l'auto-memory de Claude Code

## Configuration

Le skill utilise les variables d'environnement suivantes :
- `CLAUDE_PLUGIN_ROOT` : Chemin racine du plugin
- `PROJECT_ROOT` : Chemin racine du projet (déduit du contexte)
- `DOCS_CLAUDE_DIR` : Chemin du dossier de documentation (par défaut `docs-claude/`)

## Compatibilité

- **Plateformes** : Linux, macOS, Windows (via WSL ou Git Bash)
- **Langages** : JavaScript, TypeScript, PHP, Vue.js, Nuxt, Laravel
- **Gestionnaires de paquets** : npm, yarn, pnpm, bun, composer
