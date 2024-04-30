# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="C++ algorithms for specialized vertex coloring problems"
LICENSE="GPL-3 LGPL-3"
HOMEPAGE="http://cscapes.cs.purdue.edu/coloringpage/"
SRC_URI="https://github.com/CSCsw/ColPack/tarball/ffa4e4130011537bdc4658ebb78ab3088f0ea6dc -> ColPack-1.0.10-ffa4e41.tar.gz"

SLOT="0"
IUSE="openmp static-libs"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/CSCsw-ColPack-ffa4e41"

pkg_setup() {
	if [[ ${MERGE_TYPE} != "binary" ]] && use openmp && [[ $(tc-getCC)$ == *gcc* ]] &&	! tc-has-openmp; then
		ewarn "You are using gcc without OpenMP"
		die "Need an OpenMP capable compiler"
	fi
}

src_prepare() {
	default
	sed -e 's/-O3//' -i Makefile.am || die
	eautoreconf
}

src_configure() {
	econf \
		--enable-shared \
		$(use_enable static-libs static) \
		$(use_enable openmp)
}

src_install() {
	default
	rm -rf "${ED}"/usr/examples
	use static-libs || prune_libtool_files --all
}