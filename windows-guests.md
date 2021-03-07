# Windows Guests

## Activation

While I have appropriate license keys to run Windows. The process of activation everytime I want to generate a new instance becomes a pain.

As such I am running the py-kms docker image.

```ps
docker run -d --name py-kms --restart always -p 1688:1688 pykmsorg/py-kms
```

Assuming the VM can resolve "The Beast" the following commands will work.

```ps
cscript //nologo slmgr.vbs /upk
cscript //nologo slmgr.vbs /skms TheBeast:1688
cscript //nologo slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
```
