# Fire TV Cube 3 Wi-Fi 6/6E port

This branch starts at SamuriHL's CoreELEC release tag
`v22.0-samurihl-20260928164552` (`f91de32345`). It keeps that release's
BD-J, Dolby Vision FEL, audio-sync, subtitle, and Kodi patch stack unchanged.

## Applied CoreELEC commits

The following commits were cherry-picked from the official `coreelec-22`
branch, in their original order:

1. `0e0fd056fe` - install the mt76 regional power tables from the driver
   sources.
2. `15afb567f1` - update `linux-amlogic` from `69e87fa40c` to
   `968a93c282`.
3. `eb9eaca7e5` - update mt76 from `647c054310` to `2be28adcf`.

No Kodi, libbluray, FFmpeg, media_modules, common_drivers, device-tree, or
unrelated RC1 package changes were imported.

## Included driver changes

The `linux-amlogic` update contains exactly these three commits after the
SamuriHL kernel revision:

- `5a411bac6c` - restore the HE receive aggregation-window limit.
- `52aa0aedcc` - allow legacy airtime calculation on 6 GHz.
- `968a93c282` - propagate the access point's 6 GHz power type.

The mt76 update contains the following Cube 3 changes:

- `302542ded9` - restore mt7921 HE capabilities on 2.4 and 5 GHz.
- `9eca6f5dd7` - load Fire TV Cube 3 regional power tables.
- `85ad30df92` - add the Fire TV Cube 3 regional power-table files.
- `8b14ec9bc0` - merge the HE-capability restoration.
- `2be28adcf` - finalize loading the Cube 3 regional power tables.

The existing `wlan-firmware` pin remains `c0ad2587a8`; it is identical in the
SamuriHL base and the official RC1-era branch. The Cube 3 mt7961 SDIO device ID
was already present in SamuriHL's `linux-amlogic` base, so no device-tree or
additional firmware change was required.

## Verification

- All three distro commits cherry-picked without content conflicts.
- The resulting diff from the SamuriHL tag is limited to the two mt76 package
  lines, the mt76 power-table install step, this document, and the
  `linux-amlogic` package pin (before the requested boot-artwork change below).
- A full CoreELEC image build still requires the supported Linux build
  environment; Windows is suitable for source and configuration checks only.

## Requested stock boot animation

The Amlogic-no static splash and complete progress-animation directory were
restored byte-for-byte from official CoreELEC `coreelec-22` revision
`3636aaa649efc5060e89cffb1257e8d36c8792e8`, replacing SamuriHL's samurai artwork.
The official configuration uses 20 frames per second. This is an artwork-only
change; SamuriHL's BD-J/playback modifications and the Wi-Fi fixes remain intact.

## Upstream update proposals

`Check SamuriHL updates` runs daily at 07:23 UTC and can also be started manually
in GitHub Actions. It tracks `SamuriHL/CoreELEC: samurihl-ce22` only, not the
official CoreELEC RC/nightly branch. If there are new commits, it updates the
dedicated `updates/samurihl-ce22` proposal branch and opens or refreshes one
draft pull request targeting `cube3-wifi6e-samurihl-20260928`.

The default branch is never automatically changed. The workflow does not run
upstream build scripts, approve PRs, merge PRs, or install anything on the Cube.
It reports merge conflicts and flags merged-tree changes to the stock boot
artwork or Wi-Fi package configuration. A new build and hardware testing remain
required before manual merging. Upstream history rewrites fail safely rather
than force-pushing over the proposal branch.

GitHub Actions must be enabled and its repository setting for creating pull
requests allowed. General default workflow permissions remain read-only; only
this proposal job requests contents/write and pull-requests/write. Public
repositories can have scheduled workflows disabled by GitHub after inactivity;
check Actions if no scheduled runs appear.
