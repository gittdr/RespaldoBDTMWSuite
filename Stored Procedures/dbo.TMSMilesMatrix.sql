SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[TMSMilesMatrix](@batchId int, @lookupType varchar(1), @mileageBucket int)
as 
Begin

if @lookupType = 'L'
 exec TMSLatLongMilesMatrix @batchId,@mileageBucket
 
else if @lookupType = 'C'
 exec TMSCityMilesMatrix @batchID,@mileageBucket
 
else 
exec TMSZipMilesMatrix @batchID,@mileageBucket

End
GO
GRANT EXECUTE ON  [dbo].[TMSMilesMatrix] TO [public]
GO
