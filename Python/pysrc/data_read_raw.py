import pandas as pd
from typing import List
import os
import json

# directories
DATA_DIR = os.path.join("data")
DATA_DIR_RAW = os.path.join(DATA_DIR, "raw")
PREPROCESSING_DIR = os.path.join(DATA_DIR, "preprocessing")


# extensions
DATA_EXT = "csv"
TEXT_EXT = "txt"
DICT_EXT = "json"

# encodings
BASIC_ENC = 'utf-8'
FISHN_ENC = 'utf-8' #'iso-8859-1'

DISTRICT_NAME = 'district_name'
DISTRICT_ID_NAME = "district_id"
INDEX_SAVE_NAME = "id"

# read kwargs
PLACES_READ_OPTIONS = dict()
OCCUPATIONS_READ_OPTIONS = dict()
FISHNET_READ_OPTIONS = dict(
    encoding=FISHN_ENC,
    sep='\t',
    header=None,
    names=['lng', 'lat', DISTRICT_NAME],
)

FISHNET_READ_OPTIONS_500 = dict(
    encoding=FISHN_ENC,
    sep='\t',
    header=None,
    names=['lng', 'lat', DISTRICT_ID_NAME, DISTRICT_NAME],
)

# FILE NAMES
PLACES_NAME = "places"
OCCUPATION_NAME = "popular_times"
OCCUPATION_SUFFIXES = [1, 2]
FISHNET_NAME = "warsaw_wgs84_every_"
FISHNET_SUFFIXES = [100, 500, 1000, 2000]
CONV_DICT_NAME = "district_convert"
CONV_DICT_PATH = os.path.join(DATA_DIR, CONV_DICT_NAME + "." + DICT_EXT)
DISTRICT_IDS_MAPPING = "district_ids_mapping"

def data_dir():
    return os.path.join(DATA_DIR_RAW)


def places_path() -> str:
    return os.path.join(data_dir(), PLACES_NAME + '.' + DATA_EXT)


def occupations_paths() -> List[str]:
    return [
        os.path.join(data_dir(), OCCUPATION_NAME + "_" + str(occ_suff) + '.' + DATA_EXT)
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
        ]).reset_index(drop=True)
    return df

def read_fishnet_500() -> pd.DataFrame:
    df = pd.read_csv(fishnet_paths()[500], **FISHNET_READ_OPTIONS_500)
    df[DISTRICT_NAME] = df[DISTRICT_NAME].str.strip().str.title()
    with open(CONV_DICT_PATH) as fr:
        convert_dict = json.load(fr)
    df[DISTRICT_NAME] = df[DISTRICT_NAME].apply(lambda x: convert_dict[x])
    return df

def read_fishnet(grid_size: int) -> pd.DataFrame:
    if grid_size == 500:
        df = read_fishnet_500()
        df.drop(columns=DISTRICT_ID_NAME, inplace=True)
    else:
        df = pd.read_csv(fishnet_paths()[grid_size], **FISHNET_READ_OPTIONS)
    df.dropna(inplace=True)
    df[DISTRICT_NAME] = df[DISTRICT_NAME].str.strip().str.title()
    conv_path = os.path.join(DATA_DIR, CONV_DICT_NAME + "." + DICT_EXT)
    with open(conv_path) as fr:
        convert_dict = json.load(fr)
    df[DISTRICT_NAME] = df[DISTRICT_NAME].apply(lambda x: convert_dict[x])
    district_id_mapping = pd.read_csv(
        os.path.join(PREPROCESSING_DIR, DISTRICT_IDS_MAPPING + "." + DATA_EXT),
        index_col=INDEX_SAVE_NAME).squeeze().to_dict()
    district_id_mapping = {v:k for k,v in district_id_mapping.items()}
    df[DISTRICT_ID_NAME] = df[DISTRICT_NAME].apply(lambda x: district_id_mapping[x])
    df.drop(columns=DISTRICT_NAME, inplace=True)

    return df


# DEMO #
def read_amrit_places():
    df = pd.read_csv("data/sample/amrit.csv", **PLACES_READ_OPTIONS)
    return df


def read_amrit_occupations():
    df = pd.read_csv("data/sample/amrit_popular_times.csv", **OCCUPATIONS_READ_OPTIONS)
    return df
