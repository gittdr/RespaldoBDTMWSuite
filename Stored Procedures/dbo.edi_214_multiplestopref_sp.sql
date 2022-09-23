SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[edi_214_multiplestopref_sp] @docid varchar(30), @stopedicode varchar(6)

AS
/**
exec edi_214_multiplestopref_sp '07181147184890000001891', 'SI'
 * 
 * NAME:
 * dbo.edi_214_multiplestopref_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:	 Stored procedure that runs following the creation of a 214 document.  
 *				 If the trading partner is set to generate multiple 214 based on stop refs
 *				 and there is more than one such ref attached to the stop, 
 *				 a 214 will be created for each additional ref number.
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 *       
 * 001 - @docid varchar(30); Represents the original edi document id.
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * 7/15/2011.01 PTS 51916- Dwilk - Initial release.
 *
 **/

DECLARE @refcount	int,
	@newdocid	varchar(30),
	@trp_id		varchar(20),
	@firstident	int,
	@lastident	int,
	@nextident	int,
	@next_bol	varchar(30),
	@orig_bol	varchar(30),
	@bolseq		int,
	@After339  int,
	@NewAfter339  int,
	@After739  int,
	@NewAfter739  int,
	@RecordType char(1),
	@EDICode varchar(3),
	@StopRef	varchar(30),
	@ord_hdrnumber varchar(10),
	@maxback int,
	@maxforward int

--temp table to store the bols   attached to the stop
Create Table #temp_bol 
(
	ref_sequence int,
	edi_214_identity_col	int,
	StopRef		    varchar(30)
)	

	set @orig_bol = null
	set @refcount = 0
	select @firstident = MIN(identity_col) from edi_214 WHERE doc_id = @docid 
	select @lastident = MAX(identity_col) from edi_214 WHERE doc_id = @docid
	set @nextident = @firstident 
	set @After339 = 0
	set @orig_bol = ''
    WHILE Isnull(@nextident,@lastident) < @lastident
    BEGIN --2
		select top 1 @nextident = identity_col from edi_214 where doc_id = @docid and identity_col > @nextident order by identity_col 
		if @nextident is null 
			break
		select @RecordType = LEFT(data_col,1), @EDICode = SUBSTRING(data_col,7,3), @StopRef = SUBSTRING(data_col,10,30) from edi_214 where identity_col = @nextident 
		if @RecordType = '3'
			set @After339 = @nextident
		if @RecordType = '7'
			set @After739 = @nextident
		IF @After339 is not null and @After739 is null
			IF @RecordType = '4'
				IF @EDICode = @stopedicode
					begin
						set @refcount = @refcount + 1
						Insert #temp_bol 
							select @refcount, @nextident, @StopRef
						if @refcount = 1
							SET @orig_bol = @StopRef
					end
			
	END	
	if @After739 is null
		set @After739 = @nextident
		
	set @maxback = @lastident - @After339 
	set @maxforward = @lastident - @After739 

--condition variable
SELECT @bolseq = 1

IF (SELECT count(*) FROM #temp_bol) > 1
BEGIN --1
     SELECT @refcount = count(*) FROM #temp_bol
     --Get the trp_id, ord_hdrnumber
     SELECT @trp_id = trp_id, @ord_hdrnumber = SUBSTRING(doc_id, 14, 10) FROM edi_214 WHERE doc_id = @docid AND Left(data_col,3) = '139'
     WHILE @bolseq < @refcount
     BEGIN --2
		  --generate a new docid
          SELECT @newdocid = Right('0' + CONVERT(varchar(2),MONTH(GETDATE())), 2) + right('0' + CONVERT(varchar(2),DAY(GETDATE())), 2) +
          		     CONVERT(varchar(20),GETDATE(),114) + @ord_hdrnumber
          SELECT @newdocid = REPLACE(@newdocid,':','')
          
          --Copy The Original edi_214 document with the new docid
          INSERT INTO edi_214 (data_col,trp_id,doc_id)
          	SELECT	data_col,
          			@trp_id,
          			@newdocid
          	FROM	edi_214
          	WHERE	doc_id = @docid
          	
          	set @NewAfter339  = @@IDENTITY - @maxback 
          	set @NewAfter739  = @@IDENTITY - @maxforward

			select '@bolseq ' + convert(varchar,@bolseq)
          
          SELECT top 1 @nextident = edi_214_identity_col, @bolseq = ref_sequence, @next_bol = StopRef
          FROM	 #temp_bol
          WHERE	 ref_sequence = (SELECT (MIN(ref_sequence)) FROM #temp_bol WHERE ref_sequence  > @bolseq)
          Order by ref_sequence 
          
          --delete the refs that are not applicable to this 214
          DELETE edi_214
          WHERE	 doc_id = @newdocid
          AND	left(data_col,3) = '439' 
          AND SUBSTRING(data_col,10,30) <> @next_bol 
          AND SUBSTRING(data_col,7,3) = @stopedicode
          AND identity_col > @NewAfter339  
          AND identity_col < @NewAfter739  
         
          --Pause to ensure a new docid is correctly generated
          WAITFOR DELAY '00:00:01'
     END --2     
     -- delete the refs that are not applicable to the original 214
	DELETE edi_214
    WHERE	 doc_id = @docid
    AND	left(data_col,3) = '439' 
    AND SUBSTRING(data_col,10,30) <> @orig_bol
    AND SUBSTRING(data_col,7,3) = @stopedicode
    AND identity_col > @After339  
    AND identity_col < @After739  
                  
END --1          

GO
GRANT EXECUTE ON  [dbo].[edi_214_multiplestopref_sp] TO [public]
GO
