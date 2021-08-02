# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils xdg-utils

DESCRIPTION="Autodesk EAGLE schematic and printed circuit board (PCB) layout editor"
HOMEPAGE="https://www.autodesk.com/products/eagle/overview"
SRC_URI="http://trial2.autodesk.com/NET17SWDLD/2017/EGLPRM/ESD/Autodesk_EAGLE_${PV}_English_Linux_64bit.tar.gz"

LICENSE="Autodesk" # http://download.autodesk.com/us/FY17/Suites/LSA/en-US/lsa.html
SLOT="0"
KEYWORDS="*"
IUSE="doc"

QA_PREBUILT="opt/eagle/eagle"
RESTRICT="mirror bindist strip"

RDEPEND="
	app-crypt/mit-krb5
	dev-libs/glib
	dev-libs/libgcrypt
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/libtasn1
	dev-libs/nspr
	dev-libs/nss
	media-libs/jasper
	media-libs/mesa[egl,gbm]
	net-libs/gnutls
	sys-apps/dbus
	virtual/jpeg
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXxf86vm
	net-dns/avahi
	dev-libs/openssl-compat:1.0.0
	sys-apps/dbus
	dev-libs/libffi
	dev-libs/libpcre
	sys-libs/libselinux
	x11-libs/libxshmfence
"

src_prepare() {
	local extralibs=$(ls -1 lib | grep -vE "^(libicu|libQt|libSuits)")
	local f
	for f in ${extralibs}; do
		rm lib/$f || die
	done

	default
}

src_install() {
	local installdir="/opt/eagle"

	exeinto ${installdir}
	doexe eagle
	rm eagle || die

	exeinto ${installdir}/libexec
	doexe libexec/QtWebEngineProcess
	rm libexec/QtWebEngineProcess || die

	doman doc/eagle.1
	rm doc/eagle.1 || die

	use doc && dodoc README
	rm README || die

	insinto ${installdir}
	doins -r .

	echo -e "ROOTPATH=${installdir}\nPRELINK_PATH_MASK=${installdir}" > "${S}/90${P}"
	doenvd "${S}/90${P}"

	newicon "bin/${PN}-logo.png" "autodesk-${PN}.png"
	make_wrapper ${PN} "${EROOT}opt/${PN}/eagle" "${EROOT}opt/${PN}" "${EROOT}opt/${PN}/lib"
	make_desktop_entry ${PN} "EAGLE PCB Designer" "autodesk-${PN}.png" "Development;Electronics"
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update

	elog "Run \`env-update && source /etc/profile\` from within \${ROOT}"
	elog "now to set up the correct paths."
	ewarn
	ewarn "Due to changes in licensing, from version 8.0 onwards a subscription is required."
	ewarn "Access https://www.autodesk.com/products/eagle/subscribe for more information."
	ewarn
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
