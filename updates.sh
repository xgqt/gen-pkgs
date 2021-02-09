#!/bin/sh


# This file is part of gen-pkgs.

# gen-pkgs is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# gen-pkgs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with gen-pkgs.  If not, see <https://www.gnu.org/licenses/>.


trap 'exit 128' INT
export PATH


updates="$(euscan -q "${1}")"


mkdir -p ./public

if [ -n "${updates}" ]
then
    cat <<EOF
<p>
    <b>
        Updates:
    </b>
     $(echo "${updates}" | busybox ts '<br/>')
</p>
EOF
    echo "${updates}" >> ./public/updates.txt
fi
