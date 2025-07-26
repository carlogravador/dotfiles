
main() {
  disk_info=$(df -h / | tail -n -1 | awk -F' ' '{print $4 " free of " $2}')
  echo "${disk_info}"
}

main
