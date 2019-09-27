import pandas as pd
import os
import shutil
import Python.pysrc.data_read_raw as drr

# directories
POPULAR_TIMES_NAME = "popular_times"
DESTINATION_ENCODING = 'utf-8-sig' # to work well on windows


def save_dataframe_to_csv(data_frame, path, encoding=DESTINATION_ENCODING):
    data_frame.index.name = drr.INDEX_SAVE_NAME
    data_frame.to_csv(path, encoding=encoding)


def run_preprocessing():
    # REMOVE PREVIOUS PREPROCESING
    try:
        shutil.rmtree(drr.PREPROCESSING_DIR)
    except FileNotFoundError:
        pass
    os.makedirs(drr.PREPROCESSING_DIR)

    # district ID mapping
    df = drr.read_fishnet_500()
    df = df[[drr.DISTRICT_NAME, drr.DISTRICT_ID_NAME]]
    df = df.set_index(drr.DISTRICT_ID_NAME).drop_duplicates()
    df = df.sort_index()
    save_dataframe_to_csv(
        data_frame=df,
        path=os.path.join(drr.PREPROCESSING_DIR, drr.DISTRICT_IDS_MAPPING + "." + drr.DATA_EXT)
    )

    # places
    df = drr.read_places()
    save_dataframe_to_csv(
        data_frame=df,
        path=os.path.join(drr.PREPROCESSING_DIR, drr.PLACES_NAME + "." + drr.DATA_EXT)
    )

    # occupations
    df = drr.read_occupations()
    save_dataframe_to_csv(
        data_frame=df,
        path=os.path.join(drr.PREPROCESSING_DIR, drr.OCCUPATION_NAME + "." + drr.DATA_EXT)
    )

    # fishnets
    for fishn_suff in drr.FISHNET_SUFFIXES:
        df = drr.read_fishnet(fishn_suff)
        save_dataframe_to_csv(
            data_frame=df,
            path=os.path.join(drr.PREPROCESSING_DIR, drr.FISHNET_NAME + str(fishn_suff) + 'm.' + drr.TEXT_EXT)
        )

if __name__ == "__main__":
    run_preprocessing()