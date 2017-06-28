# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit unpacker eutils

DESCRIPTION="A free molecule editor written in Java"
HOMEPAGE="https://www.chemaxon.com/download/marvin-suite/#marvin"
SRC_URI="http://dl.chemaxon.com/marvin/${PV}/Marvin_linux_${PV}.deb"

LICENSE="Marvin-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="virtual/jre:1.8"

S="${WORKDIR}"

RESTRICT="mirror"

src_unpack() {
    unpack_deb ${A}
}

src_install() {
    cp -R "${WORKDIR}/opt" "${D}" || die "install failed!"
    doicon "${WORKDIR}/opt/chemaxon/marvinsuite/.install4j/MarvinView.png"
    doicon "${WORKDIR}/opt/chemaxon/marvinsuite/.install4j/MarvinSketch.png"
    make_desktop_entry /opt/chemaxon/marvinsuite/bin/mview MarvinView MarvinView "Education;Chemistry;Science;"
    make_desktop_entry /opt/chemaxon/marvinsuite/bin/msketch MarvinSketch MarvinSketch "Education;Chemistry;Science;"
}
