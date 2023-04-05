#!/bin/bash

inpipe="in"
outpipe="out"

# Create the input and output named pipes if they don't exist
if [ ! -p "$inpipe" ]; then
  mkfifo "$inpipe"
fi

if [ ! -p "$outpipe" ]; then
  mkfifo "$outpipe"
fi

while true; do
  # Read input from the input named pipe
  input=$(cat "$inpipe")

  # Perform the calculation using calc
  result=$(echo "$input" | calc)

  # Write the result to the output named pipe
  echo "$result" > "$outpipe"
done
