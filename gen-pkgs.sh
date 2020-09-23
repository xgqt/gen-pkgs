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
BLOCK

cd "${here_dir}" || exit 1
rm -dfr /tmp/src_prepare-overlay
