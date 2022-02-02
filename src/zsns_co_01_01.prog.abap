*&---------------------------------------------------------------------*
*& Report ZSNS_CO_01_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsns_co_01_01.

INCLUDE ZSNS_CO_01_01_top.
INCLUDE ZSNS_CO_01_01_c01.
INCLUDE ZSNS_CO_01_01_f01.
INCLUDE ZSNS_CO_01_01_i01.
INCLUDE ZSNS_CO_01_01_o01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM open_file.
  PERFORM get_data.

START-OF-SELECTION.
    CALL SCREEN 0100.
