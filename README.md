# integration-image

This project publishes the Docker imgae for developing custom integration.

The image is based on Python 3.10.0 and has these packages installed:

    autoflake==2.0.0
    bandit==1.7.4
    black==22.10.0
    codespell==2.2.2
    flake8-comprehensions==3.10.1
    flake8-docstrings==1.6.0
    flake8-noqa==1.3.0
    flake8==6.0.0
    isort==5.11.3
    mccabe==0.7.0
    pycodestyle==2.10.0
    pydocstyle==6.1.1
    pyflakes==3.0.1
    pyupgrade==3.3.1
    yamllint==1.28.0

    # Unit tests requirements
    pylint==2.15.8
    pytest==7.2.0
    numpy==1.23.2
    pytest-homeassistant-custom-component== 0.11.24

    #HomeAssistant
    homeassistant==2023.1.3