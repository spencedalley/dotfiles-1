# This checks if the current branch is ahead of
# or behind the remote branch with which it is tracked

# Source lib to get the function get_tmux_pwd
source "${TMUX_POWERLINE_DIR_HOME}/config.sh"

mod_symbol="﹢"

run_segment() {
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"

	stats=""
	if [ -n "${git_stats=$(__parse_git_stats)}" ]; then
		stats="$git_stats"
	elif [ -n "${svn_stats=$(__parse_svn_stats)}" ]; then
		stats="$svn_stats"
	elif [ -n "${hg_stats=$(__parse_hg_stats)}" ]; then
		stats="$hg_stats"
	fi
	if [[ -n "$stats" && $stats -gt 0 ]]; then
		echo "${stats}"
	fi
}

__parse_git_stats(){
	type git >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	# check if git
	[[ -z $(git rev-parse --git-dir 2> /dev/null) ]] && return

	# return the number of staged items
	staged=$(git ls-files --modified | wc -l)
	echo $staged
}
__parse_hg_stats(){
	type hg >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi
	# not yet implemented
}
__parse_svn_stats() {
	type svn >/dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		return
	fi

	local svn_info=$(svn info 2>/dev/null)
	if [ -z "${svn_info}" ]; then
		return
	fi

	local svn_wcroot=$(echo "${svn_info}" | sed -ne 's#^Working Copy Root Path: ##p')
	local svn_st=$(cd "${svn_wcroot}"; svn st)
	local modified=$(echo "${svn_st}" | egrep '^M' | wc -l)
	local conflicted=$(echo "${svn_st}" | egrep '^!?\s*C' | wc -l)

	#print
	if [[ $modified -gt 0 ]] ; then
		local ret="#[fg=colour${TMUX_POWERLINE_CUR_SEGMENT_FG}]±${modified}"
	fi
	if [[ $conflicted -gt 0 ]] ; then
		local ret="#[fg=colour${svn_colour}]ϟ${conflicted} ${ret}"
	fi
	echo "${ret}"
}
