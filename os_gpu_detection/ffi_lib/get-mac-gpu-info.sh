if [[ -f "${cache_dir}/neofetch/gpu" ]]; then
    source "${cache_dir}/neofetch/gpu"
else
    gpu="$(system_profiler SPDisplaysDataType |\
            awk -F': ' '/^\ *Chipset Model:/ {printf $2 ", "}')"
    gpu="${gpu//\/ \$}"
    gpu="${gpu%,*}"

    # cache "gpu" "$gpu"
fi

touch enum-gpu

echo "$gpu" >> enum-gpu
