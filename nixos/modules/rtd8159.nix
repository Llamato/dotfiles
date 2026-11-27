# Realtek RTL8159 (USB ID 0bda:815a) 10GbE USB NIC: PHY firmware patch.
#
# The in-tree r8152 driver needs rtl_nic/rtl8159-1.fw to drive the PHY above
# 5 Gbit/s. Kernel commit a51e171e176c ("r8152: Add firmware upload capability
# for RTL8157/RTL8159") is explicit:
#
#     The RTL8159 (RTL_VER_17) requires firmware for its PHY in order to work
#     at connection speeds > 5GBit.
#
# Without the patch the PHY never advertises 10000baseT/Full, so
# autonegotiation settles at 5000baseT/Full even though ethtool still lists
# 10000baseT/Full under "Supported link modes" (that table is static in the
# driver). The kernel says so at plug time:
#
#     r8152 2-2:1.0: Direct firmware load for rtl_nic/rtl8159-1.fw failed with error -2
#     r8152 2-2:1.0: unable to load firmware patch rtl_nic/rtl8159-1.fw (-2)
#
# linux-firmware (20261019) ships rtl8156a-2/rtl8156b-2 but neither
# rtl8159-1.fw nor rtl8157-1.fw. Realtek sent candidates to
# linux-firmware@kernel.org in Nov 2026 but they have not landed, so the blob
# is vendored here in ./firmware/. Regenerate it with:
#
#     git clone https://gitlab.com/koblitz-rtlnic/rtlnic_fw && cd rtlnic_fw
#     nix-shell -p openssl --run 'gcc rtl_fw.c -o rtl_fw -lssl -lcrypto'
#     ./rtl_fw -w 17          # writes rtl8159-1.fw
#
# sha256 of ./firmware/rtl8159-1.fw:
#     0213f1e3e048e13f0f29aad6a33559370f8d32acaa202baff1f04d0a01e5d3cf
#
# Drop this module once linux-firmware ships the file itself, i.e. when
#     ls /run/current-system/firmware/rtl_nic/rtl8159-1.fw*
# finds the file after a plain `nixos-rebuild switch` without this module.
#
# Caveat that firmware does not fix: the RTL8159 wants a USB 3.2 Gen 2x2
# (20 Gbps) port. On a Gen 2x1 (10 Gbps) port it will still link up at
# 10GbE, but USB overhead caps real throughput well below line rate.
{
  pkgs,
  lib,
  ...
}:
{
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "rtl8159-phy-firmware";
      version = "2026-01-01";
      src = ./firmware;

      meta.license = lib.licenses.unfreeRedistributableFirmware;

      # NixOS zstd-compresses this automatically (hardware.firmwareCompression,
      # default "zstd" for kernels >= 5.19), matching how the rtl_nic blobs
      # from linux-firmware appear under /run/current-system/firmware.
      phases = [ "installPhase" ];
      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/firmware/rtl_nic
        # src is a directory, and there is no unpackPhase, so the blob sits at $src/.
        cp $src/rtl8159-1.fw $out/lib/firmware/rtl_nic/

        runHook postInstall
      '';
    })
  ];
}
