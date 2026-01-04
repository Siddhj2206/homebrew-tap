# Ghostty terminal emulator for Linux
# Uses AppImage from pkgforge-dev/ghostty-appimage
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
  bash_completion "squashfs-root/share/bash-completion/completions/ghostty.bash"
  fish_completion "squashfs-root/share/fish/vendor_completions.d/ghostty.fish"
  zsh_completion "squashfs-root/share/zsh/site-functions/_ghostty"
  artifact "squashfs-root/com.mitchellh.ghostty.desktop",
           target: "#{Dir.home}/.local/share/applications/com.mitchellh.ghostty.desktop"
  artifact "squashfs-root/com.mitchellh.ghostty.png",
           target: "#{Dir.home}/.local/share/icons/com.mitchellh.ghostty.png"
  artifact "squashfs-root/share/dbus-1/services/com.mitchellh.ghostty.service",
           target: "#{Dir.home}/.local/share/dbus-1/services/com.mitchellh.ghostty.service"
  artifact "squashfs-root/share/ghostty",
           target: "#{Dir.home}/.local/share/ghostty"
  artifact "squashfs-root/share/nautilus-python/extensions/ghostty.py",
           target: "#{Dir.home}/.local/share/nautilus-python/extensions/ghostty.py"
  artifact "squashfs-root/share/kio/servicemenus/com.mitchellh.ghostty.desktop",
           target: "#{Dir.home}/.local/share/kio/servicemenus/com.mitchellh.ghostty.desktop"
  artifact "squashfs-root/share/terminfo/g/ghostty",
           target: "#{Dir.home}/.terminfo/g/ghostty"
  artifact "squashfs-root/share/vim/vimfiles/compiler/ghostty.vim",
           target: "#{Dir.home}/.vim/compiler/ghostty.vim"
  artifact "squashfs-root/share/vim/vimfiles/ftdetect/ghostty.vim",
           target: "#{Dir.home}/.vim/ftdetect/ghostty.vim"
  artifact "squashfs-root/share/vim/vimfiles/ftplugin/ghostty.vim",
           target: "#{Dir.home}/.vim/ftplugin/ghostty.vim"
  artifact "squashfs-root/share/vim/vimfiles/syntax/ghostty.vim",
           target: "#{Dir.home}/.vim/syntax/ghostty.vim"
  artifact "squashfs-root/share/nvim/site/compiler/ghostty.vim",
           target: "#{Dir.home}/.local/share/nvim/site/compiler/ghostty.vim"
  artifact "squashfs-root/share/nvim/site/ftdetect/ghostty.vim",
           target: "#{Dir.home}/.local/share/nvim/site/ftdetect/ghostty.vim"
  artifact "squashfs-root/share/nvim/site/ftplugin/ghostty.vim",
           target: "#{Dir.home}/.local/share/nvim/site/ftplugin/ghostty.vim"
  artifact "squashfs-root/share/nvim/site/syntax/ghostty.vim",
           target: "#{Dir.home}/.local/share/nvim/site/syntax/ghostty.vim"

  preflight do
    # Create target directories for artifacts
    dirs = [
      "#{Dir.home}/.local/share/applications",
      "#{Dir.home}/.local/share/dbus-1/services",
      "#{Dir.home}/.local/share/icons",
      "#{Dir.home}/.local/share/kio/servicemenus",
      "#{Dir.home}/.local/share/nautilus-python/extensions",
      "#{Dir.home}/.local/share/nvim/site/compiler",
      "#{Dir.home}/.local/share/nvim/site/ftdetect",
      "#{Dir.home}/.local/share/nvim/site/ftplugin",
      "#{Dir.home}/.local/share/nvim/site/syntax",
      "#{Dir.home}/.terminfo/g",
      "#{Dir.home}/.vim/compiler",
      "#{Dir.home}/.vim/ftdetect",
      "#{Dir.home}/.vim/ftplugin",
      "#{Dir.home}/.vim/syntax",
    ]
    dirs.each { |dir| FileUtils.mkdir_p(dir) }

    # Extract AppImage
    appimage_path = "#{staged_path}/Ghostty-#{version}-x86_64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm appimage_path

    # Fix hardcoded build paths in extracted files
    # The AppImage contains paths like /__w/ghostty-appimage/.../bin/ghostty
    # that need to be replaced with the Homebrew prefix path
    build_path_regex = %r{/__w/ghostty-appimage[^\s]*}

    # Patch desktop file: fix paths and disable DBus activation (no systemd service)
    desktop_file = "#{staged_path}/squashfs-root/com.mitchellh.ghostty.desktop"
    desktop_content = File.read(desktop_file)
    desktop_content.gsub!(build_path_regex, "#{HOMEBREW_PREFIX}/bin/ghostty")
    desktop_content.gsub!("DBusActivatable=true", "DBusActivatable=false")
    File.write(desktop_file, desktop_content)

    # Patch DBus service: fix paths and remove systemd service reference
    dbus_service = "#{staged_path}/squashfs-root/share/dbus-1/services/com.mitchellh.ghostty.service"
    dbus_content = File.read(dbus_service)
    dbus_content.gsub!(build_path_regex, "#{HOMEBREW_PREFIX}/bin/ghostty")
    dbus_content.gsub!(/^SystemdService=.*\n/, "")
    File.write(dbus_service, dbus_content)

    # Patch Nautilus extension: use full path since Nautilus doesn't have Homebrew in PATH
    nautilus_ext = "#{staged_path}/squashfs-root/share/nautilus-python/extensions/ghostty.py"
    nautilus_content = File.read(nautilus_ext)
    nautilus_content.gsub!("cmd = ['ghostty',", "cmd = ['#{HOMEBREW_PREFIX}/bin/ghostty',")
    File.write(nautilus_ext, nautilus_content)
  end

  postflight do
    ohai "Restart Nautilus to enable 'Open in Ghostty': nautilus -q"
  end

  zap trash: [
    "~/.cache/ghostty",
    "~/.local/share/applications/com.mitchellh.ghostty.desktop",
    "~/.local/share/dbus-1/services/com.mitchellh.ghostty.service",
    "~/.local/share/ghostty",
    "~/.local/share/icons/com.mitchellh.ghostty.png",
    "~/.local/share/kio/servicemenus/com.mitchellh.ghostty.desktop",
    "~/.local/share/nautilus-python/extensions/ghostty.py",
    "~/.local/share/nvim/site/compiler/ghostty.vim",
    "~/.local/share/nvim/site/ftdetect/ghostty.vim",
    "~/.local/share/nvim/site/ftplugin/ghostty.vim",
    "~/.local/share/nvim/site/syntax/ghostty.vim",
    "~/.terminfo/g/ghostty",
    "~/.vim/compiler/ghostty.vim",
    "~/.vim/ftdetect/ghostty.vim",
    "~/.vim/ftplugin/ghostty.vim",
    "~/.vim/syntax/ghostty.vim",
  ]
end
