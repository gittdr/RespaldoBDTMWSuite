SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_TrailerCount]
	(
        @Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

	-- Additional / Optional Parameters
		@Numerator varchar(20) = 'Current',			-- Seated, Unseated, Working, Current, Total, OOSJ, OOSM, OOS
		@Denominator varchar(20) = 'Day',			-- Current, Total, Historical, OOS, Day
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

	-- parameters for Numerator Trailer Count ONLY
		@NumeratorOnlyTrlType1List varchar(255) = '',
		@NumeratorOnlyTrlType2List varchar(255) = '',
		@NumeratorOnlyTrlType3List varchar(255) = '',
		@NumeratorOnlyTrlType4List varchar(255) = '',
		@NumeratorOnlyTrlCompanyList varchar(255) = '',
		@NumeratorOnlyTrlDivisionList varchar(255) = '',
		@NumeratorOnlyTrlTerminalList varchar(255) = '',
		@NumeratorOnlyTrlFleetList varchar(255) = '',
		@NumeratorOnlyTrlBranchList varchar(255) = '',

		@NumeratorExcludeTrlType1List varchar(255) = '',
		@NumeratorExcludeTrlType2List varchar(255) = '',
		@NumeratorExcludeTrlType3List varchar(255) = '',
		@NumeratorExcludeTrlType4List varchar(255) = '',
		@NumeratorExcludeTrlCompanyList varchar(255) = '',
		@NumeratorExcludeTrlDivisionList varchar(255) = '',
		@NumeratorExcludeTrlTerminalList varchar(255) = '',
		@NumeratorExcludeTrlFleetList varchar(255) = '',
		@NumeratorExcludeTrlBranchList varchar(255) = '',

	-- parameters for Denominator Trailer Count ONLY
		@DenominatorOnlyTrlType1List varchar(255) = '',
		@DenominatorOnlyTrlType2List varchar(255) = '',
		@DenominatorOnlyTrlType3List varchar(255) = '',
		@DenominatorOnlyTrlType4List varchar(255) = '',
		@DenominatorOnlyTrlCompanyList varchar(255) = '',
		@DenominatorOnlyTrlDivisionList varchar(255) = '',
		@DenominatorOnlyTrlTerminalList varchar(255) = '',
		@DenominatorOnlyTrlFleetList varchar(255) = '',
		@DenominatorOnlyTrlBranchList varchar(255) = '',

		@DenominatorExcludeTrlType1List varchar(255) = '',
		@DenominatorExcludeTrlType2List varchar(255) = '',
		@DenominatorExcludeTrlType3List varchar(255) = '',
		@DenominatorExcludeTrlType4List varchar(255) = '',
		@DenominatorExcludeTrlCompanyList varchar(255) = '',
		@DenominatorExcludeTrlDivisionList varchar(255) = '',
		@DenominatorExcludeTrlTerminalList varchar(255) = '',
		@DenominatorExcludeTrlFleetList varchar(255) = '',
		@DenominatorExcludeTrlBranchList varchar(255) = '',

		@MetricCode varchar(255)= 'TrailerCount'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Inactivos,2:Trabajando

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

	Set @NumeratorOnlyTrlType1List= ',' + ISNULL(@NumeratorOnlyTrlType1List,'') + ','
	Set @NumeratorOnlyTrlType2List= ',' + ISNULL(@NumeratorOnlyTrlType2List,'') + ','
	Set @NumeratorOnlyTrlType3List= ',' + ISNULL(@NumeratorOnlyTrlType3List,'') + ','
	Set @NumeratorOnlyTrlType4List= ',' + ISNULL(@NumeratorOnlyTrlType4List,'') + ','
	Set @NumeratorOnlyTrlCompanyList= ',' + ISNULL(@NumeratorOnlyTrlCompanyList,'') + ','
	Set @NumeratorOnlyTrlDivisionList= ',' + ISNULL(@NumeratorOnlyTrlDivisionList,'') + ','
	Set @NumeratorOnlyTrlTerminalList= ',' + ISNULL(@NumeratorOnlyTrlTerminalList,'') + ','
	Set @NumeratorOnlyTrlFleetList= ',' + ISNULL(@NumeratorOnlyTrlFleetList,'') + ','
	Set @NumeratorOnlyTrlBranchList= ',' + ISNULL(@NumeratorOnlyTrlBranchList,'') + ','

	Set @NumeratorExcludeTrlType1List= ',' + ISNULL(@NumeratorExcludeTrlType1List,'') + ','
	Set @NumeratorExcludeTrlType2List= ',' + ISNULL(@NumeratorExcludeTrlType2List,'') + ','
	Set @NumeratorExcludeTrlType3List= ',' + ISNULL(@NumeratorExcludeTrlType3List,'') + ','
	Set @NumeratorExcludeTrlType4List= ',' + ISNULL(@NumeratorExcludeTrlType4List,'') + ','
	Set @NumeratorExcludeTrlCompanyList= ',' + ISNULL(@NumeratorExcludeTrlCompanyList,'') + ','
	Set @NumeratorExcludeTrlDivisionList= ',' + ISNULL(@NumeratorExcludeTrlDivisionList,'') + ','
	Set @NumeratorExcludeTrlTerminalList= ',' + ISNULL(@NumeratorExcludeTrlTerminalList,'') + ','
	Set @NumeratorExcludeTrlFleetList= ',' + ISNULL(@NumeratorExcludeTrlFleetList,'') + ','
	Set @NumeratorExcludeTrlBranchList= ',' + ISNULL(@NumeratorExcludeTrlBranchList,'') + ','

	Set @DenominatorOnlyTrlType1List= ',' + ISNULL(@DenominatorOnlyTrlType1List,'') + ','
	Set @DenominatorOnlyTrlType2List= ',' + ISNULL(@DenominatorOnlyTrlType2List,'') + ','
	Set @DenominatorOnlyTrlType3List= ',' + ISNULL(@DenominatorOnlyTrlType3List,'') + ','
	Set @DenominatorOnlyTrlType4List= ',' + ISNULL(@DenominatorOnlyTrlType4List,'') + ','
	Set @DenominatorOnlyTrlCompanyList= ',' + ISNULL(@DenominatorOnlyTrlCompanyList,'') + ','
	Set @DenominatorOnlyTrlDivisionList= ',' + ISNULL(@DenominatorOnlyTrlDivisionList,'') + ','
	Set @DenominatorOnlyTrlTerminalList= ',' + ISNULL(@DenominatorOnlyTrlTerminalList,'') + ','
	Set @DenominatorOnlyTrlFleetList= ',' + ISNULL(@DenominatorOnlyTrlFleetList,'') + ','
	Set @DenominatorOnlyTrlBranchList= ',' + ISNULL(@DenominatorOnlyTrlBranchList,'') + ','

	Set @DenominatorExcludeTrlType1List= ',' + ISNULL(@DenominatorExcludeTrlType1List,'') + ','
	Set @DenominatorExcludeTrlType2List= ',' + ISNULL(@DenominatorExcludeTrlType2List,'') + ','
	Set @DenominatorExcludeTrlType3List= ',' + ISNULL(@DenominatorExcludeTrlType3List,'') + ','
	Set @DenominatorExcludeTrlType4List= ',' + ISNULL(@DenominatorExcludeTrlType4List,'') + ','
	Set @DenominatorExcludeTrlCompanyList= ',' + ISNULL(@DenominatorExcludeTrlCompanyList,'') + ','
	Set @DenominatorExcludeTrlDivisionList= ',' + ISNULL(@DenominatorExcludeTrlDivisionList,'') + ','
	Set @DenominatorExcludeTrlTerminalList= ',' + ISNULL(@DenominatorExcludeTrlTerminalList,'') + ','
	Set @DenominatorExcludeTrlFleetList= ',' + ISNULL(@DenominatorExcludeTrlFleetList,'') + ','
	Set @DenominatorExcludeTrlBranchList= ',' + ISNULL(@DenominatorExcludeTrlBranchList,'') + ','

    Declare @NumeratorList Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20),ord_hdrnumber varchar(10), lgh_startdate datetime, lgh_enddate datetime, tipore varchar (20) )
	Declare @NumeratorListUno Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20),ord_hdrnumber varchar(10), lgh_startdate datetime, lgh_enddate datetime, tipore varchar (20) )
	Declare @NumeratorListDos Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), tipo varchar (20), subtipo varchar (20),ord_hdrnumber varchar(10), lgh_startdate datetime, lgh_enddate datetime, tipore varchar (20) )
    Declare @DenominatorList Table (lgh_Trailer varchar(12), fleet varchar(20), div varchar(12), fechaini datetime, stat varchar(50), horas int)

----------NUMERADOR TRAILERS TRABAJANDO (QUE TIENEN UNA ORDEN ASIGNADA)-----------------------------------------------------------------------------------------------------------------------------

	If @Numerator = 'Working'
		Begin
			Insert into @NumeratorListUno (lgh_Trailer,lgh_startdate,lgh_enddate, ord_hdrnumber, tipore)
			
            select distinct substring(RNT.lgh_Trailer1,1,10), (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber), 'Remolque 1'
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_TrailerCache_Final TDF (NOLOCK) on RNT.lgh_Trailer1 = TDF.Trailer_id
			where 
            day(@dateStart) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            and month(@dateStart) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            and year(@dateStart) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)
			AND RNT.lgh_Trailer1 <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TDF.Trailer_DateStart AND RNT.lgh_startdate < TDF.Trailer_DateEnd
            and  (select max(trl_owner) from trailerprofile where trl_number = lgh_trailer1)=  'TDR'
         

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

			AND (@NumeratorOnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @NumeratorOnlyTrlType1List) > 0)
			AND (@NumeratorOnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @NumeratorOnlyTrlType2List) > 0)
			AND (@NumeratorOnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @NumeratorOnlyTrlType3List) > 0)
			AND (@NumeratorOnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @NumeratorOnlyTrlType4List) > 0)
			AND (@NumeratorOnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @NumeratorOnlyTrlCompanyList) > 0)
			AND (@NumeratorOnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @NumeratorOnlyTrlDivisionList) > 0)
			AND (@NumeratorOnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @NumeratorOnlyTrlTerminalList) > 0)
			AND (@NumeratorOnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @NumeratorOnlyTrlFleetList) > 0)
			AND (@NumeratorOnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @NumeratorOnlyTrlBranchList) > 0)

			AND (@NumeratorExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @NumeratorExcludeTrlType1List) = 0)
			AND (@NumeratorExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @NumeratorExcludeTrlType2List) = 0)
			AND (@NumeratorExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @NumeratorExcludeTrlType3List) = 0)
			AND (@NumeratorExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @NumeratorExcludeTrlType4List) = 0)
			AND (@NumeratorExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @NumeratorExcludeTrlCompanyList) = 0)
			AND (@NumeratorExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @NumeratorExcludeTrlDivisionList) = 0)
			AND (@NumeratorExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @NumeratorExcludeTrlTerminalList) = 0)
			AND (@NumeratorExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @NumeratorExcludeTrlFleetList) = 0)
			AND (@NumeratorExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @NumeratorExcludeTrlBranchList) = 0)


		End


---------NUMERADOR 2 PARA EL SEGUNDO REMOLQUE-----------------------------------------------------------------------------------------------------------------------------------------------------------

	If @Numerator = 'Working'
		Begin
			Insert into @NumeratorListDos (lgh_Trailer,lgh_startdate,lgh_enddate, ord_hdrnumber, tipore)
			
            select distinct substring(RNT.lgh_Trailer2,1,10), (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber),'Remolque 2'
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_TrailerCache_Final TDF (NOLOCK) on RNT.lgh_Trailer2 = TDF.Trailer_id
			where 
            day(@dateStart) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            and month(@dateStart) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            and year(@dateStart) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)
			AND RNT.lgh_Trailer2 <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TDF.Trailer_DateStart AND RNT.lgh_startdate < TDF.Trailer_DateEnd
            and  (select max(trl_owner) from trailerprofile where trl_number = lgh_trailer2)=  'TDR'
         

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

			AND (@NumeratorOnlyTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @NumeratorOnlyTrlType1List) > 0)
			AND (@NumeratorOnlyTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @NumeratorOnlyTrlType2List) > 0)
			AND (@NumeratorOnlyTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @NumeratorOnlyTrlType3List) > 0)
			AND (@NumeratorOnlyTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @NumeratorOnlyTrlType4List) > 0)
			AND (@NumeratorOnlyTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @NumeratorOnlyTrlCompanyList) > 0)
			AND (@NumeratorOnlyTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @NumeratorOnlyTrlDivisionList) > 0)
			AND (@NumeratorOnlyTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @NumeratorOnlyTrlTerminalList) > 0)
			AND (@NumeratorOnlyTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @NumeratorOnlyTrlFleetList) > 0)
			AND (@NumeratorOnlyTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @NumeratorOnlyTrlBranchList) > 0)

			AND (@NumeratorExcludeTrlType1List =',,' or CHARINDEX(',' + TDF.trailer_type1 + ',', @NumeratorExcludeTrlType1List) = 0)
			AND (@NumeratorExcludeTrlType2List =',,' or CHARINDEX(',' + TDF.trailer_type2 + ',', @NumeratorExcludeTrlType2List) = 0)
			AND (@NumeratorExcludeTrlType3List =',,' or CHARINDEX(',' + TDF.trailer_type3 + ',', @NumeratorExcludeTrlType3List) = 0)
			AND (@NumeratorExcludeTrlType4List =',,' or CHARINDEX(',' + TDF.trailer_type4 + ',', @NumeratorExcludeTrlType4List) = 0)
			AND (@NumeratorExcludeTrlCompanyList =',,' or CHARINDEX(',' + TDF.trailer_company + ',', @NumeratorExcludeTrlCompanyList) = 0)
			AND (@NumeratorExcludeTrlDivisionList =',,' or CHARINDEX(',' + TDF.trailer_division + ',', @NumeratorExcludeTrlDivisionList) = 0)
			AND (@NumeratorExcludeTrlTerminalList =',,' or CHARINDEX(',' + TDF.trailer_terminal + ',', @NumeratorExcludeTrlTerminalList) = 0)
			AND (@NumeratorExcludeTrlFleetList =',,' or CHARINDEX(',' + TDF.trailer_fleet + ',', @NumeratorExcludeTrlFleetList) = 0)
			AND (@NumeratorExcludeTrlBranchList =',,' or CHARINDEX(',' + TDF.trailer_branch + ',', @NumeratorExcludeTrlBranchList) = 0)


		End




----------NUMERADOR CUENTA TRAILERS TOTAL, HISTORICAL, OOS, OOSJ,OOSM-----------------------------------------------------------------------------------------------------------------------------

	Else -- @TypeOfTrailerCount <> 'Working'
		Begin
			Insert into @NumeratorList (lgh_Trailer)
			Select SUBSTRING(Trailer,1,10)
			from dbo.fnc_TMWRN_TrailerCount3 
					(
						@Numerator,@NumeratorOnlyTrlType1List,@NumeratorOnlyTrlType2List
						,@NumeratorOnlyTrlType3List,@NumeratorOnlyTrlType4List
						,@NumeratorOnlyTrlCompanyList,@NumeratorOnlyTrlDivisionList
						,@NumeratorOnlyTrlTerminalList,@NumeratorOnlyTrlFleetList,@NumeratorOnlyTrlBranchList
						,@NumeratorExcludeTrlType1List,@NumeratorExcludeTrlType2List
						,@NumeratorExcludeTrlType3List,@NumeratorExcludeTrlType4List
						,@NumeratorExcludeTrlCompanyList,@NumeratorExcludeTrlDivisionList
						,@NumeratorExcludeTrlTerminalList,@NumeratorExcludeTrlFleetList
						,@NumeratorExcludeTrlBranchList,@DateStart
					)
		End

---agregamos los resultados del segundo remolque.

insert into @NumeratorList select * from @NumeratorListDos 
union select * from @NumeratorListUno

--hacemos respectivos updates para datos adicionales

update @NumeratorList set fleet = (select max(name) from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select max(trl_fleet) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @NumeratorList set div = (select max(trl_type4) from trailerprofile where lgh_trailer = trailerprofile.trl_number)
update @NumeratorList set subtipo = ( select max(name) from labelfile where labeldefinition = 'TrlType1' and abbr = (select max(trl_type1) from trailerprofile where trailerprofile.trl_number = lgh_trailer))
update @NumeratorList set tipo = (select max( trl_equipmenttype) from trailerprofile where trailerprofile.trl_number = lgh_trailer)


delete from @NumeratorList where lgh_trailer in ( ( select trl_number from trailerprofile where trl_owner <> 'TDR')) 
	
----------DENOMINADOR CUENTA TRAILERS CURRENT----------------------------------------------------------------------------------------------------------------------------


			Insert into @DenominatorList (lgh_Trailer, fleet, div, fechaini)
		    

	            Select 
                distinct substring(replace(replace(trailer_id,',',''),'.',''),1,10)
                ,fleet = (select max(name) from labelfile with (nolock)  where labelfile.labeldefinition = 'Fleet' and abbr = trailer_fleet)
			    ,div =   trailer_type4
                ,fechaini = (select max(trl_avail_date)   from trailerprofile with (nolock) where trl_number = trailer_id)


                /* case  when (select max(lgh_Startdate) from ResNow_Triplets RNT where RNT.lgh_trailer1 = trailer_id) < 
                 isnull((select max(lgh_Startdate) from ResNow_Triplets RNT where RNT.lgh_trailer2 = trailer_id),0)
                 then (select max(lgh_Startdate) from ResNow_Triplets RNT where RNT.lgh_trailer2 = Trailer_id) else (select max(lgh_Startdate) from ResNow_Triplets RNT where RNT.lgh_trailer1 = Trailer_id) end
                */

                FROM ResNow_TrailerCache_Final RNTCF (NOLOCK) 

			    Where (trailer_retiredate > @Datestart AND trailer_startdate <= @DateStart)
				AND trailer_id <> 'UNKNOWN'
                and Trailer_fleet <> '17'
                     -- Expiration OUT
                and trailer_id not in ( select exp_id from expiration with (nolock)  where exp_code = 'OUT' and exp_idtype='TRL')
				and trailer_id not in ( Select  substring(exp_id ,1,10) FROM expiration WITH (NOLOCK)   WHERE exp_idtype='TRL'  and exp_code not in ('OUT','ICFM','INS')  and exp_completed <> 'Y' and exp_id  in ( select trl_number from trailerprofile where trl_owner = 'TDR')     )
                and trailer_owner = 'TDR'
                

              

                update @DenominatorList set stat = case when datediff(hh,fechaini,getdate()) >= 0 then 'Horas Inactivo: ' else  'Por iniciar leg en:' end 
                update @DenominatorList set horas =  case when datediff(hh,fechaini,getdate()) < 1  then  datediff(hh,fechaini,getdate()) * -1 else datediff(hh,fechaini,getdate()) end 

                delete from @DenominatorList where lgh_trailer in ( ( select trl_number from trailerprofile where trl_owner <> 'TDR')) 



---------ASIGNACION DE LOS RESULTADOS A LAS VARIBLES TOTALES TRAILER COUNT----------------------------------------------------------------------------------------------------------------------------

 Declare @NumeratorRes Table (trail varchar(12))
      Insert into @NumeratorRes (trail)
      (Select distinct lgh_trailer from @NumeratorList)

	-- set the Metric Numerator & Denominator values
	if @numerator = 'WORKING'
       BEGIN
       Set @ThisCount = (Select distinct count(trail) from @NumeratorRes)
       END
    else 
       BEGIN
       Set @ThisCount = (Select distinct count(lgh_Trailer) from @NumeratorList)
       END


set  @ThisTotal =
		Case When @Denominator = 'Day' then 
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		Else
			(Select count(lgh_trailer) from @DenominatorList)
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / 1 END 


-----------------VISTA DETALLES DE LA METRICA TRAILER COUNT-----------------------------------------------------------------------------------------------------------


--------DETALLE REMOLQUES INACTIVOS-------------------------------------------------------------------------------------------------------------------------------------------------------

 If @ShowDetail = 1 and @numerator = 'Working'
		BEGIN
			  
Select
            Remolque = lgh_trailer
           -- ,ini = fechaini
            ,Status = stat
            ,Horas  = horas
            ,Flota = fleet
            ,Division = div
            ,RegionActual = (select max(rgh_name) from regionheader (NOLOCK) where rgh_id =( select max(trl_prior_region1) from  trailerprofile where trl_number = lgh_trailer))

			From @DenominatorList t  where t.lgh_trailer not in (Select lgh_trailer  From @NumeratorListUno) 
            and t.lgh_trailer not in (Select lgh_trailer  From @NumeratorListDos) 
            -- and (select datediff(d,trc_avl_date,getdate()) from tractorprofile where trc_number = lgh_tractor)  > 0
           Order by horas desc  


		END





 ELSE If @ShowDetail = 1 and @numerator in ('OOSJ','OOSM','OOS')
		BEGIN
		    Select 
            Remolque = lgh_trailer, 
            Tipo = ( select name from labelfile with (nolock) where labeldefinition = 'TrlType1' and abbr = (select trl_type1 from trailerprofile where trailerprofile.trl_number = lgh_trailer)),
           -- Orden = (select max(ord_number) from orderheader where ord_trailer = lgh_trailer and year(ord_startdate) = year(getdate())  and ord_number <'A' ),
            Flota = (select name from labelfile with (nolock) where labelfile.labeldefinition = 'Fleet' and abbr = (select trl_fleet from trailerprofile where trailerprofile.trl_number = lgh_trailer)),
            Division = (select trl_type4 from trailerprofilewith (nolock)  where lgh_trailer = trailerprofile.trl_number),
            ComentarioTMW = (select  exp_description from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N' 
            and  exp_key = (select max(exp_key) from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N')),
            FechaInicioInactivo = (select max(exp_creatdate)  from expiration with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N'),
            DiasInactivo = datediff(d, (select max(exp_creatdate)  from expiration  with (nolock) where exp_id = lgh_trailer and exp_Completed = 'N'),getdate())
            
			From @NumeratorList
            order by Remolque
		END




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------DETALLE REMOLQUES TRABAJANDO-------------------------------------------------------------------------------------------------------------------------------------------------------
	 If @ShowDetail = 2 and @numerator = 'WORKING'
		BEGIN
			Select 
            Remolque = lgh_trailer
           ,Tipo = tipore
           ,Orden = ord_hdrnumber
           ,FechaIni =  lgh_startdate
           ,FechaFin = lgh_enddate
            ,Flota = fleet
            ,Division = div
			From @NumeratorList

            order by lgh_trailer desc 

		END
/*

	ELSE If @ShowDetail = 2
		BEGIN

			Select 
            Remolque = lgh_trailer, 
            Tipo = ( select name from labelfile where labeldefinition = 'TrlType1' and abbr = (select trl_type1 from trailerprofile where trailerprofile.trl_number = lgh_trailer)),
            Flota = (select name from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select trl_fleet from trailerprofile where trailerprofile.trl_number = lgh_trailer)),
            Division = (select trl_type4 from trailerprofile where lgh_trailer = trailerprofile.trl_number)
            
			From @DenominatorList
            order by Remolque

		END

  */



	SET NOCOUNT OFF

-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'TrailerCount',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Trailer Count Metrics',
		@sCaptionFull = 'Trailer Count Metrics',
		@sProcedureName = 'Metric_TrailerCount',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_TrailerCount] TO [public]
GO
