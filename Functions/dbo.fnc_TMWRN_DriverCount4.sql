SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*  sample call
Select * from dbo.fnc_TMWRN_DriverCount3 (@Mode,@OnlyDrvType1List,@OnlyDrvType2List,@OnlyDrvType3List
,@OnlyDrvType4List,@OnlyDrvCompanyList,@OnlyDrvDivisionList,@OnlyDrvTerminalList,@OnlyDrvFleetList
,@OnlyDrvBranchList,@OnlyDrvDomicileList,@OnlyDrvTeamLeaderList,@ExcludeDrvType1List,@ExcludeDrvType2List
,@ExcludeDrvType3List,@ExcludeDrvType4List,@ExcludeDrvCompanyList,@ExcludeTrcDivisionList,@ExcludeDrvTerminalList
,@ExcludeDrvFleetList,@ExcludeDrvBranchList,@ExcludeDrvDomicileList,@ExcludeDrvTeamLeaderList,@DriverCountDate)
*/

CREATE FUNCTION [dbo].[fnc_TMWRN_DriverCount4] 
	( 
		@Mode varchar(25) = 'Bloqueados', -- Current, Total, OOS, Historical, Bloqueados
		@OnlyDrvType1List varchar(255) = '',
		@OnlyDrvType2List varchar(255) = '',
		@OnlyDrvType3List varchar(255) = '',
		@OnlyDrvType4List varchar(255) = '',
		@OnlyDrvCompanyList varchar(255) = '',
		@OnlyDrvDivisionList varchar(255) = '',
		@OnlyDrvTerminalList varchar(255) = '',
		@OnlyDrvFleetList varchar(255) = '',
		@OnlyDrvBranchList varchar(255) = '' ,
		@OnlyDrvDomicileList varchar(255) = '',
		@OnlyDrvTeamLeaderList varchar(255) = '',
		@ExcludeDrvType1List varchar(255)='', 
		@ExcludeDrvType2List varchar(255)='', 
		@ExcludeDrvType3List varchar(255)='', 
		@ExcludeDrvType4List varchar(255)='', 
		@ExcludeDrvCompanyList varchar(255)='',
		@ExcludeDrvDivisionList varchar(255)='',
		@ExcludeDrvTerminalList varchar(255)='',
		@ExcludeDrvFleetList varchar(255)='',
		@ExcludeDrvBranchList varchar(255)='',
		@ExcludeDrvDomicileList varchar(255) = '',
		@ExcludeDrvTeamLeaderList varchar(255) = '',
		@DriverCountDate datetime
	) 

Returns @DriverList TABLE 
	(
		Driver varchar(8)
	)
As 
Begin 

	SELECT @OnlyDrvType1List = Case When Left(@OnlyDrvType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType1List, ''))) + ',' Else @OnlyDrvType1List End
	SELECT @OnlyDrvType2List = Case When Left(@OnlyDrvType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType2List, ''))) + ',' Else @OnlyDrvType2List End
	SELECT @OnlyDrvType3List = Case When Left(@OnlyDrvType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType3List, ''))) + ',' Else @OnlyDrvType3List End
	SELECT @OnlyDrvType4List = Case When Left(@OnlyDrvType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType4List, ''))) + ',' Else @OnlyDrvType4List End

	SELECT @OnlyDrvCompanyList = Case When Left(@OnlyDrvCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvCompanyList, ''))) + ',' Else @OnlyDrvCompanyList End
	SELECT @OnlyDrvDivisionList = Case When Left(@OnlyDrvDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDivisionList, ''))) + ',' Else @OnlyDrvDivisionList End
	SELECT @OnlyDrvTerminalList = Case When Left(@OnlyDrvTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTerminalList, ''))) + ',' Else @OnlyDrvTerminalList End
	SELECT @OnlyDrvFleetList = Case When Left(@OnlyDrvFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvFleetList, ''))) + ',' Else @OnlyDrvFleetList End
	SELECT @OnlyDrvBranchList = Case When Left(@OnlyDrvBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvBranchList, ''))) + ',' Else @OnlyDrvBranchList End
	SELECT @OnlyDrvDomicileList = Case When Left(@OnlyDrvDomicileList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDomicileList, ''))) + ',' Else @OnlyDrvDomicileList End
	SELECT @OnlyDrvTeamleaderList = Case When Left(@OnlyDrvTeamleaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTeamleaderList, ''))) + ',' Else @OnlyDrvTeamleaderList End

	SELECT @ExcludeDrvType1List = Case When Left(@ExcludeDrvType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvType1List, ''))) + ',' Else @ExcludeDrvType1List End
	SELECT @ExcludeDrvType2List = Case When Left(@ExcludeDrvType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvType2List, ''))) + ',' Else @ExcludeDrvType2List End
	SELECT @ExcludeDrvType3List = Case When Left(@ExcludeDrvType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvType3List, ''))) + ',' Else @ExcludeDrvType3List End
	SELECT @ExcludeDrvType4List = Case When Left(@ExcludeDrvType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvType4List, ''))) + ',' Else @ExcludeDrvType4List End

	SELECT @ExcludeDrvCompanyList = Case When Left(@ExcludeDrvCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvCompanyList, ''))) + ',' Else @ExcludeDrvCompanyList End
	SELECT @ExcludeDrvDivisionList = Case When Left(@ExcludeDrvDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDivisionList, ''))) + ',' Else @ExcludeDrvDivisionList End
	SELECT @ExcludeDrvTerminalList = Case When Left(@ExcludeDrvTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvTerminalList, ''))) + ',' Else @ExcludeDrvTerminalList End
	SELECT @ExcludeDrvFleetList = Case When Left(@ExcludeDrvFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvFleetList, ''))) + ',' Else @ExcludeDrvFleetList End
	SELECT @ExcludeDrvBranchList = Case When Left(@ExcludeDrvBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvBranchList, ''))) + ',' Else @ExcludeDrvBranchList End
	SELECT @ExcludeDrvDomicileList = Case When Left(@ExcludeDrvDomicileList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDomicileList, ''))) + ',' Else @ExcludeDrvDomicileList End
	SELECT @ExcludeDrvTeamleaderList = Case When Left(@ExcludeDrvTeamleaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvTeamleaderList, ''))) + ',' Else @ExcludeDrvTeamleaderList End

	Declare @DriverExpirations TABLE (Driver varchar(8))

	Insert into @DriverExpirations (Driver)
		Select exp_id
		FROM expiration WITH (NOLOCK) 
		WHERE exp_idtype = 'DRV' 
		AND exp_priority = '1' 
        AND exp_code = 'HOME'
		AND (exp_compldate >= @DriverCountDate And exp_expirationdate <= @DriverCountDate)

	If @Mode = 'OOS'
		Begin
			INSERT into @DriverList (Driver)
				Select distinct Driver
				From @DriverExpirations TE join ResNow_DriverCache_Final RNDCF on TE.Driver = RNDCF.Driver_ID
				Where (@DriverCountDate >= Driver_DateStart AND @DriverCountDate < Driver_DateEnd) 
				AND Driver_TerminationDate > @DriverCountDate
		End
	Else If @Mode = 'Bloqueados'	-- consider expirations
		BEGIN
			INSERT @DriverList (Driver)
				Select driver_id 
				FROM   ResNow_DriverCache_Final RNDCF (NOLOCK) 
				Where (Driver_TerminationDate > @DriverCountDate AND driver_hiredate <= @DriverCountDate) 
				AND (@DriverCountDate >= Driver_DateStart AND @DriverCountDate < Driver_DateEnd) 
				AND driver_id <> 'UNKNOWN'
				And  Exists (select Driver from @DriverExpirations DE where RNDCF.driver_id = DE.Driver)
				-- include filters
				AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @OnlyDrvType1List) > 0) 
        		AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @OnlyDrvType2List) > 0) 
        		AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @OnlyDrvType3List) > 0) 
        		AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @OnlyDrvType4List) > 0) 
				AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @OnlyDrvCompanyList) > 0) 
        		AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @OnlyDrvDivisionList) > 0) 
        		AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @OnlyDrvTerminalList) > 0) 
        		AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @OnlyDrvFleetList) > 0) 
				And (@OnlyDrvBranchList =',,' or CHARINDEX(',' + driver_branch + ',', @OnlyDrvBranchList) >0)
        		AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @OnlyDrvDomicileList) > 0) 
        		AND (@OnlyDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @OnlyDrvTeamLeaderList) > 0) 
				-- exclude filters
				AND (@ExcludeDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @ExcludeDrvType1List) = 0) 
        		AND (@ExcludeDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @ExcludeDrvType2List) = 0) 
        		AND (@ExcludeDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @ExcludeDrvType3List) = 0) 
        		AND (@ExcludeDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @ExcludeDrvType4List) = 0) 
				AND (@ExcludeDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @ExcludeDrvCompanyList) = 0) 
        		AND (@ExcludeDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @ExcludeDrvDivisionList) = 0) 
        		AND (@ExcludeDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @ExcludeDrvTerminalList) = 0) 
        		AND (@ExcludeDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @ExcludeDrvFleetList) = 0) 
				And (@ExcludeDrvBranchList =',,' or (CHARINDEX(',' + driver_branch + ',', @ExcludeDrvBranchList) = 0))
        		AND (@ExcludeDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @ExcludeDrvDomicileList) = 0) 
        		AND (@ExcludeDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0) 
		END
	Else If @Mode = 'Total'	-- do NOT consider expirations
		BEGIN
			INSERT @DriverList (Driver)
				Select driver_id 
				FROM   ResNow_DriverCache_Final RNDCF (NOLOCK) 
				Where (driver_terminationdate > @DriverCountDate AND driver_hiredate <= @DriverCountDate) 
				AND (@DriverCountDate >= Driver_DateStart AND @DriverCountDate < Driver_DateEnd) 
				AND driver_id <> 'UNKNOWN'
				-- include filters
				AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @OnlyDrvType1List) > 0) 
        		AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @OnlyDrvType2List) > 0) 
        		AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @OnlyDrvType3List) > 0) 
        		AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @OnlyDrvType4List) > 0) 
				AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @OnlyDrvCompanyList) > 0) 
        		AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @OnlyDrvDivisionList) > 0) 
        		AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @OnlyDrvTerminalList) > 0) 
        		AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @OnlyDrvFleetList) > 0) 
				And (@OnlyDrvBranchList =',,' or CHARINDEX(',' + driver_branch + ',', @OnlyDrvBranchList) >0)
        		AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @OnlyDrvDomicileList) > 0) 
        		AND (@OnlyDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @OnlyDrvTeamLeaderList) > 0) 
				-- exclude filters
				AND (@ExcludeDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @ExcludeDrvType1List) = 0) 
        		AND (@ExcludeDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @ExcludeDrvType2List) = 0) 
        		AND (@ExcludeDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @ExcludeDrvType3List) = 0) 
        		AND (@ExcludeDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @ExcludeDrvType4List) = 0) 
				AND (@ExcludeDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @ExcludeDrvCompanyList) = 0) 
        		AND (@ExcludeDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @ExcludeDrvDivisionList) = 0) 
        		AND (@ExcludeDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @ExcludeDrvTerminalList) = 0) 
        		AND (@ExcludeDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @ExcludeDrvFleetList) = 0) 
				And (@ExcludeDrvBranchList =',,' or (CHARINDEX(',' + driver_branch + ',', @ExcludeDrvBranchList) = 0))
        		AND (@ExcludeDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @ExcludeDrvDomicileList) = 0) 
        		AND (@ExcludeDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0) 
		END
	Else If @Mode = 'Historical'	-- ALL drivers from whenever
		BEGIN
			INSERT @DriverList (Driver)
				Select distinct driver_id 
				FROM   ResNow_DriverCache_Final RNDCF (NOLOCK) 
				Where driver_id <> 'UNKNOWN'
				-- include filters
				AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @OnlyDrvType1List) > 0) 
        		AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @OnlyDrvType2List) > 0) 
        		AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @OnlyDrvType3List) > 0) 
        		AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @OnlyDrvType4List) > 0) 
				AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @OnlyDrvCompanyList) > 0) 
        		AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @OnlyDrvDivisionList) > 0) 
        		AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @OnlyDrvTerminalList) > 0) 
        		AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @OnlyDrvFleetList) > 0) 
				And (@OnlyDrvBranchList =',,' or CHARINDEX(',' + driver_branch + ',', @OnlyDrvBranchList) >0)
        		AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @OnlyDrvDomicileList) > 0) 
        		AND (@OnlyDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @OnlyDrvTeamLeaderList) > 0) 
				-- exclude filters
				AND (@ExcludeDrvType1List =',,' OR CHARINDEX(',' + driver_Type1 + ',', @ExcludeDrvType1List) = 0) 
        		AND (@ExcludeDrvType2List =',,' OR CHARINDEX(',' + driver_Type2 + ',', @ExcludeDrvType2List) = 0) 
        		AND (@ExcludeDrvType3List =',,' OR CHARINDEX(',' + driver_Type3 + ',', @ExcludeDrvType3List) = 0) 
        		AND (@ExcludeDrvType4List =',,' OR CHARINDEX(',' + driver_Type4 + ',', @ExcludeDrvType4List) = 0) 
				AND (@ExcludeDrvCompanyList =',,' OR CHARINDEX(',' + driver_company + ',', @ExcludeDrvCompanyList) = 0) 
        		AND (@ExcludeDrvDivisionList =',,' OR CHARINDEX(',' + driver_division + ',', @ExcludeDrvDivisionList) = 0) 
        		AND (@ExcludeDrvTerminalList =',,' OR CHARINDEX(',' + driver_terminal + ',', @ExcludeDrvTerminalList) = 0) 
        		AND (@ExcludeDrvFleetList =',,' OR CHARINDEX(',' + driver_fleet + ',', @ExcludeDrvFleetList) = 0) 
				And (@ExcludeDrvBranchList =',,' or (CHARINDEX(',' + driver_branch + ',', @ExcludeDrvBranchList) = 0))
        		AND (@ExcludeDrvDomicileList =',,' OR CHARINDEX(',' + driver_domicile + ',', @ExcludeDrvDomicileList) = 0) 
        		AND (@ExcludeDrvTeamLeaderList =',,' OR CHARINDEX(',' + driver_teamleader + ',', @ExcludeDrvTeamLeaderList) = 0) 
		END


		
	RETURN 
                   
End 

GO
