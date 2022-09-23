SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_DriverCount2] ( 
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
Returns @MetricTempIDs TABLE (
		MetricItem varchar(13)
	)
AS 
BEGIN 

	SELECT @OnlyDrvFleetList = Case When Left(@OnlyDrvFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvFleetList, ''))) + ',' Else @OnlyDrvFleetList End
	SELECT @OnlyDrvDivisionList = Case When Left(@OnlyDrvDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDivisionList, ''))) + ',' Else @OnlyDrvDivisionList End
	SELECT @OnlyDrvDomicileList = Case When Left(@OnlyDrvDomicileList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDomicileList, ''))) + ',' Else @OnlyDrvDomicileList End
	SELECT @OnlyDrvCompanyList = Case When Left(@OnlyDrvCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvCompanyList, ''))) + ',' Else @OnlyDrvCompanyList End
	SELECT @OnlyDrvTerminalList = Case When Left(@OnlyDrvTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTerminalList, ''))) + ',' Else @OnlyDrvTerminalList End
	SELECT @OnlyDrvStatusList = Case When Left(@OnlyDrvStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvStatusList, ''))) + ',' Else @OnlyDrvStatusList End

	SELECT @ExcludeDrvFleetList = Case When Left(@ExcludeDrvFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvFleetList, ''))) + ',' Else @ExcludeDrvFleetList End
	SELECT @ExcludeDrvDivisionList = Case When Left(@ExcludeDrvDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDivisionList, ''))) + ',' Else @ExcludeDrvDivisionList End
	SELECT @ExcludeDrvDomicileList = Case When Left(@ExcludeDrvDomicileList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDomicileList, ''))) + ',' Else @ExcludeDrvDomicileList End
	SELECT @ExcludeDrvCompanyList = Case When Left(@ExcludeDrvCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvCompanyList, ''))) + ',' Else @ExcludeDrvCompanyList End
	SELECT @ExcludeDrvTerminalList = Case When Left(@ExcludeDrvTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvTerminalList, ''))) + ',' Else @ExcludeDrvTerminalList End
	SELECT @ExcludeDrvStatusList = Case When Left(@ExcludeDrvStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvStatusList, ''))) + ',' Else @ExcludeDrvStatusList End
	

	SELECT @OnlyMppType1List = Case When Left(@OnlyMppType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType1List, ''))) + ',' Else @OnlyMppType1List End
	SELECT @OnlyMppType2List = Case When Left(@OnlyMppType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType2List, ''))) + ',' Else @OnlyMppType2List End
	SELECT @OnlyMppType3List = Case When Left(@OnlyMppType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType3List, ''))) + ',' Else @OnlyMppType3List End
	SELECT @OnlyMppType4List = Case When Left(@OnlyMppType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType4List, ''))) + ',' Else @OnlyMppType4List End

	SELECT @OnlyTeamLeaderList = Case When Left(@OnlyTeamLeaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTeamLeaderList, ''))) + ',' Else @OnlyTeamLeaderList End
	SELECT @ExcludeTeamLeaderList = Case When Left(@ExcludeTeamLeaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTeamLeaderList, ''))) + ',' Else @ExcludeTeamLeaderList End

	SELECT @OnlyRevClass1List = Case When Left(@OnlyRevClass1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass1List, ''))) + ',' Else @OnlyRevClass1List End
	SELECT @OnlyRevClass2List = Case When Left(@OnlyRevClass2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass2List, ''))) + ',' Else @OnlyRevClass2List End
	SELECT @OnlyRevClass3List = Case When Left(@OnlyRevClass3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass3List, ''))) + ',' Else @OnlyRevClass3List End
	SELECT @OnlyRevClass4List = Case When Left(@OnlyRevClass4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass4List, ''))) + ',' Else @OnlyRevClass4List End
	
	SELECT @OnlyDriverID = Case When Left(@OnlyDriverID,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDriverID, ''))) + ',' Else @OnlyDriverID End

	IF @datetype = 'Active'
		BEGIN
			INSERT @MetricTempIDs -- @DrvCount = COUNT(*)
			Select mpp_id
			FROM 	manpowerprofile m (NOLOCK)
			WHERE	(m.mpp_terminationdt>= @DateStart AND m.mpp_hiredate < @DateEnd) 
	    And (	(	
					@IncludeWorkingAssetsOnlyYN = 'N' 
					AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
					AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
					AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
					AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
					AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
					AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
       				
					AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
					AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
					AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
					AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
					AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
					AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
       				
					AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
				
					AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
					AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)
		    	)
					Or 	
				(
					@IncludeWorkingAssetsOnlyYN = 'Y' 
			    		and
			      	mpp_id = 	(	
										Select top 1 lgh_Driver1
									    From legheader (NOLOCK)
									    Where LGH_OUTSTATUS In ('STD','CMP')
										AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
										AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
										AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
										AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
										AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
										AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
					       				
										AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
										AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
										AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
										AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
										AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
										AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
					       				
										AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			                        	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			                        	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			                        	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
									
										AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
										AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)

							 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
			       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

										And lgh_Driver1 = mpp_id
					     				And lgh_enddate >= @DateStart and lgh_enddate < @DateEnd
				      				)
			   ) )

		END

	IF @datetype = 'Termination'
		BEGIN
			INSERT @MetricTempIDs -- @DrvCount = COUNT(*)
			Select mpp_id
        	FROM   manpowerprofile m (NOLOCK) 
			WHERE	(m.mpp_terminationdt>= @DateStart AND m.mpp_terminationdt < @DateEnd) 
					AND (@OnlyDriverID =',,' OR CHARINDEX(',' + RTRIM( m.mpp_id ) + ',', @OnlyDriverID) >0)
				And (	(	
					@IncludeWorkingAssetsOnlyYN = 'N' 
					AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
					AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
					AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
					AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
					AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
					AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
       				
					AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
					AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
					AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
					AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
					AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
					AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
       				
					AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
				
					AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
					AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)
		    	)
					Or 	
				(
					@IncludeWorkingAssetsOnlyYN = 'Y' 
			    		and
			      	mpp_id = 	(	
										Select top 1 lgh_Driver1
									    From legheader (NOLOCK)
									    Where LGH_OUTSTATUS In ('STD','CMP')
										AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
										AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
										AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
										AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
										AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
										AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
					       				
										AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
										AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
										AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
										AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
										AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
										AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
					       				
										AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			                        	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			                        	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			                        	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
									
										AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
										AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)

							 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
			       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

					     				And lgh_Driver1 = mpp_id
					     				And lgh_enddate >= @DateStart and lgh_enddate < @DateEnd
				      				)
			   ) )

		END
	
	ELSE IF @datetype = 'Expiration'
		BEGIN
			INSERT @MetricTempIDs -- @DrvCount = COUNT(*)
			Select mpp_id
        	FROM   manpowerprofile m (NOLOCK), expiration e (NOLOCK) 
			WHERE	m.mpp_id = e.exp_id
					AND e.exp_idtype = 'DRV'
					AND e.exp_expirationdate >= @DateStart AND e.exp_expirationdate < @DateEnd
				    And (	(	
						@IncludeWorkingAssetsOnlyYN = 'N' 
						AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
						AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
						AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
						AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
						AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
						AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
	       				
						AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
						AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
						AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
						AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
						AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
						AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
	       				
						AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                    	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                    	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                    	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
					
						AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
						AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)
			    	)
						Or 	
					(
						@IncludeWorkingAssetsOnlyYN = 'Y' 
				    		and
				      	mpp_id = 	(	
											Select top 1 lgh_Driver1
										    From legheader (NOLOCK)
										    Where LGH_OUTSTATUS In ('STD','CMP')
											AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
											AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
											AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
											AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
											AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
											AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
						       				
											AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
											AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
											AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
											AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
											AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
											AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
						       				
											AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
				                        	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
				                        	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
				                        	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
										
											AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
											AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)

								 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
				       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
				       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
				      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

						     				And lgh_Driver1 = mpp_id
						     				And lgh_enddate >= @DateStart and lgh_enddate < @DateEnd
					      				)
				   ) )


		END

	ELSE IF @datetype = 'Hire'
		BEGIN
			INSERT @MetricTempIDs -- @DrvCount = COUNT(*)
			Select mpp_id
        	FROM   manpowerprofile m (NOLOCK) 
			WHERE	(m.mpp_hiredate>= @DateStart AND m.mpp_hiredate < @DateEnd) 
	    And (	(	
					@IncludeWorkingAssetsOnlyYN = 'N' 
					AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
					AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
					AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
					AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
					AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
					AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
       				
					AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
					AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
					AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
					AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
					AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
					AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
       				
					AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
				
					AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
					AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)
		    	)
					Or 	
				(
					@IncludeWorkingAssetsOnlyYN = 'Y' 
			    		and
			      	mpp_id = 	(	
										Select top 1 lgh_Driver1
									    From legheader (NOLOCK)
									    Where LGH_OUTSTATUS In ('STD','CMP')
										AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
										AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
										AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
										AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
										AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
										AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
					       				
										AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
										AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
										AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
										AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
										AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
										AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
					       				
										AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			                        	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			                        	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			                        	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
									
										AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
										AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)

							 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
			       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

					     				And lgh_Driver1 = mpp_id
					     				And lgh_enddate >= @DateStart and lgh_enddate < @DateEnd
				      				)
			   ) )


		END			

	ELSE IF @datetype = 'Seniority'
		BEGIN
			INSERT @MetricTempIDs -- @DrvCount = COUNT(*)
			Select mpp_id
        	FROM   manpowerprofile m (NOLOCK) 
			WHERE	(m.mpp_senioritydate>= @DateStart AND m.mpp_senioritydate < @DateEnd) 
	    And (	(	
					@IncludeWorkingAssetsOnlyYN = 'N' 
					AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
					AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
					AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
					AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
					AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
					AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
       				
					AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
					AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
					AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
					AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
					AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
					AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
       				
					AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
				
					AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
					AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)
		    	)
					Or 	
				(
					@IncludeWorkingAssetsOnlyYN = 'Y' 
			    		and
			      	mpp_id = 	(	
										Select top 1 lgh_Driver1
									    From legheader (NOLOCK)
									    Where LGH_OUTSTATUS In ('STD','CMP')
										AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
										AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivisionList) >0)
										AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
										AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompanyList) >0)
										AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
										AND (@OnlyDrvStatusList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @OnlyDrvStatusList) >0)
					       				
										AND (@ExcludeDrvFleetList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @ExcludeDrvFleetList) =0)
										AND (@ExcludeDrvDivisionList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @ExcludeDrvDivisionList) =0)
										AND (@ExcludeDrvDomicileList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @ExcludeDrvDomicileList) =0)
										AND (@ExcludeDrvCompanyList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @ExcludeDrvCompanyList) =0)
										AND (@ExcludeDrvTerminalList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @ExcludeDrvTerminalList) =0)
										AND (@ExcludeDrvStatusList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_status ) + ',', @ExcludeDrvStatusList) =0)
					       				
										AND (@OnlyMppType1List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			                        	AND (@OnlyMppType2List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			                        	AND (@OnlyMppType3List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			                        	AND (@OnlyMppType4List =',,' OR CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
									
										AND (@OnlyTeamLeaderList =',,' OR CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
										AND (@ExcludeTeamLeaderList =',,' OR NOT CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @ExcludeTeamLeaderList) =0)

							 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
			       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

					     				And lgh_Driver1 = mpp_id
					     				And lgh_enddate >= @DateStart and lgh_enddate < @DateEnd
				      				)
			   ) )

				
		END
		
RETURN 
                   
End 

GO
GRANT SELECT ON  [dbo].[fnc_TMWRN_DriverCount2] TO [public]
GO
