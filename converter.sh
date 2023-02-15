#!/usr/bin/bash
file_name="definitions.txt"

printDefinitions() {
  i=1
  while read -r line; do
    echo $i". ""$line"
    ((i += 1))
  done <$file_name
}

addDefinition() {
  re="^[a-zA-Z]+_to_[A-Za-z]+ -?[0-9]+(.[0-9]+)?$"

  while true; do
    echo "Enter a definition:"
    read -r input

    if [[ "$input" =~ $re ]]; then
      break
    else
      echo "The definition is incorrect!"
    fi
  done
  echo "$input" >>"$file_name"

}

deleteDefinition() {
  if [ -s $file_name ]; then
    echo "Type the line number to delete or '0' to return"
    printDefinitions
    while true; do
      read -r line_number
      if [ "$line_number" -eq 0 ]; then
        break
      fi
      size=$(cat $file_name | wc -l)
      if [[ $line_number =~ ^[0-9]+$ && $line_number -le $size ]]; then
        break
      else
        echo "Enter a valid line number!"
      fi
    done
    sed -i "${line_number}d" "$file_name"
  else
    echo "Please add a definition first!"
  fi

}

convertUnits() {
  if [ -s $file_name ]; then
    echo "Type the line number to convert units or '0' to return"
    printDefinitions
    while true; do
      read -r line_number
      if [[ "$line_number" == "0" ]]; then
        break
      fi
      size=$(cat $file_name | wc -l)
      if [[ $line_number =~ ^[0-9]+$ && $line_number -le $size ]]; then
        line=$(sed "${line_number}!d" "$file_name")
        read definition <<<"$line"
        constant=$(echo $definition | cut -d " " -f 2)
        echo "Enter a value to convert:"
        while true; do
          read -r value
          if [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            break
          fi
          echo "Enter a float or integer value!"
        done
        result=$(echo "scale=2; $constant * $value" | bc -l)
        echo "Result: ""$result"
        break
      else
        echo "Enter a valid line number!"
      fi
    done
  else
    echo "Please add a definition first!"
  fi
}

menu() {
  echo "Welcome to the Simple converter!"
  while true; do
    echo "Select an option
0. Type '0' or 'quit' to end program
1. Convert units
2. Add a definition
3. Delete a definition"
    read -r option
    case $option in
    0 | "quit")
      echo "Goodbye!"
      break
      ;;
    1) convertUnits ;;
    2) addDefinition ;;
    3) deleteDefinition ;;
    *) echo "Invalid option!" ;;
    esac
  done
}
menu
