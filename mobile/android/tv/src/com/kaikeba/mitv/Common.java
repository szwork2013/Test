package com.kaikeba.mitv;

/**
 * Created by sjyin on 14-8-21.
 */
public interface Common {

    float SCALE_MAIN = 1.0f;
    float SCALE_FAVOR_HISTORY = 2f;
    float SCALE_RECOMMEND = 4f;

    int FROM_MAIN = 1;
    int FROM_FAVOR = 2;
    int FROM_HISTORY = 3;
    int FROM_RECOMMEND = 4;

    //////////////////////////////////////// TOP IAMGE

    //FROM MAIN
    int DEFAULT_CARD_WIDTH_FROM_MAIN = 213;
    int DEFAULT_CARD_HEIGHT_FROM_MAIN = 133;

    int PRESS_CARD_WIDTH_FROM_MAIN = 240;
    int PRESS_CARD_HEIGHT_FROM_MAIN = 150;

    //FROM FAVOR AND HISTORY
    int DEFAULT_CARD_WIDTH_FROM_FAVOR = 226;
    int DEFAULT_CARD_HEIGHT_FROM_FAVOR = 146;

    int PRESS_CARD_WIDTH_FROM_FAVOR = 253;
    int PRESS_CARD_HEIGHT_FROM_FAVOR = 160;

    //FROM RECOMMEND
    int DEFAULT_CARD_WIDTH_FROM_REC = 154;
    int DEFAULT_CARD_HEIGHT_FROM_REC = 90;

    int PRESS_CARD_WIDTH_FROM_REC = 173;
    int PRESS_CARD_HEIGHT_FROM_REC = 101;


    //////////////////////////////////////// TOP VIEW CONTAINER

    // FORM MAIN
    int TOP_VIEW_HEIGHT_FROM_MAIN = 53;
    int TOP_VIEW_PADDING_LEFT_FROM_MAIN = 13;
    int TOP_VIEW_PADDING_RIGHT_FROM_MAIN = 13;
    int TOP_VIEW_TEXT_SIZE_FROM_MAIN = 15;
    int TOP_VIEW_HEART_WIDTH_HEIGHT = 29;
    int PRESS_TOP_VIEW_PADDING_LEFT = 16;
    int PRESS_TOP_VIEW_PADDING_RIGHT = 16;


    // FROM FAVOR AND HISTORY
    int TOP_VIEW_TEXT_SIZE_FROM_FAVOR = 16;

    //FROM RECOMMEND
    int TOP_VIEW_HEIGHT_FROM_REC = 38;
    int TOP_VIEW_PADDING_LEFT_FROM_REC = 10;
    int TOP_VIEW_PADDING_RIGHT_FROM_REC = 10;
    int TOP_VIEW_TEXT_SIZE_FROM_REC = 10;

    int PRESS_TOP_VIEW_PADDING_LEFT_RROM_REC = 11;
    int PRESS_TOP_VIEW_PADDING_REIGHT_RROM_REC = 11;

    //////////////////////////////////////// BOTTOM VIEW CONTAINER

    //FROM MAIN
    int BOTTOM_VIEW_STAR_WIDTH_HEIGHT = 20;
    int BOTTOM_VIEW_STAR_MARGIN_RIGHT = 3;
    int BOTTOM_VIEW_HEART_WIDTH_HEIGHT = 40;

    //FROM FAVOR AND HISTORY


    /** default**/


    /** card from main ***********************************/

    // NO HEART


    /**
     * card from favor history **********************************
     */


    int DEFAULT_CARD_TOP_VIEW_HEART_WIDTH_HEIGHT = 29;
    int DEFAULT_CARD_TOP_VIEW_HEART_MARGIN_LEFT = 12;
    int DEFAULT_CARD_TOP_VIEW_HEART_MARGIN_RIGHT = 12;

    /**
     * card from recommend **********************************
     */


    //NO HEART


    int PRESS_BOTTOM_VIEW_PADDING_LEFT_FROM_REC = 12;
    int PRESS_BOTTOM_VIEW_PADDING_RIGHT_FROM_REC = 12;

    int BOTTOM_VIEW_STAR_WIDTH_HEIGHT_FROM_REC = 6;
    int BOTTOM_VIEW_STAR_MARGIN_RIGHT_FROM_REC = 1;

    //NO BOTTOM HEART
}
