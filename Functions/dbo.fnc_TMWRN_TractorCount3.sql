SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*  sample call
dbo.fnc_TMWRN_TractorCount3 (@Mode,@OnlyTrcType1List,@OnlyTrcType2List,@OnlyTrcType3List,@OnlyTrcType4List
,@OnlyTrcCompanyList,@OnlyTrcDivisionList,@OnlyTrcTerminalList,@OnlyTrcFleetList
,@ExcludeTrcType1List,@ExcludeTrcType2List,@ExcludeTrcType3List,@ExcludeTrcType4List
,@ExcludeTrcCompanyList,@ExcludeTrcDivisionList,@ExcludeTrcTerminalList,@ExcludeTrcFleetList,@TractorCountDate)
*/


/****************
Funcion Modificada por Emilio Olvera  01/03/2013.
Revisado por: Emilio Olvera Yañez y Carlos Salvador Rodriguez J
Fecha revision: 3 Junio 2015

Cuenta con revisón de matematica de calculo en base a Hoshin 2015.

CURRENT: todos los camiones que  estan en out y si tienen expiraciones
TOTAL:  todos los camiones que no estan en out y no tienen expiraciones

********************/





CREATE Function [dbo].[fnc_TMWRN_TractorCount3]
	( 
		@Mode varchar(100) = 'Current', -- Seated, Unseated, Current, Total, OOS, Historical
		@OnlyTrcType1List varchar(255) = '',
		@OnlyTrcType2List varchar(255) = '',
		@OnlyTrcType3List varchar(255) = '',
		@OnlyTrcType4List varchar(255) = '',
		@OnlyTrcCompanyList varchar(255) = '' ,
		@OnlyTrcDivisionList varchar(255) = '' ,
		@OnlyTrcTerminalList varchar(255) = '' ,
		@OnlyTrcFleetList varchar(255) = '' ,
		@OnlyTrcBranchList varchar(255) = '' ,
		@ExcludeTrcType1List varchar(255)='', 
		@ExcludeTrcType2List varchar(255)='', 
		@ExcludeTrcType3List varchar(255)='', 
		@ExcludeTrcType4List varchar(255)='', 
		@ExcludeTrcCompanyList varchar(255)='',
		@ExcludeTrcDivisionList varchar(255)='',
		@ExcludeTrcTerminalList varchar(255)='',
		@ExcludeTrcFleetList varchar(255)='',
		@ExcludeTrcBranchList varchar(255)='',
		@TractorCountDate datetime
	)
 
Returns @TractorList TABLE 
	(
		Tractor varchar(12)
	)
As 
Begin 


	SELECT @OnlyTrcType1List = Case When Left(@OnlyTrcType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcType1List, ''))) + ',' Else @OnlyTrcType1List End
	SELECT @OnlyTrcType2List = Case When Left(@OnlyTrcType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcType2List, ''))) + ',' Else @OnlyTrcType2List End
	SELECT @OnlyTrcType3List = Case When Left(@OnlyTrcType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcType3List, ''))) + ',' Else @OnlyTrcType3List End
	SELECT @OnlyTrcType4List = Case When Left(@OnlyTrcType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcType4List, ''))) + ',' Else @OnlyTrcType4List End
	SELECT @OnlyTrcCompanyList = Case When Left(@OnlyTrcCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcCompanyList, ''))) + ',' Else @OnlyTrcCompanyList End
	SELECT @OnlyTrcDivisionList = Case When Left(@OnlyTrcDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcDivisionList, ''))) + ',' Else @OnlyTrcDivisionList End
	SELECT @OnlyTrcTerminalList = Case When Left(@OnlyTrcTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcTerminalList, ''))) + ',' Else @OnlyTrcTerminalList End
	SELECT @OnlyTrcFleetList = Case When Left(@OnlyTrcFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcFleetList, ''))) + ',' Else @OnlyTrcFleetList End
	SELECT @OnlyTrcBranchList = Case When Left(@OnlyTrcBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyTrcBranchList, ''))) + ',' Else @OnlyTrcBranchList End

	SELECT @ExcludeTrcType1List = Case When Left(@ExcludeTrcType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcType1List, ''))) + ',' Else @ExcludeTrcType1List End
	SELECT @ExcludeTrcType2List = Case When Left(@ExcludeTrcType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcType2List, ''))) + ',' Else @ExcludeTrcType2List End
	SELECT @ExcludeTrcType3List = Case When Left(@ExcludeTrcType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcType3List, ''))) + ',' Else @ExcludeTrcType3List End
	SELECT @ExcludeTrcType4List = Case When Left(@ExcludeTrcType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcType4List, ''))) + ',' Else @ExcludeTrcType4List End        
	SELECT @ExcludeTrcCompanyList = Case When Left(@ExcludeTrcCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcCompanyList, ''))) + ',' Else @ExcludeTrcCompanyList End
	SELECT @ExcludeTrcDivisionList = Case When Left(@ExcludeTrcDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcDivisionList, ''))) + ',' Else @ExcludeTrcDivisionList End
	SELECT @ExcludeTrcTerminalList = Case When Left(@ExcludeTrcTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcTerminalList, ''))) + ',' Else @ExcludeTrcTerminalList End
	SELECT @ExcludeTrcFleetList = Case When Left(@ExcludeTrcFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcFleetList, ''))) + ',' Else @ExcludeTrcFleetList End
	SELECT @ExcludeTrcBranchList = Case When Left(@ExcludeTrcBranchList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTrcBranchList, ''))) + ',' Else @ExcludeTrcBranchList End
	
	Declare @TractorExpirations TABLE (Tractor varchar(10))


  

-------------TRACTOR EXPIRATIONS----------------------------------------------------------------------------------------------------


	Insert into @TractorExpirations
		--Considerando expiraciones
          Select  substring(exp_id ,1,10)
		  FROM expiration WITH (NOLOCK) 
		  WHERE exp_idtype='TRC' 
		  and exp_code not in ('OUT','ICFM','INS')  
          and (exp_completed <> 'Y') 
         
 
       --Considerando que no tengan un leg en 6 días
        --  select  lgh_tractor, max(lgh_startdate)  from legheader 
         -- group by lgh_tractor

   --delete from @TractorExpirations where datediff(d,UltFecha,getdate()) <= 6

-----------TRACTOR OUT OF SERVICE-----------------------------------------------------------------------------------------------------

	If @Mode = 'OOS'
		Begin
			INSERT @TractorList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code not in ('OUT','ICFM','INS') and (exp_completed <> 'Y')  
 
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End
   	ELSE If @Mode = 'OOSJ'
		Begin
			INSERT @TractorList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code in ('LEG')   and (exp_completed <> 'Y')  
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End
     	ELSE If @Mode = 'OOSM'
		Begin
			INSERT @TractorList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code not in ('OUT','ICFM','INS')  and (exp_completed <> 'Y')    and
                 exp_description not like '%Corral%n%' 
 
                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End
		    	ELSE If @Mode = 'MANTT'
		Begin
			INSERT @TractorList -- @TrailerCount = Count(*) 
				Select substring(exp_id ,1,10)
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code =  ('VAC')  and (exp_completed <> 'Y')   
          


                /*Select distinct Tractor
				From @TractorExpirations TE join ResNow_TractorCache_Final RNTCF on TE.Tractor = RNTCF.Tractor_ID
				Where (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND Tractor_RetireDate > @TractorCountDate */
		End

---------------------TRACTOS DISPONIBLES------------------------------------------------------------------------------------------------------------------------
---------------------SON TODOS LOS TRACTORES QUE NO TIENEN EXPIRACIONES


	Else If @Mode = 'Current'	-- consider expirations
		BEGIN
		INSERT @TractorList -- @TractorCount = Count(*) 
				Select distinct  substring(trc_number ,1,10)
				FROM   tractorprofile (NOLOCK) 
				Where (trc_retiredate > @TractorCountDate AND trc_startdate <= @TractorCountDate) 
				AND (@TractorCountDate >= trc_startdate AND @TractorCountDate < trc_retiredate) 
				AND trc_number <>  ('UNKNOWN')   
				AND  (trc_owner = 'TDR' )
                --Flota de ventas
                and trc_fleet <> '17'
				--No este en expirations
                And Not Exists (select Tractor from @TractorExpirations TE where trc_number = TE.Tractor)
                and trc_number not in ( select exp_id from expiration where exp_code = 'OUT' and exp_idtype='TRC'  )

				AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + trc_type1 + ',', @OnlyTrcType1List) >0)
				AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + trc_type2 + ',', @OnlyTrcType2List) >0)
				And (@OnlyTrcType3List =',,' or CHARINDEX(',' + trc_type3 + ',', @OnlyTrcType3List) >0)
				And (@OnlyTrcType4List =',,' or CHARINDEX(',' + trc_type4 + ',', @OnlyTrcType4List) >0)
				And (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + trc_company + ',', @OnlyTrcCompanyList) >0)
				And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + trc_division + ',', @OnlyTrcDivisionList) >0)
				And (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + trc_terminal + ',', @OnlyTrcTerminalList) >0)
				And (@OnlyTrcFleetList =',,' or CHARINDEX(',' + trc_fleet + ',', @OnlyTrcFleetList) >0)
				And (@OnlyTrcBranchList =',,' or CHARINDEX(',' + trc_branch + ',', @OnlyTrcBranchList) >0)

				And (@ExcludeTrcType1List = ',,' OR (CHARINDEX(',' + trc_type1 + ',', @ExcludeTrcType1List) = 0))        
				And (@ExcludeTrcType2List = ',,' OR (CHARINDEX(',' + trc_type2 + ',', @ExcludeTrcType2List) = 0))        
				And (@ExcludeTrcType3List = ',,' OR (CHARINDEX(',' + trc_type3 + ',', @ExcludeTrcType3List) = 0))        
				And (@ExcludeTrcType4List = ',,' OR (CHARINDEX(',' + trc_type4 + ',', @ExcludeTrcType4List) = 0))        
				And (@ExcludeTrcCompanyList =',,' or (CHARINDEX(',' + trc_company + ',', @ExcludeTrcCompanyList) = 0))
				And (@ExcludeTrcDivisionList =',,' or (CHARINDEX(',' + trc_division + ',', @ExcludeTrcDivisionList) = 0))
				And (@ExcludeTrcTerminalList =',,' or (CHARINDEX(',' + trc_terminal + ',', @ExcludeTrcTerminalList) = 0))
				And (@ExcludeTrcFleetList =',,' or (CHARINDEX(',' + trc_fleet + ',', @ExcludeTrcFleetList) = 0))
				And (@ExcludeTrcBranchList =',,' or (CHARINDEX(',' + trc_branch + ',', @ExcludeTrcBranchList) = 0))
		END

---------------------TRACTOS TOTALES------------------------------------------------------------------------------------------------------------------------
---------------------TOMAMOS TODOS LOS TRACTORES MIENTRAS NO TENGAN UN TERMINATED 

	Else If @Mode = 'Total'	-- ignore expirations
		BEGIN
			INSERT @TractorList -- @TractorCount = Count(*) 
				Select distinct substring(tractor_id ,1,10)
				FROM   ResNow_TractorCache_Final RNTCF (NOLOCK) 
				Where (tractor_retiredate > @TractorCountDate AND tractor_startdate <= @TractorCountDate) 
				AND (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND tractor_id  <> ('UNKNOWN')   
				AND tractor_id  in ( select TRC_NUMBER from tractorprofile where trc_owner = 'TDR' )
                --Flota de ventas
                and tractor_fleet <> '17'
                -- Expiration OUT
                and tractor_id not in ( select exp_id from expiration where exp_code = 'OUT' and exp_idtype='TRC' )

				AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + tractor_type1 + ',', @OnlyTrcType1List) >0)
				AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + tractor_type2 + ',', @OnlyTrcType2List) >0)
				And (@OnlyTrcType3List =',,' or CHARINDEX(',' + tractor_type3 + ',', @OnlyTrcType3List) >0)
				And (@OnlyTrcType4List =',,' or CHARINDEX(',' + tractor_type4 + ',', @OnlyTrcType4List) >0)
				And (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + tractor_company + ',', @OnlyTrcCompanyList) >0)
				And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + tractor_division + ',', @OnlyTrcDivisionList) >0)
				And (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + tractor_terminal + ',', @OnlyTrcTerminalList) >0)
				And (@OnlyTrcFleetList =',,' or CHARINDEX(',' + tractor_fleet + ',', @OnlyTrcFleetList) >0)
				And (@OnlyTrcBranchList =',,' or CHARINDEX(',' + tractor_branch + ',', @OnlyTrcBranchList) >0)

				And (@ExcludeTrcType1List = ',,' OR (CHARINDEX(',' + tractor_type1 + ',', @ExcludeTrcType1List) = 0))        
				And (@ExcludeTrcType2List = ',,' OR (CHARINDEX(',' + tractor_type2 + ',', @ExcludeTrcType2List) = 0))        
				And (@ExcludeTrcType3List = ',,' OR (CHARINDEX(',' + tractor_type3 + ',', @ExcludeTrcType3List) = 0))        
				And (@ExcludeTrcType4List = ',,' OR (CHARINDEX(',' + tractor_type4 + ',', @ExcludeTrcType4List) = 0))        
				And (@ExcludeTrcCompanyList =',,' or (CHARINDEX(',' + tractor_company + ',', @ExcludeTrcCompanyList) = 0))
				And (@ExcludeTrcDivisionList =',,' or (CHARINDEX(',' + tractor_division + ',', @ExcludeTrcDivisionList) = 0))
				And (@ExcludeTrcTerminalList =',,' or (CHARINDEX(',' + tractor_terminal + ',', @ExcludeTrcTerminalList) = 0))
				And (@ExcludeTrcFleetList =',,' or (CHARINDEX(',' + tractor_fleet + ',', @ExcludeTrcFleetList) = 0))
				And (@ExcludeTrcBranchList =',,' or (CHARINDEX(',' + tractor_branch + ',', @ExcludeTrcBranchList) = 0))
		END

---------------------TRACTOS HISTORICOS-----------------------------------------------------------------------------------------------------------------------


	Else If @Mode = 'Historical'	-- ignore expirations and retirements
		BEGIN
			INSERT @TractorList -- @TractorCount = Count(*) 
				Select distinct substring(tractor_id ,1,10)
				FROM   ResNow_TractorCache_Final RNTCF (NOLOCK) 
				Where tractor_id <> 'UNKNOWN'
				AND tractor_id  in ( select TRC_NUMBER from tractorprofile where trc_owner = 'TDR' )
				AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + tractor_type1 + ',', @OnlyTrcType1List) >0)
				AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + tractor_type2 + ',', @OnlyTrcType2List) >0)
				And (@OnlyTrcType3List =',,' or CHARINDEX(',' + tractor_type3 + ',', @OnlyTrcType3List) >0)
				And (@OnlyTrcType4List =',,' or CHARINDEX(',' + tractor_type4 + ',', @OnlyTrcType4List) >0)
				And (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + tractor_company + ',', @OnlyTrcCompanyList) >0)
				And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + tractor_division + ',', @OnlyTrcDivisionList) >0)
				And (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + tractor_terminal + ',', @OnlyTrcTerminalList) >0)
				And (@OnlyTrcFleetList =',,' or CHARINDEX(',' + tractor_fleet + ',', @OnlyTrcFleetList) >0)
				And (@OnlyTrcBranchList =',,' or CHARINDEX(',' + tractor_branch + ',', @OnlyTrcBranchList) >0)

				And (@ExcludeTrcType1List = ',,' OR (CHARINDEX(',' + tractor_type1 + ',', @ExcludeTrcType1List) = 0))        
				And (@ExcludeTrcType2List = ',,' OR (CHARINDEX(',' + tractor_type2 + ',', @ExcludeTrcType2List) = 0))        
				And (@ExcludeTrcType3List = ',,' OR (CHARINDEX(',' + tractor_type3 + ',', @ExcludeTrcType3List) = 0))        
				And (@ExcludeTrcType4List = ',,' OR (CHARINDEX(',' + tractor_type4 + ',', @ExcludeTrcType4List) = 0))        
				And (@ExcludeTrcCompanyList =',,' or (CHARINDEX(',' + tractor_company + ',', @ExcludeTrcCompanyList) = 0))
				And (@ExcludeTrcDivisionList =',,' or (CHARINDEX(',' + tractor_division + ',', @ExcludeTrcDivisionList) = 0))
				And (@ExcludeTrcTerminalList =',,' or (CHARINDEX(',' + tractor_terminal + ',', @ExcludeTrcTerminalList) = 0))
				And (@ExcludeTrcFleetList =',,' or (CHARINDEX(',' + tractor_fleet + ',', @ExcludeTrcFleetList) = 0))
				And (@ExcludeTrcBranchList =',,' or (CHARINDEX(',' + tractor_branch + ',', @ExcludeTrcBranchList) = 0))
		END
	Else If @Mode = 'Seated'	-- ignore expirations
		BEGIN
			INSERT @TractorList -- @TractorCount = Count(*) 
				Select distinct substring(tractor_id ,1,10)
				FROM   ResNow_TractorCache_Final RNTCF (NOLOCK) 
				Where (tractor_retiredate > @TractorCountDate AND tractor_startdate <= @TractorCountDate) 
				AND (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND tractor_id <> 'UNKNOWN'
				AND tractor_seatedstatus <> 'Unseated'
			    AND tractor_id  in ( select TRC_NUMBER from tractorprofile where trc_owner = 'TDR' )
				AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + tractor_type1 + ',', @OnlyTrcType1List) >0)
				AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + tractor_type2 + ',', @OnlyTrcType2List) >0)
				And (@OnlyTrcType3List =',,' or CHARINDEX(',' + tractor_type3 + ',', @OnlyTrcType3List) >0)
				And (@OnlyTrcType4List =',,' or CHARINDEX(',' + tractor_type4 + ',', @OnlyTrcType4List) >0)
				And (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + tractor_company + ',', @OnlyTrcCompanyList) >0)
				And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + tractor_division + ',', @OnlyTrcDivisionList) >0)
				And (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + tractor_terminal + ',', @OnlyTrcTerminalList) >0)
				And (@OnlyTrcFleetList =',,' or CHARINDEX(',' + tractor_fleet + ',', @OnlyTrcFleetList) >0)
				And (@OnlyTrcBranchList =',,' or CHARINDEX(',' + tractor_branch + ',', @OnlyTrcBranchList) >0)

				And (@ExcludeTrcType1List = ',,' OR (CHARINDEX(',' + tractor_type1 + ',', @ExcludeTrcType1List) = 0))        
				And (@ExcludeTrcType2List = ',,' OR (CHARINDEX(',' + tractor_type2 + ',', @ExcludeTrcType2List) = 0))        
				And (@ExcludeTrcType3List = ',,' OR (CHARINDEX(',' + tractor_type3 + ',', @ExcludeTrcType3List) = 0))        
				And (@ExcludeTrcType4List = ',,' OR (CHARINDEX(',' + tractor_type4 + ',', @ExcludeTrcType4List) = 0))        
				And (@ExcludeTrcCompanyList =',,' or (CHARINDEX(',' + tractor_company + ',', @ExcludeTrcCompanyList) = 0))
				And (@ExcludeTrcDivisionList =',,' or (CHARINDEX(',' + tractor_division + ',', @ExcludeTrcDivisionList) = 0))
				And (@ExcludeTrcTerminalList =',,' or (CHARINDEX(',' + tractor_terminal + ',', @ExcludeTrcTerminalList) = 0))
				And (@ExcludeTrcFleetList =',,' or (CHARINDEX(',' + tractor_fleet + ',', @ExcludeTrcFleetList) = 0))
				And (@ExcludeTrcBranchList =',,' or (CHARINDEX(',' + tractor_branch + ',', @ExcludeTrcBranchList) = 0))
		END
	Else If @Mode = 'Unseated'	-- 
		BEGIN
			INSERT @TractorList -- @TractorCount = Count(*) 
			    --select trc_number from tractorprofile where trc_driver = 'UNKNOWN'
                Select distinct substring(tractor_id ,1,10)
				FROM   ResNow_TractorCache_Final RNTCF (NOLOCK) 
				Where 
                (tractor_retiredate > @TractorCountDate AND tractor_startdate <= @TractorCountDate) 
				AND (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd)
				 and tractor_id not in  ('010','UNKNOWN','232016')   
                --Flota de ventas
                and tractor_fleet not in  ('17','UNK')
				--No este ien expirations
               
               And  tractor_id in (select trc_number from tractorprofile where trc_driver = 'UNKNOWN' and trc_fleet not in ('17','UNK') and trc_status != 'OUT' AND trc_owner = 'TDR'
               -- And  not Exists ( Select  substring(exp_id ,1,10)
		              --    FROM expiration WITH (NOLOCK) 
		                 --  WHERE exp_idtype='TRC' 
		                 -- and exp_code in ('OUT','ICFM','INS')  and exp_completed = 'Y' )
               )
         

                /*Select distinct tractor_id 
				FROM   ResNow_TractorCache_Final RNTCF (NOLOCK) 
				Where (tractor_retiredate > @TractorCountDate AND tractor_startdate <= @TractorCountDate) 
				AND (@TractorCountDate >= Tractor_DateStart AND @TractorCountDate < Tractor_DateEnd) 
				AND tractor_id <> 'UNKNOWN'
				AND tractor_seatedstatus = 'Unseated'*/

				--AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + trc_type1 + ',', @OnlyTrcType1List) >0)
				--AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + trc_type2 + ',', @OnlyTrcType2List) >0)
				--And (@OnlyTrcType3List =',,' or CHARINDEX(',' + trc_type3 + ',', @OnlyTrcType3List) >0)
				--And (@OnlyTrcType4List =',,' or CHARINDEX(',' + trc_type4 + ',', @OnlyTrcType4List) >0)
				--And (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + trc_company + ',', @OnlyTrcCompanyList) >0)
				--And (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + tractor_division + ',', @OnlyTrcDivisionList) >0)
				--And (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + tractor_terminal + ',', @OnlyTrcTerminalList) >0)
				And (@OnlyTrcFleetList =',,' or CHARINDEX(',' + tractor_fleet + ',', @OnlyTrcFleetList) >0)
				--And (@OnlyTrcBranchList =',,' or CHARINDEX(',' + tractor_branch + ',', @OnlyTrcBranchList) >0)

				--And (@ExcludeTrcType1List = ',,' OR (CHARINDEX(',' + tractor_type1 + ',', @ExcludeTrcType1List) = 0))        
				--And (@ExcludeTrcType2List = ',,' OR (CHARINDEX(',' + tractor_type2 + ',', @ExcludeTrcType2List) = 0))        
				--And (@ExcludeTrcType3List = ',,' OR (CHARINDEX(',' + tractor_type3 + ',', @ExcludeTrcType3List) = 0))        
				--And (@ExcludeTrcType4List = ',,' OR (CHARINDEX(',' + tractor_type4 + ',', @ExcludeTrcType4List) = 0))        
				--And (@ExcludeTrcCompanyList =',,' or (CHARINDEX(',' + tractor_company + ',', @ExcludeTrcCompanyList) = 0))
				--And (@ExcludeTrcDivisionList =',,' or (CHARINDEX(',' + tractor_division + ',', @ExcludeTrcDivisionList) = 0))
				--And (@ExcludeTrcTerminalList =',,' or (CHARINDEX(',' + tractor_terminal + ',', @ExcludeTrcTerminalList) = 0))
				And (@ExcludeTrcFleetList =',,' or (CHARINDEX(',' + tractor_fleet + ',', @ExcludeTrcFleetList) = 0))
				--And (@ExcludeTrcBranchList =',,' or (CHARINDEX(',' + tractor_branch + ',', @ExcludeTrcBranchList) = 0))
		END

    Return 
END
GO
GRANT SELECT ON  [dbo].[fnc_TMWRN_TractorCount3] TO [public]
GO
