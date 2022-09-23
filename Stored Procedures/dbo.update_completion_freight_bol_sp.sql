SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_completion_freight_bol_sp]	
@p_bol varchar(30),
@p_fgt_number int,
@p_ord_hdrnumber int

AS

/**
 * 
 * NAME:
 * update_completion_freight_bol_sp
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
 * PARAMETERS: 	@p_bol 			varchar(30)	BOL to update referencenumber table
 *		@p_fgt_number		int		Freight Number for referencenumber
 *		@p_ord_hdrnumber	int		Orderheader Number for referencenumber
 * 		
 * REVISION HISTORY:
 * 8/3/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 * 03/31/2011 PTS 56334 SPN now on we are using referencenumber table instead of completion_referencenumber
 * gkanz 7/28/2011 un comment code
 * 11/29/11 PTS 57732 uncommented section of code needs to use referencenumber table instead of completion_referencenumber
 *
 **/

DECLARE	@v_ref_sequence int,
	@v_tmwuser varchar(255)

exec gettmwuser @v_tmwuser output

--Either insert row or delete row depending on whether or not refnum of the specified type already exists


--BEGIN PTS 56334 SPN 
--IF EXISTS (SELECT * FROM completion_referencenumber 
--	    WHERE ref_tablekey = @p_fgt_number
--	    AND   ref_table = 'freightdetail'
--	    AND   ord_hdrnumber = @p_ord_hdrnumber
--	    AND   ref_type = 'BL#')
-- BEGIN
--	IF rtrim(ltrim(@p_bol)) <> ''
--	 BEGIN
--		UPDATE 	completion_referencenumber
--		SET		ref_number = @p_bol
--		WHERE	ref_tablekey = @p_fgt_number
--		AND 	ref_table = 'freightdetail'
--		AND 	ord_hdrnumber = @p_ord_hdrnumber
--		AND 	ref_type = 'BL#'
--	 END
--	ELSE
--	 BEGIN
--		DELETE FROM completion_referencenumber
--		WHERE	ref_tablekey = @p_fgt_number
--		AND 	ref_table = 'freightdetail'
--		AND 	ord_hdrnumber = @p_ord_hdrnumber
--		AND 	ref_type = 'BL#'
--	 END
--  END
IF EXISTS (SELECT * FROM referencenumber 
	    WHERE ref_tablekey = @p_fgt_number
	    AND   ref_table = 'freightdetail'
	    AND   ord_hdrnumber = @p_ord_hdrnumber
	    AND   ref_type = 'BL#')
 BEGIN
	IF rtrim(ltrim(@p_bol)) <> ''
	 BEGIN
		UPDATE 	referencenumber
		SET		ref_number = @p_bol
		WHERE	ref_tablekey = @p_fgt_number
		AND 	ref_table = 'freightdetail'
		AND 	ord_hdrnumber = @p_ord_hdrnumber
		AND 	ref_type = 'BL#'
	 END
	ELSE
	 BEGIN
		DELETE FROM referencenumber
		WHERE	ref_tablekey = @p_fgt_number
		AND 	ref_table = 'freightdetail'
		AND 	ord_hdrnumber = @p_ord_hdrnumber
		AND 	ref_type = 'BL#'
	 END
  END

--END PTS 56334 SPN 
ELSE /*gkanz 7/28/2011 commented back in*/

 BEGIN
	IF (SELECT	COUNT(*) FROM referencenumber
		WHERE	ord_hdrnumber = @p_ord_hdrnumber 
		AND		ref_table = 'freightdetail') = 0 
	 BEGIN
		SELECT	@v_ref_sequence = 1

		--Also update completion_freightdetail since this is the first referencenumber
		UPDATE	completion_freightdetail
		SET		fgt_reftype = 'BL#',
				fgt_refnum = @p_bol
		WHERE	fgt_number = @p_fgt_number
	 END
	ELSE
	 BEGIN
		SELECT	@v_ref_sequence = max(ref_sequence) + 1
		--FROM	completion_referencenumber 
		FROM	referencenumber 
		WHERE	ord_hdrnumber = @p_ord_hdrnumber
		AND		ref_table = 'freightdetail'
	 END

--BEGIN PTS 56334 SPN 
--	INSERT INTO completion_referencenumber
--	(ref_tablekey, ref_type, ref_number, ref_sequence, 
--	 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
--	VALUES
--	(@p_fgt_number, 'BL#', @p_bol, @v_ref_sequence,
--	 @p_ord_hdrnumber, 'freightdetail', @v_tmwuser, getdate())
	INSERT INTO referencenumber
	(ref_tablekey, ref_type, ref_number, ref_sequence, 
	 ord_hdrnumber, ref_table, last_updateby, last_updatedate)
	VALUES
	(@p_fgt_number, 'BL#', @p_bol, @v_ref_sequence,
	 @p_ord_hdrnumber, 'freightdetail', @v_tmwuser, getdate())

--END PTS 56334 SPN 
 END

GO
GRANT EXECUTE ON  [dbo].[update_completion_freight_bol_sp] TO [public]
GO
