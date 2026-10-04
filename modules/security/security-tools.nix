{
  # A browsing catalog, nothing here is active. Uncomment a line, rebuild, try it.
  # Once you're actually using something regularly, give it its own file, see
  # wireless-audit.nix for an example of something promoted out of this list.
  flake.modules.nixos.security-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # -- Network / wireless --
      # nmap
      # wireshark
      # bettercap
      # wifite2

      # -- Web application testing --
      # burpsuite          # Community Edition by default, see programs/git.nix for Pro
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
