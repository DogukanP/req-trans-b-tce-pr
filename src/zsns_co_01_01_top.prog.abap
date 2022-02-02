*&---------------------------------------------------------------------*
*& Include          ZSNS_CO_01_01_TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields.
INCLUDE <icon>.


SELECTION-SCREEN BEGIN OF BLOCK a1.
  PARAMETERS : p_file TYPE rlgrap-filename ." OBLIGATORY.
  SKIP 2 .
  PARAMETERS : chbox AS CHECKBOX.
  SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN FUNCTION KEY 1.

*SELECTION-SCREEN PUSHBUTTON 2(12) TEXT-010 USER-COMMAND BUTTON1.

INITIALIZATION.
  CONCATENATE icon_generate 'ŞABLONU İNDİR' INTO sscrfields-functxt_01.


  DATA : BEGIN OF itab OCCURS 0,

           str TYPE BAPICURR_D,

         END OF itab.


  DATA : gt_out TYPE TABLE OF zsnscobg,
         gs_out TYPE zsnscobg.

  DATA : gt_excel LIKE TABLE OF alsmex_tabline,
         gs_excel LIKE alsmex_tabline.

  DATA : ok_code TYPE sy-ucomm.

  DATA: go_container        TYPE scrfname VALUE 'GO_CONTAINER',
        go_grid             TYPE REF TO cl_gui_alv_grid,
        go_custom_container TYPE REF TO cl_gui_custom_container,
        gs_layout           TYPE lvc_s_layo,   "layout
        gt_fcat             TYPE lvc_t_fcat,   "fieldcatalog
        gs_fcat             TYPE lvc_s_fcat,   "fieldcatalog
        gt_exclude          TYPE ui_functions, "alv toolbardaki butonlar için
        gs_exclude          TYPE ui_func,      "alv toolbardaki butonlar için
        gs_variant          TYPE disvariant.   "alv datasının varyantlı gelmesi için

  DATA : bapi_headerinfo     TYPE bapiplnhdr,
         bapi_indexstructure LIKE TABLE OF bapiacpstru WITH HEADER LINE,
         bapi_pervalue       LIKE TABLE OF bapipcpval WITH HEADER LINE,
         bapi_coobject       LIKE TABLE OF bapipcpobj WITH HEADER LINE,
         bapi_return         LIKE TABLE OF bapiret2 WITH HEADER LINE.


  DATA : gt_out2 TYPE TABLE OF zsnscobg,
         gs_out2 TYPE zsnscobg.


AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM export_template USING 'ZCO01_TEMPLATE'.
  ENDCASE.
