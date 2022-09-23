SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[copy_master_notes_to_completion_sp]	
@p_master_ord_number	int,
@p_new_ord_hdrnumber	int

AS

/**
 * 
 * NAME:
 * copy_master_notes_to_completion_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: 	@p_master_ord_number 		int		Master order # from which to copy notes
 * 				@p_new_ord_hdrnumber 		int		New orderheader number to copy notes to
 *
 * REVISION HISTORY:
 * 9/20/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 *
 **/

DECLARE	@v_new_not_number		int,
		@v_max_not_number		int,
		@v_cur_not_number		int,
		@v_master_ord_hdrnumber	int

SELECT	@v_master_ord_hdrnumber = ord_hdrnumber
FROM	orderheader
WHERE	ord_number = @p_master_ord_number

SELECT	not_number, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires, not_forwardedfrom,
	    ntb_table, @p_new_ord_hdrnumber nre_tablekey, not_sequence, last_updatedby, last_updatedatetime, not_text_large,
	    not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, not_number_copied_from,
	    not_tmsend
INTO	#TEMP
FROM	notes
WHERE	ntb_table = 'orderheader'
AND		nre_tablekey = @v_master_ord_hdrnumber

SELECT	@v_new_not_number = max(not_number) + 1
FROM	notes

SELECT	@v_cur_not_number = min(not_number)
FROM	#temp

SELECT	@v_max_not_number = max(not_number)
FROM	#temp

WHILE @v_cur_not_number <= @v_max_not_number
 BEGIN
	UPDATE	#temp 
	SET		not_number = @v_new_not_number
	WHERE	not_number = @v_cur_not_number

	SELECT	@v_new_not_number = @v_new_not_number + 1

	SELECT	@v_cur_not_number = min(not_number)
	FROM	#temp
	WHERE	not_number > @v_cur_not_number
 END

INSERT INTO notes(not_number, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires, not_forwardedfrom,
				  ntb_table, nre_tablekey, not_sequence, last_updatedby, last_updatedatetime, not_text_large,
				  not_viewlevel, ntb_table_copied_from, nre_tablekey_copied_from, not_number_copied_from,
				  not_tmsend)
SELECT	* FROM #temp

GO
GRANT EXECUTE ON  [dbo].[copy_master_notes_to_completion_sp] TO [public]
GO
