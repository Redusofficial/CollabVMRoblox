# CollabVMRoblox

### WIP Luau port of [collab-vm-1.2-webapp](collab-vm-1.2-webapp)

# TODO
- [ ] Port [protocol & CollabVMClient](https://github.com/computernewb/collab-vm-1.2-webapp/tree/master/src/ts/protocol)
    - [x] Port enums and interfaces
    - [ ] Implement all messages in CollabVMClient.onMessage()
    - [ ] Multithread Jpeg decoder to improve performance
    - [ ] Prevent script timeouts when multiple images are recieved at once. This may be resolved by the multithreading TODO

- [ ] GUI
    - [ ] Start creation of the GUI