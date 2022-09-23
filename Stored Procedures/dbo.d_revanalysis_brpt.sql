SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create Procedure [dbo].[d_revanalysis_brpt]

	(
	@stringparm varchar (255)
	)
AS
/**
 * 
 * NAME:
 * dbo.d_revanalysis_brpt
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


DECLARE	@EarlyBillDate 	datetime,
	@LateBillDate 	datetime,
	@coltouse	varchar(4)

Select @coltouse = SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1)
SELECT @stringparm = SUBSTRING(@stringparm, PATINDEX('%,%', @stringparm) + 1, LEN(@stringparm))
Select @earlybilldate = CONVERT( datetime, SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1))
SELECT @stringparm = SUBSTRING(@stringparm, PATINDEX('%,%', @stringparm) + 1, LEN(@stringparm))
Select @latebilldate = CONVERT ( datetime, @stringparm) 

--SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1))

/* Build a list of invoice to include - finding the primary invoice for each order */



Select 
	invoiceheader.ivh_hdrnumber,
	ord_hdrnumber
into #tempInvoiceList
From
	invoiceheader
Where

	(case @coltouse WHEN 'DELV' THEN ivh_deliverydate WHEN 'SHIP' THEN ivh_shipdate 
		WHEN 'BILL' THEN ivh_billdate ELSE ivh_billdate end) between @EarlyBillDate and @LateBillDate

--	ivh_billdate between @EarlyBillDate and @LateBillDate
	and
	ivh_invoicestatus in ('PRN', 'XFR')
	and
	invoiceheader.ivh_hdrnumber =
	(Select 
		min(ivh3.ivh_hdrnumber)
	from
		Invoiceheader ivh3
	where
		invoiceheader.ord_hdrnumber = ivh3.ord_hdrnumber
						
	)	



Select 
	orderheader.ord_number,

	/* Get the sum of the line haul charges for 
	   ALL invoices stemming from this order
	*/
	Isnull(
	(
	Select 
		Sum(IsNull(ivd_charge,0)) 
	From
		InvoiceDetail,
		Invoiceheader inv1,
		ChargeType
	where
		inv1.ord_hdrnumber=orderheader.ord_hdrnumber
		and
		Invoicedetail.ivh_hdrnumber =inv1.ivh_hdrnumber
		and
		ChargeType.cht_itemcode= Invoicedetail.cht_itemcode
		and
		ChargeType.cht_primary='Y'
	),0.00)
	FrtCharge,

	/* Get the sum of the Accessorial charges for 
	   ALL invoices stemming from this order
	*/
	IsNull(
	(
	Select 
		Sum(ISNULL(ivd_charge,0)) 
	From
		invoiceheader inv2,
		InvoiceDetail,
		ChargeType
	where
		inv2.ord_hdrnumber=orderheader.ord_hdrnumber
		and
		Invoicedetail.ivh_hdrnumber =inv2.ivh_hdrnumber
		and
		ChargeType.cht_itemcode= Invoicedetail.cht_itemcode
		and
		ChargeType.cht_primary<>'Y'
	),0.00)
	AccCharge,

	Convert(Float,0.00) TotalCharges,	

	
	/*	Get the sum of the Billable miles for Order 
		From the stops table
	*/
	CONVERT(float, IsNull(
	(
	Select 
		sum(IsNull(stp_ord_mileage,0))
	From
		stops
	where
		stops.mov_number=Invoiceheader.Mov_number
		and
		stops.ord_hdrnumber= Orderheader.ord_hdrnumber
	),0)) BillableMiles,

	/*	Get the sum of the Travel miles for mov_number 
		From the stops table
	*/
	CONVERT(float, IsNull(
	(
	Select 
		sum(IsNull(stp_Lgh_mileage,0))
	From
		stops
	where
		stops.mov_number=Invoiceheader.Mov_number
	),0)) TravelMiles,

	/*	Get the sum of the Empty Travel miles for mov_number 
		From the stops table
	*/
	CONVERT(float, IsNull(
	(
	Select 
		sum(IsNull(stp_Lgh_mileage,0))
	From
		stops
	where
		stops.mov_number=Invoiceheader.Mov_number
		and
		stops.stp_loadstatus<>'LD'
	),0)) EmptyMiles,

	Convert(float,0.0000) MTPercent,

	companyBillto.cmp_name,
	CityOrigin.cty_region1,

	--RegionOrigin.rgh_name,
	(
	Select 	
		rgh_name
	From
		Regionheader
	where
		Rgh_id=	CityOrigin.cty_region1
	)Region1Name,


	CityOrigin.cty_nmstct OriginCity,
	CityOrigin.cty_State OriginState,

	statecountry.stc_state_desc,
	CityDestination.cty_nmstct,
	ivh_billdate  BillDate,


	ivh_revtype1 RevType1Abbr,
	


	ivh_shipdate PUDate,

	

	(
	Select 
		name
	from
		labelfile
	where
		Labelfile.labeldefinition='RevType1'
		and
		Labelfile.Abbr=ivh_revtype1
	) RevType1Name,

	IsNull(ivh_totalmiles,0) InvoiceHeaderMiles,

	-- Revenue Per Invoiced Miles
	-- 
	/*
	(
	Select 
		Sum(IsNull(ivd_distance,0)) 
	From
		invoiceheader inv4,
		InvoiceDetail,
		ChargeType
	where
		inv4.ord_hdrnumber=orderheader.ord_hdrnumber
		and
		Invoicedetail.ivh_hdrnumber =inv4.ivh_hdrnumber
		and
		ChargeType.cht_itemcode= Invoicedetail.cht_itemcode
		and
		ChargeType.cht_primary='Y'
	) InvoiceDetailMiles
	*/
	Convert(float,0.00) RevPerBillMileFreightOnly,
	Convert(float,0.00) RevPerBillMileAllCharges,
	Convert(float,0.00) RevPerTravelMileFreightOnly,
	Convert(float,0.00) RevPerTravelMileAllCharges,
	'N' MissingMiles,
	Orderheader.mov_number

into #TempReport

FROM
	#TempInvoicelist,
	Orderheader,
	invoiceheader,
	Company CompanyBillto,
	City	CityOrigin,
	City	CityDestination,
	statecountry

Where
	#TempInvoicelist.ord_hdrnumber=Orderheader.ord_hdrnumber
	and
	#TempInvoicelist.ivh_hdrnumber = Invoiceheader.ivh_hdrnumber
	and
	CompanyBillto.cmp_id=ivh_billto
	and
	CityOrigin.cty_code= ivh_origincity
	and
 	CityDestination.Cty_code=ivh_destcity
	and

	statecountry.stc_state_c=CityOrigin.cty_state

Update #tempReport 
	Set TotalCharges =(FrtCharge + AccCharge)

--select emptymiles / billablemiles from #tempreport

Update #tempReport 
	Set MTPercent = emptymiles / billablemiles
	where billablemiles >0
Update #TempReport
	Set RevPerBillMileFreightOnly =FrtCharge /InvoiceHeaderMiles
	where
	InvoiceHeaderMiles >0

Update #TempReport
	Set RevPerBillMileAllCharges =TotalCharges /InvoiceHeaderMiles
	where
	InvoiceHeaderMiles >0


Update #TempReport
	Set RevPerTravelMileFreightOnly =FrtCharge /TravelMiles
	where
	TravelMiles >0

Update #TempReport
	Set RevPerTravelMileAllCharges =TotalCharges /TravelMiles
	where
	TravelMiles >0

Select 
	stops.Mov_number
Into #MissingMilesList
from 
	stops,
	#tempInvoicelist,
	Orderheader
where
	#tempInvoicelist.ord_hdrnumber = orderheader.ord_hdrnumber
	and
	orderheader.mov_number =stops.mov_number
	and
	(Stops.stp_lgh_mileage <0 or
	Stops.stp_ord_mileage <0
		/* or 
		(Stops.stp_lgh_mileage is NULL
		and
		Stops.stp_mfh_sequence<>1) */
	)
order by stops.mov_number

Update  #TempReport
	Set MissingMiles ='Y'
	From
		#MissingMilesList	
	where
		#MissingMilesList.mov_number =#TempReport.mov_number
/*
Select 
	stops.Mov_number,
	stops.ord_hdrnumber,
	stops.stp_event,
	stops.cmp_id, 
	stops.stp_city,    
	stops.stp_state,
	cty_name,
	stops.stp_arrivaldate, 
	stops.stp_ord_mileage, 
	stops.stp_lgh_mileage,
	stops.stp_number  
	
From
	#MissingMilesList,
	Stops,
	city
Where
	Stops.Mov_number=#MissingMilesList.Mov_number
	and
	cty_code=stops.stp_city
Order by stops.Mov_number,stops.stp_arrivaldate	
*/
Select	ord_number 'ORDER #',
	FrtCharge,
	AccCharge,
	TotalCharges,
	BillableMiles,      
	TravelMiles,
	EmptyMiles,
	MTPercent,
	cmp_name 'BILLTO ID',
	OriginCity,
	cty_nmstct 'DEST CITY', 
	BillDate,
	PUDate,
	RevType1Name,
	RevPerBillMileAllCharges,
	RevPerTravelMileAllCharges,  
	MissingMiles, 
	mov_number,
	@coltouse 'date_type',
	'RevType1' 'revtype1_label',
	@earlybilldate 'early_date', 
	@latebilldate 'end_date'
	from #tempReport
Drop table #tempInvoicelist	
Drop Table #MissingMilesList

GO
GRANT EXECUTE ON  [dbo].[d_revanalysis_brpt] TO [public]
GO
