SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Function [dbo].[fnc_TMWRN_TractorCount] 
( 
				@EnteredTractorCount int = 0,
				@OnlyTrcClass1List varchar(255) = '',
				@OnlyTrcClass2List varchar(255) = '',
				@OnlyTrcClass3List varchar(255) = '',
				@OnlyTrcClass4List varchar(255) = '',
				@OnlyTrcTerminal varchar(255) = '' ,
				@ExcludeTractorType1 varchar(255)='', 
				@ExcludeTractorType2 varchar(255)='', 
				@ExcludeTractorType3 varchar(255)='', 
                @ExcludeTractorType4 varchar(255)='', 
                @ExcludeOutOfServiceTrucks char(1) = 'N',
				@OnlyMppType1List varchar(255) = '',
				@OnlyMppType2List varchar(255) = '',
				@OnlyMppType3List varchar(255) = '',
				@OnlyMppType4List varchar(255) = '',
				@OnlyRevClass1List varchar(255) = '', -- only significant when IncludeWorkingAssetsOnlyYN is Y or @Mode is Working
				@OnlyRevClass2List varchar(255) = '',
				@OnlyRevClass3List varchar(255) = '',
				@OnlyRevClass4List varchar(255) = '',
				@DateStart datetime,
				@DateEnd datetime,
			    @DateType varchar(200) = 'Delivery',
			    @IncludeWorkingAssetsOnlyYN char(1) = 'N',
				@OnlyTeamLeaderList varchar(255) = '',
				@ExpirationCodeWhichMeanOffDuty varchar(255) = 'VAC,SIC,HOME',
				@Mode varchar(25) = '', --Seated, Working, OffDuty, OOS, Unseated, Total
				@OnlyTrcDivisionList varchar(255)='',
				@ExcludeTrcDivisionList varchar(255)='',
				@OnlyTractorNumberList varchar(255)=''
)
Returns int 
As 
Begin 

DECLARE @TractorCount INT
DECLARE @MetricTempIDs TABLE (
		MetricItem varchar(13)
	)


	IF @EnteredTractorCount > 0
		SET @TractorCount = @EnteredTractorCount 
	ELSE
		/* Reason for function fnc_TMWRN_TractorCount2_1 used here:
				TMW inadvenrtantly inserted a parameter into the middle of the parameter list for function [fnc_TMWRN_TractorCount2]
				Clients that used [fnc_TMWRN_TractorCount2] in custom procedures would break upon an upgrade.
				To preserve compatability, [fnc_TMWRN_TractorCount2] is no longer distributed by TMW,
					so that code that relies on [fnc_TMWRN_TractorCount2] will be preserved.
		*/
		SET @TractorCount =	(Select COUNT(*) FROM dbo.fnc_TMWRN_TractorCount2_1(@OnlyTrcClass1List, @OnlyTrcClass2List, @OnlyTrcClass3List, @OnlyTrcClass4List, @OnlyTrcTerminal, 
				'', -- @ExcludeTrcTerminal was added to fnc_TMWRN_TractorCount2_1
				@ExcludeTractorType1, @ExcludeTractorType2, @ExcludeTractorType3, @ExcludeTractorType4, @ExcludeOutOfServiceTrucks, @OnlyMppType1List, @OnlyMppType2List, @OnlyMppType3List, @OnlyMppType4List, @OnlyRevClass1List,  @OnlyRevClass2List, @OnlyRevClass3List, @OnlyRevClass4List, @DateStart, @DateEnd, @DateType, @IncludeWorkingAssetsOnlyYN, @OnlyTeamLeaderList, @ExpirationCodeWhichMeanOffDuty, @Mode,@OnlyTrcDivisionList,@ExcludeTrcDivisionList,@OnlyTractorNumberList))

    Return @TractorCount 
END



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_TractorCount] TO [public]
GO
