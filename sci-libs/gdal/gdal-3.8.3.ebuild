# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit cmake java-pkg-opt-2 python-single-r1

DESCRIPTION="Translator library for raster geospatial data formats (includes OGR support)"
HOMEPAGE="https://gdal.org/"
SRC_URI="https://github.com/OSGeo/gdal/tarball/654f4907abbbf6bf4226d58a8c067d134eaf3ce9 -> gdal-3.8.3-654f490.tar.gz"

LICENSE="BSD Info-ZIP MIT"
SLOT="0/31" # subslot is libgdal.so.<SONAME>
KEYWORDS="*"
IUSE="armadillo +curl cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse4_1 cpu_flags_x86_ssse3 fits geos gif gml hdf5 heif java jpeg jpeg2k lzma mysql netcdf odbc ogdi opencl oracle pdf png postgres python spatialite sqlite webp xls zstd"
# Tests fail to build in 3.5.0, let's not worry too much yet given
# we're only just porting to CMake. Revisit later.
RESTRICT="test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )
	spatialite? ( sqlite )"

BDEPEND="virtual/pkgconfig
	java? (
		dev-java/ant-core
		dev-lang/swig:0
		>=virtual/jdk-1.8:*
	)
	python? (
		dev-lang/swig:0
		$(python_gen_cond_dep '
			dev-python/setuptools[${PYTHON_USEDEP}]
		')
	)"
DEPEND="dev-libs/expat
	dev-libs/json-c:=
	dev-libs/libpcre2
	dev-libs/libxml2:2
	dev-libs/openssl:=
	media-libs/tiff
	>=sci-libs/libgeotiff-1.5.1-r1:=
	>=sci-libs/proj-6.0.0:=
	sys-libs/zlib[minizip(+)]
	armadillo? ( sci-libs/armadillo:=[lapack] )
	curl? ( net-misc/curl )
	fits? ( sci-libs/cfitsio:= )
	geos? ( >=sci-libs/geos-3.8.0 )
	gif? ( media-libs/giflib:= )
	gml? ( >=dev-libs/xerces-c-3.1 )
	heif? ( media-libs/libheif:= )
	hdf5? ( >=sci-libs/hdf5-1.6.4:=[cxx,szip] )
	jpeg? ( media-libs/libjpeg-turbo:= )
	jpeg2k? ( media-libs/openjpeg:2= )
	lzma? ( || (
		app-arch/xz-utils
		app-arch/lzma
	) )
	mysql? ( virtual/mysql )
	netcdf? ( sci-libs/netcdf:= )
	odbc? ( dev-db/unixODBC )
	ogdi? ( >=sci-libs/ogdi-4.1.0-r1 )
	opencl? ( virtual/opencl )
	oracle? ( dev-db/oracle-instantclient:= )
	pdf? ( app-text/poppler:= )
	png? ( media-libs/libpng:= )
	postgres? ( >=dev-db/postgresql-8.4:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
	spatialite? ( dev-db/spatialite )
	sqlite? ( dev-db/sqlite:3 )
	webp? ( media-libs/libwebp:= )
	xls? ( dev-libs/freexl )
	zstd? ( app-arch/zstd:= )"
RDEPEND="${DEPEND}
	java? ( >=virtual/jre-1.8:* )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use java && java-pkg-opt-2_pkg_setup
}

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/OSGeo-gdal* "${S}" || die
	fi
}

src_prepare(){
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_IPO=OFF
		-DGDAL_USE_EXTERNAL_LIBS=ON
		-DGDAL_USE_INTERNAL_LIBS=OFF
		-DBUILD_TESTING=OFF

		# bug #844874 and bug #845150
		-DCMAKE_INSTALL_INCLUDEDIR="include/gdal"

		# Options here are generally off because of one of:
		# - Not yet packaged dependencies
		#
		# - Off for autotools build and didn't want more churn by
		#   enabling during port to CMake. Feel free to request them
		#   being turned on if useful for you.
		-DGDAL_USE_ARMADILLO=$(usex armadillo)
		-DGDAL_USE_ARROW=OFF
		-DGDAL_USE_BLOSC=OFF
		-DGDAL_USE_BRUNSLI=OFF
		-DGDAL_USE_CRNLIB=OFF
		-DGDAL_USE_CFITSIO=$(usex fits)
		-DGDAL_USE_CURL=$(usex curl)
		-DGDAL_USE_CRYPTOPP=OFF
		-DGDAL_USE_DEFLATE=OFF
		-DGDAL_USE_ECW=OFF
		-DGDAL_USE_EXPAT=ON
		-DGDAL_USE_FILEGDB=OFF
		-DGDAL_USE_FREEXL=$(usex xls)
		-DGDAL_USE_FYBA=OFF
		-DGDAL_USE_GEOTIFF=ON
		-DGDAL_USE_GEOS=$(usex geos)
		-DGDAL_USE_GIF=$(usex gif)
		-DGDAL_USE_GTA=OFF
		-DGDAL_USE_HEIF=$(usex heif)
		-DGDAL_USE_HDF4=OFF
		-DGDAL_USE_HDF5=$(usex hdf5)
		-DGDAL_USE_HDFS=OFF
		-DGDAL_USE_ICONV=ON # TODO dep
		-DGDAL_USE_IDB=OFF
		-DGDAL_USE_JPEG=$(usex jpeg)

		# https://gdal.org/build_hints.html#jpeg12
		# Independent of whether using system libjpeg
		-DGDAL_USE_JPEG12_INTERNAL=ON

		-DGDAL_USE_JSONC=ON
		-DGDAL_USE_JXL=OFF
		-DGDAL_USE_KDU=OFF
		-DGDAL_USE_KEA=OFF
		-DGDAL_USE_LERC=OFF
		-DGDAL_USE_LIBKML=OFF
		-DGDAL_USE_LIBLZMA=$(usex lzma)
		-DGDAL_USE_LIBXML2=ON
		-DGDAL_USE_LURATECH=OFF
		-DGDAL_USE_LZ4=OFF
		-DGDAL_USE_MONGOCXX=OFF
		-DGDAL_USE_MRSID=OFF
		-DGDAL_USE_MSSQL_NCLI=OFF
		-DGDAL_USE_MSSQL_ODBC=OFF
		-DGDAL_USE_MYSQL=$(usex mysql)
		-DGDAL_USE_NETCDF=$(usex netcdf)
		-DGDAL_USE_ODBC=$(usex odbc)
		-DGDAL_USE_ODBCCPP=OFF
		-DGDAL_USE_OGDI=$(usex ogdi)
		-DGDAL_USE_OPENCAD=OFF
		-DGDAL_USE_OPENCL=$(usex opencl)
		-DGDAL_USE_OPENEXR=OFF
		-DGDAL_USE_OPENJPEG=$(usex jpeg2k)
		-DGDAL_USE_OPENSSL=ON
		-DGDAL_USE_ORACLE=$(usex oracle)
		-DGDAL_USE_PARQUET=OFF
		-DGDAL_USE_PCRE2=ON
		-DGDAL_USE_PDFIUM=OFF
		-DGDAL_USE_PNG=$(usex png)
		-DGDAL_USE_POPPLER=$(usex pdf)
		-DGDAL_USE_POSTGRESQL=$(usex postgres)
		-DGDAL_USE_QHULL=OFF
		-DGDAL_USE_RASTERLITE2=OFF
		-DGDAL_USE_RDB=OFF
		-DGDAL_USE_SPATIALITE=$(usex spatialite)
		-DGDAL_USE_SQLITE3=$(usex sqlite)
		-DGDAL_USE_SFCGAL=OFF
		-DGDAL_USE_TEIGHA=OFF
		-DGDAL_USE_TIFF=ON
		-DGDAL_USE_TILEDB=OFF
		-DGDAL_USE_WEBP=$(usex webp)
		-DGDAL_USE_XERCESC=$(usex gml)
		-DGDAL_USE_ZLIB=ON
		-DGDAL_USE_ZSTD=$(usex zstd)

		# Bindings
		-DBUILD_PYTHON_BINDINGS=$(usex python)
		-DBUILD_JAVA_BINDINGS=$(usex java)
		# bug #845369
		-DBUILD_CSHARP_BINDINGS=OFF

		# Check work/gdal-3.5.0_build/CMakeCache.txt after configure
		# and https://github.com/OSGeo/gdal/blob/master/cmake/helpers/CheckCompilerMachineOption.cmake#L71
		# Commented out: not (yet?) implemented upstream.
		# Also, arm64 stuff is a TODO upstream, but not there (yet?)
		-Dtest_avx=$(usex cpu_flags_x86_avx)
		-Dtest_avx2=$(usex cpu_flags_x86_avx2)
		-Dtest_sse=$(usex cpu_flags_x86_sse)
		-Dtest_sse2=$(usex cpu_flags_x86_sse2)
		#-Dtest_sse3=$(usex cpu_flags_x86_sse3)
		-Dtest_sse4.1=$(usex cpu_flags_x86_sse4_1)
		#-Dtest_sse4.2=$(usex cpu_flags_x86_sse4_2)
		#-Dtest_sse4a=$(usex cpu_flags_x86_sse4a)
		-Dtest_ssse3=$(usex cpu_flags_x86_ssse3)
		#-Dtest_fma4=$(usex cpu_flags_x86_fma4)
		#-Dtest_xop=$(usex cpu_flags_x86_xop)
	)

	cmake_src_configure
}

pkg_postinst() {
	elog "Check available image and data formats after building with"
	elog "gdalinfo and ogrinfo (using the --formats switch)."
}