SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Function [dbo].[fnc_TMWRN_TractorCount2_1] 
( 
				@OnlyTrcClass1List varchar(255) = '',
				@OnlyTrcClass2List varchar(255) = '',
				@OnlyTrcClass3List varchar(255) = '',
				@OnlyTrcClass4List varchar(255) = '',
				@OnlyTrcTerminal varchar(255) = '' ,
				@ExcludeTrcTerminal varchar(255) = '' ,
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
 
Returns @MetricTempIDs TABLE (
		MetricItem varchar(13)
	)
As 
Begin 

	SELECT @ExcludeTractorType1 = Case When Left(@ExcludeTractorType1,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTractorType1, ''))) + ',' Else @ExcludeTractorType1 End
	SELECT @ExcludeTractorType2 = Case When Left(@ExcludeTractorType2,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTractorType2, ''))) + ',' Else @ExcludeTractorType2 End
	SELECT @ExcludeTractorType3 = Case When Left(@ExcludeTractorType3,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTractorType3, ''))) + ',' Else @ExcludeTractorType3 End
	SELECT @ExcludeTractorType4 = Case When Left(@ExcludeTractorType4,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTractorType4, ''))) + ',' Else @ExcludeTractorType4 End        

	SELECT @OnlyTrcClass1List = Case When Left(@OnlyTrcClass1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcClass1List, ''))) + ',' Else @OnlyTrcClass1List End
	SELECT @OnlyTrcClass2List = Case When Left(@OnlyTrcClass2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcClass2List, ''))) + ',' Else @OnlyTrcClass2List End
	SELECT @OnlyTrcClass3List = Case When Left(@OnlyTrcClass3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcClass3List, ''))) + ',' Else @OnlyTrcClass3List End
	SELECT @OnlyTrcClass4List = Case When Left(@OnlyTrcClass4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcClass4List, ''))) + ',' Else @OnlyTrcClass4List End
	
	SELECT @OnlyTrcDivisionList = Case When Left(@OnlyTrcDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcDivisionList, ''))) + ',' Else @OnlyTrcDivisionList End
	SELECT @ExcludeTrcDivisionList = Case When Left(@ExcludeTrcDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcDivisionList, ''))) + ',' Else @ExcludeTrcDivisionList End
	
	SELECT @OnlyTrcTerminal = Case When Left(@OnlyTrcTerminal,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcTerminal, ''))) + ',' Else @OnlyTrcTerminal End
	SELECT @ExcludeTrcTerminal = Case When Left(@ExcludeTrcTerminal,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcTerminal, ''))) + ',' Else @ExcludeTrcTerminal End
	
	SELECT @OnlyMppType1List = Case When Left(@OnlyMppType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType1List, ''))) + ',' Else @OnlyMppType1List End
	SELECT @OnlyMppType2List = Case When Left(@OnlyMppType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType2List, ''))) + ',' Else @OnlyMppType2List End
	SELECT @OnlyMppType3List = Case When Left(@OnlyMppType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType3List, ''))) + ',' Else @OnlyMppType3List End
	SELECT @OnlyMppType4List = Case When Left(@OnlyMppType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyMppType4List, ''))) + ',' Else @OnlyMppType4List End

	SELECT @OnlyTeamLeaderList = Case When Left(@OnlyTeamLeaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTeamLeaderList, ''))) + ',' Else @OnlyTeamLeaderList End

	SELECT @OnlyRevClass1List = Case When Left(@OnlyRevClass1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass1List, ''))) + ',' Else @OnlyRevClass1List End
	SELECT @OnlyRevClass2List = Case When Left(@OnlyRevClass2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass2List, ''))) + ',' Else @OnlyRevClass2List End
	SELECT @OnlyRevClass3List = Case When Left(@OnlyRevClass3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass3List, ''))) + ',' Else @OnlyRevClass3List End
	SELECT @OnlyRevClass4List = Case When Left(@OnlyRevClass4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyRevClass4List, ''))) + ',' Else @OnlyRevClass4List End

	SELECT @OnlyTractorNumberList = Case When Left(@OnlyTractorNumberList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTractorNumberList, ''))) + ',' Else @OnlyTractorNumberList End

	IF (@ExcludeOutOfServiceTrucks ='Y') and @Mode = ''
	Begin
		INSERT @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number 
        FROM   tractorProfile t (NOLOCK) 
			Left Join manpowerprofile m (NOLOCK) On m.mpp_id = t.trc_driver 
		Where (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <> 'UNKNOWN'
        	And trc_number NOT IN 	( 
	                					SELECT exp_id 
	                        			FROM expiration WITH (NOLOCK) 
	                        			WHERE exp_idtype='TRC' AND exp_priority = '1' 
	                                		AND (exp_compldate > @DateEnd And exp_expirationdate < @DateStart)
					    					AND NOT EXISTS	(	
																Select top 1 lgh_tractor
																From legheader (NOLOCK)
																Where LGH_OUTSTATUS In ('STD','CMP')
																	and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( lgh_tractor ) + ',', @OnlyTractorNumberList) >0)
																	AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
																    AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
																    And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
																    And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
																    And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
																    And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
																    And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
																	And (@ExcludeTrcTerminal =',,' or NOT CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)
														     		And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
														     		And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
														     		And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
														     		And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
														     		And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
															     	And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
															     	And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
															     	And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
																	And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
														 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
										       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
										       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
										      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
																	And lgh_tractor = exp_id
																	And (
																			(@DateType = 'Ship' and lgh_startdate >=@DateStart and lgh_startdate < @DateEnd)
																			Or
																			(@DateType = 'Delivery' and lgh_enddate >= @DateStart and lgh_enddate < @DateEnd)
														  					Or
																			(@DateType = 'Arrival' and legheader.lgh_number = (select min(stops.lgh_number) from stops (NOLOCK) where stp_arrivaldate >= @DateStart and stp_arrivaldate < @DateEnd and stops.lgh_number = legheader.lgh_number))
																		)
																	   
																)
									)
		    And (	(
						@IncludeWorkingAssetsOnlyYN = 'N' 
						and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0)
			     		and (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
		       	     	AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
		       	     	And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
		      	     	And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
		       	     	And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
						And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
						And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
						And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)
			     		And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			     		And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			     		And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			     		And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			     		And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                        And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                        And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                        And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
						And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
			    	)
						Or 	
					(
						@IncludeWorkingAssetsOnlyYN = 'Y' 
				    		and
				      	trc_number = 	(	
											Select top 1 lgh_tractor
										    From legheader (NOLOCK)
										    Where LGH_OUTSTATUS In ('STD','CMP')
												and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( lgh_tractor ) + ',', @OnlyTractorNumberList) >0)
						     					AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
			       	     		     			AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
			       	     		     			And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
			      	     		     			And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
			       	     		     			And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
												And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
			       	     						And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     			
												And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
				     		     				And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
				     		     				And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
				     		     				And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
				     		     				And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
				     		     				And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                               	     		    And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                               	     		    And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                               	     		    And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
												And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
									 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
					       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
					       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
					      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
						     					And lgh_tractor = trc_number
						     					And (
							   							(@DateType = 'Ship' and lgh_startdate >=@DateStart and lgh_startdate < @DateEnd)
							   								Or
							   							(@DateType = 'Delivery' and lgh_enddate >= @DateStart and lgh_enddate < @DateEnd)
						          							Or
							   							(@DateType = 'Arrival' and legheader.lgh_number = (select min(stops.lgh_number) from stops (NOLOCK) where stp_arrivaldate >= @DateStart and stp_arrivaldate < @DateEnd and stops.lgh_number = legheader.lgh_number))
						     						)
						     
						    
					      				)
				   )
				)
	End
	Else IF (@ExcludeOutOfServiceTrucks <>'Y') and @Mode = ''--Must Include Out Of Service Trucks 
	Begin


		Insert @MetricTempIDs
		Select trc_number
        FROM   tractorProfile t (NOLOCK) 
			Left Join manpowerprofile m (NOLOCK) On m.mpp_id = t.trc_driver 
		Where (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <> 'UNKNOWN'
        	And (	(
						@IncludeWorkingAssetsOnlyYN = 'N' 
						
						and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0)
			     		and (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
		       	     	AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
		       	     	And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
		      	     	And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
		       	     	And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
						And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
		       	     	And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
						And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     						     		
						And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			     		And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			     		And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			     		And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			    		And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                        And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                        And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                        And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
						And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
			    	)
			    	Or 
			   		(
						@IncludeWorkingAssetsOnlyYN = 'Y' 
			    		and trc_number = 	(
												Select top 1 lgh_tractor
											    From legheader (NOLOCK)
											    Where LGH_OUTSTATUS In ('STD','CMP')
												and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( lgh_tractor ) + ',', @OnlyTractorNumberList) >0)
						 						And (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
		       	     			 				AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
		       	     			 				And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
		      	     			 				And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
		       	     			 				And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
												And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
		       	     			 				And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
												And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     						     			 					
												And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			     			 					And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			     			 					And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			     			 					And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			     			 					And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                           	     				And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
                           	     		        And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                           	     		     	And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
												And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
									 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
					       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
					       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
					      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
					     	 					And lgh_tractor = trc_number
					         					And (
						   								(@DateType = 'Ship' and lgh_startdate >=@DateStart and lgh_startdate < @DateEnd)
						   									Or
						   								(@DateType = 'Delivery' and lgh_enddate >= @DateStart and lgh_enddate < @DateEnd)
					           								Or
						   								(@DateType = 'Arrival' and legheader.lgh_number = (select min(stops.lgh_number) from stops (NOLOCK) where stp_arrivaldate >= @DateStart and stp_arrivaldate < @DateEnd and stops.lgh_number = legheader.lgh_number))
					        						)
				     						)
			   	)
	
			)
	End
	ELSE -- Mode must be set
	IF @Mode = 'OOS'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
        FROM   tractorProfile t (NOLOCK) 
			Left Join manpowerprofile m (NOLOCK) On m.mpp_id = t.trc_driver 
		Where (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <>'UNKNOWN'
        	And trc_number IN 	( 
	                				SELECT exp_id 
	                        		FROM expiration WITH (NOLOCK) 
	                        		WHERE exp_idtype='TRC' AND exp_priority = '1' 
	                                	AND (exp_compldate > @DateEnd And exp_expirationdate < @DateStart)
					    				AND NOT EXISTS	(	
															Select top 1 lgh_tractor
															From legheader (NOLOCK)
															Where LGH_OUTSTATUS In ('STD','CMP')
																and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( lgh_tractor ) + ',', @OnlyTractorNumberList) >0)
																AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
															    AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
															    And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
															    And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
															    And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
																And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
															    And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
																And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     																	    	
																And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
														    	And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
														    	And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
														    	And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
														    	And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
															   	And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
															   	And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
															   	And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
																And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
													 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
									       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
									       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
									      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
																And lgh_tractor = exp_id
																And (
																		(@DateType = 'Ship' and lgh_startdate >=@DateStart and lgh_startdate < @DateEnd)
																		Or
																		(@DateType = 'Delivery' and lgh_enddate >= @DateStart and lgh_enddate < @DateEnd)
														  				Or
																		(@DateType = 'Arrival' and legheader.lgh_number = (select min(stops.lgh_number) from stops (NOLOCK) where stp_arrivaldate >= @DateStart and stp_arrivaldate < @DateEnd and stops.lgh_number = legheader.lgh_number))
																		)
																	   
																)
									)
	END
	ELSE IF @Mode = 'Seated'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
		from	tractorprofile Left Join manpowerprofile m (NOLOCK) On m.mpp_id = trc_driver 
		WHERE 	trc_driver not in ('UNKNOWN')
			AND trc_number <> 'UNKNOWN'
			AND (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0)
			AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
			AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
			And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
			And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
			And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
			And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
			And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
			And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     			
			And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
			And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 												
	END
	ELSE IF @Mode = 'Working'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
        FROM   tractorProfile t (NOLOCK) 
			Left Join manpowerprofile m (NOLOCK) On m.mpp_id = t.trc_driver 
		Where (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <> 'UNKNOWN'
        	And (trc_number = 	(
									Select top 1 lgh_tractor
									From legheader (NOLOCK)
									Where LGH_OUTSTATUS In ('STD','CMP')
									and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( lgh_tractor ) + ',', @OnlyTractorNumberList) >0)
						 			And (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
		       	     			 	AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
		       	     			 	And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
		      	     			 	And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
		       	     			 	And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
									And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
		       	     			 	And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
									And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     						     			 		
									And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			     			 		And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			     			 		And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			     			 		And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			     			 		And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
                           	     	And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
             	     				And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
                           	     	And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
									And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
						 			And (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
		       	     			 	AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2List) >0)
		       	     			 	And (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
		      	     			 	And (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

					     	 		And lgh_tractor = trc_number
					         		And (
						   					(@DateType = 'Ship' and lgh_startdate >=@DateStart and lgh_startdate < @DateEnd)
						   						Or
						   					(@DateType = 'Delivery' and lgh_enddate >= @DateStart and lgh_enddate < @DateEnd)
					           					Or
						   					(@DateType = 'Arrival' and legheader.lgh_number = (select min(stops.lgh_number) from stops (NOLOCK) where stp_arrivaldate >= @DateStart and stp_arrivaldate < @DateEnd and stops.lgh_number = legheader.lgh_number))
					        			)
				     			)
			   	)
	END
	ELSE IF @Mode = 'Unseated'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
		from	tractorprofile (NOLOCK) Left Join manpowerprofile m (NOLOCK) On m.mpp_id = trc_driver 
		WHERE 	trc_driver in ('UNKNOWN')
			AND trc_number <> 'UNKNOWN'
			AND (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0)
			AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
			AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
			And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
			And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
			And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
			And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
			And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
			And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     			
			And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
			And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
	END
	ELSE IF @Mode = 'AvailableToSeat'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
		from	tractorprofile (NOLOCK) Left Join manpowerprofile m (NOLOCK) On m.mpp_id = trc_driver 
		WHERE 	trc_driver in ('UNKNOWN')
			AND trc_number <> 'UNKNOWN'
			AND (trc_retiredate >= @DateStart AND trc_startdate < @DateStart)
			and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0) 
			AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
			AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
			And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
			And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
			And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
			And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
			And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
			And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     			
			And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
			And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
			And trc_number NOT IN 	( 
	                					SELECT exp_id 
	                        			FROM expiration WITH (NOLOCK) 
	                        			WHERE exp_idtype='TRC' AND exp_priority = '1' 
	                                		AND (exp_compldate > @DateEnd And exp_expirationdate < @DateStart)
									)
	END
	ELSE IF @Mode = 'OffDuty'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
        FROM   tractorProfile t (NOLOCK) 
			Left Join manpowerprofile m (NOLOCK) On m.mpp_id = t.trc_driver 
		Where (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <> 'UNKNOWN'
        	And trc_number IN 	( 
	                				SELECT exp_id 
	                        		FROM expiration WITH (NOLOCK) 
	                        		WHERE exp_idtype='TRC' AND exp_priority = '1' 
	                        			AND (@ExpirationCodeWhichMeanOffDuty =',,' or CHARINDEX(',' + RTRIM( exp_code ) + ',', @ExpirationCodeWhichMeanOffDuty) >0)		                        			
	                                	AND (exp_compldate > @DateEnd And exp_expirationdate < @DateStart)	
								)
	END
	ELSE IF @Mode = 'Total'
	BEGIN
		Insert @MetricTempIDs -- @TractorCount = Count(*) 
		Select trc_number
		from	tractorprofile (NOLOCK) Left Join manpowerprofile m (NOLOCK) On m.mpp_id = trc_driver 
		WHERE (trc_retiredate >= @DateStart AND trc_startdate < @DateStart) 
			AND trc_number <> 'UNKNOWN'
			and (@OnlyTractorNumberList =',,' or CHARINDEX(',' + RTRIM( trc_number ) + ',', @OnlyTractorNumberList) >0)
			AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
			AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
			And (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
			And (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
			And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @OnlyTrcDivisionList) >0)
			And (@ExcludeTrcDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( trc_division ) + ',', @ExcludeTrcDivisionList) >0)
			And (@OnlyTrcTerminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminal) >0)
			And (@ExcludeTrcTerminal =',,' or NOT  CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @ExcludeTrcTerminal) >0)     			
			And (@ExcludeTractorType1 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @ExcludeTractorType1) > 0))        
			And (@ExcludeTractorType2 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @ExcludeTractorType2) > 0))        
			And (@ExcludeTractorType3 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @ExcludeTractorType3) > 0))        
			And (@ExcludeTractorType4 = ',,' OR Not (CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @ExcludeTractorType4) > 0))        
			And (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0) 
			And (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0) 
			And (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0) 
			And (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0) 
			And (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( Mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
	END
    Return 
END

GO
GRANT SELECT ON  [dbo].[fnc_TMWRN_TractorCount2_1] TO [public]
GO
