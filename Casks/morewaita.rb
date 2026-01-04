# MoreWaita icon theme - an Adwaita-styled companion icon theme for GNOME
cask "morewaita" do
  version "49"
  sha256 "33a00ac6a9214d228b43071a09e0ba59b92da225b1321afe246f64f6ec96bb48"

  url "https://github.com/somepaulo/MoreWaita/archive/refs/tags/v#{version}.tar.gz"
  name "MoreWaita"
  desc "Adwaita-styled companion icon theme with extra icons for GNOME"
  homepage "https://github.com/somepaulo/MoreWaita"

  livecheck do
    url "https://github.com/somepaulo/MoreWaita/releases/latest"
    strategy :github_latest
  end

  preflight do
    theme_dir = "#{Dir.home}/.local/share/icons/MoreWaita"
    FileUtils.mkdir_p(theme_dir)

    source_dir = "#{staged_path}/MoreWaita-#{version}"
    install_items = %w[index.theme scalable symbolic _extras]

    install_items.each do |item|
      source = "#{source_dir}/#{item}"
      FileUtils.cp_r(source, theme_dir) if File.exist?(source)
    end

    # Remove any stray build files
    Dir.glob("#{theme_dir}/**/*.build").each { |f| FileUtils.rm(f) }
  end

  postflight do
    theme_dir = "#{Dir.home}/.local/share/icons/MoreWaita"
    system "gtk-update-icon-cache", "-f", "-t", theme_dir
    ohai "Activate the theme with: gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'"
  end

  uninstall_postflight do
    theme_dir = "#{Dir.home}/.local/share/icons/MoreWaita"
    FileUtils.rm_r(theme_dir) if Dir.exist?(theme_dir)
  end

  zap trash: "~/.local/share/icons/MoreWaita"
end
