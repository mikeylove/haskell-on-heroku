#!/usr/bin/env bash


function echo_ghc_original_url () {
	local ghc_version
	expect_args ghc_version -- "$@"

	case "${ghc_version}" in
	'7.8.2')
		echo 'http://www.haskell.org/ghc/dist/7.8.2/ghc-7.8.2-x86_64-unknown-linux-centos65.tar.xz';;
	'7.8.1')
		echo 'http://www.haskell.org/ghc/dist/7.8.1/ghc-7.8.1-x86_64-unknown-linux-centos65.tar.xz';;
	'7.6.3')
		echo 'http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2';;
	'7.6.2')
		echo 'http://www.haskell.org/ghc/dist/7.6.2/ghc-7.6.2-x86_64-unknown-linux.tar.bz2';;
	'7.6.1')
		echo 'http://www.haskell.org/ghc/dist/7.6.1/ghc-7.6.1-x86_64-unknown-linux.tar.bz2';;
	'7.4.2')
		echo 'http://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-x86_64-unknown-linux.tar.bz2';;
	'7.4.1')
		echo 'http://www.haskell.org/ghc/dist/7.4.1/ghc-7.4.1-x86_64-unknown-linux.tar.bz2';;
	'7.2.2')
		echo 'http://www.haskell.org/ghc/dist/7.2.2/ghc-7.2.2-x86_64-unknown-linux.tar.bz2';;
	'7.2.1')
		echo 'http://www.haskell.org/ghc/dist/7.2.1/ghc-7.2.1-x86_64-unknown-linux.tar.bz2';;
	'7.0.4')
		echo 'http://www.haskell.org/ghc/dist/7.0.4/ghc-7.0.4-x86_64-unknown-linux.tar.bz2';;
	'7.0.3')
		echo 'http://www.haskell.org/ghc/dist/7.0.3/ghc-7.0.3-x86_64-unknown-linux.tar.bz2';;
	'7.0.2')
		echo 'http://www.haskell.org/ghc/dist/7.0.2/ghc-7.0.2-x86_64-unknown-linux.tar.bz2';;
	'7.0.1')
		echo 'http://www.haskell.org/ghc/dist/7.0.1/ghc-7.0.1-x86_64-unknown-linux.tar.bz2';;
	'6.12.3')
		echo 'http://www.haskell.org/ghc/dist/6.12.3/ghc-6.12.3-x86_64-unknown-linux-n.tar.bz2';;
	'6.12.2')
		echo 'http://www.haskell.org/ghc/dist/6.12.2/ghc-6.12.2-x86_64-unknown-linux-n.tar.bz2';;
	'6.12.1')
		echo 'http://www.haskell.org/ghc/dist/6.12.1/ghc-6.12.1-x86_64-unknown-linux-n.tar.bz2';;
	'6.10.4')
		echo 'http://www.haskell.org/ghc/dist/6.10.4/ghc-6.10.4-x86_64-unknown-linux-n.tar.bz2';;
	'6.10.3')
		echo 'http://www.haskell.org/ghc/dist/6.10.3/ghc-6.10.3-x86_64-unknown-linux-n.tar.bz2';;
	'6.10.2')
		echo 'http://www.haskell.org/ghc/dist/6.10.2/ghc-6.10.2-x86_64-unknown-linux-libedit2.tar.bz2';;
	'6.10.1')
		echo 'http://www.haskell.org/ghc/dist/6.10.1/ghc-6.10.1-x86_64-unknown-linux-libedit2.tar.bz2';;
	*)
		die "Unexpected GHC version: ${ghc_version}"
	esac
}


function echo_ghc_base_version () {
	local base_version
	expect_args base_version -- "$@"

	case "${base_version}" in
	'4.7.0.0')
		echo '7.8.2';;
	'4.6.0.1')
		echo '7.6.3';;
	'4.6.0.0')
		echo '7.6.1';;
	*)
		die "Unexpected base version: ${base_version}"
	esac
}


function echo_ghc_default_version () {
	echo '7.8.2'
}




function echo_ghc_tag () {
	local ghc_version ghc_label
	expect_args ghc_version ghc_label -- "$@"

	echo "${ghc_version}${ghc_label:+-${ghc_label}}"
}


function echo_ghc_tag_version () {
	local ghc_tag
	expect_args ghc_tag -- "$@"

	echo "${ghc_tag%%-*}"
}


function echo_ghc_tag_label () {
	local ghc_tag
	expect_args ghc_tag -- "$@"

	case "${ghc_tag}" in
	*'-'*)
		echo "${ghc_tag#*-}";;
	*)
		echo
	esac
}


function echo_ghc_archive () {
	local ghc_tag
	expect_args ghc_tag -- "$@"

	echo "halcyon-ghc-${ghc_tag}.tar.xz"
}


function echo_ghc_description () {
	local ghc_tag
	expect_args ghc_tag -- "$@"

	local ghc_version ghc_label
	ghc_version=$( echo_ghc_tag_version "${ghc_tag}" ) || die
	ghc_label=$( echo_ghc_tag_label "${ghc_tag}" ) || die

	echo "GHC ${ghc_version}${ghc_label:+ (${ghc_label})}"
}




function echo_ghc_tmp_dir () {
	mktemp -du "/tmp/halcyon-ghc.XXXXXXXXXX"
}


function echo_ghc_tmp_log () {
	mktemp -u "/tmp/halcyon-ghc.log.XXXXXXXXXX"
}




function validate_ghc_tag () {
	local ghc_tag
	expect_args ghc_tag -- "$@"

	local ghc_version candidate_tag
	candidate_tag=$( match_exactly_one ) || die

	if [ "${candidate_tag}" != "${ghc_tag}" ]; then
		return 1
	fi
}




function build_ghc () {
	expect_vars HALCYON HALCYON_CACHE
	expect_no "${HALCYON}/ghc"

	local ghc_version
	expect_args ghc_version -- "$@"

	log "Building GHC ${ghc_version}"

	local original_url original_archive tmp_dir tmp_log
	original_url=$( echo_ghc_original_url "${ghc_version}" ) || die
	original_archive=$( basename "${original_url}" ) || die
	tmp_dir=$( echo_ghc_tmp_dir ) || die
	tmp_log=$( echo_ghc_tmp_log ) || die

	if ! download_original "${original_archive}" "${original_url}" "${HALCYON_CACHE}"; then
		die "GHC ${ghc_version} is not available"
	fi

	tar_extract "${HALCYON_CACHE}/${original_archive}" "${tmp_dir}" || die

	log "Installing GHC ${ghc_version}..."

	case "${ghc_version}" in
	'7.8.'*)
		expect '/usr/lib/libncurses.so.5' '/usr/lib/libgmp.so.3'

		mkdir -p "${HALCYON}/ghc/lib" || die
		ln -s '/usr/lib/libncurses.so.5' "${HALCYON}/ghc/lib/libtinfo.so.5" || die
		ln -s '/usr/lib/libgmp.so.3' "${HALCYON}/ghc/lib/libgmp.so" || die;;
	'7.6.'*)
		expect '/usr/lib/libgmp.so.3'

		mkdir -p "${HALCYON}/ghc/lib" || die
		ln -s '/usr/lib/libgmp.so.3' "${HALCYON}/ghc/lib/libgmp.so" || die;;
	*)
		die "Installing GHC ${ghc_version} is not implemented yet"
	esac

	if ! (
		cd "${tmp_dir}/ghc-${ghc_version}" &&
		./configure --prefix="${HALCYON}/ghc" &> "${tmp_log}" &&
		make install &>> "${tmp_log}"
	); then
		log_file_indent < "${tmp_log}"
		die 'Installing GHC failed'
	fi

	rm -rf "${HALCYON}/ghc/share" "${tmp_dir}" "${tmp_log}" || die

	echo_ghc_tag "${ghc_version}" 'uncut' > "${HALCYON}/ghc/tag" || die

	local ghc_size
	ghc_size=$( measure_recursively "${HALCYON}/ghc" ) || die
	re_log "done, ${ghc_size}"
}


function cut_ghc () {
	expect_vars HALCYON
	expect "${HALCYON}/ghc/tag"

	local ghc_tag ghc_version
	ghc_tag=$(< "${HALCYON}/ghc/tag" ) || die
	ghc_version=$( echo_ghc_tag_version "${ghc_tag}" ) || die

	log "Cutting GHC ${ghc_version}..."

	case "${ghc_version}" in
	'7.8.'*)
		rm -rf  "${HALCYON}/ghc/bin/haddock"                        \
			"${HALCYON}/ghc/bin/haddock-ghc-${ghc_version}"     \
			"${HALCYON}/ghc/bin/hp2ps"                          \
			"${HALCYON}/ghc/bin/hpc"                            \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/haddock" \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/hpc"     \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/html"        \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/latex" || die
		find "${HALCYON}/ghc"                  \
				-type f           -and \
				\(                     \
				-name '*_p.a'     -or  \
				-name '*.p_hi'    -or  \
				-name '*HS*.o'    -or  \
				-name '*_debug.a'      \
				\)                     \
				-delete || die
		ghc-pkg recache || die;;
	'7.6.'*)
		rm -rf  "${HALCYON}/ghc/bin/haddock"                    \
			"${HALCYON}/ghc/bin/haddock-ghc-${ghc_version}" \
			"${HALCYON}/ghc/bin/hp2ps"                      \
			"${HALCYON}/ghc/bin/hpc"                        \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/haddock" \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/html"    \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/latex" || die
		find "${HALCYON}/ghc"                  \
				-type f           -and \
				\(                     \
				-name '*_p.a'     -or  \
				-name '*.p_hi'    -or  \
				-name '*.dyn_hi'  -or  \
				-name '*HS*.so'   -or  \
				-name '*HS*.o'    -or  \
				-name '*_debug.a'      \
				\)                     \
				-delete || die
		ghc-pkg recache || die;;
	*)
		die "Cutting GHC ${ghc_version} is not implemented yet"
	esac

	echo_ghc_tag "${ghc_version}" '' > "${HALCYON}/ghc/tag" || die

	local ghc_size
	ghc_size=$( measure_recursively "${HALCYON}/ghc" ) || die
	re_log "done, ${ghc_size}"
}


function strip_ghc () {
	expect_vars HALCYON
	expect "${HALCYON}/ghc/tag"

	local ghc_tag ghc_version
	ghc_tag=$(< "${HALCYON}/ghc/tag" ) || die
	ghc_version=$( echo_ghc_tag_version "${ghc_tag}" ) || die
	ghc_description=$( echo_ghc_description "${ghc_tag}" ) || die

	log "Stripping ${ghc_description}..."

	case "${ghc_version}" in
	'7.8.'*)
		strip --strip-unneeded                                            \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/ghc"               \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/ghc-pkg"           \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/hsc2hs"            \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/bin/runghc"            \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/mkGmpDerivedConstants" \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/unlit" || die
		find "${HALCYON}/ghc"               \
				-type f        -and \
				\(                  \
				-name '*.so'   -or  \
				-name '*.so.*' -or  \
				-name '*.a'         \
				\)                  \
				-print0 |
			strip0 --strip-unneeded || die;;
	'7.6.'*)
		strip --strip-unneeded                              \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/ghc"     \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/ghc-pkg" \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/hsc2hs"  \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/runghc"  \
			"${HALCYON}/ghc/lib/ghc-${ghc_version}/unlit" || die
		find "${HALCYON}/ghc"               \
				-type f        -and \
				\(                  \
				-name '*.so'   -or  \
				-name '*.so.*' -or  \
				-name '*.a'         \
				\)                  \
				-print0 |
			strip0 --strip-unneeded || die;;
	*)
		die "Stripping GHC ${ghc_version} is not implemented yet"
	esac

	local ghc_size
	ghc_size=$( measure_recursively "${HALCYON}/ghc" ) || die
	re_log "done, ${ghc_size}"
}




function cache_ghc () {
	expect_vars HALCYON HALCYON_CACHE
	expect "${HALCYON}/ghc/tag"

	local ghc_tag ghc_description
	ghc_tag=$(< "${HALCYON}/ghc/tag" ) || die
	ghc_description=$( echo_ghc_description "${ghc_tag}" ) || die

	log "Caching ${ghc_description}"

	local ghc_archive
	ghc_archive=$( echo_ghc_archive "${ghc_tag}" ) || die

	rm -f "${HALCYON_CACHE}/${ghc_archive}" || die
	tar_archive "${HALCYON}/ghc" "${HALCYON_CACHE}/${ghc_archive}" || die
	upload_prepared "${HALCYON_CACHE}/${ghc_archive}" || die
}


function restore_ghc () {
	expect_vars HALCYON HALCYON_CACHE

	local ghc_tag
	expect_args ghc_tag -- "$@"

	local ghc_description
	ghc_description=$( echo_ghc_description "${ghc_tag}" ) || die

	log "Restoring ${ghc_description}"

	if [ -f "${HALCYON}/ghc/tag" ] &&
		validate_ghc_tag "${ghc_tag}" < "${HALCYON}/ghc/tag"
	then
		return 0
	fi
	rm -rf "${HALCYON}/ghc" || die

	local ghc_archive
	ghc_archive=$( echo_ghc_archive "${ghc_tag}" ) || die

	if ! download_prepared "${ghc_archive}" "${HALCYON_CACHE}"; then
		log_warning "${ghc_description} is not prepared"
		return 1
	fi

	tar_extract "${HALCYON_CACHE}/${ghc_archive}" "${HALCYON}/ghc" || die

	if ! [ -f "${HALCYON}/ghc/tag" ] ||
		! validate_ghc_tag "${ghc_tag}" < "${HALCYON}/ghc/tag"
	then
		log_warning "Restoring ${ghc_archive} failed"
		rm -rf "${HALCYON}/ghc" || die
		return 1
	fi
}




function infer_ghc_version () {
	local build_dir
	expect_args build_dir -- "$@"

	log 'Inferring GHC version...'

	local ghc_version
	if has_vars FORCE_GHC_VERSION; then
		ghc_version="${FORCE_GHC_VERSION}"

		re_log "${ghc_version}, forced"
	elif [ -f "${build_dir}/cabal.config" ]; then
		local base_version
		base_version=$(
			detect_constraints "${build_dir}" |
				filter_matching "^base " |
				match_exactly_one |
				sed 's/^.* //'
		) || die

		ghc_version=$( echo_ghc_base_version "${base_version}" ) || die

		re_log "done, ${ghc_version}"
	else
		ghc_version=$( echo_ghc_default_version ) || die

		re_log "${ghc_version}, default"
		if ! (( "${HALCYON_FAKE_BUILD:-0}" )); then
			log_warning 'Expected cabal.config with explicit constraints'
		fi
	fi

	echo "${ghc_version}"
}




function activate_ghc () {
	expect_vars HALCYON
	expect "${HALCYON}/ghc/tag"

	local ghc_tag ghc_description
	ghc_tag=$(< "${HALCYON}/ghc/tag" ) || die
	ghc_description=$( echo_ghc_description "${ghc_tag}" ) || die

	log "Activating ${ghc_description}..."

	if [ -e "${HOME}/.ghc" ]; then
		die "Expected no custom ${HOME}/.ghc"
	fi

	re_log 'done'
}


function deactivate_ghc () {
	expect_vars HALCYON
	expect "${HALCYON}/ghc/tag"

	local ghc_tag ghc_description
	ghc_tag=$(< "${HALCYON}/ghc/tag" ) || die
	ghc_description=$( echo_ghc_description "${ghc_tag}" ) || die

	log "Dectivating ${ghc_description}..."

	if [ -e "${HOME}/.ghc" ]; then
		die "Expected no custom ${HOME}/.ghc"
	fi

	re_log 'done'
}




function prepare_ghc () {
	local has_time build_dir
	expect_args has_time build_dir -- "$@"

	local ghc_label
	if (( ${NO_CUT_GHC:-0} )); then
		ghc_label='uncut'
	else
		ghc_label=''
	fi

	local ghc_version ghc_tag
	ghc_version=$( infer_ghc_version "${build_dir}" ) || die
	ghc_tag=$( echo_ghc_tag "${ghc_version}" "${ghc_label}" ) || die

	if restore_ghc "${ghc_tag}"; then
		activate_ghc || die
		return 0
	fi

	(( ${has_time} )) || return 1

	build_ghc "${ghc_version}" || die
	if ! (( ${NO_CUT_GHC:-0} )); then
		cut_ghc || die
	fi
	strip_ghc || die
	cache_ghc || die
	activate_ghc || die
}
