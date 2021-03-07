# LEDs

LED's once hooked up are simple to control.

Installing OpenRGB is easy, but using it though an X11 pipe is a bit harder.

As such we need to modify the source code and then install it.

```bash
git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git
cd OpenRGB
```

Edit `main.cpp`

Between line 171 and 172 add the following `QApplication::setSetuidAllowed(true);`.

It should now look something like this:

```cpp
QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
QApplication::setSetuidAllowed(true);
QApplication a(argc, argv);
```

```bash
qmake OpenRGB.pro
make -j8
sudo make install
sudo chmod u+s /usr/bin/OpenRGB
```

Launching `OpenRGB` should bring up the GUI and you will be able to control the LED lights.