EAPI=8

inherit cmake git-r3

DESCRIPTION="Simple Direct Media Layer"
HOMEPAGE="https://www.libsdl.org/"
EGIT_REPO_URI="https://github.com/libsdl-org/SDL.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
    cmake_src_prepare
}

src_configure() {
    local mycmakeargs=(
        # Add any necessary CMake options here
    )

    cmake_src_configure
}

src_compile() {
    cmake_src_compile
}

src_install() {
    cmake_src_install
}
