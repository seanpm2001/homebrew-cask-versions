cask "gpg-suite-nightly" do
  version :latest
  sha256 :no_check

  url "https://releases.gpgtools.org/nightlies/" do |page|
    page[/<td class='filename'><a href='(.*)'>/, 1]
  end
  name "GPG Suite Nightly"
  desc "Tools to protect your emails and files"
  homepage "https://gpgtools.org/"

  conflicts_with cask: "gpg-suite"

  pkg "Install.pkg"

  uninstall_postflight do
    ["gpg", "gpg2", "gpg-agent"].map { |exec_name| "/usr/local/bin/#{exec_name}" }.each do |exec|
      FileUtils.rm_rf(exec) && File.readlink(exec).include?("MacGPG2")
    end
  end

  uninstall script:    {
              executable: "#{staged_path}/Uninstall.app/Contents/Resources/GPG Suite Uninstaller.app/Contents/Resources/uninstall.sh",
              sudo:       true,
            },
            pkgutil:   "org.gpgtools.*",
            quit:      [
              "com.apple.mail",
              "org.gpgtools.gpgkeychainaccess",
              "org.gpgtools.gpgkeychain",
              "org.gpgtools.gpgservices",
              # TODO: add "killall -kill gpg-agent"
            ],
            launchctl: [
              "org.gpgtools.Libmacgpg.xpc",
              "org.gpgtools.gpgmail.patch-uuid-user",
              "org.gpgtools.macgpg2.fix",
              "org.gpgtools.macgpg2.shutdown-gpg-agent",
              "org.gpgtools.macgpg2.updater",
              "org.gpgtools.macgpg2.gpg-agent",
              "org.gpgtools.gpgmail.enable-bundles",
              "org.gpgtools.gpgmail.user-uuid-patcher",
              "org.gpgtools.gpgmail.uuid-patcher",
              "org.gpgtools.updater",
            ],
            delete:    [
              "/Library/Services/GPGServices.service",
              "/Library/Mail/Bundles/GPGMail.mailbundle",
              "/Library/Mail/Bundles.gpgmail*",
              "/Network/Library/Mail/Bundles/GPGMail.mailbundle",
              "/usr/local/MacGPG2",
              "/private/etc/paths.d/MacGPG2",
              "/private/etc/manpaths.d/MacGPG2",
              "/private/tmp/gpg-agent",
              "/Library/PreferencePanes/GPGPreferences.prefPane",
              "/Library/Application Support/GPGTools",
              "/Library/Frameworks/Libmacgpg.framework",
            ]

  zap trash: [
    "~/Library/Services/GPGServices.service",
    "~/Library/Mail/Bundles/GPGMail.mailbundle",
    "~/Library/PreferencePanes/GPGPreferences.prefPane",
    "~/Library/LaunchAgents/org.gpgtools.*",
    "~/Library/Containers/com.apple.mail/Data/Library/Preferences/org.gpgtools.*",
    "~/Library/Frameworks/Libmacgpg.framework",
    "~/Containers/com.apple.mail/Data/Library/Frameworks/Libmacgpg.framework",
    "~/Library/Caches/org.gpgtools.gpg*",
    "~/Library/Application Support/GPGTools",
    "~/Library/Preferences/org.gpgtools.*",
  ]

  caveats do
    files_in_usr_local
  end
end
