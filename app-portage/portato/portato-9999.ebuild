# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON="2.5"
inherit python eutils distutils subversion

PPATH="portato/trunk"
ESVN_REPO_URI="https://svn.origo.ethz.ch/${PPATH}"
ESVN_PROJECT="portato"

DESCRIPTION="A GUI for Portage written in Python."
HOMEPAGE="http://portato.origo.ethz.ch/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="catapult etc-proposals kde libnotify nls userpriv"

RDEPEND=">=dev-python/lxml-1.3.2
		>=dev-python/pygtk-2.12.0
		>=x11-libs/vte-0.12.2
		>=gnome-base/libglade-2.5.1
		>=x11-libs/gtksourceview-2.0.1-r1
		>=dev-python/pygtksourceview-2.0.0
		!userpriv? (
			kde? ( || ( >=kde-base/kdesu-3.5.5 >=kde-base/kdebase-3.5.5 ) )
			!kde? ( >=x11-libs/gksu-2.0.0 ) )
		
		catapult? ( 
			app-portage/catapult 
			>=dev-python/dbus-python-0.82.2 )
		!catapult? ( >=sys-apps/portage-2.1.2 )
		libnotify? ( >=dev-python/notify-python-0.1.1 )
		nls? ( virtual/libintl )
		etc-proposals? ( >=app-portage/etc-proposals-1.0 )"

DEPEND="nls? ( sys-devel/gettext )"

S="${WORKDIR}/${PN}"
CONFIG_DIR="etc/${PN}/"
DATA_DIR="usr/share/${PN}/"
LOCALE_DIR="usr/share/locale/"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"

pkg_setup ()
{
	if ! built_with_use x11-libs/vte python; then
		echo
		eerror "x11-libs/vte has not been built with python support."
		eerror "Please re-emerge vte with the python use-flag enabled."
		die "missing python flag for x11-libs/vte"
	fi
}

src_compile ()
{
	local rev=$(svn status -v ${ESVN_STORE_DIR}/${PPATH} | awk '{print $1;}' |
	head -n1)

	# currently only gtk is supported
	local std="gtk"
	local frontends="[\"$std\"]"

	local su="\"gksu -D 'Portato'\""
	use kde && su="\"kdesu -t --nonewdcop -i %s -c\" % APP_ICON"

	# catapult?
	local catapult="False"
	use catapult && catapult="True"

	sed -i 	-e "s;^\(VERSION\s*=\s*\).*;\1\"${PV} rev. $rev\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${ROOT}${CONFIG_DIR}\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${ROOT}${DATA_DIR}\";" \
			-e "s;^\(TEMPLATE_DIR\s*=\s*\).*;\1DATA_DIR;" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ROOT}${ICON_DIR}\";" \
			-e "s;^\(LOCALE_DIR\s*=\s*\).*;\1\"${ROOT}${LOCALE_DIR}\";" \
			-e "s;^\(FRONTENDS\s*=\s*\).*;\1$frontends;" \
			-e "s;^\(STD_FRONTEND\s*=\s*\).*;\1\"$std\";" \
			-e "s;^\(SU_COMMAND\s*=\s*\).*;\1$su;" \
			-e "s;^\(USE_CATAPULT\s*=\s*\).*;\1$catapult;" \
			${PN}/constants.py

	use userpriv && sed -i -e "s/Exec=.*/Exec=portato --no-listener/" portato.desktop
	use nls && ./pocompile.sh -emerge

	distutils_src_compile
}

src_install ()
{
	dodir "${DATA_DIR}"
	distutils_src_install

	newbin portato.py portato
	dodoc doc/*

	# config
	insinto "${CONFIG_DIR}"
	doins etc/*

	# plugins
	insinto "${PLUGIN_DIR}"
	keepdir "${PLUGIN_DIR}"

	use etcproposals && doins "plugins/etc_proposals.xml"
	use libnotify && doins "plugins/notify.xml"

	# icon
	doicon icons/portato-icon.png

	# menu
	domenu portato.desktop

	# nls
	use nls && domo i18n/mo/*
}
