SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetOrdHdrForAssetAndDate](@asgnType varchar(6), @asgnID varchar(13), @ckc_date datetime)
RETURNS varchar(12)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ordNumber int,
			@lgh_number int
	
	select top 1 @lgh_number = lgh_number from assetassignment 
		where asgn_type = @asgntype and asgn_id = @asgnid and asgn_enddate > @ckc_date
		order by case when asgn_status = 'CMP' then 0 when asgn_status = 'STD' then 1 when asgn_status = 'DSP' then 2 else 3 end, asgn_enddate;

	if isnull(@lgh_number, 0) = 0
		select top 1 @lgh_number = lgh_number from assetassignment
			where asgn_type = @asgntype and asgn_id = @asgnid
			order by asgn_enddate desc;

	select @ordNumber = null;
	if @lgh_number > 0
		select @ordNumber = ord_hdrnumber from legheader where lgh_number = @lgh_number;
	RETURN(@ordNumber);
END;
GO
GRANT EXECUTE ON  [dbo].[GetOrdHdrForAssetAndDate] TO [public]
GO
