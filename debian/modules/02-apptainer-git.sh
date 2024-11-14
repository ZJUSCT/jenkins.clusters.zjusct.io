#!/bin/bash
# https://github.com/apptainer/apptainer
install_deb_from_github apptainer/apptainer 'test("^apptainer_[0-9.]+_amd64\\.deb$")'
