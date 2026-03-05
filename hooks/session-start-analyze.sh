#!/bin/bash
# Hook: SessionStart
# Lance l'analyse des dépendances en arrière-plan au début de chaque session
# Vérifie la présence de package.json ou composer.json

set -euo pipefail

# Récupération du chemin du plugin depuis la variable d'environnement
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    echo "Erreur: CLAUDE_PLUGIN_ROOT n'est pas défini" >&2
    exit 1
fi

# Récupération du répertoire de travail actuel (projet)
PROJECT_ROOT="${PWD}"

# Exporter pour le script d'analyse
export CLAUDE_PLUGIN_ROOT
export PROJECT_ROOT

# Vérifier si le projet a un fichier de dépendances
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    # Lancer l'analyse en arrière-plan pour ne pas bloquer la session
    (
        sleep 2  # Attendre un peu que la session soit stabilisée
        bash "${CLAUDE_PLUGIN_ROOT}/skills/analyze-deps/analyze.sh"
    ) > /tmp/claude-analyze-deps.log 2>&1 &
    disown $!  # Détacher le processus
elif [[ -f "$PROJECT_ROOT/composer.json" ]]; then
    # Lancer l'analyse pour un projet PHP/Laravel
    (
        sleep 2
        bash "${CLAUDE_PLUGIN_ROOT}/skills/analyze-deps/analyze.sh"
    ) > /tmp/claude-analyze-deps.log 2>&1 &
    disown $!
fi

exit 0
