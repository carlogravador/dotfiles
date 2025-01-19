
main() {
  disk_info=$(df -h / | tail -n -1 | awk -F' ' '{print "Disk: " $3 "/" $2}')
  echo ${disk_info}
}

main
