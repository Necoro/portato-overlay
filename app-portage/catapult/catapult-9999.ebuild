# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion

ESVN_REPO_URI="https://svn.origo.ethz.ch/catapult/catapult"
ESVN_PROJECT="catapult"

DESCRIPTION="The Catapult Backend"
HOMEPAGE="http://catapult.origo.ethz.ch"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="portage"

DEFAULT_DEPEND="!portage? ( app-portage/catapult-portage )"

DEPEND=""
RDEPEND="sys-apps/dbus
		portage? ( app-portage/catapult-portage )
		$DEFAULT_DEPEND"

pkg_setup ()
{
	if ! use portage; then
		ewarn "No backend selected. Defaulting to portage."
	fi
}

src_install ()
{	
	newbin "catapult-start.sh" catapult-start
	dodir /usr/libexec/catapult
	keepdir /usr/libexec/catapult
}
