cask "ghostty-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.2.3"
  sha256 arm64_linux:  "b8cec82eaa66a253f0d446b1a8afbd4331acce8be8247f72d436c0a4cc50d254",
         x86_64_linux: "cf239a0a9383aa9a148da2f6c6444993f871618cf4309d4db15d7be992d16725"

  url "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v#{version}/Ghostty-#{version}-#{arch}.AppImage"
  name "Ghostty"
  desc "Terminal emulator that uses platform-native UI and GPU acceleration"
  homepage "https://ghostty.org/"

  livecheck do
    url "https://github.com/pkgforge-dev/ghostty-appimage/releases/latest"
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/AppRun", target: "ghostty"
  artifact "squashfs-root/com.mitchellh.ghostty.desktop",
           target: "#{Dir.home}/.local/share/applications/com.mitchellh.ghostty.desktop"
  artifact "squashfs-root/com.mitchellh.ghostty.png",
           target: "#{Dir.home}/.local/share/icons/com.mitchellh.ghostty.png"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    appimage_path = "#{staged_path}/Ghostty-#{version}-#{arch}.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm appimage_path

    desktop_file = "#{staged_path}/squashfs-root/com.mitchellh.ghostty.desktop"
    if File.exist?(desktop_file)
      contents = File.read(desktop_file)
      contents.gsub!(/Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/ghostty")
      contents.gsub!(/Icon=.*/, "Icon=#{Dir.home}/.local/share/icons/com.mitchellh.ghostty.png")
      File.write(desktop_file, contents)
    end
  end

  uninstall_postflight do
    FileUtils.rm("#{Dir.home}/.local/share/applications/com.mitchellh.ghostty.desktop")
    FileUtils.rm("#{Dir.home}/.local/share/icons/com.mitchellh.ghostty.png")
  end

  zap trash: [
    "~/.cache/ghostty",
    "~/.config/ghostty",
    "~/.local/share/ghostty",
  ]
end
