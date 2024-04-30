# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v7.7.0.tar.gz -> v7.7.0.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

post_src_unpack() {
	if [ ! -d "${WORKDIR}/${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DSUITESPARSE_ENABLE_PROJECTS="suitesparse_config"
		-DNSTATIC=ON
	)
	cmake_src_configure
}