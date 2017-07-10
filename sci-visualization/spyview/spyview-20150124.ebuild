# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools flag-o-matic eutils multilib

DESCRIPTION="2D and 3D data visualization and analysis program"
HOMEPAGE="http://nsweb.tn.tudelft.nl/~gsteele/spyview/"
SRC_URI="https://github.com/gsteele13/spyview/archive/966012afae2fbb77262bd96a7e530e81b0ed3b90.tar.gz -> $P.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""  # no keywords since it doesnt build yet...
IUSE=""

COMMON_DEPEND="
	dev-libs/boost:=
	media-libs/netpbm
	x11-libs/fltk:1[opengl]
	app-text/ghostscript-gpl
	virtual/glu
"

DEPEND="${COMMON_DEPEND}
	sys-apps/groff"

RDEPEND="${COMMON_DEPEND}
	sci-visualization/gnuplot"

src_unpack() {
	default
	mv -v "${WORKDIR}"/spyview-*/source "${S}" || die
}

src_prepare() {
	append-cflags $(fltk-config --cflags)
	append-cxxflags $(fltk-config --cxxflags) -I/usr/include/netpbm

	# append-ldflags $(fltk-config --ldflags)
	# this one leads to an insane amount of warnings
	append-ldflags -L$(dirname $(fltk-config --libs))

	find "${S}" -name Makefile.am -exec sed -i -e 's:-mwindows -mconsole::g' {} + || die

	default
	eautoreconf
}

src_configure() {
	econf --datadir=/usr/share/spyview --docdir=/usr/share/doc/${PF}
}
