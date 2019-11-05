Vagrant.configure('2') do |config|
  ['vmware_fusion', 'vmware_workstation', 'vmware_appcatalyst'].each do |p|
    config.vm.provider p do |v|
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
end
