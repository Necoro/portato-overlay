# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

NEED_PYTHON="2.5"
inherit distutils subversion

ESVN_REPO_URI="https://svn.origo.ethz.ch/catapult/portage"
ESVN_PROJECT="catapult/portage"

DESCRIPTION="The Portage Provider for the Catapult Backend"
HOMEPAGE="http://catapult.origo.ethz.ch"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND=">=dev-python/dbus-python-0.82.2
	>=sys-apps/portage-2.1.3"
PDEPEND="app-portage/catapult"

src_install ()
{	
	distutils_src_install
	
	exeinto /usr/libexec/catapult
	newexe "start.py" portage

	insinto /usr/share/dbus-1/services
	doins *.service
}
