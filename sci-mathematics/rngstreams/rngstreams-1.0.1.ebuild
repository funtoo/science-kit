# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Multiple independent streams of pseudo-random numbers"
HOMEPAGE="http://statmath.wu.ac.at/software/RngStreams/"
SRC_URI="https://statmath.wu.ac.at/software/RngStreams/rngstreams-1.0.1.tar.gz -> rngstreams-1.0.1.tar.gz"

LICENSE="GPL-3"
SLOT=0
KEYWORDS="*"
IUSE="doc examples static-libs"

src_install() {
	use doc && dohtml -r doc/rngstreams.html/* && dodoc doc/${PN}.pdf
	if use examples; then
		rm examples/Makefile*
		dodoc -r examples
	fi
}