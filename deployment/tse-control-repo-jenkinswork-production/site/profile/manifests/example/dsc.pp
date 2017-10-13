class profile::example::dsc {

  # NOTE this requires powershell5, please use the powershell5 module to update.  It will reboot the machine without asking.

  #Features
  dsc_windowsfeature{'iis':
      dsc_ensure => 'Present',
      dsc_name => 'Web-Server',
  }
  dsc_windowsfeature{'iisconsole':
      dsc_ensure => 'present',
      dsc_name => 'Web-Mgmt-Console',
  }
  dsc_windowsfeature{'aspnet45':
      dsc_ensure => 'Present',
      dsc_name => 'Web-Asp-Net45',
  }
  
  windows_java::jdk{'7u51':
    install_path => 'C:\java\jdk7u51',
    default      => false,
  }

  #  Setup sample share
  file { 'c:\shares':
    ensure => 'directory',
  }
  acl { 'c:\shares':
    permissions => [
     { identity => 'Administrators', rights => ['full'] },
     { identity => 'Users', rights => ['read','execute'] }
    ],
    owner       => 'Administrators',
    inherit_parent_permissions => 'true',
    before  =>  Dsc_xsmbshare["Shares Root"],
  }
  dsc_xsmbshare { 'Shares Root':
    dsc_ensure     => 'present',
    dsc_name       => 'SharesRoot',
    dsc_path       => 'c:\shares',
    dsc_fullaccess => ["everyone"],
    dsc_folderenumerationmode => "Unrestricted",
  }

}
