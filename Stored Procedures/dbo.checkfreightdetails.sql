SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[checkfreightdetails] @mov int
AS
DECLARE @stpnum int, @recnum int
while (select count(*) from stops where not exists (select * from freightdetail 
		where freightdetail.stp_number = stops.stp_number) and stops.mov_number = @mov) > 0
	BEGIN
	SELECT @stpnum = MIN(stp_number) FROM stops where not exists (select * from freightdetail 
		where freightdetail.stp_number = stops.stp_number) and stops.mov_number = @mov

-- RE - 02/12/02 - PTS #13312 Start
	SELECT @recnum = ISNULL(tmp_fgt_number,0) FROM stops WHERE stp_number = @stpnum

	IF @recnum = 0 EXEC @recnum = getsystemnumber 'FGTNUM', '' 		
-- RE - 02/12/02 - PTS #13312 End

	INSERT INTO freightdetail 
		(stp_number,
		fgt_number, 
		cmd_code,
		fgt_weight,
		fgt_weightunit,
		fgt_description,
		fgt_count,
		fgt_countunit,	
		fgt_sequence,
		fgt_reftype ,
		cht_itemcode,   
		fgt_charge,   
		fgt_quantity,
		fgt_volume, 
		fgt_volumeunit) 
	SELECT
		stp_number,
		@recnum,
		cmd_code,
		stp_weight,
		stp_weightunit,
		stp_description,
		stp_count,
		stp_countunit,
		1,
		'REF',
		'UNK',
		0,
		0,
		stp_volume,
		stp_volumeunit
	FROM	stops
	WHERE	stp_number = @stpnum  
         
	END
GO
GRANT EXECUTE ON  [dbo].[checkfreightdetails] TO [public]
GO
