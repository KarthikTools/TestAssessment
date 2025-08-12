#!/usr/bin/env python3
"""
Setup script for the Risk Policy module.
This module demonstrates MagicMock for service virtualization.
"""

from setuptools import setup, find_packages

setup(
    name="risk-policy",
    version="0.1.0",
    description="Risk policy module with MagicMock unit tests for service virtualization demo",
    author="Demo Team",
    author_email="demo@example.com",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        # No external dependencies needed
        # MagicMock is part of Python standard library
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
        ],
        "test": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
        ],
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Software Development :: Testing",
        "Topic :: Software Development :: Testing :: Mocking",
    ],
)
