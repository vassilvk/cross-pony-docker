cross-pony
==========

Utility Docker image for cross-compiling Pony programs.

Cross-compile Pony?
-------------------

Use this image to compile and link Pony programs to any of the supported target platforms regardless of the platform of
the host running the image. For example, one does not need to run a Windows machine to build Pony projects to Windows
executables.

Currently supported platforms:

- Linux x64
- Windows x64


Simple Example
--------------

To build a Pony program, run the following from the root of your Pony project...

```bash
docker run --rm -it -v /$(pwd):/src/main vassilvk/cross-pony <target>
```

...where `<target>` is either `linux` or `windows`.


Pony stable
-----------

If your project includes file `bundle.json`, `cross-pony` will perform `stable fetch` to pull in dependencies, after which
it will compile your project through `stable env ponyc...`.


Passing arguments to ponyc
--------------------------

You can pass parameters to the underlying `ponyc` call - every argument past `<target>` is relayed to `ponyc`.

For example, the following will pass flag `--debug` to `ponyc` to build your project in debug mode:

```bash
docker run --rm -it -v /$(pwd):/src/main vassilvk/cross-pony windows --debug
```


Executable name
---------------

The image assumes that your project is called `main`. This is reflected in the executables generated by the image. For example,
the Linux executable built by the image is always called `main-linux-amd64` while the Windows executable is called `main-windows-amd64.exe`.

If you are building a subfolder of your project, you need to name your binary `main` through the `-b` option.

For example, this will build the project's `test` subfolder:

```bash
docker run --rm -it -v /$(pwd):/src/main vassilvk/cross-pony windows ./test -b main
```


Using Extra Libraries
---------------------

The image includes all the necessary libraries required to build an executable which uses Pony's standard library.
If your program imports external libraries, you will need to mount them into the respective target platform's folder (see below)
and pass the library names to the container through variable `EXTRA_LIBS`.

Extra libraries should be volume-mounted into their respective location in the container:
- **Linux:** `/usr/local/lib/extra/linux-amd64/`
- **Windows:** `/usr/local/lib/extra/windows-amd64/`

For example, [jemc/pony-zmq](https://github.com/jemc/pony-zmq) uses [libsodium](https://download.libsodium.org/doc/installation/index.html).
Follow these steps to build its tests for Windows:

* Clone [jemc/pony-zmq](https://github.com/jemc/pony-zmq)
* Download [libsodium](https://download.libsodium.org/libsodium/releases/)'s Windows binaries (for example `libsodium-1.0.16-msvc.zip`)
* Unzip the x64 static library `libsodium.lib` into your project's `lib/windows-amd64` folder
* Run the following in the project's folder:

```
docker run --rm -it -v /$(pwd):/src/main -v /$(pwd)/lib/windows-amd64:/usr/local/lib/extra/windows-amd64 -e EXTRA_LIBS="libsodium" vassilvk/cross-pony windows zmq/test -b main
```

This will compile and link `pony-zmq`'s test suite into Windows executable `main-windows-amd64.exe`.

Image contents
--------------

The image contains the following:

* `ponyc 0.21.3`
* `LLVM 6.0.1`
* Linux static libraries
* Windows 10 static libraries