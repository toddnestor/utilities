parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\] $(parse_git_branch)\[\033[00m\]\$ '

. /usr/share/bash-completion/completions/git

alias gs='git status'
alias gr='git reflog'
alias gh='git push'
alias gp='git pull'
alias gc='git commit'
alias gl='git log'
alias gb='git branch'
alias gbd='git branch -D'
alias ga='git add -p'
alias gpm='git pull origin main'
alias gcp='gc -m "npm prettier" --no-verify'

function gpd() {
	echo 'did you mean gpm?'
	read response

	if [ "$response" = "y" ] || [ "$response" = "yes" ]; then
		gpm
	else
		git pull origin develop
	fi
}

__git_complete gbd _git_checkout

function gcm() {
	gc -m "$1"
}

function gcmn() {
	gc -m "$1" --no-verify
}

alias gch='git fetch --prune && git checkout'

__git_complete gch _git_checkout

function gnb() {
	gch main
	git pull origin main
	gitBranch=$1
	if [[ "$gitBranch" != *"todd/"* ]]; then
		gitBranch="todd/$gitBranch"
	fi
	git checkout -b $gitBranch
	git reset --soft origin/main
	git push --set-upstream origin $gitBranch
}
export PATH="$HOME/.tfenv/bin:$PATH"
export EDITOR=vim

function triggerQueryRuns() {
	curl 'http://localhost:3001/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: http://localhost:3001' -H "Authorization: $1" --data-binary '{"query":"# Write your query or mutation here\nmutation RunQueries {\n  invokeQueries{\n    success\n    message\n  }\n}"}' --compressed
}

alias sshr='ssh -i ~/Downloads/robbjack-testing.pem ubuntu@ec2-34-237-0-83.compute-1.amazonaws.com'

function ensureAWSSSO() {
    profile=$1

    if [ "$profile" = "" ]; then
      echo "You must specify an aws profile"
      exit
    fi

    aws_user=$(aws --profile $profile sts get-caller-identity | grep UserId)

    if [ "$aws_user" = "" ]; then
        echo "not logged in to AWS SSO, logging in"
        aws --profile $profile sso login
    fi
}

function cleanUpBuckets() {
	ensureAWSSSO "datacollector-testing"

	for b in $(AWS_PROFILE=datacollector-testing aws s3api list-buckets | jq -r '.Buckets | .[] | .Name'); do AWS_PROFILE=datacollector-testing aws s3 rm s3://$b --recursive && AWS_PROFILE=datacollector-testing aws s3 rb s3://$b & done
}

function migratePocus() {
    profile=$1

    if [ "$profile" = "" ]; then
      echo "You must specify an aws profile"
      exit
    fi

    ensureAWSSSO $profile

    cd /home/todd/dev/PocusHQ/Pocus/backend

    AWS_PROFILE=$profile ./migrate.sh
}

function migrateDev() {
    migratePocus "pocus-dev"
}

function migrateStaging() {
    migratePocus "pocus-staging"
}

function migrateProduction() {
    migratePocus "pocus-production"
}

function mapTouchscreen() {
  touchscreenIdStr=$(xinput | grep "ILITEK ILITEK-TP" | awk '{print $5}')

  if [ "$touchscreenIdStr" != "" ]; then
    touchscreenIdStrParts=(${touchscreenIdStr//=/ })
    touchscreenId=${touchscreenIdStrParts[1]}

    xinput map-to-output $touchscreenId DP-1-0
  else
    echo "touchscreen not attached"
  fi
}

export KUBECONFIG=$HOME/.kube/microk8s.config:${KUBECONFIG:-$HOME/.kube/config}
export PATH=$PATH:$HOME/.garden/bin

