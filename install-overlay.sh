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


repo_url="${1}"
repo=$(basename "${repo_url}" | sed 's/.git//')
repos_home="/etc/portage/repos.conf"


mkdir -p "${repos_home}"

cat > "${repos_home}/${repo}.conf" << CONF
[${repo}]
auto-sync = yes
location = /var/db/repos/${repo}
sync-type = git
sync-umask = 000
sync-uri = ${repo_url}
CONF

emaint sync -r "${repo}"
