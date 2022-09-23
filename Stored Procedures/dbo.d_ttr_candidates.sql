SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_ttr_candidates] @filternumber int, @billto varchar(8)
AS

SELECT ttrheader.ttr_number,
	ttrd_terminusnbr,
	SUBSTRING(ttrf_filter,1,255) Filter1,
	SUBSTRING(ttrf_filter,256,255) Filter2,
	SUBSTRING(ttrf_filter,511,255) Filter3,
	SUBSTRING(ttrf_filter,766,255) Filter4,
	SUBSTRING(ttrf_filter,1021,255) Filter5,
	SUBSTRING(ttrf_filter,1276,255) Filter6,
	SUBSTRING(ttrf_filter,1531,255) Filter7,
	SUBSTRING(ttrf_filter,1786,255) Filter8,
	SUBSTRING(ttrf_filter,2041,255) Filter9,
	SUBSTRING(ttrf_filter,2296,255) Filter10,
	SUBSTRING(ttrf_filter,2551,255) Filter11,
	SUBSTRING(ttrf_filter,2806,255) Filter12,
	ttr_code
FROM ttrfilter, ttrheader
WHERE  ttrfilter.ttr_number = ttrheader.ttr_number  and  
        ttrfilter.ttrd_terminusnbr = @filternumber AND  
        ttrheader.ttr_billto in (@billto,'UNKNOWN') 

GO
GRANT EXECUTE ON  [dbo].[d_ttr_candidates] TO [public]
GO
