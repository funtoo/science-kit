# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils flag-o-matic python-single-r1

DESCRIPTION="Advanced molecular editor that uses Qt4 and OpenGL"
HOMEPAGE="http://avogadro.openmolecules.net/"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${PV}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+glsl python cpu_flags_x86_sse2 test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	>=sci-chemistry/openbabel-2.3.0
	>=dev-qt/qtgui-4.8.5:4
	>=dev-qt/qtopengl-4.8.5:4
	x11-libs/gl2ps
	glsl? ( >=media-libs/glew-1.5.0:0= )
	python? (
		>=dev-libs/boost-1.35.0-r5[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/sip[${PYTHON_USEDEP}]
		${PYTHON_DEPS}
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	<dev-cpp/eigen-3.3"

# https://sourceforge.net/p/avogadro/bugs/653/
RESTRICT="test"

PATCHES=(
	#"${FILESDIR}"/${PN}-1.1.0-textrel.patch
#	"${FILESDIR}"/${PN}-1.1.0-xlibs.patch
#	"${FILESDIR}"/${P}-eigen3.patch
	"${FILESDIR}"/${PN}-1.1.1-mkspecs-dir.patch
	"${FILESDIR}"/${PN}-1.1.1-no-strip.patch
	"${FILESDIR}"/${PN}-1.1.1-pkgconfig_eigen.patch
	"${FILESDIR}"/${PN}-1.1.1-openbabel.patch
	"${FILESDIR}"/${PN}-1.1.1-boost-join-moc.patch
	"${FILESDIR}"/${PN}-1.1.1-math.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	sed \
		-e 's:_BSD_SOURCE:_DEFAULT_SOURCE:g' \
		-i CMakeLists.txt || die
	# warning: "Eigen2 support is deprecated in Eigen 3.2.x and it will be removed in Eigen 3.3."
	append-cppflags -DEIGEN_NO_EIGEN2_DEPRECATED_WARNING
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_THREADEDGL=OFF
		-DENABLE_RPATH=OFF
		-DENABLE_UPDATE_CHECKER=OFF
		-DQT_MKSPECS_DIR="${EPREFIX}/usr/share/qt4/mkspecs"
		-DQT_MKSPECS_RELATIVE=share/qt4/mkspecs
		-DENABLE_glsl="$(usex glsl)"
		-DENABLE_TESTS="$(usex test)"
		-DWITH_SSE2="$(usex cpu_flags_x86_sse2)"
		-DENABLE_python="$(usex python)"
	)

	cmake-utils_src_configure
}
