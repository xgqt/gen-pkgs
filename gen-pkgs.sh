#!/bin/sh


# This file is part of gen-pkgs.

# gen-pkgs is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.

# gen-pkgs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with gen-pkgs.  If not, see <https://www.gnu.org/licenses/>.

# shellcheck disable=2044,2129


trap 'exit 128' INT
export PATH


usage(){
    cat << BLOCK
gen-pkgs URL
gen-pkgs - generate a html pkg report of a git overlay

Origianl author: XGQT
Copyright (c) 2020-2021, src_prepare
Licensed under the GNU GPL v3 License
BLOCK
}


# Whether to clone the overlay or use a installed one
# default: clone
clone=1


case ${1}
in
    -h | --help )
        usage
        exit 0
        ;;
    -n | --no-clone )
        clone=0
        ;;
    "" )
        usage
        exit 1
        ;;
esac


here_dir="$(pwd)"
public_dir="${here_dir}/public"

if [ ${clone} -ge 1 ]
then
    overlay_url="${1}"
    overlay_dir="$(basename "${overlay_url}" | sed 's/\.git//')"
    cd /tmp || exit 1
    git clone "${overlay_url}" "${overlay_dir}"
else
    # In this case ${2} is the overlay dir
    # TODO: Probe this arg in a better way (...maybe just port this script to python)
    overlay_url="$(cd "${2}" && git config --get remote.origin.url 2>/dev/null)"
    overlay_dir="${2}"
fi


# Prepare

cd "${overlay_dir}" || exit 1

mkdir -p "${public_dir}"
rm "${public_dir}/index.html"


# Header

cat >> "${public_dir}/index.html" << BLOCK
<!DOCTYPE html>

<html>
<head>
    <meta charset="utf-8" />
    <meta name="generator" content="GitLab Pages" />
    <meta name="description" content="src_prepare" />
    <meta name="keywords" content="src_prepare" />
    <meta name="author" content="src_prepare" />
    <title>Gen-PKGs ($(basename "${overlay_dir}"))</title>
    <link rel="stylesheet" href="assets/styles/main.css" />
</head>
<body>
<div id="main">
<h1>
    Package report generated each day at 01:00 AM (or otherwise by Gitlab pipeline schedule)
</h1>
<ul>
    <li>
        <a href="https://gitlab.com/src_prepare/gen-pkgs">
             Git repo
        </a>
    </li>
    <li>
        <a href="https://gitlab.com/src_prepare/gen-pkgs/-/jobs">
           Jobs
        </a>
    </li>
    <li>
        <a href="https://gitlab.com/src_prepare/gen-pkgs/-/pipeline_schedules">
           Pipeline Schedules
        </a>
    </li>
</ul>
<p>
    Curent project status:
    <a href="https://gitlab.com/src_prepare/gen-pkgs/pipelines">
        <img src="https://gitlab.com/src_prepare/gen-pkgs/badges/master/pipeline.svg">
    </a>
    <a href="https://gitlab.com/src_prepare/gen-pkgs/commits/master.atom">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/feed-atom-orange.svg">
    </a>
<p>
<a href="https://gpo.zugaina.org/Overlays/${overlay_dir}">
   <p>
       Go here for a GPO report
   </p>
</a>
BLOCK


# Links to details

echo "Generating list"
pkgcount_l=$((0))
cat >> "${public_dir}/index.html" << BLOCK
<h2>
    Go to package
</h2>
<ul>
BLOCK
for meta in $(find . -name metadata.xml | sort)
do
    pkg="$(dirname "${meta}" | sed 's/.\///')"
    pkgcount_l=$((pkgcount_l+1))
    echo "[L] Package ${pkgcount_l}: ${pkg}"
    cat >> "${public_dir}/index.html" << BLOCK
<li>
    <a href="#${pkg}">
        ${pkg}
    </a>
</li>
BLOCK
done
cat >> "${public_dir}/index.html" << BLOCK
</ul>
BLOCK


# Main content

echo "Generating report"
pkgcount_r=$((0))
for meta in $(find . -name metadata.xml | sort)
do
    pkg="$(dirname "${meta}" | sed 's/.\///')"
    repology_pkg=$(basename "${pkg}" | sed 's/-bin//' )
    pkgcount_r=$((pkgcount_r+1))
    echo "[R] Package ${pkgcount_r}/${pkgcount_l}: ${pkg}"
    cd "${pkg}" >/dev/null || exit 1
    cat >> "${public_dir}/index.html" << BLOCK
<h2 id="${pkg}">
    ${pkgcount_r}/${pkgcount_l}:
BLOCK
    if echo "${overlay_url}" | grep gitlab >/dev/null 2>&1
    then
        cat >> "${public_dir}/index.html" << BLOCK
    <a href="$(echo "${overlay_url}" | sed 's/\.git//')/-/tree/master/${pkg}">
BLOCK
    elif echo "${overlay_url}" | grep github >/dev/null 2>&1
    then
        cat >> "${public_dir}/index.html" << BLOCK
    <a href="$(echo "${overlay_url}" | sed 's/\.git//')/tree/master/${pkg}">
BLOCK
    else
        cat >> "${public_dir}/index.html" << BLOCK
    <a href="${overlay_url}">
BLOCK
    fi
    cat >> "${public_dir}/index.html" << BLOCK
        ${pkg}
    </a>
</h2>
<p>
    <b>
        About:
    </b>
    <br/>
    $(grep -sh -m 1 DESCRIPTION ./*.ebuild | head -1)
    <br/>
    $(grep -sh -m 1 HOMEPAGE ./*.ebuild | head -1)
    <br/>
    $(grep -sh -m 1 LICENSE ./*.ebuild | head -1)
    $(python "${here_dir}"/metadata.py | busybox ts '<br/>')
</p>
<p>
    <b>
        Available pkgs:
    </b>
    $(find . -name "*.ebuild" | sed 's/.\///')
</p>
$(sh "${here_dir}"/updates.sh "${pkg}")
<br/>
<a href="https://repology.org/project/${repology_pkg}/versions">
    <img src="https://repology.org/badge/vertical-allrepos/${repology_pkg}.svg">
</a>
$(repoman -Idx | busybox ts '<br/>' )
BLOCK
    cd - >/dev/null || exit 1
done


# Footer

cat >> "${public_dir}/index.html" << BLOCK
<p>
    <b>
        Total number of packages: ${pkgcount_l}
    </b>
</p>
<p>
    <b>
        Generated on: $(date)
    </b>
</p>
</div>
</body>
</html>
BLOCK


# Finish

if [ "${clone}" -ge 1 ]
then
    cd "${here_dir}" || exit 1
    rm -dfr /tmp/"${overlay_dir}"
fi
