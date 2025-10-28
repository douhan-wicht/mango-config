#!/usr/bin/env bash
set -euo pipefail
sleep 1

# --- helpers ---------------------------------------------------------
best_mode_for() {
    local out=$1
    wlr-randr --output "$out" |
        awk '/px, [0-9.]+ Hz/ {
            split($1,a,"x"); w=a[1]; h=a[2]; r=$3;
            printf "%d %d %.6f\n", w, h, r
        }' |
        sort -k1,1n -k2,2n -k3,3n |
        tail -n1 |
        awk '{printf "%dx%d@%0.6fHz",$1,$2,$3}'
}

scale_for() {
    local res=$1
    local width=${res%x*}
    if   (( width >= 5000 )); then echo 2
    elif (( width >= 3800 )); then echo 1.5
    else                           echo 1
    fi
}

notify() { command -v notify-send >/dev/null && notify-send -a "Monitor Setup" "$1" "$2"; }

# --- detect outputs --------------------------------------------------
internal=$(wlr-randr | awk '/^(eDP|LVDS)-/ {print $1; exit}')
external=$(wlr-randr | awk '/^(DP|HDMI)-/ {print $1; exit}')

# --- main logic ------------------------------------------------------
if [[ -n "$external" && $(wlr-randr --output "$external" | grep -c "px,") -gt 0 ]]; then
    echo "External monitor $external detected → external only"
    best=$(best_mode_for "$external")
    res=${best%@*}
    scale=$(scale_for "$res")
    echo "$external → $best • scale $scale"
    [[ -n "$internal" ]] && wlr-randr --output "$internal" --off || true
    wlr-randr --output "$external" --mode "$best" --pos 0,0 --scale "$scale"
    notify "External Monitor Activated" "$external • $best • scale $scale×"
else
    echo "No external monitor → internal only"
    if [[ -n "$internal" ]]; then
        best=$(best_mode_for "$internal")
        res=${best%@*}
        scale=$(scale_for "$res")
        echo "$internal → $best • scale $scale"
        wlr-randr --output "$internal" --on --mode "$best" --pos 0,0 --scale "$scale"
        notify "Laptop Display Activated" "$internal • $best • scale $scale×"
    else
        notify "Monitor Script" "No active display found!"
    fi
fi

