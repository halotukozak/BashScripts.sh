#!/usr/bin/env bash
# shellcheck disable=SC2078
RANDOM=4096
COOKIE_FILE="cookie.txt"
SCORE_FILE="scores.txt"
LOGIN_DATA="rihanna:785bdf267c5244"
URL="http://0.0.0.0:8000/"

scores=0
function exit_game {
  echo "See you later!"
  exit
}

function right_answer {
  ((scores += 10))
  local RESPONSES=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")
  local size=${#RESPONSES[@]}
  local index=$((RANDOM % size))
  echo "${RESPONSES[${index}]}"
}

function wrong_answer {
  echo "Wrong answer, sorry!"
  echo "$name you have $((scores / 10)) correct answer(s)."
  echo "Your score is $scores points."
  echo "User: $name, Score: $scores, Date: $(date +%Y-%m-%d)" >> $SCORE_FILE
  scores=0

}

function play_game {
  echo "What is your name?"
  read name

  while [ TRUE ]; do
    local response
    local question
    local answer
    local user_answer
    local user_answer
    curl -sc ${COOKIE_FILE} -u ${LOGIN_DATA} ${URL}login
    response=$(curl -sb $COOKIE_FILE "${URL}game")
    question=$(python3 -c "data=${response}; print(data.get('question'))")
    answer=$(python3 -c "data=${response}; print(data.get('answer'))")

    echo "$question"
    echo "True or False?"

    read user_answer

    if [[ $answer == $user_answer ]]; then
      right_answer
    else
      wrong_answer
      break
    fi
  done
}

function display_scores {
  if [[ -a $SCORE_FILE ]]; then
    echo "Player scores"
    cat $SCORE_FILE
  else
    echo "File not found or no scores in it!"
  fi
}

function reset_scores {
  if [[ -a $SCORE_FILE ]]; then
    rm $SCORE_FILE
    echo "File deleted successfully!"
  else
    echo "File not found or no scores in it!"
  fi
}

echo "Welcome to the True or False Game!"

while [ TRUE ]; do
  printf "\n0. Exit\n1. Play a game\n2. Display scores\n3. Reset scores\nEnter an option:\n"
  read opt
  case $opt in
  0) exit_game ;;
  1) play_game ;;
  2) display_scores ;;
  3) reset_scores ;;
  *) echo "Invalid option!" ;;
  esac
done
