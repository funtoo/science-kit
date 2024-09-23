#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re

async def generate(hub, **pkginfo):
	html_data = await hub.pkgtools.fetch.get_page("https://posit.co/download/rstudio-desktop/")
	soup = BeautifulSoup(html_data, "html.parser")
	best_archive = None
	for link in soup.find_all("a"):
		href = link.get("href")
		if href is not None and href.endswith(".tar.gz"):
			# currently the first release is the newest ubuntu/debian based one
			best_archive = href
			break
	found = re.search(r"rstudio-.*-amd64",best_archive)
	if found:
		version = found.group(0)[8:-6]
	else:
		raise ValueError("Could not find link for rstudio")
	# comes in form YYYY.MM.DD-NUM and we need to make it YYYY.MM.DD.NUM
	version = version.replace("-",".")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=best_archive, final_name=f"rstudio-{version}_x86_64.pkg.tar.gz")]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
