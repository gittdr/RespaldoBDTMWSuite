SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[add_ordercarrierrates] (@ord_number VARCHAR(12))
AS
DECLARE
	@lgh_number		INT,
	@laneid			INT,
	@activedate		DATETIME

SET @activedate = GETDATE()
select
	@lgh_number=lga.lgh_number
from legheader_active as lga (NOLOCK)
inner join orderheader as ord (NOLOCK)
on ord.ord_hdrnumber=lga.ord_hdrnumber
where ord.ord_number=@ord_number

-- Creates and returns #EligibleCarriersForLeg
exec core_GetTempTableOfEligibleCarriersForLeg  @lgh_number, @activedate

/* Insert a row into the ordercarrierrates table for each eligible carrier */
--insert into #ocr
INSERT INTO ordercarrierrates (ord_number, car_id, ocr_rate, ocr_charge, 
                                           ocr_cur_commit_count, ocr_processed)
select
	@ord_number as ord_number,
	car_id,
	0 as ocr_rate,
	0 as ocr_charge,
	0 as ocr_cur_commit_count,
	'N' as ocr_processed
from ##EligibleCarriersForLeg

INSERT INTO ordercarrierrates (ord_number, car_id, ocr_rate, ocr_charge,
                                        ocr_cur_commit_count, ocr_processed)
                                VALUES (@ord_number, 'GOAL', 0, 0, 0, 'N')

drop table ##EligibleCarriersForLeg

GO
GRANT EXECUTE ON  [dbo].[add_ordercarrierrates] TO [public]
GO
