# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EANT_BUILD_TARGET="dist"
EANT_NEEDS_TOOLS="true"
JAVA_ANT_REWRITE_CLASSPATH="true"

inherit java-pkg-2 java-ant-2 vcs-snapshot

DESCRIPTION="The Genome Analysis Toolkit"
HOMEPAGE="http://www.broadinstitute.org/gsa/wiki/index.php/The_Genome_Analysis_Toolkit"
SRC_URI="https://github.com/broadgsa/gatk/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
IUSE=""
KEYWORDS="~amd64"

COMMON_DEPS=""
DEPEND="
	>=virtual/jdk-1.6
	${COMMON_DEPS}"
RDEPEND="
	>=virtual/jre-1.6
	${COMMON_DEPS}"

src_prepare() {
	sed -i '/property name="ivy.home"/ s|${user.home}|'${WORKDIR}'|' build.xml || die
	java-pkg-2_src_prepare
}

src_install() {
	java-pkg_dojar dist/*.jar
	java-pkg_dolauncher GenomeAnalysisTK --jar GenomeAnalysisTK.jar
	java-pkg_dolauncher AnalyzeCovariates --jar AnalyzeCovariates.jar
}
