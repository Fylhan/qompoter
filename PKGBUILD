# Submitter: Fylhan <https://github.com/Fylhan>
# Maintainer: Olivier Maridat (Fylhan)

pkgname=qompoter
pkgver=0.5.0-RC1
pkgrel=1
pkgdesc="Dependency manager for Qt / C++"
arch=('any')
url="http://fylhan.github.io/qompoter"
license=('LGPL3+')
makedepends=('git')
source=('git://github.com/fylhan/qompoter.git')
md5sums=('SKIP')
depends=('bash' 'git' 'sed', 'md5sum')

pkgver() {
	cd "$pkgname" || exit 1
	printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

check() {
	cd "$srcdir/$pkgname" || exit 1
	sh "run-all-tests.sh"
}

package() {
	cd "$srcdir/$pkgname" || exit 1
	install -Dm755 "$srcdir/$pkgname/qompoter.sh" "$pkgdir/usr/bin/$pkgname"
	install -Dm644 "$srcdir/$pkgname/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
	install -Dm644 "$srcdir/$pkgname/README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
	install -Dm644 "$srcdir/$pkgname/changelogs.md "$pkgdir/usr/share/doc/$pkgname/changelogs.md"
	install -Dm644 "$srcdir/$pkgname/qompoter_bash_completion.sh" "$pkgdir/usr/share/bash-completion/completions/$pkgname"
}

 
