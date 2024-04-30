# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit fortran-2 autotools

DESCRIPTION="Guile-based library for scientific simulations"
HOMEPAGE="http://ab-initio.mit.edu/libctl/"
SRC_URI="https://github.com/NanoComp/libctl/tarball/db77f32e2fd6c3d2408ae8d4d836c765a346b0dc -> libctl-4.5.1-db77f32.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="*"
IUSE="doc examples static-libs"

DEPEND="
	dev-scheme/guile
	sci-libs/nlopt"
RDEPEND="${DEPEND}"

S="${WORKDIR}/NanoComp-libctl-db77f32"

src_install() {

	use doc && dohtml doc/*
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins "${AUTOTOOLS_BUILD_DIR}"/examples/{*.c,*.h,example.scm,Makefile}
		doins "${S}"/examples/{README,example.c,run.ctl}
	fi
}