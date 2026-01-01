cask "yubitoggle" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/sudheendrachari/yubi-toggle/releases/download/v#{version}/YubiToggle.dmg"
  name "YubiToggle"
  desc "Menu bar utility to toggle YubiKey OTP interface"
  homepage "https://github.com/sudheendrachari/yubi-toggle"

  depends_on macos: ">= :ventura"

  app "YubiToggle.app"

  zap trash: [
    "~/Library/Preferences/com.sudheendrachari.yubitoggle.plist",
  ]
end
