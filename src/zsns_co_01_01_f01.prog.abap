*&---------------------------------------------------------------------*
*& Include          ZSNS_CO_01_01_F01
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Form open_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file .
  DATA : lt_filename TYPE filetable,
         ls_filename TYPE file_table,
         lv_rc       TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      default_extension       = 'XLS'
    CHANGING
      file_table              = lt_filename     " Table Holding Selected Files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE lt_filename INTO ls_filename INDEX 1.
  IF sy-subrc = 0.
    p_file = ls_filename-filename.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '20'
      i_end_row               = '256'
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF sy-subrc = 0.

    LOOP AT gt_excel INTO gs_excel.

      CASE gs_excel-col.

        WHEN '0001'.
          MOVE gs_excel-value TO gs_out-co_area.
        WHEN '0002'.
          MOVE gs_excel-value TO gs_out-version.
        WHEN '0003'.
          MOVE gs_excel-value TO gs_out-fisc_year.
        WHEN '0004'.
          MOVE gs_excel-value TO gs_out-period_from.
        WHEN '0005'.
          MOVE gs_excel-value TO gs_out-period_to.
        WHEN '0006'.
          MOVE gs_excel-value TO gs_out-cost_center.
        WHEN '0007'.
          MOVE gs_excel-value TO gs_out-cost_element.
        WHEN '0008'.
          MOVE gs_excel-value TO gs_out-fix_val_per01.
        WHEN '0009'.
          MOVE gs_excel-value TO gs_out-fix_val_per02.
        WHEN '0010'.
          MOVE gs_excel-value TO gs_out-fix_val_per03.
        WHEN '0011'.
          MOVE gs_excel-value TO gs_out-fix_val_per04.
        WHEN '0012'.
          MOVE gs_excel-value TO gs_out-fix_val_per05.
        WHEN '0013'.
          MOVE gs_excel-value TO gs_out-fix_val_per06.
        WHEN '0014'.
          MOVE gs_excel-value TO gs_out-fix_val_per07.
        WHEN '0015'.
          MOVE gs_excel-value TO gs_out-fix_val_per08.
        WHEN '0016'.
          MOVE gs_excel-value TO gs_out-fix_val_per09.
        WHEN '0017'.
          MOVE gs_excel-value TO gs_out-fix_val_per10.
        WHEN '0018'.
          MOVE gs_excel-value TO gs_out-fix_val_per11.
        WHEN '0019'.
          MOVE gs_excel-value TO gs_out-fix_val_per12.
      ENDCASE.
      AT END OF row.
        APPEND gs_out TO gt_out.
        CLEAR gs_out.
      ENDAT.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SHOW_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  IF p_file IS INITIAL.
    MESSAGE 'Dosya yolu doldurulması zorunlu alandır.' TYPE 'E'.
  ENDIF.

  IF go_custom_container IS INITIAL.
    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = go_container.

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_custom_container.

    PERFORM build_layout.

    PERFORM build_fcat .

    PERFORM exclude_button CHANGING gt_exclude .

    PERFORM event_handler.

    CALL METHOD go_grid->set_table_for_first_display ""alv basılır.
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
        is_variant           = gs_variant
        i_save               = 'A'
      CHANGING
        it_outtab            = gt_out
        it_fieldcatalog      = gt_fcat[].

    PERFORM register_event.
  ELSE .
    PERFORM check_changed_data    USING go_grid .
    PERFORM refresh_table_display USING go_grid .
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_layout .
  CLEAR gs_layout.
  gs_layout-zebra      = 'X'."ilk satır koyu ikinci satır açık
  gs_layout-cwidth_opt = 'X'."kolonların uzunluklarını optimize et
  gs_layout-sel_mode   = 'A'."hücrelerin seçilebilme kriteri
  gs_variant-report     = sy-repid .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fcat .
  DATA: lt_kkblo_fieldcat TYPE kkblo_t_fieldcat,
        lv_repid          TYPE sy-repid.

  lv_repid = sy-repid.

  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'
    EXPORTING
      i_callback_program     = lv_repid
      i_tabname              = 'GS_OUT'
      i_inclname             = lv_repid
    CHANGING
      ct_fieldcat            = lt_kkblo_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      OTHERS                 = 2.
  IF lt_kkblo_fieldcat IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR gt_fcat[].
  CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
    EXPORTING
      it_fieldcat_kkblo = lt_kkblo_fieldcat
    IMPORTING
      et_fieldcat_lvc   = gt_fcat[]
    EXCEPTIONS
      it_data_missing   = 1
      OTHERS            = 2.
  IF gt_fcat IS INITIAL.
    MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT gt_fcat INTO gs_fcat.
    gs_fcat-key = ' '.
    CASE gs_fcat-fieldname.
      WHEN 'MANDT'.
        gs_fcat-no_out = abap_true.
      WHEN 'CO_AREA'.
        gs_fcat-scrtext_s  = 'Kontrol Kodu'.
        gs_fcat-scrtext_m  = 'Kontrol Kodu'.
        gs_fcat-scrtext_l  = 'Kontrol Kodu'.
        gs_fcat-coltext    = 'Kontrol Kodu'.
      WHEN 'FISC_YEAR'.
        gs_fcat-scrtext_s  = 'Mali Yıl'.
        gs_fcat-scrtext_m  = 'Mali Yıl'.
        gs_fcat-scrtext_l  = 'Mali Yıl'.
        gs_fcat-coltext    = 'Mali Yıl'.
      WHEN 'PERIOD_FROM'.
        gs_fcat-scrtext_s  = 'İlk Dönem'.
        gs_fcat-scrtext_m  = 'İlk Dönem'.
        gs_fcat-scrtext_l  = 'İlk Dönem'.
        gs_fcat-coltext    = 'İlk Dönem'.
      WHEN 'PERIOD_TO'.
        gs_fcat-scrtext_s  = 'Son Dönem'.
        gs_fcat-scrtext_m  = 'Son Dönem'.
        gs_fcat-scrtext_l  = 'Son Dönem'.
        gs_fcat-coltext    = 'Son Dönem'.
      WHEN 'FIX_VAL_PER01'.
        gs_fcat-scrtext_s  = 'Ocak'.
        gs_fcat-scrtext_m  = 'Ocak'.
        gs_fcat-scrtext_l  = 'Ocak'.
        gs_fcat-coltext    = 'Ocak'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER02'.
        gs_fcat-scrtext_s  = 'Şubat'.
        gs_fcat-scrtext_m  = 'Şubat'.
        gs_fcat-scrtext_l  = 'Şubat'.
        gs_fcat-coltext    = 'Şubat'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER03'.
        gs_fcat-scrtext_s  = 'Mart'.
        gs_fcat-scrtext_m  = 'Mart'.
        gs_fcat-scrtext_l  = 'Mart'.
        gs_fcat-coltext    = 'Mart'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER04'.
        gs_fcat-scrtext_s  = 'Nisan'.
        gs_fcat-scrtext_m  = 'Nisan'.
        gs_fcat-scrtext_l  = 'Nisan'.
        gs_fcat-coltext    = 'Nisan'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER05'.
        gs_fcat-scrtext_s  = 'Mayıs'.
        gs_fcat-scrtext_m  = 'Mayıs'.
        gs_fcat-scrtext_l  = 'Mayıs'.
        gs_fcat-coltext    = 'Mayıs'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER06'.
        gs_fcat-scrtext_s  = 'Haziran'.
        gs_fcat-scrtext_m  = 'Haziran'.
        gs_fcat-scrtext_l  = 'Haziran'.
        gs_fcat-coltext    = 'Haziran'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER07'.
        gs_fcat-scrtext_s  = 'Temmuz'.
        gs_fcat-scrtext_m  = 'Temmuz'.
        gs_fcat-scrtext_l  = 'Temmuz'.
        gs_fcat-coltext    = 'Temmuz'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER08'.
        gs_fcat-scrtext_s  = 'Ağustos'.
        gs_fcat-scrtext_m  = 'Ağustos'.
        gs_fcat-scrtext_l  = 'Ağustos'.
        gs_fcat-coltext    = 'Ağustos'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER09'.
        gs_fcat-scrtext_s  = 'Eylül'.
        gs_fcat-scrtext_m  = 'Eylül'.
        gs_fcat-scrtext_l  = 'Eylül'.
        gs_fcat-coltext    = 'Eylül'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER10'.
        gs_fcat-scrtext_s  = 'Ekim'.
        gs_fcat-scrtext_m  = 'Ekim'.
        gs_fcat-scrtext_l  = 'Ekim'.
        gs_fcat-coltext    = 'Ekim'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER11'.
        gs_fcat-scrtext_s  = 'Kasım'.
        gs_fcat-scrtext_m  = 'Kasım'.
        gs_fcat-scrtext_l  = 'Kasım'.
        gs_fcat-coltext    = 'Kasım'.
        gs_fcat-edit = abap_true.
      WHEN 'FIX_VAL_PER12'.
        gs_fcat-scrtext_s  = 'Aralık'.
        gs_fcat-scrtext_m  = 'Aralık'.
        gs_fcat-scrtext_l  = 'Aralık'.
        gs_fcat-coltext    = 'Aralık'.
        gs_fcat-edit = abap_true.
    ENDCASE.
    MODIFY gt_fcat FROM gs_fcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_button  CHANGING p_gt_exclude.
  DATA: ls_exclude LIKE LINE OF gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_views.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND ls_exclude TO gt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_find.
  APPEND ls_exclude TO gt_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM event_handler .
  DATA: lcl_alv_event TYPE REF TO lcl_event_receiver .
  CREATE OBJECT lcl_alv_event.

  SET HANDLER lcl_alv_event->handle_toolbar      FOR go_grid.
  SET HANDLER lcl_alv_event->handle_user_command FOR go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .
  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_changed_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM check_changed_data  USING    p_go_grid.
  DATA: lv_valid TYPE c.

  CALL METHOD go_grid->check_changed_data
    IMPORTING
      e_valid = lv_valid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID
*&---------------------------------------------------------------------*
FORM refresh_table_display  USING    p_go_grid.
  DATA : ls_stable TYPE lvc_s_stbl .

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.
  CALL METHOD go_grid->refresh_table_display
    EXPORTING
      is_stable      = ls_stable
      i_soft_refresh = 'X'
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_save .

*  DATA : lv_time type i value 0,
*         lv_index   TYPE i VALUE 0,
*         lv_index_c TYPE c,
*         lv_string  TYPE string.
*
*
*
*  DO gs_out-period_from TIMES.
*    lv_index = lv_index + 1.
*    lv_index_c = lv_index.
*    CONCATENATE 'bapi_pervalue-fix_val_per0' lv_index_c into lv_string.
*    IF LV_INDEX LT gs_out-period_from .
*      BREAK-POINT.
*    ENDIF.
*  ENDDO.

  itab-str = gs_out-fix_val_per01.
  append itab.
  itab-str = gs_out-fix_val_per02.
  append itab.
  itab-str = gs_out-fix_val_per03.
  append itab.
  itab-str = gs_out-fix_val_per04.
  append itab.
  itab-str = gs_out-fix_val_per05.
  append itab.
  itab-str = gs_out-fix_val_per06.
  append itab.
  itab-str = gs_out-fix_val_per07.
  append itab.
  itab-str = gs_out-fix_val_per08.
  append itab.
  itab-str = gs_out-fix_val_per09.
  append itab.
  itab-str = gs_out-fix_val_per10.
  append itab.
  itab-str = gs_out-fix_val_per11.
  append itab.
  itab-str = gs_out-fix_val_per12.
  append itab.



  LOOP AT itab.
    IF ( sy-tabix lt gs_out-period_from ) or ( sy-tabix gt gs_out-period_to ).
      itab-str = ' ' .
      MODIFY itab[] from itab.
    ENDIF.
  ENDLOOP.



  CLEAR bapi_headerinfo.
  bapi_headerinfo-co_area = gs_out-co_area.
  bapi_headerinfo-version = gs_out-version.
  bapi_headerinfo-fisc_year = gs_out-fisc_year.
  bapi_headerinfo-period_from = gs_out-period_from.
  bapi_headerinfo-period_to = gs_out-period_to.

  CLEAR bapi_coobject.
  bapi_coobject-costcenter = gs_out-cost_center.
  APPEND bapi_coobject.

  CLEAR bapi_pervalue.
  bapi_pervalue-cost_elem = gs_out-cost_element.
  bapi_pervalue-fix_val_per01 = itab[ 1 ]-str.
  bapi_pervalue-fix_val_per02 = itab[ 2 ]-str.
  bapi_pervalue-fix_val_per03 = itab[ 3 ]-str.
  bapi_pervalue-fix_val_per04 = itab[ 4 ]-str.
  bapi_pervalue-fix_val_per05 = itab[ 5 ]-str.
  bapi_pervalue-fix_val_per06 = itab[ 6 ]-str.
  bapi_pervalue-fix_val_per07 = itab[ 7 ]-str.
  bapi_pervalue-fix_val_per08 = itab[ 8 ]-str.
  bapi_pervalue-fix_val_per09 = itab[ 9 ]-str.
  bapi_pervalue-fix_val_per10 = itab[ 10 ]-str.
  bapi_pervalue-fix_val_per11 = itab[ 11 ]-str.
  bapi_pervalue-fix_val_per12 = itab[ 12 ]-str.
  APPEND bapi_pervalue.

  bapi_headerinfo-plan_currtype = 'O'.
  bapi_indexstructure-attrib_index = 0.
  bapi_indexstructure-object_index = 1.
  bapi_indexstructure-value_index = 1.

    clear : itab, itab[].


  CALL FUNCTION 'BAPI_COSTACTPLN_CHECKPRIMCOST'
    EXPORTING
      headerinfo     = bapi_headerinfo
      delta          = chbox
    TABLES
      indexstructure = bapi_indexstructure
      coobject       = bapi_coobject
      pervalue       = bapi_pervalue
*     TOTVALUE       =
*     CONTRL         =
      return         = bapi_return.

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    MESSAGE 'İŞLEM BAŞARILI ' TYPE 'S'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CALL FUNCTION 'OXT_MESSAGE_TO_POPUP'
      EXPORTING
        it_message = bapi_return[]
      EXCEPTIONS
        bal_error  = 1
        OTHERS     = 2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXPORT_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM export_template  USING  p_template_name.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string,
        lv_result   TYPE i.

  DATA: BEGIN OF ls_header,
          txt(100) TYPE c,
        END OF ls_header,
        lt_header LIKE TABLE OF ls_header.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Dosya seçiniz'
      default_extension = 'XLS'
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath
      user_action       = lv_result.

  IF lv_result EQ 0.
    CLEAR ls_header.
    ls_header-txt  = 'KONTROL KODU'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'VERSİYON'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'MALİ YIL'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'İLK DÖNEM'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'SON DÖNEM'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'MASRAF YERİ'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'MASRAF ÇEŞİDİ'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'OCAK'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'ŞUBAT'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'MART'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'NİSAN'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'MAYIS'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'HAZİRAN'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'TEMMUZ'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'AĞUSTOS'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'EYLÜL'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'EKİM'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'KASIM'.
    APPEND ls_header TO lt_header.
    ls_header-txt = 'ARALIK'.
    APPEND ls_header TO lt_header.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        fieldnames            = lt_header
        write_field_separator = 'X'
      CHANGING
        data_tab              = gt_out.
    MESSAGE 'ŞABON İNDİRİLDİ.' TYPE 'I'.
  ELSE.
    MESSAGE 'İŞLEM İPTAL EDİLDİ.' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form control
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM control .
  DATA : lv_regex VALUE 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZWXabcçdefgğhijklmnoöprsştuüvyzwx~`!@#$%^&*()_- ={{}}|:;”‘<,>.?/’'.

  IF  gs_out-period_from BETWEEN 1 AND 12.
    IF gs_out-period_TO BETWEEN 1 AND 12.
      IF ( gs_out-fix_val_per01 NA ',' )
        AND ( gs_out-fix_val_per02 NA ',' )
        AND ( gs_out-fix_val_per03 NA ',' )
        AND ( gs_out-fix_val_per04 NA ',' )
        AND ( gs_out-fix_val_per05 NA ',' )
        AND ( gs_out-fix_val_per06 NA ',' )
        AND ( gs_out-fix_val_per07 NA ',' )
        AND ( gs_out-fix_val_per08 NA ',' )
        AND ( gs_out-fix_val_per09 NA ',' )
        AND ( gs_out-fix_val_per10 NA ',' )
        AND ( gs_out-fix_val_per11 NA ',' )
        AND ( gs_out-fix_val_per12 NA ',' ).
        IF ( gs_out-fix_val_per01 NA lv_regex )
          AND ( gs_out-fix_val_per02 NA lv_regex )
          AND ( gs_out-fix_val_per03 NA lv_regex )
          AND ( gs_out-fix_val_per04 NA lv_regex )
          AND ( gs_out-fix_val_per05 NA lv_regex )
          AND ( gs_out-fix_val_per06 NA lv_regex )
          AND ( gs_out-fix_val_per07 NA lv_regex )
          AND ( gs_out-fix_val_per08 NA lv_regex )
          AND ( gs_out-fix_val_per09 NA lv_regex )
          AND ( gs_out-fix_val_per10 NA lv_regex )
          AND ( gs_out-fix_val_per11 NA lv_regex )
          AND ( gs_out-fix_val_per12 NA lv_regex ).
            IF gs_out-period_from le gs_out-period_to .
              PERFORM create_save.
            ELSE.
               MESSAGE 'SON DÖNEM, İLK DÖNEMDEN SONRA OLMALIDIR.' TYPE 'E'.
            ENDIF.
        ELSE.
          MESSAGE 'OCAK VE ARALIK ARASINDAKİ PERİODLAR KARAKTER İÇERMEMELİDİR' TYPE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'OCAK VE ARALIK ARASINDAKİ PERİODLAR '','' İÇERMEMELİDİR' TYPE 'E'.
      ENDIF.
    ELSE.
      MESSAGE 'SON DÖNEM ARALIĞI 1-12 ARALIĞINDA OLMALIDIR.' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'İLK DÖNEM ARALIĞI 1-12 ARALIĞINDA OLMALIDIR.' TYPE 'E'.
  ENDIF.
ENDFORM.
