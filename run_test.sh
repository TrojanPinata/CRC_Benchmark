#/bin/bash

start_time=$(date +%s)

command_file="commands_c.txt"
output_file="results_c.txt"

: > "$outputs"  # clear output file

{
    while true; do
        read -r compile || break    # reads in compile command
        read -r run || break        # reads in run command

        echo "Compiling: $compile"
        eval "$compile" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Error: Compilation failed for: $compile" | tee -a "$output_file"
            continue
        fi

        echo "Running: $run"
        output=$(eval "$run" 2>/dev/null)
        echo "$output"
        echo "$output" >> "$output_file"
    done

} < "$command_file"

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "Testing complete. Completed in $((SECONDS/60)) min $((SECONDS%60)) sec"