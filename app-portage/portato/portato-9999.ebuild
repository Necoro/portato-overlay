# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

NEED_PYTHON="2.5"
inherit python eutils distutils bzr

EBZR_REPO_URI="lp:portato"
EBZR_CACHE_DIR="${P}"

DESCRIPTION="A GUI for Portage written in Python."
HOMEPAGE="http://portato.origo.ethz.ch/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="etc-proposals gpytage kde +libnotify nls userpriv"
LANGS="ca de tr pl"
for LANG in $LANGS; do IUSE="${IUSE} linguas_${LANG}"; done

RDEPEND="app-portage/portage-utils
		x11-libs/vte
		gnome-base/libglade
		dev-python/pygtksourceview:2
		|| ( =dev-python/lxml-1.3.6 >=dev-python/lxml-2.0.4 )
		>=dev-python/pygtk-2.12.0
		>=sys-apps/portage-2.1.2
		<sys-apps/portage-2.2

		!userpriv? (
			dev-python/shm
			kde? ( || ( kde-base/kdesu kde-base/kdebase ) )
			!kde? ( x11-libs/gksu ) )

		libnotify? ( dev-python/notify-python )
		nls? ( virtual/libintl )
		etc-proposals? ( app-portage/etc-proposals )
		gpytage? ( app-portage/gpytage )"

DEPEND="nls? ( sys-devel/gettext )"

CONFIG_DIR="etc/${PN}/"
DATA_DIR="usr/share/${PN}/"
LOCALE_DIR="usr/share/locale/"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"
TEMPLATE_DIR="${DATA_DIR}/templates"

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
	local rev=$(${EBZR_REVNO_CMD} "${EBZR_STORE_DIR}/${EBZR_CACHE_DIR}")

	local su="\"gksu -D 'Portato'\""
	use kde && su="\"kdesu -t --nonewdcop -i %s -c\" % APP_ICON"

	sed -i 	-e "s;^\(VERSION\s*=\s*\).*;\1\"${PV} rev. $rev\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${ROOT}${CONFIG_DIR}\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${ROOT}${DATA_DIR}\";" \
			-e "s;^\(TEMPLATE_DIR\s*=\s*\).*;\1\"${ROOT}${TEMPLATE_DIR}\";" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ROOT}${ICON_DIR}\";" \
			-e "s;^\(LOCALE_DIR\s*=\s*\).*;\1\"${ROOT}${LOCALE_DIR}\";" \
			-e "s;^\(SU_COMMAND\s*=\s*\).*;\1$su;" \
			-e "s;^\(USE_CATAPULT\s*=\s*\).*;\1False;" \
			${PN}/constants.py

	use userpriv && sed -i -e "s/Exec=.*/Exec=portato --no-fork/" portato.desktop
	use nls && ./pocompile.sh -emerge ${LINGUAS}

	distutils_src_compile
}

src_install ()
{
	dodir ${DATA_DIR}
	distutils_src_install

	newbin portato.py portato
	dodoc doc/*

	# config
	insinto ${CONFIG_DIR}
	doins etc/*

	# plugins
	insinto ${PLUGIN_DIR}
	keepdir ${PLUGIN_DIR}

	use etc-proposals && doins plugins/etc_proposals.xml
	use gpytage && doins plugins/gpytage.xml
	use libnotify && doins plugins/notify.xml
	use libnotify && doins plugins/new_version.xml

	# desktop
	doicon icons/portato-icon.png
	domenu portato.desktop

	# nls
	use nls && domo i18n/mo/*
}
