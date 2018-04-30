FROM ponylang/ponyc:0.21.3

# Space-separated list of extra libraries to pass to the linker.
# Put those libraries in the following locations depending on what platform you target:
# - Linux: /usr/local/lib/extra/linux-amd64/
# - Windows: /usr/local/lib/extra/windows-amd64/
ENV EXTRA_LIBS=

# Bring over Windows static libraries.
COPY lib/lib* /tmp/cross-pony/

# Copy bootstrap script.
COPY bin/ /usr/local/bin/

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget \
  # Install LLVM 6.
  && echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" | tee -a /etc/apt/sources.list \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - \
  # Clean and update apt lists - if we don't, LLVM's installation croaks with a "bad checksum" error.
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    clang-6.0 \
    lld-6.0 \
  # Set up Windows static libraries.
  && cat /tmp/cross-pony/lib* > /tmp/cross-pony/windows-amd64.tar.gz \
  && mkdir -p /usr/local/lib/windows-amd64 \
  && tar xzf /tmp/cross-pony/windows-amd64.tar.gz -C /usr/local/lib/ \
  # Make all library names lower-case.
  && find /usr/local/lib/windows-amd64 -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \; \
  # Create upper-case symlink to each Windows library name (i.e. /usr/local/lib/windows-amd64/msvc/MSVCRT.lib => /usr/local/lib/windows-amd64/msvc/msvcrt.lib).
  # Some libs are being referred to by their upper-case name, some by their lower-case names.
  && for FILE in /usr/local/lib/windows-amd64/*/**; do echo $FILE | sed -r -e "s|(.*/)(.*)(\.lib)|\1\U\2\L\3|" | xargs -L1 bash -c 'ln -s "${0,,}" "$0" '; done \
  # Set up cross-ponyc.
  && chmod +x /usr/local/bin/cross-ponyc* \
  # Turn off SSL cert verification for git as github ca-certificates are broken for ubuntu 16.04.
  # We need git in order to be able to run stable fetch.
  && git config --global http.sslVerify false \
  # Create extra lib directories.
  && mkdir -p /usr/local/lib/extra/linux-amd64/ \
  && mkdir -p /usr/local/lib/extra/windows-amd64/ \
  # Cleanup.
  && rm -rf /tmp/cross-pony/ \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["cross-ponyc"]