# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit flag-o-matic java-pkg-2 java-pkg-simple python-r1 toolchain-funcs

DESCRIPTION="An efficient theorem prover"
HOMEPAGE="http://z3.codeplex.com/"
SRC_URI="https://github.com/Z3Prover/z3/archive/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE="doc gmp isabelle java python"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	gmp? ( dev-libs/gmp:0 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	java? ( >=virtual/jdk-1.8 )"

S=${WORKDIR}/${PN}-${P}
JAVA_SRC_DIR=${S}/src/api/java

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ $(tc-getCXX)$ == *g++* ]] && ! tc-has-openmp; then
			ewarn "Please use an openmp compatible compiler"
			ewarn "like >gcc-4.2 with USE=openmp"
			die "Openmp support missing in compiler"
		fi
	fi
}

src_prepare() {
	default

	sed \
		-e 's:-O3::g' \
		-e 's:-fomit-frame-pointer::' \
		-e 's:-msse2::g' \
		-e 's:-msse::g' \
		-e "/LINK_EXTRA_FLAGS/s:@LDFLAGS@:-lrt $(usex gmp -lgmp ""):g" \
		-e 's:t@\$:t\$:g' \
		-i scripts/*mk* || die

	sed \
		-e "s:SLIBEXTRAFLAGS = '':SLIBEXTRAFLAGS = '-Wl,-soname,lib${PN}.so.0.1':" \
		-i scripts/mk_util.py || die

	sed -e 's:api\\html\\ml:api/html/ml:' \
		-e 's:python/z3.py:python/z3/z3.py:' \
		-i doc/mk_api_doc.py || die

	append-ldflags -fopenmp
}

src_configure() {
	python_setup
	python_export PYTHON_SITEDIR
	export Z3_INSTALL_LIB_DIR="$(get_libdir)"
	export Z3_INSTALL_INCLUDE_DIR="include/z3"
	set -- \
		--pypkgdir="${PYTHON_SITEDIR}" \
		--prefix="${ROOT}usr" \
		$(usex gmp --gmp "") \
		$(usex python --python "") \
		$(usex java --java "")
	elog ./configure "$@"
	./configure "$@" || die
	${EPYTHON} scripts/mk_make.py || die
}

src_compile() {
	emake \
		--directory="build" \
		CXX=$(tc-getCXX) \
		LINK="$(tc-getCXX) ${LDFLAGS}" \
		LINK_FLAGS="${LDFLAGS}"

	use java && java-pkg-simple_src_compile

	if use doc; then
		pushd doc || die
		${EPYTHON} mk_api_doc.py || die
		popd || die
	fi
}

src_install() {
	emake \
		--directory="build" \
		CXX=$(tc-getCXX) \
		LINK="$(tc-getCXX) ${LDFLAGS}" \
		LINK_FLAGS="${LDFLAGS}" \
		install DESTDIR="${D}"

	if use python; then
		python_foreach_impl python_domodule src/api/python/*.py
	fi

	use java && java-pkg-simple_src_install

	if use isabelle; then
		ISABELLE_HOME="${ROOT}usr/share/Isabelle"
		dodir "${ISABELLE_HOME}/contrib/${PN}-${PV}/etc"
		cat <<- EOF >> "${S}/settings"
			Z3_COMPONENT="\$COMPONENT"
			Z3_HOME="${ROOT}usr/bin"
			Z3_SOLVER="${ROOT}usr/bin/z3"
			Z3_REMOTE_SOLVER="z3"
			Z3_VERSION="${PV}"
			Z3_INSTALLED="yes"
			Z3_NON_COMMERCIAL="yes"
		EOF
		insinto "${ISABELLE_HOME}/contrib/${PN}-${PV}/etc"
		doins "${S}/settings"
	fi

	local DOCS=( "README.md" "RELEASE_NOTES" )
	local HTML_DOCS=( "doc/api/html/." )
	use doc && einstalldocs
}

pkg_postinst() {
	if use isabelle; then
		if [ -f "${ROOT}etc/isabelle/components" ]; then
			if egrep "contrib/${PN}-[0-9.]*" "${ROOT}etc/isabelle/components"; then
				sed -e "/contrib\/${PN}-[0-9.]*/d" \
					-i "${ROOT}etc/isabelle/components"
			fi
			cat <<- EOF >> "${ROOT}etc/isabelle/components"
				contrib/${PN}-${PV}
			EOF
		fi
	fi
}

pkg_postrm() {
	if use isabelle; then
		if [ ! -f "${ROOT}usr/bin/Z3" ]; then
			if [ -f "${ROOT}etc/isabelle/components" ]; then
				# Note: this sed should only match the version of this ebuild
				# Which is what we want as we do not want to remove the line
				# of a new Isabelle component being installed during an upgrade.
				sed -e "/contrib\/${PN}-${PV}/d" \
					-i "${ROOT}etc/isabelle/components"
			fi
		fi
	fi
}
