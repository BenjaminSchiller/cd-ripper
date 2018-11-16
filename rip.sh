#!/bin/bash

source /home/pi/cd-ripper/rip.cfg

function log {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $@"
}

function print_delimiter {
    echo ""
    echo "# # # # # # # # # # # # # # # # # # # #"
    echo "# # # # # # # # # # # # # # # # # # # #"
    echo ""
}

function encode {
    ARTIST=$1
    ALBUM=$2
    log "create mp3 version for $ARTIST / $ALBUM"

    log "create dir $MP3_PATH/$ARTIST/$ALBUM"
    mkdir -p $MP3_PATH/$ARTIST/$ALBUM
    for FILE in $(ls $FLAC_PATH/$ARTIST/$ALBUM | grep '\.flac$'); do
        SRC="$FLAC_PATH/$ARTIST/$ALBUM/$FILE"
        DST="$MP3_PATH/$ARTIST/$ALBUM/${FILE/.flac/.mp3}"
        if [[ ! -f $DST ]]; then
            avconv -i $SRC -c:a libmp3lame -b:a 320k $DST | tee $MP3_PATH/$ARTIST/$ALBUM/avconv.log
        else
            log "skip file $SRC"
            log "$DST exists already"
        fi
    done
}

function disc_inserted {
    print_delimiter
    log "disc inserted"

    # check if output dir is empty
    if [[ $(ls ${OUTPUT_PATH} | wc -l) -gt 0 ]]; then
        log "output dir ${OUTPUT_PATH} is not empty"
        print_delimiter
        exit 1
    fi

    # determine which cddb source to use
    log "test musicbrainz as cddb source"
    COUNT=$(abcde -c ${ABCDE_CONF_MUSICBRAINZ} |& grep "$NO_CDDB_MSG" | wc -l)
    if [[ $COUNT -eq 0 ]]; then
        cat "${ABCDE_CONF_MUSICBRAINZ}" > $ABCDE_CONF_TMP
        log "entry found, use musicbrainz"
    else
        cat "${ABCDE_CONF_CDDB}" > $ABCDE_CONF_TMP
        log "no entry found, use cddb instead"
    fi

    # add main flac rip abcde conf
    cat $ABCDE_CONF_FLAC >> $ABCDE_CONF_TMP

    # DISC = (DISC + 1 % DISTS) + 1
    if [ $DISCS -gt 1 ] && [ $DISC -lt $DISCS ]; then
        echo "DISC=$((DISC+1))" >> /home/pi/cd-ripper/rip.cfg
    elif [ $DISCS -gt 1 ] && [ $DISC == $DISCS ]; then
        echo "DISC=1" >> /home/pi/cd-ripper/rip.cfg
    else
        DISC="0"
    fi

    # start abcde
    if [[ "$DISC" == "0" ]]; then
        log "rip single cd"
        log "command: 'abcde -V -c $ABCDE_CONF_TMP'"
        abcde -V -c $ABCDE_CONF_TMP
    else
        log "rip cd $DISC / $DISCS"
        log "command: 'abcde -V -c $ABCDE_CONF_TMP -W $DISC'"
        abcde -V -c $ABCDE_CONF_TMP -W $DISC
    fi
    rc=$?

    eject cd if abcde exited with an error
    if [[ $rc != 0 ]] ; then
        log "abcde exited with error code $rc"
        log "eject disc"
        eject
    fi

    # determine artist
    if [[ $(ls "$OUTPUT_PATH" | wc -l) != 1 ]]; then
        log "no or more than one artist found: '$(ls $OUTPUT_PATH)'"
        exit 1
    fi
    ARTIST_SRC=$(ls "${OUTPUT_PATH}")
    ARTIST_DST="${ARTIST_SRC}"
    log "artist: $ARTIST_SRC / $ARTIST_DST"

    # determine album
    if [[ $(ls "$OUTPUT_PATH/$ARTIST_SRC" | wc -l) != 1 ]]; then
        log "no or more than one album found: '$(ls $OUTPUT_PATH/$ARTIST_SRC)'"
        exit 1
    fi
    ALBUM_SRC=$(ls "${OUTPUT_PATH}/${ARTIST_SRC}")
    ALBUM_DST="${ALBUM_SRC}"
    if [[ ${ALBUM_DST} == "Unknown_Album" ]]; then
        ALBUM_DST="${ALBUM_DST}_${DATETIME}"
    fi
    log "album: $ALBUM_SRC / $ALBUM_DST"

    # create dst dir
    if [[ ! -d "$FLAC_PATH/${ARTIST_DST}/${ALBUM_DST}" ]]; then
        log "create dir $FLAC_PATH/${ARTIST_DST}/${ALBUM_DST}"
        mkdir -p "$FLAC_PATH/${ARTIST_DST}/${ALBUM_DST}"
    fi

    # move all files
    SRC="${OUTPUT_PATH}/${ARTIST_SRC}/${ALBUM_SRC}"
    DST="${FLAC_PATH}/${ARTIST_DST}/${ALBUM_DST}"
    mkdir -p $DST
    log "move files from $SRC to $DST"
    for FILE in $(ls $SRC); do
        log "move file $FILE"
        if [[ -f "$DST/$FILE" ]]; then
            log "WARNING: file $DST/$FILE exists already."
            log "         overwriting it!"
        fi
        mv "$SRC/$FILE" "$DST/$FILE"
    done

    # delete empty output dir
    log "delete ${OUTPUT_PATH}/${ARTIST_SRC}"
    rm -rf "${OUTPUT_PATH}/${ARTIST_SRC}"

    # convert ripped flac to mp3
    if [[ "${FLAC_2_MP3}" = true ]]; then
        if [[ "$ARTIST_DST" != "Unknown_Artist" ]]; then
            log "encode $ARTIST_DST $ALBUM_DST START"
            encode $ARTIST_DST $ALBUM_DST
            log "encode $ARTIST_DST $ALBUM_DST DONE"
        else
            log "do not encode $ARTIST_DST / $ALBUM_DST"
        fi
    fi

    # copy log file
    TARGET_LOG_FILE="$FLAC_PATH/$ARTIST_DST/$ALBUM_DST/${DATETIME}.log"
    TARGET_LOG_FILE="$FLAC_PATH/$ARTIST_DST/$ALBUM_DST/rip.log"
    log "copy logfile from"
    log "             $LOG_FILE to"
    log "             $TARGET_LOG_FILE"
    cp "$LOG_FILE" "$TARGET_LOG_FILE"

    # write artist/album to rips log file
    log "$ARTIST_DST - $ALBUM_DST" >> $RIPS_LOG_FILE

    print_delimiter
}

function disc_ejected {
    log "disc ejected"
}

function sync {
    if [[ "${SYNC_FLAC}" = true ]]; then
        log "sync flac: START"
        rsync -auvzl "${FLAC_PATH}/" "${FLAC_SYNC_PATH}"
        log "sync flac: DONE"
    fi
    if [[ "${SYNC_MP3}" = true ]]; then
        log "sync mp3: START"
        rsync -auvzl "${MP3_PATH}/" "${MP3_SYNC_PATH}"
        log "sync mp3: DONE"
    fi
}

if [[ ${ID_CDROM_MEDIA} == "1" ]]; then
    disc_inserted |& tee -a $LOG_FILE $MAIN_LOG_FILE
    sync |& tee -a $MAIN_LOG_FILE
    eject
else
    disc_ejected |& tee -a $MAIN_LOG_FILE
fi
