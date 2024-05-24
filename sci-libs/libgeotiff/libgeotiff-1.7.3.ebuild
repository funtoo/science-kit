# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Library for reading TIFF files with embedded tags for geographic information"
HOMEPAGE="https://trac.osgeo.org/geotiff/ https://github.com/OSGeo/libgeotiff"
SRC_URI="https://github.com/OSGeo/libgeotiff/tarball/533bd5592ca70100796bd2dd15619262edfcfe14 -> libgeotiff-1.7.3-533bd55.tar.gz"

LICENSE="GPL-2"
SLOT="0/5"
KEYWORDS="*"
IUSE="doc jpeg +tiff zlib"

DEPEND=">=sci-libs/proj-6.0.0:=
	jpeg? ( media-libs/libjpeg-turbo:= )
	tiff? ( >=media-libs/tiff-3.9.1:= )
	zlib? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

post_src_unpack() {
	if [ ! -d "${WORKDIR}/${S}" ]; then
		mv "${WORKDIR}"/OSGeo-libgeotiff-533bd55/libgeotiff "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DGEOTIFF_LIB_SUBDIR="lib64"
		-DWITH_JPEG=$(usex jpeg)
		-DWITH_TIFF=$(usex tiff)
		-DWITH_ZLIB=$(usex zlib)
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use doc; then
		mkdir -p docs/api || die
		cp "${FILESDIR}"/Doxyfile Doxyfile || die
		doxygen -u Doxyfile || die "updating doxygen config failed"
		doxygen Doxyfile || die "docs generation failed"
	fi
}

src_install() {
	use doc && local HTML_DOCS=( docs/api/. )

	cmake_src_install
}