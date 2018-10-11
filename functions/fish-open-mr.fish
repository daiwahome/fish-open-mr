function open-mr
  argparse -n open-mr 'd/debug' 't/token=' -- $argv
  or return

  if not git rev-parse > /dev/null 2>&1
    echo 'fatal: not a git repository'
    return
  end

  set -l project (git remote get-url origin | sed -e 's|^.*/\([^/]\+/.\+\)\.git$|\1|' | sed 's|/|%2F|g')
  set -l branch (git rev-parse --abbrev-ref HEAD)
  set -l api_url "https://rendezvous.m3.com/api/v4/projects/$project/merge_requests?source_branch=$branch"
  if set -lq _flag_token
      set api_url "$api_url&private_token=$_flag_token"
  end

  set -l result (curl -s $api_url)
  if set -lq _flag_debug
    echo "curl -s $api_url"
    echo $result
  end

  if echo $result | grep -q message
      echo 'Error:' (echo $result | jq -r '.message')
      return
  end

  set -l mr_url (echo $result | jq -r '.[] | .web_url')

  echo "open $mr_url"
  open $mr_url
end
