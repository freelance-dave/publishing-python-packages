import sys

import pytest
from termcolor import colored

from imppkg.harmony import main


@pytest.mark.parametrize(
    "inputs, expected",
    [
        (["3", "3", "3"], 3.0),
        ([], 0.0),
        (["foo", "bar"], 0.0),
    ],
)
def test_harmony_parametrized(inputs, monkeypatch, capsys, expected):
    monkeypatch.setattr(sys, "argv", ["harmony"] + inputs)
    main()
    assert capsys.readouterr().out.strip() == colored(expected, "red", "on_cyan", attrs=["bold"])


@pytest.fixture
def FRUITS():
    return ["apple"]


def test_len(FRUITS):
    assert len(FRUITS) == 1


def test_append(FRUITS):
    FRUITS.append("banana")
    assert FRUITS == ["apple", "banana"]
