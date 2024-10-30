#!/bin/bash

# Array of quotes from Seneca on Stoicism
quotes=(
    "True happiness is to enjoy the present, without anxious dependence upon the future."
    "We are more often frightened than hurt; and we suffer more from imagination than from reality."
    "It is not because things are difficult that we do not dare, it is because we do not dare that they are difficult."
    "The whole future lies in uncertainty: live immediately."
    "Life is very short and anxious for those who forget the past, neglect the present, and fear the future."
    "It is quality rather than quantity that matters."
    "Difficulties strengthen the mind, as labor does the body."
    "The bravest sight in the world is to see a great man struggling against adversity."
    "We are born once and cannot be born twice, but we must be born again many times."
    "The greatest remedy for anger is delay."
)

# Get the total number of quotes
num_quotes=${#quotes[@]}

# Generate a random index
random_index=$((RANDOM % num_quotes))

# Print the random quote
echo "${quotes[$random_index]}"
