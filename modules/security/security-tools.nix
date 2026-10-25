{
  # A browsing catalog, nothing here is active. Uncomment a line, rebuild, try it.
  # Once you're actually using something regularly, give it its own file, see
  # wireless-audit.nix and recon.nix for examples of tools promoted out of this list.
  flake.modules.nixos.security-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # -- Network / wireless --
      # nmap               # promoted, now lives in recon.nix
      # wireshark
      # bettercap
      # wifite2

      # -- Web application testing --
      # burpsuite          # Community Edition by default; Pro features need a paid license
      # sqlmap
      # nikto
      # gobuster
      # ffuf

      # -- Passwords / cracking --
      # john
      # hashcat
      # hydra

      # -- Exploitation --
      # metasploit

      # -- Forensics / reverse engineering --
      # radare2
      # ghidra
      # binwalk
      # foremost
      # exiftool
      # volatility3
    ];
  };
}
