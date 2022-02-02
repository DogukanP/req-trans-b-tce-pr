*&---------------------------------------------------------------------*
*& Include          ZSNS_CO_01_01_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*CLASS lcl_event_receiver DEFINITION DEFERRED.
*----------------------------------------------------------------------*
*CLASS lcl_event_receiver DEFINITION DEFERRED.
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_toolbar.
    DATA: ls_toolbar TYPE stb_button.
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'SAVE'.
    ls_toolbar-butn_type = 0.
    ls_toolbar-text      = 'KAYDET'.
    ls_toolbar-quickinfo = 'KAYDET'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.
  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'SAVE'.
        LOOP AT gt_out INTO gs_out.
          PERFORM control.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
