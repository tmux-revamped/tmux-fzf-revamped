#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin"
tmux_path=$(command -v tmux)
ln -s "${tmux_path}" "${demo}/bin/tmux"
mkdir -p "${demo}/tmux-fzf-revamped" "${demo}/projects/api" "${demo}/projects/docs" "${demo}/projects/web" "${demo}/home/.config/fzf-revamped"
printf '%s\n' "${demo}/projects/*" >"${demo}/home/.config/fzf-revamped/projects"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/fzf-revamped.tmux" "${demo}/tmux-fzf-revamped/"
printf '#!/bin/sh\nprintf "%%s\\n" /Users/Shared/demo/projects/api /Users/Shared/demo/projects/web\n' >"${demo}/bin/zoxide"
chmod 755 "${demo}/bin/zoxide"
mkdir -p "${demo}/popup-bin"
printf '#!/bin/sh\nprintf "%%s\\n" "  101 tmux" "  214 bash" "  377 node" "  378 vim" "  512 sleep" "  640 python3" "  702 htop"\n' >"${demo}/popup-bin/ps"
chmod 755 "${demo}/popup-bin/ps"
