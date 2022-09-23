SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[edi_214_multiplebols_sp] @ord_hdrnumber varchar(13), @docid varchar(30)

AS
/**
 * 
 * NAME:
 * dbo.edi_214_multiplebols_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:	 Stored procedure that runs following the creation of a 214 document.  
 *				 If the generalinfo setting EDI214_multibol
 *				 is set to Y and there is more than one bol attached to the order, 
 *				 a 214 will be created for each additional BOL number.
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber varchar(13); Order header number for the current 214s being processed.
 *       
 * 002 - @docid varchar(30); Represents the original edi document id.
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * 12/06/2005.01 PTS 30182 - Aross - Initial release.
 *
 **/

DECLARE @bolcount	int,
	@newdocid	varchar(30),
	@trp_id		varchar(20),
	@nextbol	varchar(30),
	@orig_bol	varchar(30),
	@bolseq		int

--check the generalinfo setting
IF (SELECT UPPER(LEFT(ISNULL(gi_string1,'N'),1)) FROM generalinfo WHERE gi_name = 'EDI214_MultiBOL') <> 'Y'
	RETURN


--temp table to store the bols   attached to the orderheader
Create Table #temp_bol 
(
	seq_number	int,
	bol_number	varchar(30)
)	

--condition variable
SELECT @bolseq = 0

--get the original bol number from the 214
SELECT @orig_bol = RTRIM(LTRIM(SUBSTRING(data_col,23,30))) FROM edi_214 WHERE doc_id = @docid AND Left(data_col,3) = '139'

--insert additional bols into temp table
INSERT INTO #temp_bol
	SELECT	ref_sequence,ref_number
	FROM	referencenumber
	WHERE	ord_hdrnumber = @ord_hdrnumber
		   AND ref_type in ('BOL','BL#','BL')
		   AND ref_table = 'orderheader'
		   AND ref_number <> @orig_bol
		ORDER BY ref_sequence   

IF (SELECT count(*) FROM #temp_bol) > 0
BEGIN --1
     SELECT @bolcount = count(*) FROM #temp_bol
     --Get the trp_id
     SELECT @trp_id = trp_id FROM edi_214 WHERE doc_id = @docid AND Left(data_col,3) = '139'
     
     WHILE @bolcount > 0
     BEGIN --2
          --generate a new docid
          SELECT @newdocid = CONVERT(varchar(2),MONTH(GETDATE())) + CONVERT(varchar(2),DAY(GETDATE())) +
          		     CONVERT(varchar(20),GETDATE(),114) + REPLICATE('0',10-LEN(@ord_hdrnumber)) +
          		     @ord_hdrnumber
          SELECT @newdocid = REPLACE(@newdocid,':','')
          
          --Copy The Original edi_214 document with the new docid
          INSERT INTO edi_214 (data_col,trp_id,doc_id)
          	SELECT	data_col,
          			@trp_id,
          			@newdocid
          	FROM	edi_214
          	WHERE	doc_id = @docid
          	
          SELECT @nextbol = bol_number,@bolseq = seq_number
          FROM	 #temp_bol
          WHERE	 seq_number = (SELECT (MIN(seq_number)) FROM #temp_bol WHERE seq_number > @bolseq) 
          
          --condition the bol#
	  SELECT @orig_bol = @orig_bol + REPLICATE(' ',30-LEN(@orig_bol))

          Select @nextbol =  @nextbol + Replicate(' ',30 - LEN(@nextbol)) 
          
          --Replace the bol# in the 1 record with the new one for the newly created 214
          UPDATE edi_214
          SET	 data_col = REPLACE(data_col,@orig_bol,@nextbol)
          FROM	 edi_214
          WHERE	 doc_id = @newdocid
          	    AND	left(data_col,3) = '139'
          
          DELETE #temp_bol where seq_number = @bolseq
          
          --decrement the # of bols	  
          SELECT @bolcount = @bolcount - 1
          
          --Pause to ensure a new docid is correctly generated
          WAITFOR DELAY '00:00:01'
          
     END --2     
END --1          

GO
GRANT EXECUTE ON  [dbo].[edi_214_multiplebols_sp] TO [public]
GO
