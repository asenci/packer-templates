Vagrant.configure('2') do |config|
  config.nfs.functional = false
  config.smb.functional = false

  config.vm.provider 'vmware_desktop' do |v|
    # persistent device naming whitelist
    v.functional_hgfs = false
    v.whitelist_verified = true
  end
  config.vm.provider "parallels" do |prl|
    prl.check_guest_tools = false
    prl.functional_psf = false
  end
end
