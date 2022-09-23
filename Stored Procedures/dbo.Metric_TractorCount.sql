SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_TractorCount]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

	-- Additional / Optional Parameters
		@Numerator varchar(100) = 'Current',			-- Seated, Unseated, Working, Current, Total, OOSJ, OOSM, OOS
		@Denominator varchar(100) = 'Day',			-- Seated, Unseated, Working, Current, Total, Historical, Day
        @Mode varchar(100) = 'Normal',               -- Normal

	-- filtering parameters: includes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',

	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',
		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',

	-- parameters for Numerator Tractor Count ONLY
		@NumeratorOnlyTrcType1List varchar(255) = '',
		@NumeratorOnlyTrcType2List varchar(255) = '',
		@NumeratorOnlyTrcType3List varchar(255) = '',
		@NumeratorOnlyTrcType4List varchar(255) = '',
		@NumeratorOnlyTrcCompanyList varchar(255) = '',
		@NumeratorOnlyTrcDivisionList varchar(255) = '',
		@NumeratorOnlyTrcTerminalList varchar(255) = '',
		@NumeratorOnlyTrcFleetList varchar(255) = '',
		@NumeratorOnlyTrcBranchList varchar(255) = '',

		@NumeratorExcludeTrcType1List varchar(255) = '',
		@NumeratorExcludeTrcType2List varchar(255) = '',
		@NumeratorExcludeTrcType3List varchar(255) = '',
		@NumeratorExcludeTrcType4List varchar(255) = '',
		@NumeratorExcludeTrcCompanyList varchar(255) = '',
		@NumeratorExcludeTrcDivisionList varchar(255) = '',
		@NumeratorExcludeTrcTerminalList varchar(255) = '',
		@NumeratorExcludeTrcFleetList varchar(255) = '',
		@NumeratorExcludeTrcBranchList varchar(255) = '',

	-- parameters for Denominator Tractor Count ONLY
		@DenominatorOnlyTrcType1List varchar(255) = '',
		@DenominatorOnlyTrcType2List varchar(255) = '',
		@DenominatorOnlyTrcType3List varchar(255) = '',
		@DenominatorOnlyTrcType4List varchar(255) = '',
		@DenominatorOnlyTrcCompanyList varchar(255) = '',
		@DenominatorOnlyTrcDivisionList varchar(255) = '',
		@DenominatorOnlyTrcTerminalList varchar(255) = '',
		@DenominatorOnlyTrcFleetList varchar(255) = '',
		@DenominatorOnlyTrcBranchList varchar(255) = '',

		@DenominatorExcludeTrcType1List varchar(255) = '',
		@DenominatorExcludeTrcType2List varchar(255) = '',
		@DenominatorExcludeTrcType3List varchar(255) = '',
		@DenominatorExcludeTrcType4List varchar(255) = '',
		@DenominatorExcludeTrcCompanyList varchar(255) = '',
		@DenominatorExcludeTrcDivisionList varchar(255) = '',
		@DenominatorExcludeTrcTerminalList varchar(255) = '',
		@DenominatorExcludeTrcFleetList varchar(255) = '',
		@DenominatorExcludeTrcBranchList varchar(255) = '',

		@MetricCode varchar(500)= 'TractorCount'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Numerador,2:Denominador

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	Set @NumeratorOnlyTrcType1List= ',' + ISNULL(@NumeratorOnlyTrcType1List,'') + ','
	Set @NumeratorOnlyTrcType2List= ',' + ISNULL(@NumeratorOnlyTrcType2List,'') + ','
	Set @NumeratorOnlyTrcType3List= ',' + ISNULL(@NumeratorOnlyTrcType3List,'') + ','
	Set @NumeratorOnlyTrcType4List= ',' + ISNULL(@NumeratorOnlyTrcType4List,'') + ','
	Set @NumeratorOnlyTrcCompanyList= ',' + ISNULL(@NumeratorOnlyTrcCompanyList,'') + ','
	Set @NumeratorOnlyTrcDivisionList= ',' + ISNULL(@NumeratorOnlyTrcDivisionList,'') + ','
	Set @NumeratorOnlyTrcTerminalList= ',' + ISNULL(@NumeratorOnlyTrcTerminalList,'') + ','
	Set @NumeratorOnlyTrcFleetList= ',' + ISNULL(@NumeratorOnlyTrcFleetList,'') + ','
	Set @NumeratorOnlyTrcBranchList= ',' + ISNULL(@NumeratorOnlyTrcBranchList,'') + ','

	Set @NumeratorExcludeTrcType1List= ',' + ISNULL(@NumeratorExcludeTrcType1List,'') + ','
	Set @NumeratorExcludeTrcType2List= ',' + ISNULL(@NumeratorExcludeTrcType2List,'') + ','
	Set @NumeratorExcludeTrcType3List= ',' + ISNULL(@NumeratorExcludeTrcType3List,'') + ','
	Set @NumeratorExcludeTrcType4List= ',' + ISNULL(@NumeratorExcludeTrcType4List,'') + ','
	Set @NumeratorExcludeTrcCompanyList= ',' + ISNULL(@NumeratorExcludeTrcCompanyList,'') + ','
	Set @NumeratorExcludeTrcDivisionList= ',' + ISNULL(@NumeratorExcludeTrcDivisionList,'') + ','
	Set @NumeratorExcludeTrcTerminalList= ',' + ISNULL(@NumeratorExcludeTrcTerminalList,'') + ','
	Set @NumeratorExcludeTrcFleetList= ',' + ISNULL(@NumeratorExcludeTrcFleetList,'') + ','
	Set @NumeratorExcludeTrcBranchList= ',' + ISNULL(@NumeratorExcludeTrcBranchList,'') + ','

	Set @DenominatorOnlyTrcType1List= ',' + ISNULL(@DenominatorOnlyTrcType1List,'') + ','
	Set @DenominatorOnlyTrcType2List= ',' + ISNULL(@DenominatorOnlyTrcType2List,'') + ','
	Set @DenominatorOnlyTrcType3List= ',' + ISNULL(@DenominatorOnlyTrcType3List,'') + ','
	Set @DenominatorOnlyTrcType4List= ',' + ISNULL(@DenominatorOnlyTrcType4List,'') + ','
	Set @DenominatorOnlyTrcCompanyList= ',' + ISNULL(@DenominatorOnlyTrcCompanyList,'') + ','
	Set @DenominatorOnlyTrcDivisionList= ',' + ISNULL(@DenominatorOnlyTrcDivisionList,'') + ','
	Set @DenominatorOnlyTrcTerminalList= ',' + ISNULL(@DenominatorOnlyTrcTerminalList,'') + ','
	Set @DenominatorOnlyTrcFleetList= ',' + ISNULL(@DenominatorOnlyTrcFleetList,'') + ','
	Set @DenominatorOnlyTrcBranchList= ',' + ISNULL(@DenominatorOnlyTrcBranchList,'') + ','

	Set @DenominatorExcludeTrcType1List= ',' + ISNULL(@DenominatorExcludeTrcType1List,'') + ','
	Set @DenominatorExcludeTrcType2List= ',' + ISNULL(@DenominatorExcludeTrcType2List,'') + ','
	Set @DenominatorExcludeTrcType3List= ',' + ISNULL(@DenominatorExcludeTrcType3List,'') + ','
	Set @DenominatorExcludeTrcType4List= ',' + ISNULL(@DenominatorExcludeTrcType4List,'') + ','
	Set @DenominatorExcludeTrcCompanyList= ',' + ISNULL(@DenominatorExcludeTrcCompanyList,'') + ','
	Set @DenominatorExcludeTrcDivisionList= ',' + ISNULL(@DenominatorExcludeTrcDivisionList,'') + ','
	Set @DenominatorExcludeTrcTerminalList= ',' + ISNULL(@DenominatorExcludeTrcTerminalList,'') + ','
	Set @DenominatorExcludeTrcFleetList= ',' + ISNULL(@DenominatorExcludeTrcFleetList,'') + ','
	Set @DenominatorExcludeTrcBranchList= ',' + ISNULL(@DenominatorExcludeTrcBranchList,'') + ','

	Declare @NumeratorList Table (lgh_tractor varchar(12), lgh_startdate datetime,lgh_enddate datetime, ord_hdrnumber varchar(10))
	Declare @DenominatorList Table (lgh_tractor varchar(12))

   -- update expiration set exp_completed = 'N' where exp_lastdate < getdate() and exp_code not in ('OUT','ICFM','INS')  

----------NUMERADOR TRACTOS TRABAJANDO (QUE TIENEN UNA ORDEN ASIGNADA)-----------------------------------------------------------------------------------------------------------------------------

	If @Numerator = 'Working'
		Begin
			Insert into @NumeratorList (lgh_tractor,lgh_startdate,lgh_enddate, ord_hdrnumber)
			select distinct substring(RNT.lgh_tractor,1,10), (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber)
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_TractorCache_Final TCF (NOLOCK) on RNT.lgh_tractor = TCF.tractor_id
			where
            --orderheader.ord_completiondate > @DateStart AND orderheader.ord_startdate < @DateEnd AND 
            day(@dateStart) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            and month(@dateStart) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            and year(@dateStart) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)
            AND RNT.lgh_tractor <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TCF.tractor_DateStart AND RNT.lgh_startdate < TCF.tractor_DateEnd
           -- and (select count(stp_lgh_status) from stops where  stp_lgh_status = 'STD' and stops.ord_hdrnumber = orderheader.ord_hdrnumber) > 0
       

			-- transaction-grain filters
			AND (@OnlyRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @OnlyRevType1List) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @OnlyRevType2list) > 0)
			AND (@OnlyRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @OnlyRevType3List) > 0)
			AND (@OnlyRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @OnlyRevType4List) > 0)

			AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @ExcludeRevType1List) = 0)
			AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @ExcludeRevType2List) = 0)
			AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @ExcludeRevType3List) = 0)
			AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @ExcludeRevType4List) = 0)

			AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
			AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
			AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

			AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
			AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
			AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

			AND (@NumeratorOnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @NumeratorOnlyTrcType1List) > 0)
			AND (@NumeratorOnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @NumeratorOnlyTrcType2List) > 0)
			AND (@NumeratorOnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @NumeratorOnlyTrcType3List) > 0)
			AND (@NumeratorOnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @NumeratorOnlyTrcType4List) > 0)
			AND (@NumeratorOnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @NumeratorOnlyTrcCompanyList) > 0)
			AND (@NumeratorOnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @NumeratorOnlyTrcDivisionList) > 0)
			AND (@NumeratorOnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @NumeratorOnlyTrcTerminalList) > 0)
			AND (@NumeratorOnlyTrcFleetList =',,' or CHARINDEX(',' + cast(L.trc_fleet as varchar) + ',', @NumeratorOnlyTrcFleetList) > 0)
			AND (@NumeratorOnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @NumeratorOnlyTrcBranchList) > 0)

			AND (@NumeratorExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @NumeratorExcludeTrcType1List) = 0)
			AND (@NumeratorExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @NumeratorExcludeTrcType2List) = 0)
			AND (@NumeratorExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @NumeratorExcludeTrcType3List) = 0)
			AND (@NumeratorExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @NumeratorExcludeTrcType4List) = 0)
			AND (@NumeratorExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @NumeratorExcludeTrcCompanyList) = 0)
			AND (@NumeratorExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @NumeratorExcludeTrcDivisionList) = 0)
			AND (@NumeratorExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @NumeratorExcludeTrcTerminalList) = 0)
			AND (@NumeratorExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @NumeratorExcludeTrcFleetList) = 0)
			AND (@NumeratorExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @NumeratorExcludeTrcBranchList) = 0)
		End

----------NUMERADOR CUENTA TRACTORES TOTAL, HISTORICAL, OOS, OOSJ,OOSM-----------------------------------------------------------------------------------------------------------------------------

	Else -- @TypeOfTractorCount <> 'Working'
		Begin
			Insert into @NumeratorList (lgh_tractor)
			Select  substring(tractor,1,10)
			from dbo.fnc_TMWRN_TractorCount3 
					(
						@Numerator,@NumeratorOnlyTrcType1List,@NumeratorOnlyTrcType2List
						,@NumeratorOnlyTrcType3List,@NumeratorOnlyTrcType4List
						,@NumeratorOnlyTrcCompanyList,@NumeratorOnlyTrcDivisionList
						,@NumeratorOnlyTrcTerminalList,@NumeratorOnlyTrcFleetList,@NumeratorOnlyTrcBranchList
						,@NumeratorExcludeTrcType1List,@NumeratorExcludeTrcType2List
						,@NumeratorExcludeTrcType3List,@NumeratorExcludeTrcType4List
						,@NumeratorExcludeTrcCompanyList,@NumeratorExcludeTrcDivisionList
						,@NumeratorExcludeTrcTerminalList,@NumeratorExcludeTrcFleetList
						,@NumeratorExcludeTrcBranchList,@DateStart
					)
		End

----------DENOMINADOR CUENTA TRACTORES TOTAL, HISTORICAL, OOS, OOSJ,OOSM-----------------------------------------------------------------------------------------------------------------------------

	
			Insert into @DenominatorList (lgh_tractor)
			Select substring(Tractor,1,10)
			from dbo.fnc_TMWRN_TractorCount3 
				(
					@Denominator,@DenominatorOnlyTrcType1List,@DenominatorOnlyTrcType2List
					,@DenominatorOnlyTrcType3List,@DenominatorOnlyTrcType4List
					,@DenominatorOnlyTrcCompanyList,@DenominatorOnlyTrcDivisionList
					,@DenominatorOnlyTrcTerminalList,@DenominatorOnlyTrcFleetList,@DenominatorOnlyTrcBranchList
					,@DenominatorExcludeTrcType1List,@DenominatorExcludeTrcType2List
					,@DenominatorExcludeTrcType3List,@DenominatorExcludeTrcType4List
					,@DenominatorExcludeTrcCompanyList,@DenominatorExcludeTrcDivisionList
					,@DenominatorExcludeTrcTerminalList,@DenominatorExcludeTrcFleetList
					,@DenominatorExcludeTrcBranchList,@DateStart
				)
	


---------ASIGNACION DE LOS RESULTADOS A LAS VARIBLES TOTALES TRACTOR COUNT----------------------------------------------------------------------------------------------------------------------------

  --creamos variable tabla para eliminar repetidos en la cuenta.

      Declare @NumeratorRes Table (trac varchar(12))
      Insert into @NumeratorRes (trac)
      (Select distinct lgh_tractor from @NumeratorList)


      Declare @NumeratorSinVenta Table (trac varchar(12))
      Insert into @NumeratorSinVenta (trac)
      (Select distinct lgh_tractor from @NumeratorList
         where     lgh_tractor  in (select trc_number from tractorprofile where trc_type3 <> 'PRU')  )

	-- set the Metric Numerator & Denominator values
	if @numerator = 'WORKING'
       BEGIN
       Set @ThisCount = (Select distinct count(trac) from @NumeratorRes)
       END
   else if   @numerator = 'UNSEATED'
       Set @ThisCount = (Select distinct count(trac) from @NumeratorSinVenta)
   else 
       BEGIN
       Set @ThisCount = (Select distinct count(lgh_Tractor) from @NumeratorList)
       END
 
      
	Set @ThisTotal =
		Case When @Denominator = 'Day' then 
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		Else
			(Select distinct count(lgh_tractor) from @DenominatorList)
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

-----------------VISTA DETALLES DE LA METRICA TRACTOR COUNT-----------------------------------------------------------------------------------------------------------------------------------------

-----------------TRACTORES INACTIVOS----------------------------------------------------------------------------------------------------------------------------------------------------------------

 If @ShowDetail = 1 and @numerator = 'Working'
		BEGIN
			  
Select
            Tractor = lgh_tractor,
			Estatus = 'Trabajando',
          --Diassinasignar = (select datediff(d,trc_avl_date,getdate()) from tractorprofile where trc_number = lgh_tractor),
           -- Status = case when (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_tractor = t.lgh_tractor)>= 0 then
          --  'Horas Inactivo: ' else  'Por iniciar leg en:' end, 
            Horas  = case when (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_tractor = t.lgh_tractor)< 1 then
           (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_tractor = t.lgh_tractor) * -1 else (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_tractor = t.lgh_tractor) end    ,
            Flota = (select name from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
           -- Division = (select trc_type4 from tractorprofile with (nolock) where lgh_tractor = tractorprofile.trc_number),
            Escuderia = (select name from labelfile where labeldefinition = 'teamleader' and abbr =(select trc_teamleader from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)),
			Operador = replace((select trc_driver from tractorprofile with (nolock) where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            RegionActual = (select rgh_name from regionheader with (nolock)  where rgh_id =( select trc_prior_region1  from  tractorprofile where trc_number = lgh_tractor)),
            Ubicacion  = (select trc_gps_desc from tractorprofile  with (nolock) where lgh_tractor = tractorprofile.trc_number)

			From @DenominatorList t where lgh_tractor not in (Select Tractor = lgh_tractor From @NumeratorList) 
            -- and (select datediff(d,trc_avl_date,getdate()) from tractorprofile where trc_number = lgh_tractor)  > 0
            Order by (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_tractor = t.lgh_tractor) desc 
		END


 ELSE If @ShowDetail = 1 and @numerator in ('OOSJ','OOSM','OOS')
		BEGIN
		    Select 
            Tractor = lgh_tractor, 
           -- Orden = (select max(ord_number) from orderheader where ord_tractor = lgh_tractor and year(ord_startdate) = year(getdate())  and ord_number <'A' ),
            Flota = (select name from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
            Division = (select trc_type4 from tractorprofile with (nolock) where lgh_tractor = tractorprofile.trc_number),
            Operador = replace((select trc_driver from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            ComentarioTMW = (select  exp_description from expiration  with (nolock)where exp_id = lgh_tractor and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration with (nolock) where exp_id = lgh_tractor and exp_Completed = 'N')),
            FechaInicioInactivo = (select max(exp_creatdate)   from expiration with (nolock) where exp_id = lgh_tractor and exp_Completed = 'N'),
            DiasInactivo = datediff(d, (select max(exp_creatdate)  from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N'),getdate()),
            Ubicacion = (select trc_gps_desc from tractorprofile with (nolock) where lgh_tractor = tractorprofile.trc_number)
			From @NumeratorList
            order by tractor
		END

 ELSE If @ShowDetail = 1 and @numerator = 'Unseated'
		BEGIN
		    Select 
            Tractor = lgh_tractor, 
			Estatus = 'Sin Operador',
           -- Orden = (select max(ord_number) from orderheader where ord_tractor = lgh_tractor and year(ord_startdate) = year(getdate())  and ord_number <'A' ),
            Flota = (select name from labelfile  with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
            Escuderia = (select name from labelfile where labeldefinition = 'teamleader' and abbr =(select trc_teamleader from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)),

			DiasInactivo = datediff(dd, (select max(exp_creatdate)  from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N' and
			 exp_code = (select trc_Status from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number) ),getdate()),
            Operador = replace((select trc_driver from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            Ubicacion = (select trc_gps_desc from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)

			

			From @NumeratorList
            where  lgh_tractor in (select trac from @NumeratorSinVenta) 

            order by Estatus,tractor
		END


 ELSE If @ShowDetail = 1 and @numerator = 'Seated'
		BEGIN
		    Select 
            Tractor = lgh_tractor, 
			Estatus = 'Con Operador (asignado)',
           -- Orden = (select max(ord_number) from orderheader where ord_tractor = lgh_tractor and year(ord_startdate) = year(getdate())  and ord_number <'A' ),
            Flota = (select name from labelfile  with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
            Escuderia = (select name from labelfile where labeldefinition = 'teamleader' and abbr =(select trc_teamleader from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)),

			--DiasInactivo = datediff(dd, (select max(exp_creatdate)  from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N' and
			-- exp_code = (select trc_Status from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number) ),getdate()),
            Operador = replace((select trc_driver from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            Ubicacion = (select trc_gps_desc from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)

			

			From @NumeratorList
            where  lgh_tractor in (select trac from @NumeratorSinVenta) 

            order by Estatus,tractor
		END


	--	select * from expiration where exp_id = '1110' and exp_completed = 'N'

  ELSE If @ShowDetail = 1
		BEGIN
			Select
            Tractor = lgh_tractor,
            DiasInactivo = (select  datediff(d,exp_creatdate,getdate())  from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration   with (nolock) where exp_id = lgh_tractor and exp_Completed = 'N')),

            Flota = (select name from labelfile  with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
            Division = (select trc_type4 from tractorprofile  with (nolock) where lgh_tractor = tractorprofile.trc_number),
            Operador = replace((select trc_driver   from tractorprofile with (nolock) where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            Razon = ( select name from labelfile  with (nolock)  where labeldefinition = 'TrcExp' and abbr = (select  exp_code from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration  with (nolock) where exp_id = lgh_tractor and exp_Completed = 'N'))),
            ComentarioTMW = (select  exp_description from expiration   with (nolock) where exp_id = lgh_tractor and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration  with (nolock)  where exp_id = lgh_tractor and exp_Completed = 'N')),
            Ubicacion  = (select trc_gps_desc from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number)

			From @DenominatorList  where lgh_tractor not in (Select Tractor = lgh_tractor From @NumeratorList)
            Order by diasinactivo desc
		END


-----------------TRACTORES TRABAJANDO----------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    If @ShowDetail = 2 and @numerator in ('Unseated')
    begin
	Select 
         Mensaje = 'No hay detalle para esta metrica'

   end




  If @ShowDetail = 2 and @numerator in ('OOSJ','OOSM','OOS')
    begin
	Select 
            Tractor = lgh_tractor, 
            Flota = (select name from labelfile with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = lgh_tractor)),
            Division = (select trc_type4 from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number),
            Operador = replace((select trc_driver from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            Ubicacion = (select trc_gps_desc from tractorprofile  with (nolock) where lgh_tractor = tractorprofile.trc_number)
			From @DenominatorList
            order by cast(lgh_tractor as int)

   end


-----------DETALLE TRACTORES TRABAJANDO--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	ELSE If @ShowDetail = 2 and @Numerator = 'Working'
		BEGIN
			Select 
            Tractor = lgh_tractor,
			Estatus = 'No trabajando (Con operador)'
           ---,Orden = ord_hdrnumber
           --,FechaIni =  lgh_startdate
          -- ,FechaFin = lgh_enddate
            ,Flota = (select name from labelfile with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile with (nolock)  where tractorprofile.trc_number = lgh_tractor))
            --,Division = (select trc_type4 from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number)
            ,Escuderia = (select name from labelfile where labeldefinition = 'teamleader' and abbr =(select trc_teamleader from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number))
			,Operador = replace((select trc_driver from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.')
            ,Ubicacion = substring((select trc_gps_desc from tractorprofile with (nolock)   where lgh_tractor = tractorprofile.trc_number),1,100)
			From @DenominatorList
            where lgh_tractor  not in (Select Tractor = lgh_tractor From @NumeratorList) 

            order by lgh_tractor desc 

		END

			ELSE If @ShowDetail = 2  
		BEGIN
			Select 
            Tractor = lgh_tractor
           ---,Orden = ord_hdrnumber
           --,FechaIni =  lgh_startdate
          -- ,FechaFin = lgh_enddate
            ,Flota = (select name from labelfile with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile with (nolock)  where tractorprofile.trc_number = lgh_tractor))
            --,Division = (select trc_type4 from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number)
            ,Escuderia = (select name from labelfile where labeldefinition = 'teamleader' and abbr =(select trc_teamleader from tractorprofile  with (nolock)  where lgh_tractor = tractorprofile.trc_number))
			,Operador = replace((select trc_driver from tractorprofile with (nolock)  where lgh_tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.')
            ,Ubicacion = substring((select trc_gps_desc from tractorprofile with (nolock)   where lgh_tractor = tractorprofile.trc_number),1,100)
			From @NumeratorList
            where lgh_tractor  in (Select Tractor = lgh_tractor From @NumeratorList) 

            order by lgh_tractor desc 

		END



	SET NOCOUNT OFF




-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'TractorCount',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Tractor Count Metrics',
		@sCaptionFull = 'Tractor Count Metrics',
		@sProcedureName = 'Metric_TractorCount',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_TractorCount] TO [public]
GO
