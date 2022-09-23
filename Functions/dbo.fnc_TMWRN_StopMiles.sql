SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_StopMiles]
(
	@StopNumber int = Null,
	@MileageForZeroLegHeader int = 0,
	@LoadStatus varchar(255)='ALL',
	@StopStatusList varchar(255) = ''
)

RETURNS int
AS
BEGIN


SELECT @StopStatusList = Case When Left(@StopStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@StopStatusList, ''))) + ',' Else @StopStatusList End

Declare @StopMiles int

		  Select @StopMiles = IsNull(stp_lgh_mileage,0)
		  From Stops (NOLOCK)
		  where 
			stops.stp_number=@StopNumber
			And
			 (
			  (@LoadStatus = 'ALL')
        		   Or
			   (@LoadStatus = 'LD' And stops.stp_loadstatus = 'LD')
		           Or
			   (@LoadStatus = 'MT' And stops.stp_loadstatus <> 'LD')
			  )
			 And
			 (@StopStatusList = ',,' OR CHARINDEX(',' + RTRIM( stp_status ) + ',', @StopStatusList) > 0)  	
		
	

Return @StopMiles


END

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_StopMiles] TO [public]
GO
