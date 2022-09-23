SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ace_docsbymove] @p_ordnum varchar(13),@p_mov_number int
AS
/**
 * 
 * NAME:
 * dbo.d_ace_docsbymove
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves all archived ACE documents for a particular movement.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * .
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/1/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 09/15/2006.02 PTS34504 - A.Rossman - Added 355 reject reason to window.
 *
 **/
 
 DECLARE @v_mov_number	int
 
 
IF UPPER(LEFT(@p_ordnum,2)) = 'MT'
	SELECT @v_mov_number = RIGHT(@p_ordnum,datalength(@p_ordnum)- 2)
ELSE
--Use the input move number when necessary.
IF @p_mov_number > 0
	SET @v_mov_number = @p_mov_number
ELSE	
	SELECT @v_mov_number = mov_number
	FROM 	orderheader 
	WHERE ord_number = @p_ordnum
 
 SELECT aea_doctype,
 	aea_batch,
 	aea_archivedate,
 	aea_tmwuser,
 	aea_997_flg,
 	aea_997_date,
 	aea_355_flg,
 	aea_355_date,
 	aea_355_reason
 FROM	ace_edidocument_archive
 WHERE	mov_number = @v_mov_number
 	AND aea_batch_seq = 1
 ORDER BY 	aea_doctype ASC,
		aea_batch ASC
		
		
GO
GRANT EXECUTE ON  [dbo].[d_ace_docsbymove] TO [public]
GO
