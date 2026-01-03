cask "ghostty-linux" do
  version "1.2.3"
  sha256 "cf239a0a9383aa9a148da2f6c6444993f871618cf4309d4db15d7be992d16725"

  url "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v#{version}/Ghostty-#{version}-x86_64.AppImage"
  name "Ghostty"
  desc "Terminal emulator that uses platform-native UI and GPU acceleration"
  homepage "https://ghostty.org/"

  livecheck do
    url "https://github.com/pkgforge-dev/ghostty-appimage/releases/latest"
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/bin/ghostty"
  artifact "squashfs-root/com.mitchellh.ghostty.desktop",
           target: "#{Dir.home}/.local/share/applications/com.mitchellh.ghostty.desktop"
  artifact "squashfs-root/com.mitchellh.ghostty.png",
           target: "#{Dir.home}/.local/share/icons/com.mitchellh.ghostty.png"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    appimage_path = "#{staged_path}/Ghostty-#{version}-x86_64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm appimage_path

    desktop_content = File.read("#{staged_path}/squashfs-root/com.mitchellh.ghostty.desktop")
    desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/ghostty")
    File.write("#{staged_path}/squashfs-root/com.mitchellh.ghostty.desktop", desktop_content)
  end

  zap trash: [
    "~/.cache/ghostty",
    "~/.config/ghostty",
    "~/.local/share/ghostty",
  ]
end
