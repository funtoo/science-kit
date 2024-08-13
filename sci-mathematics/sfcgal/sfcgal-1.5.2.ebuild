# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit	cmake-utils

DESCRIPTION="SFCGAL provides standard compliant geometry types and operations."
HOMEPAGE="http://sfcgal.org/"
SRC_URI="https://gitlab.com/sfcgal/SFCGAL/-/archive/v1.5.2/SFCGAL-v1.5.2.tar.bz2 -> sfcgal-1.5.2.tar.bz2"
LICENSE="LGPL-2"

SLOT="0"
KEYWORDS="*"
IUSE="+osg"

RDEPEND="
	dev-libs/boost
	dev-libs/gmp
	dev-libs/mpfr
	>=sci-mathematics/cgal-4.14
	osg? ( dev-games/openscenegraph:= )
"

DEPEND="${RDEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv SFCGAL-v1.5.2 "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DSFCGAL_WITH_OSG=$(usex osg)
	)
	cmake-utils_src_configure
}