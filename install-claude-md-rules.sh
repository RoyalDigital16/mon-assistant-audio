#!/bin/bash
# Script d'installation des règles MCP dans le CLAUDE.md global
# Vérifie intelligemment si les règles sont déjà présentes

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

CLAUDE_MD_PATH="$HOME/.claude/CLAUDE.md"
mkdir -p "$(dirname "$CLAUDE_MD_PATH")"

MARKER_START="# BEGIN MCP RULES (mon-assistant-audio)"
MARKER_END="# END MCP RULES (mon-assistant-audio)"

MCP_RULES='# Règles globales pour Claude Code

- **Utilise systématiquement les MCPs disponibles** :
  - `browseros` pour tester des pages web, naviguer, vérifier le comportement utilisateur.
  - `context7` pour obtenir la documentation à jour des librairies, frameworks, langages.
  - `nuxt-remote` et `nuxt-ui-remote` pour les documentations officielles Nuxt.
  - `searxng` pour faire des recherches internet quand une information manque.
  - `laravel-boost` (quand disponible) pour interroger le projet Laravel en cours.

- **Avant de répondre à une question sur une bibliothèque**, vérifie sa version réelle dans le projet (package.json, composer.json) et utilise un MCP pour confirmer la documentation correspondant à cette version.

- **Quand tu rédiges du code**, privilégie les versions modernes (ex. Tailwind CSS 4) et adapte les exemples en fonction de la documentation récupérée.

- **Le dossier `docs-claude/`** contient des connaissances accumulées sur le projet. Consulte‑le régulièrement et mets‑le à jour si tu découvres des informations importantes.
'

# Vérifier si les règles avec marqueurs existent déjà
has_markered_rules() {
    [[ -f "$CLAUDE_MD_PATH" ]] && grep -q "$MARKER_START" "$CLAUDE_MD_PATH" 2>/dev/null
}

# Vérifier si le contenu existe (avec ou sans marqueurs)
has_content() {
    [[ -f "$CLAUDE_MD_PATH" ]] && grep -q "Utilise systématiquement les MCPs disponibles" "$CLAUDE_MD_PATH" 2>/dev/null
}

# Ajouter les règles avec marqueurs (remplace si existe sans marqueurs)
add_or_replace_rules() {
    local tmp_file
    tmp_file=$(mktemp)

    if [[ -f "$CLAUDE_MD_PATH" ]]; then
        # Supprimer l'ancien contenu sans marqueurs s'il existe
        grep -v "Utilise systématiquement les MCPs disponibles" "$CLAUDE_MD_PATH" 2>/dev/null | \
        grep -v "Avant de répondre à une question sur une bibliothèque" | \
        grep -v "Quand tu rédiges du code" | \
        grep -v "Le dossier \`docs-claude/\`\` contient" | \
        grep -v "^# Règles globales pour Claude Code$" | \
        grep -v "^  - \`browseros\` pour tester des pages web" | \
        grep -v "^  - \`context7\` pour obtenir la documentation" | \
        grep -v "^  - \`nuxt-remote\` et \`nuxt-ui-remote\`" | \
        grep -v "^  - \`searxng\` pour faire des recherches" | \
        grep -v "^  - \`laravel-boost\` (quand disponible)" | \
        grep -v "privilégie les versions modernes" | \
        grep -v "vérifie sa version réelle dans le projet" > "$tmp_file" || true

        # Nettoyer les lignes vides multiples
        awk 'NF {print} /^$/ {if (!blank) print; blank=1} NF {blank=0}' "$tmp_file" > "${tmp_file}.2"
        mv "${tmp_file}.2" "$tmp_file"

        # Ajouter une ligne vide si nécessaire
        if [[ -n "$(tail -c 1 "$tmp_file")" ]]; then
            echo "" >> "$tmp_file"
        fi
    fi

    # Ajouter les règles avec marqueurs
    cat >> "$tmp_file" << EOF

$MARKER_START
$MCP_RULES
$MARKER_END
EOF

    mv "$tmp_file" "$CLAUDE_MD_PATH"
    log_success "Règles MCP installées avec marqueurs dans $CLAUDE_MD_PATH"
}

# Supprimer les règles
remove_rules() {
    if [[ ! -f "$CLAUDE_MD_PATH" ]]; then
        log_warning "Le fichier $CLAUDE_MD_PATH n'existe pas."
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)

    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        BEGIN { blank=0 }
        $0 == start { in_section=1; next }
        $0 == end { in_section=0; next }
        !in_section {
            if (NF || !blank) { print; blank=NF==0 }
        }
    ' "$CLAUDE_MD_PATH" > "$tmp_file"

    mv "$tmp_file" "$CLAUDE_MD_PATH"
    log_success "Règles MCP supprimées de $CLAUDE_MD_PATH"
}

# Afficher les règles actuelles
show_rules() {
    if [[ -f "$CLAUDE_MD_PATH" ]]; then
        if has_markered_rules; then
            echo ""
            sed -n "/$MARKER_START/,/$MARKER_END/p" "$CLAUDE_MD_PATH"
        elif has_content; then
            echo ""
            log_warning "Les règles existent mais sans marqueurs de gestion."
            echo ""
            grep -A 15 "Utilise systématiquement les MCPs disponibles" "$CLAUDE_MD_PATH" || echo "Contenu partiel"
        else
            log_info "Aucune règle MCP trouvée."
        fi
    else
        log_info "Le fichier $CLAUDE_MD_PATH n'existe pas encore."
    fi
}

# Main
main() {
    case "${1:-}" in
        install|add)
            if has_markered_rules; then
                log_warning "Les règles avec marqueurs existent déjà."
                echo "Utilisez '$0 update' pour mettre à jour ou '$0 remove' pour supprimer."
            else
                if has_content; then
                    log_info "Contenu détecté sans marqueurs. Remplacement avec marqueurs..."
                fi
                add_or_replace_rules
            fi
            ;;
        update)
            remove_rules
            add_or_replace_rules
            ;;
        remove|uninstall)
            remove_rules
            ;;
        show|status)
            show_rules
            ;;
        *)
            echo "Usage: $0 {install|update|remove|show}"
            echo ""
            echo "  install  - Installe les règles (remplace si existe sans marqueurs)"
            echo "  update   - Met à jour les règles existantes"
            echo "  remove   - Supprime les règles"
            echo "  show     - Affiche les règles actuelles"
            echo ""
            show_rules
            exit 1
            ;;
    esac
}

main "$@"
