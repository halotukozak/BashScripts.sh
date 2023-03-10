#!/usr/bin/env bash
# shellcheck disable=SC2078
SCORE_FILE="scores.txt"
#Bash doesn't support returning arrays...
declare question correct_answer URL category_URL
declare -i scores answers

get_session_token() {
  URL="https://opentdb.com/"
  local SESSION_TOKEN=$(curl -s "$URL""api.php?command=request" | jq -r ".token")
  category_URL=$URL"api.php?amount=1&type=boolean&token=${SESSION_TOKEN}"
}

exit_game() {
  echo "See you later!"
  exit
}

right_answer() {
  ((scores += 10))
  local RESPONSES=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")
  local size=${#RESPONSES[@]}
  local index=$((RANDOM % size))
  echo "${RESPONSES[${index}]}"
}

wrong_answer() {
  echo "Wrong answer, sorry!"
  echo "$name you have $answers correct answer(s)."
  echo "Your score is $scores points."
  echo "User: $name, Score: $scores, Date: $(date +%Y-%m-%d)" >>$SCORE_FILE
  scores=0
  answers=0

}

get_question() {
  local response=$(curl -s "$category_URL")
  if [[ "$#" == 1 ]]; then
    response+=$1
  fi
  question=$(echo -e "$response" | jq -r '.results[].question' | recode html..ascii)
  correct_answer=$(echo -e "$response" | jq -r '.results[].correct_answer' | recode html..ascii)
}

pick_category() {
  while [ TRUE ]; do
    select opt in "Play" "Display Scores" "Reset Scores" "Exit"; do
      case $opt in
      "Play") play_game ;;
      "Display Scores") display_scores ;;
      "Reset Scores") reset_scores ;;
      "Exit") exit_game ;;
      *) echo "Invalid option!" ;;
      esac
      break
    done
  done
}

play_game() {
  clear
  echo "What is your name?"
  read -r name
  while [ TRUE ]; do
    local user_answer
    get_question $category

    echo "$question"
    read -r -p "True or False? " user_answer

    if [[ "$correct_answer" == "$user_answer" ]]; then
      right_answer
    else
      wrong_answer
      break
    fi
  done
}

display_scores() {
  clear
  if [[ -e $SCORE_FILE ]]; then
    echo "Player scores"
    cat $SCORE_FILE
  else
    echo "File not found or no scores in it!"
  fi
}

reset_scores() {
  clear
  if [[ -e $SCORE_FILE ]]; then
    rm $SCORE_FILE
    echo "File deleted successfully!"
  else
    echo "File not found or no scores in it!"
  fi
}

menu() {
  while [ TRUE ]; do
    select opt in "Play" "Display Scores" "Reset Scores" "Exit"; do
      case $opt in
      "Play") play_game ;;
      "Display Scores") display_scores ;;
      "Reset Scores") reset_scores ;;
      "Exit") exit_game ;;
      *) echo "Invalid option!" ;;
      esac
      break
    done
  done
}

is_not_installed() {
  if [[ "" = $(dpkg-query -W --showformat='${Status}\n' "$1" 2>/dev/null | grep "install ok installed") ]]; then
    return 0
  else
    return 1
  fi
}

install_required_packages() {
  local REQUIRED_PACKAGES=("jq")
  local pkg
  for pkg in $REQUIRED_PACKAGES; do
    while is_not_installed "$pkg"; do
      echo "Our game requires $pkg. Setting up $pkg."
      sudo -S apt-get --yes install "$pkg"
    done
  done
}

get_categories() {
  declare -A array
  local category name id
  while read -r category; do
    IFS=: read name id < <(echo $category | sed 's/:/./2')

    category_names+=($name)
    category_ids+=($id)
  done < <(
    curl -s "$URL""api_category.php" | jq '.trivia_categories | .[] | { (.name) : (.id) }' | tr -d '"{}'
  )
  echo "t"
}

run_game() {
  clear
  echo "Welcome to the True or False Game!"
  get_session_token
  get_categories
  menu
}

install_required_packages
run_game
