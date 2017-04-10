# works in zsh
precmd () {
  local filename=/dev/shm/cwd # tmpfs
  local dir=$(cat $filename)
  if [[ -n $dir ]] ; then
    cd $dir
    : > $filename
  fi
}
