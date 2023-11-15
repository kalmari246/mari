# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit python-any-r1 meson

MY_PV=$(ver_cut 1-3)
[[ -n "$(ver_cut 4)" ]] && MY_PV_REV="-$(ver_cut 4)"

DESCRIPTION="Vulkan and OpenGL overlay for monitoring FPS, sensors, system load and more"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

VK_HEADERS_VER="1.2.158"
VK_HEADERS_MESON_WRAP_VER="2"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
else
	SRC_URI="
		https://github.com/flightlessmango/MangoHud/archive/v${MY_PV}${MY_PV_REV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VK_HEADERS_VER}.tar.gz
			-> vulkan-headers-${VK_HEADERS_VER}.tar.gz
		https://wrapdb.mesonbuild.com/v2/vulkan-headers_${VK_HEADERS_VER}-${VK_HEADERS_MESON_WRAP_VER}/get_patch
			-> vulkan-headers-${VK_HEADERS_VER}-${VK_HEADERS_MESON_WRAP_VER}-meson-wrap.zip
	"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland video_cards_nvidia video_cards_amdgpu"

REQUIRED_USE="
	|| ( X wayland )
	xnvctrl? ( video_cards_nvidia )"

BDEPEND="
	app-arch/unzip
	$(python_gen_any_dep 'dev-python/mako[${PYTHON_USEDEP}]')
"

python_check_deps() {
	python_has_version "dev-python/mako[${PYTHON_USEDEP}]"
}

DEPEND="
	media-libs/imgui[opengl,vulkan]
	dev-cpp/nlohmann_json
	dev-libs/spdlog
	dev-util/glslang
	media-libs/vulkan-loader
	media-libs/libglvnd
	x11-libs/libdrm
	dbus? ( sys-apps/dbus )
	X? ( x11-libs/libX11 )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland )
"

RDEPEND="${DEPEND}"

[[ "$PV" != "9999" ]] && S="${WORKDIR}/MangoHud-${PV}"

PATCHES=(
	"${FILESDIR}/use-system-imgui.patch"
)

src_unpack() {
	default
	if [[ $PV != 9999 ]]; then

		[[ -n "${MY_PV_REV}" ]] && ( mv "${WORKDIR}/MangoHud-${MY_PV}${MY_PV_REV}" "${WORKDIR}/MangoHud-${PV}" || die )

		unpack vulkan-headers-${VK_HEADERS_VER}.tar.gz
		unpack vulkan-headers-${VK_HEADERS_VER}-${VK_HEADERS_MESON_WRAP_VER}-meson-wrap.zip
		mv "${WORKDIR}/Vulkan-Headers-${VK_HEADERS_VER}" "${S}/subprojects/" || die
	else
		git-r3_src_unpack
	fi
}

src_prepare() {
	default
	# replace all occurences of "#include <imgui.h>" to "#include <imgui/imgui.h>"
	find . -type f -exec sed -i 's/#include <imgui.h>/#include <imgui\/imgui.h>/g' {} \;
	find . -type f -exec sed -i 's/#include "imgui.h"/#include <imgui\/imgui.h>/g' {} \;
}

src_configure() {
	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Duse_system_spdlog=enabled
		-Dinclude_doc=false
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
	)
	meson_src_configure
}

pkg_postinst() {
	if ! use xnvctrl; then
		einfo ""
		einfo "If mangohud can't get GPU load, or other GPU information,"
		einfo "and you have an older Nvidia device."
		einfo ""
		einfo "Try enabling the 'xnvctrl' useflag."
		einfo ""
	fi
}
