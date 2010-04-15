# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

EGIT_REPO_URI="git://github.com/Necoro/portato.git"

inherit python eutils distutils git

DESCRIPTION="A GUI for Portage written in Python."
HOMEPAGE="http://necoro.eu/portato"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="+eix kde +libnotify nls userpriv sqlite"
LANGS="ca de es fr it pl pt_BR tr"
for X in $LANGS; do IUSE="${IUSE} linguas_${X}"; done

COMMON_DEPEND="|| (
			dev-lang/python:2.7[sqlite?,threads]
			dev-lang/python:2.6[sqlite?,threads] )"

RDEPEND="$COMMON_DEPEND
		app-portage/portage-utils
		x11-libs/vte[python]
		>=dev-python/pygtk-2.14.0
		dev-python/pygtksourceview:2
		>=sys-apps/portage-2.1.7.17

		kde? ( kde-base/kdesu )
		!kde? ( || ( x11-misc/ktsuss x11-libs/gksu ) )
		libnotify? ( dev-python/notify-python )
		nls? ( virtual/libintl )
		eix? ( >=app-portage/eix-0.15.4 )"

# python should be set as DEPEND in the python-eclass
DEPEND="$COMMON_DEPEND
		nls? ( sys-devel/gettext )
		>=dev-python/cython-0.12"

CONFIG_DIR="etc/${PN}"
DATA_DIR="usr/share/${PN}"
LOCALE_DIR="usr/share/locale"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"
TEMPLATE_DIR="${DATA_DIR}/templates"

pkg_setup()
{
	python_set_active_version 2
}

src_configure ()
{
	sed -i 	-e "s;^\(REVISION\s*=\s*\).*;\1\"${EGIT_VERSION}\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${ROOT}${CONFIG_DIR}/\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${ROOT}${DATA_DIR}/\";" \
			-e "s;^\(TEMPLATE_DIR\s*=\s*\).*;\1\"${ROOT}${TEMPLATE_DIR}/\";" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ROOT}${ICON_DIR}/\";" \
			-e "s;^\(LOCALE_DIR\s*=\s*\).*;\1\"${ROOT}${LOCALE_DIR}/\";" \
			-e "s;^\(REPOURI\s*=\s*\).*;\1\"${EGIT_REPO_URI}::${EGIT_BRANCH}\";" \
			"${PN}"/constants.py || die "sed failed"

	if use userpriv; then
		sed -i -e "s/Exec=.*/Exec=portato --no-fork/" portato.desktop || die "sed failed"
	fi
}

src_compile ()
{
	if use nls; then
		./pocompile.sh -emerge ${LINGUAS} || die "pocompile failed"
	fi

	distutils_src_compile $(use_enable eix)
}

src_install ()
{
	dodir ${DATA_DIR} || die "dodir failed"
	distutils_src_install $(use_enable eix)

	newbin portato.py portato || die "newbin failed"
	dodoc doc/* || die "dodoc failed"

	# config
	insinto ${CONFIG_DIR}
	doins etc/* || die "installing config files failed"

	# plugins
	insinto ${PLUGIN_DIR}
	doins plugins/new_version.py || die "installing new_version.py failed"

	# desktop
	doicon icons/portato-icon.png || die "doicon failed"
	domenu portato.desktop || die "domenu failed"

	# nls
	if use nls && [ -d i18n/mo ]; then
		domo i18n/mo/*
	fi

	# man page
	doman portato.1
}

pkg_postinst ()
{
	distutils_pkg_postinst
	python_mod_optimize "/${PLUGIN_DIR}"
}

pkg_postrm ()
{
	distutils_pkg_postrm
	python_mod_cleanup "/${PLUGIN_DIR}"

	# try to remove the DATA_DIR, because it may still reside there, as it was tried
	# to remove it before plugin stuff was purged
	rmdir "${ROOT}"${DATA_DIR} 2> /dev/null
}
