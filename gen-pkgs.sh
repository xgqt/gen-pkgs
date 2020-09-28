#!/bin/sh


# shellcheck disable=2044


trap 'exit 128' INT
export PATH

usage(){
    cat << BLOCK
gen-pkgs URL
gen-pkgs - generate a html pkg report of a git overlay

Origianl author: XGQT
Copyright (c) 2020, src_prepare
Licensed under the ISC License
BLOCK
}


case ${1}
in
    -h | --help )
        usage
        exit 0
        ;;
    "" )
        usage
        exit 1
        ;;
esac


here_dir="$(pwd)"
public_dir="${here_dir}/public"

overlay_url="${1}"
overlay_dir="$(basename "${overlay_url}")"


cd /tmp || exit 1
git clone "${overlay_url}"
cd "${overlay_dir}" || exit 1

mkdir -p "${public_dir}"
rm "${public_dir}/index.html"

cat >> "${public_dir}/index.html" << BLOCK
<!DOCTYPE html>

<html>
<head>
    <meta charset="utf-8" />
    <meta name="generator" content="GitLab Pages" />
    <meta name="description" content="src_prepare" />
    <meta name="keywords" content="src_prepare" />
    <meta name="author" content="src_prepare" />
    <title>Gen-PKGs (${overlay_dir})</title>
</head>
<body>
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
    echo "[R] Package ${pkgcount_r}: ${pkg}"
    cd "${pkg}" >/dev/null || exit 1
    cat >> "${public_dir}/index.html" << BLOCK
<h2 id="${pkg}">
    <a href="${overlay_url}/-/tree/master/${pkg}">
        ${pkg}
    </a>
</h2>
<p>
    Available pkgs:
    $(find . -name "*.ebuild")
</p>
<p>
    Updates:
    $(euscan -q "${pkg}")
</p>
<br/>
<a href="https://repology.org/project/${repology_pkg}/versions">
    <img src="https://repology.org/badge/vertical-allrepos/${repology_pkg}.svg">
</a>
$(repoman -Idx | busybox ts '<br/>' )
BLOCK
    cd - >/dev/null || exit 1
done

cat >> "${public_dir}/index.html" << BLOCK
<p>
    Total number of packages: ${pkgcount_l}
</p>
<p>
    Generated on: $(date)
</p>
</body>
</html>
BLOCK

cd "${here_dir}" || exit 1
rm -dfr /tmp/"${overlay_dir}"
