#!/bin/bash

FLAC_PATH="./flac"
MP3_PATH="./mp3"

function encode {
    ARTIST=$1
    ALBUM=$2
    echo "ENCODE: $ARTIST / $ALBUM"

    if [[ -d "$MP3_PATH/$ARTIST/$ALBUM" ]]; then
        echo "        $MP3_PATH/$ARTIST/$ALBUM exists already"
    else
        echo "        create $MP3_PATH/$ARTIST/$ALBUM"
        mkdir -p $MP3_PATH/$ARTIST/$ALBUM
        for FILE in $(ls $FLAC_PATH/$ARTIST/$ALBUM | grep '\.flac$'); do
            SRC="$FLAC_PATH/$ARTIST/$ALBUM/$FILE"
            DST="$MP3_PATH/$ARTIST/$ALBUM/${FILE/.flac/.mp3}"
            avconv -i $SRC -c:a libmp3lame -b:a 320k $DST | tee $MP3_PATH/$ARTIST/$ALBUM/avconv.log
        done
    fi
}

function list_all {
    for ARTIST in $(ls $FLAC_PATH); do
      for ALBUM in $(ls $FLAC_PATH/$ARTIST); do
            echo "$ARTIST/$ALBUM ($(du -sh $FLAC_PATH/$ARTIST/$ALBUM | awk '{print $1}'))"
      done
    done
}

# list_all

encode "Dream_Theater" "A_Change_of_Seasons"
encode "Dream_Theater" "A_Dramatic_Turn_of_Events"
encode "Dream_Theater" "Awake"
encode "Dream_Theater" "Black_Clouds_&_Silver_Linings"
encode "Dream_Theater" "Dream_Theater"
encode "Dream_Theater" "Falling_Into_Infinity"
encode "Dream_Theater" "Images_and_Words"
encode "Dream_Theater" "Metropolis,_Pt._2_Scenes_From_a_Memory"
encode "Dream_Theater" "Octavarium"
encode "Dream_Theater" "Six_Degrees_of_Inner_Turbulence"
encode "Dream_Theater" "Systematic_Chaos"
encode "Dream_Theater" "Train_of_Thought"
encode "Dream_Theater" "When_Dream_and_Day_Unite"
encode "Dropkick_Murphys" "The_Gang’s_All_Here"
encode "Elvis_Costello" "This_Year’s_Model"
encode "Eric_Clapton" "461_Ocean_Boulevard"
encode "Eric_Clapton" "I_Still_Do"
encode "Eric_Clapton" "Me_and_Mr_Johnson"
encode "Eric_Clapton" "Slowhand"
encode "Eric_Clapton_&_Steve_Winwood" "Live_From_Madison_Square_Garden_Disc_1"
encode "Eric_Clapton_&_Steve_Winwood" "Live_From_Madison_Square_Garden_Disc_2"
encode "Guano_Apes" "Proud_Like_a_God"
encode "Guns_N’_Roses" "Appetite_for_Destruction"
encode "Peter_Doherty" "GraceWastelands"
encode "Peter_Doherty" "Hamburg_Demonstrations"
encode "Roger_Miret_and_the_Disasters" "1984"
encode "The_Clash" "Combat_Rock"
encode "The_Clash" "Cut_the_Crap"
encode "The_Clash" "Give_’Em_Enough_Rope"
encode "The_Clash" "London_Calling"
encode "The_Clash" "Sandinista!"
encode "The_Clash" "The_Clash"
encode "The_Dillinger_Escape_Plan" "Dissociation"
encode "The_Dillinger_Escape_Plan" "Miss_Machine"
encode "The_Dillinger_Escape_Plan" "One_of_Us_Is_the_Killer"
encode "The_Dillinger_Escape_Plan" "Option_Paralysis"
encode "The_Doors" "L.A._Woman"
encode "The_Doors" "Live_in_Boston_1970"
encode "The_Doors" "Morrison_Hotel"
encode "The_Doors" "Strange_Days"
encode "The_Doors" "The_Doors"
encode "The_Doors" "The_Soft_Parade"
encode "The_Doors" "Waiting_for_the_Sun"
encode "Thomas_D" "Solo"



