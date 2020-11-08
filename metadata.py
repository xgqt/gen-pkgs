#!/usr/bin/env python


"""
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
"""


import xml.etree.ElementTree as ET


def oneline(string):
    '''Return a one-line string'''
    return "".join(string.split("\n"))


try:
    with open("metadata.xml") as m:
        tree = ET.parse(m)
        root = tree.getroot()
        for item in root.findall("./"):
            print("%s:" % oneline(item.tag.capitalize()))
            if item.tag == "longdescription":
                print(4 * "&nbsp;", oneline(item.text))
            for child in item:
                print(4 * "&nbsp;", child.tag,
                      "".join(list(child.attrib.values())), ":",
                      oneline(child.text))
except ValueError:
    pass
