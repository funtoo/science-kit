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
    dosym /opt/chemaxon/marvinsuite/bin/cxcalc /usr/bin/cxcalc
    dosym /opt/chemaxon/marvinsuite/bin/cxtrain /usr/bin/cxtrain
    dosym /opt/chemaxon/marvinsuite/LicenseManager /usr/bin/lmanager
    dosym /opt/chemaxon/marvinsuite/bin/molconvert /usr/bin/molconvert
    dosym /opt/chemaxon/marvinsuite/bin/msketch /usr/bin/msketch
    dosym /opt/chemaxon/marvinsuite/bin/mview /usr/bin/mview
    doicon "${D}/opt/chemaxon/marvinsuite/.install4j/LicenseManager.png"
    doicon "${D}/opt/chemaxon/marvinsuite/.install4j/MarvinSketch.png"
    doicon "${D}/opt/chemaxon/marvinsuite/.install4j/MarvinView.png"
    make_desktop_entry lmanager LicenseManager LicenseManager "Education;Chemistry;Science;"
    make_desktop_entry msketch MarvinSketch MarvinSketch "Education;Chemistry;Science;"
    make_desktop_entry mview MarvinView MarvinView "Education;Chemistry;Science;"
}
