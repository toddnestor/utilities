parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\] $(parse_git_branch)\[\033[00m\]\$ '

. /usr/share/bash-completion/completions/git

alias gs='git status'
alias gh='git push'
alias gp='git pull'
alias gc='git commit'
alias gl='git log'
alias gb='git branch'
alias gbd='git branch -D'
alias ga='git add -p'
alias gpm='git pull origin main'

function gpd() {
	echo 'did you mean gpm?'
	read response

	if [ "$response" = "y" ] || [ "$response" = "yes" ]; then
		gpm
	else
		echo 'okay then, good luck!'
	fi
}

__git_complete gbd _git_checkout

function gcm() {
	gc -m "$1"
}

alias gch='git fetch --prune && git checkout'

__git_complete gch _git_checkout

function gnb() {
	gch main
	git pull origin main
	git checkout -b todd-$1
	git push --set-upstream origin todd-$1
}
export PATH="$HOME/.tfenv/bin:$PATH"
export EDITOR=vim

function triggerQueryRuns() {
	curl 'http://localhost:3001/graphql' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: http://localhost:3001' -H "Authorization: $1" --data-binary '{"query":"# Write your query or mutation here\nmutation RunQueries {\n  invokeQueries{\n    success\n    message\n  }\n}"}' --compressed
}
