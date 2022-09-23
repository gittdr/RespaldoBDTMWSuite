SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*  sample call
select * from dbo.fnc_TMWRN_TrailerCount3 (@Mode,@OnlyTrlType1List,@OnlyTrlType2List,@OnlyTrlType3List,@OnlyTrlType4List
,@OnlyTrlCompanyList,@OnlyTrlDivisionList,@OnlyTrlTerminalList,@OnlyTrlFleetList
,@ExcludeTrlType1List,@ExcludeTrlType2List,@ExcludeTrlType3List,@ExcludeTrlType4List
,@ExcludeTrlCompanyList,@ExcludeTrlDivisionList,@ExcludeTrlTerminalList,@ExcludeTrlFleetList,@TrailerCountDate)
*/

CREATE Function [dbo].[fnc_TMWRN_TrailerCount3]
	( 
		@Mode varchar(25)  = 'Current', -- Current, Total, Historical, OOS
		@OnlyTrlType1List varchar(255) = '',
		@OnlyTrlType2List varchar(255) = '',
		@OnlyTrlType3List varchar(255) = '',
		@OnlyTrlType4List varchar(255) = '',
		@OnlyTrlCompanyList varchar(255) = '' ,
		@OnlyTrlDivisionList varchar(255) = '' ,
		@OnlyTrlTerminalList varchar(255) = '' ,
		@OnlyTrlFleetList varchar(255) = '' ,
		@OnlyTrlBranchList varchar(255) = '' ,
		@ExcludeTrlType1List varchar(255)='', 
		@ExcludeTrlType2List varchar(255)='', 
		@ExcludeTrlType3List varchar(255)='', 
		@ExcludeTrlType4List varchar(255)='', 
		@ExcludeTrlCompanyList varchar(255)='',
		@ExcludeTrlDivisionList varchar(255)='',
		@ExcludeTrlTerminalList varchar(255)='',
		@ExcludeTrlFleetList varchar(255)='',
		@ExcludeTrlBranchList varchar(255)='',
		@TrailerCountDate datetime 
	)
 
Returns @TrailerList TABLE 
	(
		Trailer varchar(10)
	)
As 
Begin 


	SELECT @OnlyTrlType1List = Case When Left(@OnlyTrlType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlType1List, ''))) + ',' Else @OnlyTrlType1List End
	SELECT @OnlyTrlType2List = Case When Left(@OnlyTrlType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlType2List, ''))) + ',' Else @OnlyTrlType2List End
	SELECT @OnlyTrlType3List = Case When Left(@OnlyTrlType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlType3List, ''))) + ',' Else @OnlyTrlType3List End
	SELECT @OnlyTrlType4List = Case When Left(@OnlyTrlType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlType4List, ''))) + ',' Else @OnlyTrlType4List End
	SELECT @OnlyTrlCompanyList = Case When Left(@OnlyTrlCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlCompanyList, ''))) + ',' Else @OnlyTrlCompanyList End
	SELECT @OnlyTrlDivisionList = Case When Left(@OnlyTrlDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlDivisionList, ''))) + ',' Else @OnlyTrlDivisionList End
	SELECT @OnlyTrlTerminalList = Case When Left(@OnlyTrlTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlTerminalList, ''))) + ',' Else @OnlyTrlTerminalList End
	SELECT @OnlyTrlFleetList = Case When Left(@OnlyTrlFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlFleetList, ''))) + ',' Else @OnlyTrlFleetList End
	SELECT @OnlyTrlBranchList = Case When Left(@OnlyTrlBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrlBranchList, ''))) + ',' Else @OnlyTrlBranchList End

	SELECT @ExcludeTrlType1List = Case When Left(@ExcludeTrlType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlType1List, ''))) + ',' Else @ExcludeTrlType1List End
	SELECT @ExcludeTrlType2List = Case When Left(@ExcludeTrlType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlType2List, ''))) + ',' Else @ExcludeTrlType2List End
	SELECT @ExcludeTrlType3List = Case When Left(@ExcludeTrlType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlType3List, ''))) + ',' Else @ExcludeTrlType3List End
	SELECT @ExcludeTrlType4List = Case When Left(@ExcludeTrlType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlType4List, ''))) + ',' Else @ExcludeTrlType4List End        
	SELECT @ExcludeTrlCompanyList = Case When Left(@ExcludeTrlCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlCompanyList, ''))) + ',' Else @ExcludeTrlCompanyList End
	SELECT @ExcludeTrlDivisionList = Case When Left(@ExcludeTrlDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlDivisionList, ''))) + ',' Else @ExcludeTrlDivisionList End
	SELECT @ExcludeTrlTerminalList = Case When Left(@ExcludeTrlTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlTerminalList, ''))) + ',' Else @ExcludeTrlTerminalList End
	SELECT @ExcludeTrlFleetList = Case When Left(@ExcludeTrlFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlFleetList, ''))) + ',' Else @ExcludeTrlFleetList End
	SELECT @ExcludeTrlBranchList = Case When Left(@ExcludeTrlBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrlBranchList, ''))) + ',' Else @ExcludeTrlBranchList End
	
    
	Declare @TrailerExpirations TABLE (Trailer varchar(10))

-------------TRAILER EXPIRATIONS----------------------------------------------------------------------------------------------------

	Insert into @TrailerExpirations
			--Considerando expiraciones
          Select  substring(exp_id ,1,10)
		  FROM expiration WITH (NOLOCK) 
		  WHERE exp_idtype='TRL' 
		  and exp_code not in ('OUT','ICFM','INS')  and exp_completed <> 'Y'
          and exp_id  in ( select trl_number from trailerprofile where trl_owner = 'TDR')     
 
       --Considerando que no tengan un leg en 6 días
        --  select  lgh_tractor, max(lgh_startdate)  from legheader 
         -- group by lgh_tractor

   --delete from @TractorExpirations where datediff(d,UltFecha,getdate()) <= 6

-----------TRAILER OUT OF SERVICE-----------------------------------------------------------------------------------------------------

If @Mode = 'OOS'
		Begin
			INSERT @TrailerList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRL' 
		         and exp_code not in ('OUT','ICFM','INS')  and exp_completed <> 'Y'

                 and exp_id  in ( select trl_owner from trailerprofile where trl_owner = 'TDR')     
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End
   	ELSE If @Mode = 'OOSJ'
		Begin
			INSERT @TrailerList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRL' 
		         and exp_code not in ('OUT','ICFM')  and exp_completed <> 'Y' and
                 exp_description like '%Corral%n%'

                    and exp_id  in ( select trl_owner from trailerprofile where trl_owner = 'TDR')     
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End
     	ELSE If @Mode = 'OOSM'
		Begin
			INSERT @TrailerList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRL' 
		         and exp_code not in ('OUT','ICFM','INS')  and exp_completed <> 'Y' and
                 exp_description not like '%Corral%n%'

                   and exp_id  in ( select trl_owner from trailerprofile where trl_owner = 'TDR')     
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End

---------------------TRAILERS DISPONIBLES------------------------------------------------------------------------------------------------------------------------

	Else If @Mode = 'Current'	-- consider expirations
		BEGIN
			INSERT @TrailerList -- @TrailerCount = Count(*) 
		
	            Select distinct substring(replace(replace(trailer_id,',',''),'.',''),1,10)
				FROM   ResNow_TrailerCache_Final RNTCF (NOLOCK) 
			    Where (trailer_retiredate > @TrailerCountDate AND trailer_startdate <= @TrailerCountDate)
				AND (@TrailerCountDate >= Trailer_DateStart AND @TrailerCountDate < Trailer_DateEnd) 
				AND trailer_id <> 'UNKNOWN'
                and Trailer_fleet <> '17'
                     -- Expiration OUT
                and trailer_id not in ( select exp_id from expiration where exp_code = 'OUT' and exp_idtype='TRL')
				and Not Exists (select Trailer from @TrailerExpirations TE where RNTCF.trailer_id = TE.Trailer)
                and trailer_owner = 'TDR'
         

				AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + trailer_type1 + ',', @OnlyTrlType1List) >0)
				AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + trailer_type2 + ',', @OnlyTrlType2List) >0)
				And (@OnlyTrlType3List =',,' or CHARINDEX(',' + trailer_type3 + ',', @OnlyTrlType3List) >0)
				And (@OnlyTrlType4List =',,' or CHARINDEX(',' + trailer_type4 + ',', @OnlyTrlType4List) >0)
				And (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + trailer_company + ',', @OnlyTrlCompanyList) >0)
				And (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + trailer_division + ',', @OnlyTrlDivisionList) >0)
				And (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + trailer_terminal + ',', @OnlyTrlTerminalList) >0)
				And (@OnlyTrlFleetList =',,' or CHARINDEX(',' + trailer_fleet + ',', @OnlyTrlFleetList) >0)
				And (@OnlyTrlBranchList =',,' or CHARINDEX(',' + Trailer_branch + ',', @OnlyTrlBranchList) >0)

				And (@ExcludeTrlType1List = ',,' OR (CHARINDEX(',' + trailer_type1 + ',', @ExcludeTrlType1List) = 0))        
				And (@ExcludeTrlType2List = ',,' OR (CHARINDEX(',' + trailer_type2 + ',', @ExcludeTrlType2List) = 0))        
				And (@ExcludeTrlType3List = ',,' OR (CHARINDEX(',' + trailer_type3 + ',', @ExcludeTrlType3List) = 0))        
				And (@ExcludeTrlType4List = ',,' OR (CHARINDEX(',' + trailer_type4 + ',', @ExcludeTrlType4List) = 0))        
				And (@ExcludeTrlCompanyList =',,' or (CHARINDEX(',' + trailer_company + ',', @ExcludeTrlCompanyList) = 0))
				And (@ExcludeTrlDivisionList =',,' or (CHARINDEX(',' + trailer_division + ',', @ExcludeTrlDivisionList) = 0))
				And (@ExcludeTrlTerminalList =',,' or (CHARINDEX(',' + trailer_terminal + ',', @ExcludeTrlTerminalList) = 0))
				And (@ExcludeTrlFleetList =',,' or (CHARINDEX(',' + trailer_fleet + ',', @ExcludeTrlFleetList) = 0))				And (@ExcludeTrlBranchList =',,' or (CHARINDEX(',' + Trailer_branch + ',', @ExcludeTrlBranchList) = 0))
				And (@ExcludeTrlBranchList =',,' or (CHARINDEX(',' + Trailer_branch + ',', @ExcludeTrlBranchList) = 0))
		END
------------------TRAILERS TOTALES-----------------------------------------------------------------------------------------------------------------------------------

	Else If @Mode = 'Total'	-- ignore expirations
		BEGIN
			INSERT @TrailerList -- @TrailerCount = Count(*) 

	         	Select distinct replace(replace(trailer_id,',',''),'.','')
		        FROM   ResNow_TrailerCache_Final RNTCF (NOLOCK) 
				Where (trailer_retiredate > @TrailerCountDate AND trailer_startdate <= @TrailerCountDate)
			   AND (@TrailerCountDate >= Trailer_DateStart AND @TrailerCountDate < Trailer_DateEnd) and
			   trailer_id <> 'UNKNOWN'
                --Flota de ventas
                and trailer_fleet <> '17'
                -- Expiration OUT
                and trailer_id not in ( select exp_id from expiration where exp_code = 'OUT' and exp_idtype='TRL')
                and trailer_owner = 'TDR'
          
				AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + trailer_type1 + ',', @OnlyTrlType1List) >0)
				AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + trailer_type2 + ',', @OnlyTrlType2List) >0)
				And (@OnlyTrlType3List =',,' or CHARINDEX(',' + trailer_type3 + ',', @OnlyTrlType3List) >0)
				And (@OnlyTrlType4List =',,' or CHARINDEX(',' + trailer_type4 + ',', @OnlyTrlType4List) >0)
				And (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + trailer_company + ',', @OnlyTrlCompanyList) >0)
				And (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + trailer_division + ',', @OnlyTrlDivisionList) >0)
				And (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + trailer_terminal + ',', @OnlyTrlTerminalList) >0)
				And (@OnlyTrlFleetList =',,' or CHARINDEX(',' + trailer_fleet + ',', @OnlyTrlFleetList) >0)
				And (@OnlyTrlBranchList =',,' or CHARINDEX(',' + Trailer_branch + ',', @OnlyTrlBranchList) >0)

				And (@ExcludeTrlType1List = ',,' OR (CHARINDEX(',' + trailer_type1 + ',', @ExcludeTrlType1List) = 0))        
				And (@ExcludeTrlType2List = ',,' OR (CHARINDEX(',' + trailer_type2 + ',', @ExcludeTrlType2List) = 0))        
				And (@ExcludeTrlType3List = ',,' OR (CHARINDEX(',' + trailer_type3 + ',', @ExcludeTrlType3List) = 0))        
				And (@ExcludeTrlType4List = ',,' OR (CHARINDEX(',' + trailer_type4 + ',', @ExcludeTrlType4List) = 0))        
				And (@ExcludeTrlCompanyList =',,' or (CHARINDEX(',' + trailer_company + ',', @ExcludeTrlCompanyList) = 0))
				And (@ExcludeTrlDivisionList =',,' or (CHARINDEX(',' + trailer_division + ',', @ExcludeTrlDivisionList) = 0))
				And (@ExcludeTrlTerminalList =',,' or (CHARINDEX(',' + trailer_terminal + ',', @ExcludeTrlTerminalList) = 0))
				And (@ExcludeTrlFleetList =',,' or (CHARINDEX(',' + trailer_fleet + ',', @ExcludeTrlFleetList) = 0))
				And (@ExcludeTrlBranchList =',,' or (CHARINDEX(',' + Trailer_branch + ',', @ExcludeTrlBranchList) = 0))
		END

---------------------TRAILERS HISTORICOS------------------------------------------------------------------------------------------------------------------------


	Else If @Mode = 'Historical'	-- ignore expirations and retirements
		BEGIN
			INSERT @TrailerList -- @TrailerCount = Count(*) 
				Select distinct trailer_id
				FROM   ResNow_TrailerCache_Final RNTCF (NOLOCK) 
				Where trailer_id <> 'UNKNOWN'
                and trailer_id not in (select trl_number from trailerprofile  where trl_type1  in ('CAME')  )   


				AND (@OnlyTrlType1List =',,' or CHARINDEX(',' + trailer_type1 + ',', @OnlyTrlType1List) >0)
				AND (@OnlyTrlType2List =',,' or CHARINDEX(',' + trailer_type2 + ',', @OnlyTrlType2List) >0)
				And (@OnlyTrlType3List =',,' or CHARINDEX(',' + trailer_type3 + ',', @OnlyTrlType3List) >0)
				And (@OnlyTrlType4List =',,' or CHARINDEX(',' + trailer_type4 + ',', @OnlyTrlType4List) >0)
				And (@OnlyTrlCompanyList =',,' or CHARINDEX(',' + trailer_company + ',', @OnlyTrlCompanyList) >0)
				And (@OnlyTrlDivisionList =',,' or CHARINDEX(',' + trailer_division + ',', @OnlyTrlDivisionList) >0)
				And (@OnlyTrlTerminalList =',,' or CHARINDEX(',' + trailer_terminal + ',', @OnlyTrlTerminalList) >0)
				And (@OnlyTrlFleetList =',,' or CHARINDEX(',' + trailer_fleet + ',', @OnlyTrlFleetList) >0)
				And (@OnlyTrlBranchList =',,' or CHARINDEX(',' + Trailer_branch + ',', @OnlyTrlBranchList) >0)

				And (@ExcludeTrlType1List = ',,' OR (CHARINDEX(',' + trailer_type1 + ',', @ExcludeTrlType1List) = 0))        
				And (@ExcludeTrlType2List = ',,' OR (CHARINDEX(',' + trailer_type2 + ',', @ExcludeTrlType2List) = 0))        
				And (@ExcludeTrlType3List = ',,' OR (CHARINDEX(',' + trailer_type3 + ',', @ExcludeTrlType3List) = 0))        
				And (@ExcludeTrlType4List = ',,' OR (CHARINDEX(',' + trailer_type4 + ',', @ExcludeTrlType4List) = 0))        
				And (@ExcludeTrlCompanyList =',,' or (CHARINDEX(',' + trailer_company + ',', @ExcludeTrlCompanyList) = 0))
				And (@ExcludeTrlDivisionList =',,' or (CHARINDEX(',' + trailer_division + ',', @ExcludeTrlDivisionList) = 0))
				And (@ExcludeTrlTerminalList =',,' or (CHARINDEX(',' + trailer_terminal + ',', @ExcludeTrlTerminalList) = 0))
				And (@ExcludeTrlFleetList =',,' or (CHARINDEX(',' + trailer_fleet + ',', @ExcludeTrlFleetList) = 0))
				And (@ExcludeTrlBranchList =',,' or (CHARINDEX(',' + Trailer_branch + ',', @ExcludeTrlBranchList) = 0))
		END

    Return 
END
GO
GRANT SELECT ON  [dbo].[fnc_TMWRN_TrailerCount3] TO [public]
GO
