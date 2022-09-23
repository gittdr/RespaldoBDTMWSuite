SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_DriverCount] ( 
				@EnteredDrvCount int = 0,
				@DateType varchar(255) = 'Active', -- Active
				@DateStart datetime,
				@DateEnd datetime,
				@OnlyDrvFleetList varchar(255) = '' ,
				@OnlyDrvDivisionList varchar(255) = '',
				@OnlyDrvDomicileList varchar(255)='',
				@OnlyDrvCompanyList varchar(255) ='',
				@OnlyDrvTerminalList varchar(255) = '',
				@OnlyDrvStatusList varchar(255)= '',
				@ExcludeDrvFleetList varchar(255) = '',
				@ExcludeDrvDivisionList varchar(255) = '',
				@ExcludeDrvDomicileList varchar(255) = '',
				@ExcludeDrvCompanyList varchar(255) = '',
				@ExcludeDrvTerminalList varchar(255) = '',
				@ExcludeDrvStatusList varchar(255) = '',
				@OnlyMppType1List varchar(255) = '',
				@OnlyMppType2List varchar(255) = '',
				@OnlyMppType3List varchar(255) = '',
				@OnlyMppType4List varchar(255) = '',
				@OnlyRevClass1List varchar(255) = '', -- only significant when IncludeWorkingAssetsOnlyYN is Y or @Mode is Working
				@OnlyRevClass2List varchar(255) = '',	
				@OnlyRevClass3List varchar(255) = '',	
				@OnlyRevClass4List varchar(255) = '',
				@OnlyTeamLeaderList varchar(255) = '',
				@ExcludeTeamLeaderList varchar(255)='',
				@IncludeWorkingAssetsOnlyYN char(1) = 'N',
				@OnlyDriverID varchar(255)=''
								
                              ) 
RETURNS INT 
AS 
BEGIN 

    DECLARE @DrvCount AS INT 
	
DECLARE @TractorCount INT
DECLARE @MetricTempIDs TABLE (
		MetricItem varchar(13)
	)


	IF @EnteredDrvCount > 0
		SET @DrvCount = @EnteredDrvCount 
	ELSE
		SET @DrvCount =	(Select COUNT(*) FROM dbo.fnc_TMWRN_DriverCount2(@DateType, @DateStart, @DateEnd, @OnlyDrvFleetList, @OnlyDrvDivisionList, @OnlyDrvDomicileList, @OnlyDrvCompanyList, @OnlyDrvTerminalList, @OnlyDrvStatusList, @ExcludeDrvFleetList, @ExcludeDrvDivisionList, @ExcludeDrvDomicileList, @ExcludeDrvCompanyList, @ExcludeDrvTerminalList, @ExcludeDrvStatusList, @OnlyMppType1List, @OnlyMppType2List, @OnlyMppType3List, @OnlyMppType4List, @OnlyRevClass1List, @OnlyRevClass2List, @OnlyRevClass3List, @OnlyRevClass4List, @OnlyTeamLeaderList, @ExcludeTeamLeaderList, @IncludeWorkingAssetsOnlyYN, @OnlyDriverID))

		
RETURN @DrvCount    
                   
End 

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_DriverCount] TO [public]
GO
