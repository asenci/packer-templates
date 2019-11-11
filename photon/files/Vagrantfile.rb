Vagrant.configure('2') do |config|
  config.vm.provider 'vmware_desktop' do |v|
    # persistent device naming whitelist
    v.whitelist_verified = true
    # Use paravirtualized virtual hardware on VMW hypervisors
    v.vmx['ethernet0.virtualDev'] = 'vmxnet3'
    v.vmx['ethernet1.virtualDev'] = 'vmxnet3'
    v.vmx['ethernet2.virtualDev'] = 'vmxnet3'
    v.vmx['ethernet3.virtualDev'] = 'vmxnet3'
    v.vmx['scsi0.virtualDev'] = 'pvscsi'
  end
end
