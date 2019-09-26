import pandas as pd
from typing import List
import os

# directories
DATA_DIR = "data/raw/"

# extensions
DATA_EXT = "csv"
TEXT_EXT = "txt"

# encodings
BASIC_ENC = 'utf-8'
FISHN_ENC = 'utf-8' #'iso-8859-1'

# read kwargs
PLACES_READ_OPTIONS = dict()
OCCUPATIONS_READ_OPTIONS = dict()
FISHNET_READ_OPTIONS = dict(
    encoding=FISHN_ENC,
    sep='\t',
    header=None,
    names=['lng', 'lat', 'weight', 'district'],
)

# FILE NAMES
PLACES_NAME = "places"
OCCUPATION_NAME = "popular_times_"
OCCUPATION_SUFFIXES = [1, 2]
FISHNET_NAME = "warsaw_wgs84_every_"
FISHNET_SUFFIXES = [100, 500, 1000, 2000]


def data_dir():
    return os.path.join(DATA_DIR)


def places_path() -> str:
    return os.path.join(data_dir(), PLACES_NAME + '.' + DATA_EXT)


def occupations_paths() -> List[str]:
    return [
        os.path.join(data_dir(), OCCUPATION_NAME + str(occ_suff) + '.' + DATA_EXT)
        for occ_suff in OCCUPATION_SUFFIXES
    ]


def fishnet_paths() -> dict:
    return {
        fishn_suff: os.path.join(data_dir(), FISHNET_NAME + str(fishn_suff) + 'm.' + TEXT_EXT)
        for fishn_suff in FISHNET_SUFFIXES}


def read_places() -> pd.DataFrame:
    df = pd.read_csv(places_path(), **PLACES_READ_OPTIONS)
    return df


def read_occupations() -> pd.DataFrame:
    df = pd.concat(
        [
            pd.read_csv(path, **OCCUPATIONS_READ_OPTIONS)
            for path in occupations_paths()
        ])
    return df


def read_fishnet(grid_size: int) -> pd.DataFrame:
    df = pd.read_csv(fishnet_paths()[grid_size], **FISHNET_READ_OPTIONS)
    return df


# DEMO #
def read_amrit_places():
    df = pd.read_csv("data/sample/amrit.csv", **PLACES_READ_OPTIONS)
    return df


def read_amrit_occupations():
    df = pd.read_csv("data/sample/amrit_popular_times.csv", **OCCUPATIONS_READ_OPTIONS)
    return df
