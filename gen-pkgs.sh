#!/bin/sh


# shellcheck disable=2044


trap 'exit 128' INT
export PATH


here_dir="$(pwd)"
public_dir="${here_dir}/public"


cd /tmp || exit 1
git clone https://gitlab.com/src_prepare/src_prepare-overlay
cd src_prepare-overlay || exit 1

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
    <title>Gen-PKGs (src_prepare)</title>
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
    <img src="https://gitlab.com/src_prepare/gen-pkgs/badges/master/pipeline.svg">
    <img src="https://gitlab.com/src_prepare/badge/-/raw/master/feed-atom-orange.svg">
<p>
<a href="https://gpo.zugaina.org/Overlays/src_prepare-overlay">
   <p>
       For a GPO report
   </p>
</a>
BLOCK


for meta in $(find . -name metadata.xml | sort)
do
    pkg="$(dirname "${meta}" | sed 's/.\///')"
    repology_pkg=$(basename "${pkg}" | sed 's/-bin//' )
    echo "Package: ${pkg}"
    cat >> "${public_dir}/index.html" << BLOCK
<a href="https://gitlab.com/src_prepare/src_prepare-overlay/-/tree/master/${pkg}">
    <h2>
        ${pkg}
    </h2>
</a>
<p>
    Available pkgs:
    $(find "${pkg}" -name "*.ebuild")
</p>
<p>
    Updates:
    $(euscan -q "${pkg}")
</p>
<a href="https://repology.org/project/${repology_pkg}/versions">
    <p>
        <img src="https://repology.org/badge/vertical-allrepos/${repology_pkg}.svg">
    </p>
</a>
BLOCK
done

cat >> "${public_dir}/index.html" << BLOCK
<p>
    Generated on: $(date)
</p>
</body>
</html>
BLOCK

cd "${here_dir}" || exit 1
rm -dfr /tmp/src_prepare-overlay
