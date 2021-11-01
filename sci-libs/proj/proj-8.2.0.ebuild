# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="PROJ coordinate transformation software"
HOMEPAGE="https://proj4.org/"
SRC_URI="
	https://github.com/OSGeo/PROJ/releases/download/8.2.0/proj-8.2.0.tar.gz
	https://download.osgeo.org/proj/proj-datumgrid-latest.tar.gz
	europe? ( https://download.osgeo.org/proj/proj-datumgrid-europe-latest.tar.gz )
"

LICENSE="MIT"
SLOT="0/19"
KEYWORDS="*"
IUSE="curl europe static-libs test +tiff"
REQUIRED_USE="test? ( !europe )"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-db/sqlite:3
	curl? ( net-misc/curl )
	tiff? ( media-libs/tiff )
"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"/data || die
	mv README README.DATA || die
	unpack proj-datumgrid-latest.tar.gz
	use europe && unpack proj-datumgrid-europe-latest.tar.gz
}

src_configure() {
	econf \
		$(use_with curl) \
		$(use_enable static-libs static) \
		$(use_enable tiff)
}

src_install() {
	default
	cd data || die
	dodoc README.{DATA,DATUMGRID}
	use europe && dodoc README.EUROPE
	find "${D}" -name '*.la' -type f -delete || die
}