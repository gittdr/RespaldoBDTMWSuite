SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ordenborrar_mercancias_JC] (@lgh_number varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
DECLARE 
@vi_seq1 int,
@vi_seq2 int
        --DELETE FROM freightdetail WHERE 
        --stp_number in (SELECT stp_number FROM stops WHERE ORD_hdrnumber = @Ai_orden) and fgt_count = 0  
		BEGIN
		CREATE TABLE #nsecuencias2(
		id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
		stp_number int,
		fgt_sequence int
		)
		END

		DELETE freightdetail where stp_number in (select stp_number from stops where stp_event in (select abbr from eventcodetable where ect_billable = 'Y') 
		and lgh_number in(@lgh_number)) and fgt_count = 0

		DELETE freightdetail where stp_number in (select stp_number from stops where stp_event in (select abbr from eventcodetable where ect_billable = 'Y') 
		and lgh_number in(@lgh_number)) and cmd_code in ('UNKNOWN','MERGENER')
		--DELETE FROM freightdetail WHERE 
  --      stp_number in (SELECT stp_number FROM stops WHERE ORD_hdrnumber = @Ai_orden) and cmd_code in ('UNKNOWN','MERGENER')
		
		
		DELETE freightdetail where stp_number in (select stp_number from stops where stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
        and lgh_number in(@lgh_number)) and fgt_height = 0
		--DELETE FROM freightdetail WHERE 
  --      stp_number in (SELECT stp_number FROM stops WHERE ORD_hdrnumber = @Ai_orden) and fgt_height = 0;
		--PASO 1 HACER EL SELECT E INSERTARLO EN UNA TABLA TEMPORAL
		
		INSERT INTO #nsecuencias2(stp_number,fgt_sequence)
		select distinct(stp_number),min(fgt_sequence)  from freightdetail where stp_number in (select stp_number from stops where stp_event in (select abbr from eventcodetable where ect_billable = 'Y') 
		and lgh_number in(@lgh_number)) GROUP BY stp_number

		DECLARE @i int = 1,@total int,@id int = 1,@stp_number int,@fgt_sequence int,@fgt_number int
		SELECT @total = COUNT(*) FROM #nsecuencias2
		WHILE (@i <= @total)
		 BEGIN
		     SELECT @stp_number = stp_number, @fgt_sequence = fgt_sequence FROM #nsecuencias2 WHERE id = @id

			 IF @fgt_sequence <> 1
			 BEGIN 
			 
			 select @fgt_number = fgt_number from freightdetail where stp_number in (select stp_number from stops where lgh_number in(@lgh_number)) and stp_number = (@stp_number) and fgt_sequence = @fgt_sequence

			 UPDATE freightdetail SET fgt_sequence = 1 WHERE fgt_number = @fgt_number
			 
			 END
			 SET @id = @id + 1
			 SET @i = @i + 1
		 END
	
		
END
GO
