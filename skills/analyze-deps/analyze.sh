#!/bin/bash
# Analyze Dependencies Skill - Main Script
# Ce script est appelé par Claude Code pour analyser les dépendances du projet

set -euo pipefail

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Détection du système d'exploitation
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS=linux;;
        Darwin*)    OS=macos;;
        MINGW*|MSYS*|CYGWIN*) OS=windows;;
        *)          OS=unknown;;
    esac
    export OS
}

# Détection du gestionnaire de paquets
detect_package_manager() {
    if [[ -f "package.json" ]]; then
        if command -v pnpm &> /dev/null && [[ -f "pnpm-lock.yaml" ]]; then
            echo "pnpm"
        elif command -v yarn &> /dev/null && [[ -f "yarn.lock" ]]; then
            echo "yarn"
        elif command -v bun &> /dev/null && [[ -f "bun.lockb" ]]; then
            echo "bun"
        else
            echo "npm"
        fi
    elif [[ -f "composer.json" ]]; then
        echo "composer"
    else
        echo "unknown"
    fi
}

# Création du dossier de documentation
create_docs_folder() {
    local docs_dir="${PROJECT_ROOT:-.}/docs-claude"
    mkdir -p "$docs_dir/packages"
    mkdir -p "$docs_dir/patterns"
    echo "$docs_dir"
}

# Extraction des dépendances depuis package.json
extract_npm_dependencies() {
    local package_json="${PROJECT_ROOT:-.}/package.json"

    if [[ ! -f "$package_json" ]]; then
        log_warning "package.json non trouvé"
        return 1
    fi

    log_info "Extraction des dépendances depuis package.json..."

    # Utiliser jq si disponible, sinon node
    if command -v jq &> /dev/null; then
        jq '{dependencies: .dependencies // {}, devDependencies: .devDependencies // {}}' "$package_json" > "$docs_dir/dependencies.json"
    else
        node -e "
        const pkg = require('./package.json');
        const deps = {
            dependencies: pkg.dependencies || {},
            devDependencies: pkg.devDependencies || {}
        };
        console.log(JSON.stringify(deps, null, 2));
        " > "$docs_dir/dependencies.json"
    fi

    log_success "Dépendances extraites dans docs-claude/dependencies.json"
}

# Extraction des dépendances depuis composer.json
extract_composer_dependencies() {
    local composer_json="${PROJECT_ROOT:-.}/composer.json"

    if [[ ! -f "$composer_json" ]]; then
        log_warning "composer.json non trouvé"
        return 1
    fi

    log_info "Extraction des dépendances depuis composer.json..."

    # Utiliser jq si disponible, sinon php
    if command -v jq &> /dev/null; then
        jq '{require: .require // {}, requireDev: .["require-dev"] // {}}' "$composer_json" > "$docs_dir/dependencies.json"
    else
        php -r "
        \$composer = json_decode(file_get_contents('composer.json'), true);
        \$deps = [
            'require' => \$composer['require'] ?? [],
            'requireDev' => \$composer['require-dev'] ?? []
        ];
        echo json_encode(\$deps, JSON_PRETTY_PRINT);
        " > "$docs_dir/dependencies.json"
    fi

    log_success "Dépendances extraites dans docs-claude/dependencies.json"
}

# Détection du framework principal
detect_framework() {
    local package_json="${PROJECT_ROOT:-.}/package.json"
    local composer_json="${PROJECT_ROOT:-.}/composer.json"
    local framework=""

    if [[ -f "$package_json" ]]; then
        # Détection pour Node.js
        if grep -q '"nuxt"' "$package_json"; then
            framework="nuxt"
        elif grep -q '"@nuxt/ui"' "$package_json"; then
            framework="nuxt-ui"
        elif grep -q '"next"' "$package_json"; then
            framework="next"
        elif grep -q '"vue"' "$package_json" && ! grep -q '"nuxt"' "$package_json"; then
            framework="vue"
        elif grep -q '"react"' "$package_json" && ! grep -q '"next"' "$package_json"; then
            framework="react"
        elif grep -q '"@angular/core"' "$package_json"; then
            framework="angular"
        elif grep -q '"svelte"' "$package_json"; then
            framework="svelte"
        elif grep -q '"remix-run"' "$package_json"; then
            framework="remix"
        elif grep -q '"astro"' "$package_json"; then
            framework="astro"
        fi
    elif [[ -f "$composer_json" ]]; then
        # Détection pour PHP
        if grep -q '"laravel/framework"' "$composer_json"; then
            framework="laravel"
        elif grep -q '"symfony"' "$composer_json"; then
            framework="symfony"
        elif grep -q '"wordpress"' "$composer_json"; then
            framework="wordpress"
        elif grep -q '"drupal"' "$composer_json"; then
            framework="drupal"
        fi
    fi

    echo "$framework"
}

# Génération du README de docs-claude
generate_docs_readme() {
    local framework="$1"
    local docs_dir="$2"

    cat > "$docs_dir/README.md" <<EOF
# Documentation du Projet

Cette documentation a été générée automatiquement par le plugin **mon-assistant-audio**.

## Type de projet

- **Framework** : ${framework:-"Non détecté"}
- **Gestionnaire de paquets** : $(detect_package_manager)
- **Date de génération** : $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Structure

- \`dependencies.json\` : Liste structurée des dépendances
- \`framework.md\` : Documentation du framework principal
- \`packages/\` : Documentation des packages importants
- \`patterns/\` : Patterns et bonnes pratiques

## Utilisation

Cette documentation est utilisée par Claude Code pour comprendre votre projet et vous fournir des réponses plus pertinentes.

## Mise à jour

Pour régénérer cette documentation, utilisez le skill \`/analyze-deps\` dans Claude Code.
EOF

    log_success "README généré dans docs-claude/README.md"
}

# Point d'entrée principal
main() {
    log_info "Démarrage de l'analyse des dépendances..."

    detect_os
    log_info "Système détecté : $OS"

    # Détection du projet
    local pkg_manager
    pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "unknown" ]]; then
        log_error "Aucun fichier package.json ou composer.json trouvé"
        log_info "Création du dossier docs-claude quand même..."
        local docs_dir
        docs_dir=$(create_docs_folder)
        exit 0
    fi

    log_info "Gestionnaire de paquets détecté : $pkg_manager"

    # Création du dossier de documentation
    local docs_dir
    docs_dir=$(create_docs_folder)

    # Extraction des dépendances
    if [[ "$pkg_manager" == "composer" ]]; then
        extract_composer_dependencies
    else
        extract_npm_dependencies
    fi

    # Détection du framework
    local framework
    framework=$(detect_framework)

    if [[ -n "$framework" ]]; then
        log_success "Framework détecté : $framework"
    else
        log_warning "Aucun framework détecté"
    fi

    # Génération du README
    generate_docs_readme "$framework" "$docs_dir"

    log_success "Analyse terminée ! Documentation disponible dans docs-claude/"
    log_info "Claude utilisera cette documentation pour vous aider plus efficacement."
}

# Exécution
main "$@"
