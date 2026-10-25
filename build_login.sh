#!/bin/bash
set -euo pipefail

g++ -Wall -Wextra -g -std=c++20 \
    $(wx-config --cxxflags) \
    -I$(brew --prefix argon2)/include \
    -I$(brew --prefix libpqxx)/include \
    *.cpp \
    $(wx-config --libs) \
    -L$(brew --prefix argon2)/lib -largon2 \
    -L$(brew --prefix libpqxx)/lib -L$(brew --prefix libpq)/lib -lpqxx -lpq \
    -o login

echo "Build complete: ./login"
