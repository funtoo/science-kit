# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Repository for proj datum grids (for use by PROJ 7 or later)"
HOMEPAGE="https://proj.org/"
SRC_URI="https://github.com/OSGeo/PROJ-data/tarball/e2f2a50b5bdec896dd27ed375f3beae406a78a24 -> PROJ-data-1.20.0-e2f2a50.tar.gz"

LICENSE="MIT"
# Changes on every major release
SLOT="0"
KEYWORDS="*"
IUSE="+tiff"


RDEPEND="sci-libs/proj
	tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv OSGeo-* "${S}" || die
	fi
}


src_install() {
	dodoc README.DATA

	insinto /usr/share/proj
	
	find -mindepth 2 -type f \( -name '*.tif' -o -name '*.txt' -o -name '*.json' \) -exec doins {} \;
}