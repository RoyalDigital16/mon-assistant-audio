#!/bin/bash
# Hook: PermissionRequest
# Joue un son quand Claude a besoin d'une interaction utilisateur

set -euo pipefail

# Récupération du chemin du plugin depuis la variable d'environnement
if [[ -z "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    echo "Erreur: CLAUDE_PLUGIN_ROOT n'est pas défini" >&2
    exit 1
fi

# Chemin vers le fichier audio
AUDIO_FILE="${CLAUDE_PLUGIN_ROOT}/audio/interaction-needed.wav"

# Détection de l'OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *)          echo "unknown";;
    esac
}

OS=$(detect_os)

# Vérification de l'existence du fichier
if [[ ! -f "$AUDIO_FILE" ]]; then
    echo "Fichier audio non trouvé: $AUDIO_FILE" >&2
    # Tentative de créer un fichier son par défaut
    mkdir -p "$(dirname "$AUDIO_FILE")"
    # Créer un fichier WAV minimal (en-tête seulement)
    # Format: WAV 16-bit, mono, 44100Hz, 1 seconde
    {
        printf "RIFF"
        printf '%06x' 36 | xxd -r -p
        printf "WAVEfmt "
        printf '%08x' 16 | xxd -r -p
        printf '%01x' 1 | xxd -r -p  # PCM
        printf '%01x' 1 | xxd -r -p  # Mono
        printf '%08x' 44100 | xxd -r -p  # Sample rate
        printf '%08x' 88200 | xxd -r -p  # Byte rate
        printf '%02x' 2 | xxd -r -p  # Block align
        printf '%02x' 16 | xxd -r -p  # Bits per sample
        printf "data"
        printf '%08x' 0 | xxd -r -p
    } > "$AUDIO_FILE" 2>/dev/null || true
fi

# Lecture du fichier audio selon l'OS
case "$OS" in
    linux)
        # Linux: essayer plusieurs lecteurs
        if command -v paplay &> /dev/null; then
            paplay "$AUDIO_FILE" 2>/dev/null &
        elif command -v aplay &> /dev/null; then
            aplay -q "$AUDIO_FILE" 2>/dev/null &
        elif command -v mpv &> /dev/null; then
            mpv --really-quiet --no-video "$AUDIO_FILE" 2>/dev/null &
        elif command -v ffplay &> /dev/null; then
            ffplay -nodisp -autoexit -loglevel quiet "$AUDIO_FILE" 2>/dev/null &
        else
            # Fallback: beep système
            echo -e "\a" >&2
        fi
        ;;
    macos)
        # macOS: utiliser afplay
        if command -v afplay &> /dev/null; then
            afplay "$AUDIO_FILE" 2>/dev/null &
        else
            # Fallback: beep
            echo -e "\a" >&2
        fi
        ;;
    windows)
        # Windows: utiliser PowerShell pour jouer un son
        if command -v powershell.exe &> /dev/null; then
            powershell.exe -Command \
                "(New-Object Media.SoundPlayer '$AUDIO_FILE').PlaySync()" \
                2>/dev/null &
        elif command -v cmd.exe &> /dev/null; then
            # Alternative: sons système Windows
            cmd.exe /c "echo " 2>/dev/null &
        else
            echo -e "\a" >&2
        fi
        ;;
    *)
        # Fallback générique
        echo -e "\a" >&2
        ;;
esac

exit 0
