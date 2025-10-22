#!/usr/bin/env bash

palette="/etc/stylix/palette.json"
out="$HOME/.config/btop/themes/stylix.theme"

jq -r '
  . as $p |
  "# Auto-generated Stylix theme for btop\n" +
  "theme[main_bg]=\"#" + $p.base00 + "\"\n" +
  "theme[main_fg]=\"#" + $p.base05 + "\"\n" +
  "theme[hi_fg]=\"#" + $p.base08 + "\"\n" +
  "theme[menu_bg]=\"#" + $p.base01 + "\"\n" +
  "theme[menu_fg]=\"#" + $p.base06 + "\"\n" +
  "theme[title_fg]=\"#" + $p.base0A + "\"\n" +
  "theme[graph_1]=\"#" + $p.base0B + "\"\n" +
  "theme[graph_2]=\"#" + $p.base0C + "\"\n" +
  "theme[graph_3]=\"#" + $p.base0D + "\"\n"
' "$palette" > "$out"

