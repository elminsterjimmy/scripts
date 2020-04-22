function help() {
  echo "usage $0 -d <git dir> [-b <git branch (default master)>] [-r <date from (default from 1 week ago>]
}


GIT_DIR=""
GIT_BRANCH="master"
DATE_RANGE="-1week"


function opt() {
  optspec=":d:b:r:"
  while getopts "$optspec" opt; do
	case "${opt}" in
	  d ) GIT_DIR=$OPTARG;;
	  b ) GIT_BRANCH=$OPTARG;;
	  r ) DATE_RANGE=$OPTARG;;
	  \?) help; exit;;
	  : ) echo "Missing option argument for -$OPTARG" >&2; exit 2;;
	  * ) echo "Unimplemented option: -$OPTARG" >&2; exit 2;;
	esac
  done
  [ -z "$GIT_DIR" ] && help && exit 1
}

function collect() {
  NOW=`date +%Y%m%d`
  FROM_DATE=`date -d '-1week' +%Y%m%d`
  CODE_REVIEW_BASEDIR=/home/mystic/code_review
  CODE_REVIEW_DIR="$CODE_REVIEW_BASEDIR/code_review_$FROM_DATE-$NOW"
  CODE_REVIEW_TAR="$CODE_REVIEW_DIR/code_review.tar.gz"
  CODE_REVIEW_CSV="$CODE_REVIEW_DIR/code_review_$FROM_DATE-$NOW.csv"
  rm -rf "$CODE_REVIEW_DIR"
  mkdir -p "$CODE_REVIEW_DIR"
  
  cd "$GIT_DIR"
  echo "Collect commit from $FROM_DATE to $NOW"
  git log --since '1 week ago' --pretty=format:%H,%an,%cd,%s > "$CODE_REVIEW_CSV"
  LAST_COMMIT_SHA=`cat "$CODE_REVIEW_CSV" | awk -F "," 'END {print $1}'`
  echo "" >> "$CODE_REVIEW_CSV"
  COMMIT_COUNT=`wc -l "$CODE_REVIEW_DIR/code_review.csv" | cut -d' ' -f 1`
  echo "Total [$COMMIT_COUNT] to collect from [$LAST_COMMIT_SHA]"
  echo "Generate commit patchs"
  git format-patch "^$LAST_COMMIT_SHA" --output-directory "$CODE_REVIEW_DIR"
  echo "Tar code review file"
  tar cvzf "$code_review_tar" "$CODE_REVIEW_DIR"
  #mail -s "Weekly code review of master branch" -A "$code_review_tar" ""
}

opt
