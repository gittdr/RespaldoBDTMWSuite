SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[create_cancelled_order_note_sp]
        @p_ord_hdrnumber 	int,
	@p_urgent_level		varchar(1)

AS

/**
 * 
 * NAME:
 * create_cancelled_order_note_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts a note in the notes table for a recently cancelled order
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:
 * @p_ord_hdrnumber	int		Specifies the ord_hdrnumber for the note the proc will create, 
 *			        	which it also uses to get the cancelled order information
 *			        	from the orderheader_cancel_log table.
 * @p_urgent_level	varchar(1)	Specified the urgency level of the note, which comes ultimately
 *				 	from the UrgencyForCancelledOrderNote ini setting.
 *
 * REVISION HISTORY:
 * 9/13/2005.01 ? PTS22346 - Dan Hudec ? Created Procedure
 * 04/01/2010 - PTS50912 increased size of ohc_remark field from 30 to 256; 
 *
 **/

DECLARE	@v_note_sequence 	int, 
	@v_ntb_table 		varchar(18), 
	@v_not_urgent 		char(1), 
	@v_not_number 		int, 
	@v_nre_tablekey 	int,
	@v_not_type		varchar(6),
	@v_ord_number		varchar(12),
	@v_ohc_cancelled_by	varchar(20),
	@v_ohc_cancelled_date	datetime,
	@v_ohc_requested_by	varchar(20),
	@v_ohc_remark		varchar(256),
	@v_note			varchar(256)

  
SELECT @v_nre_tablekey = @p_ord_hdrnumber

IF @p_ord_hdrnumber IS NULL RETURN 

If exists (select *
	   from   orderheader_cancel_log
	   where  ord_hdrnumber = @p_ord_hdrnumber)
 BEGIN
	SELECT	@v_ord_number = ord_number,
		@v_ohc_requested_by = ohc_requested_by,
		@v_ohc_cancelled_by = ohc_cancelled_by,
		@v_ohc_cancelled_date = ohc_cancelled_date,
		@v_ohc_remark = ohc_remark
	FROM	orderheader_cancel_log
	WHERE	ord_hdrnumber = @p_ord_hdrnumber
	AND	ohc_cancelled_date = (SELECT MAX(ohc_cancelled_date)
				      FROM   orderheader_cancel_log
				      WHERE  ord_hdrnumber = @p_ord_hdrnumber)

	SELECT 	@v_note = 'Order Number: ' + RTRIM(LTRIM(isNull(@v_ord_number, @p_ord_hdrnumber)))
	SELECT	@v_note = @v_note + '   Cancel Requested by: ' + RTRIM(LTRIM(isNull(@v_ohc_requested_by, 'None')))
	SELECT	@v_note = @v_note + '   Cancelled by: ' + RTRIM(LTRIM(isNull(@v_ohc_cancelled_by, 'None')))
	SELECT	@v_note = @v_note + '   Cancelled on: ' + RTRIM(LTRIM(Cast(isNull(@v_ohc_cancelled_date, getdate()) as varchar(50))))
	SELECT	@v_note = @v_note + '   Reason Cancelled: ' + RTRIM(LTRIM(isNull(@v_ohc_remark, 'None')))

	SELECT @v_ntb_table = 'orderheader'

	--urgent = A   not urgent = N
	SELECT @v_not_urgent = IsNull(@p_urgent_level, 'N')

	If @v_not_urgent = ''
		Select @v_not_urgent = 'N'

	EXEC @v_not_number = dbo.getsystemnumber 'NOTES',NULL
	
	SELECT 	@v_note_sequence = MAX(not_sequence)
	FROM	notes
	WHERE 	ntb_table = @v_ntb_table
	AND   	nre_tablekey = @v_nre_tablekey

	IF @v_note_sequence IS NULL 
		SELECT @v_note_sequence = 1
	ELSE
		SELECT @v_note_sequence = @v_note_sequence + 1

	INSERT 
	INTO notes (
		not_number, not_text, not_type,                       --1
		not_urgent, not_expires, ntb_table,                   --2
		nre_tablekey, not_sequence, last_updatedby,           --3
		last_updatedatetime                                   --4
		)
	VALUES (
		@v_not_number, @v_note, @v_not_type,                  --1
		@v_not_urgent, '12-31-49 23:59', @v_ntb_table,        --2
		@v_nre_tablekey, @v_note_sequence, suser_sname(),     --3
		getdate()                                             --4
		)

	IF @@error<>0
	BEGIN
		EXEC tmw_log_error 888, 'Update TPR Note Failed', @@error, @p_ord_hdrnumber
		return -1
	END
 END
 
GO
GRANT EXECUTE ON  [dbo].[create_cancelled_order_note_sp] TO [public]
GO
