SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[fueltax_export_sp] 
  @BegDate  datetime,
  @EndDate  datetime,
  @FuelTaxStatus   varchar ( 6 )	

AS

SELECT  legheader.lgh_number,
	legheader.lgh_firstlegnumber, 
	legheader.lgh_lastlegnumber,
  	legheader.lgh_startdate, 
	legheader.lgh_enddate, 
	stops.mov_number,
	legheader.lgh_startcity, 
	legheader.lgh_endcity, 
	legheader.lgh_outstatus, 
	legheader.lgh_class1,
	legheader.lgh_class2, 
	legheader.lgh_class3, 
	legheader.lgh_class4, 
	legheader.lgh_instatus,
	legheader.lgh_tractor, 
	legheader.lgh_fueltaxstatus, 
	stops.stp_arrivaldate, 
	eventcodetable.fgt_event stp_type, 
	city.cty_name, 
	city.cty_state, 
	ISNULL ( company.cmp_zip, "" ) cty_zip, 
 	convert(varchar(36), null) fp_id,
	convert(char(12),'') ord_number, 
	convert(datetime, null) fp_date, 
	convert(varchar(6),'') fp_fueltype,
	convert(money,0) fp_amount, 
	convert(float,0) fp_cost_per, 
	convert(varchar(10),'') fp_invoice_no, 
	convert(varchar(30),'') fp_vendorname, 
	convert(varchar(6),'') fp_uom,
	convert(float,0) fp_quantity,
	convert(varchar(6),'') fp_purchcode, 
	0 ord_type,
	stops.ord_hdrnumber lgh_ord_hdrnumber,
	1 fix_sort_ind,
	legheader.stp_number_start,
	stops.stp_number,
	tractorprofile.trc_type1,
	tractorprofile.trc_type2,
	tractorprofile.trc_type3,
	tractorprofile.trc_type4,
	stops.stp_city
into #t
FROM legheader, stops, city, tractorprofile, eventcodetable, company
WHERE (legheader.lgh_startdate >= @BegDate AND legheader.lgh_startdate < DATEADD(dd,1,@EndDate))
AND (legheader.lgh_fueltaxstatus = @FuelTaxStatus)
AND legheader.lgh_number = stops.lgh_number
AND stops.stp_city = city.cty_code
AND legheader.lgh_outstatus = 'CMP'
AND tractorprofile.trc_number = legheader.lgh_tractor
AND eventcodetable.abbr = stops.stp_event
AND company.cmp_id = stops.cmp_id

UPDATE #t 
SET fix_sort_ind = -1 --before fuelpurchase
WHERE stp_number = stp_number_start

UPDATE 	#t
SET 	#t.cty_zip = city.cty_zip 
FROM 	city
WHERE 	city.cty_code = #t.stp_city
  AND	#t.cty_zip = ''
	

INSERT INTO #t (lgh_number,
	lgh_firstlegnumber, 
	lgh_lastlegnumber,
  	lgh_startdate, 
	lgh_enddate, 
	mov_number,
	lgh_startcity, 
	lgh_endcity, 
	lgh_outstatus, 
	lgh_class1,
	lgh_class2, 
	lgh_class3, 
	lgh_class4, 
	lgh_instatus,
	lgh_tractor, 
	lgh_fueltaxstatus, 
	stp_arrivaldate, 
	stp_type, 
	cty_name, 
	cty_state, 
	cty_zip, 
 	fp_id,
	ord_number, 
	fp_date, 
	fp_fueltype,
	fp_amount, 
	fp_cost_per, 
	fp_invoice_no, 
	fp_vendorname, 
	fp_uom,
	fp_quantity,
	fp_purchcode, 
	ord_type,
	lgh_ord_hdrnumber,
	fix_sort_ind,
	stp_number_start,
	stp_number,
	trc_type1,
	trc_type2,
	trc_type3,
	trc_type4,
	stp_city)

SELECT  fuelpurchased.lgh_number, 
	0,
	0,
 	'', 
	'', 
	fuelpurchased.mov_number,
	0, 
	0, 
	'', 
	'',
  	'',
	'',
	'',
	'',
   	tractorprofile.trc_number,
   	'',
   fuelpurchased.fp_date,
   '',
   city.cty_name,
   city.cty_state, 
   city.cty_zip, 
   fuelpurchased.fp_id, 
   fuelpurchased.ord_number, 
   fuelpurchased.fp_date, 
   fuelpurchased.fp_fueltype, 
   fuelpurchased.fp_amount, 
   fuelpurchased.fp_cost_per,
   ISNULL(fuelpurchased.fp_invoice_no, ''), 
   fuelpurchased.fp_vendorname, 
   fuelpurchased.fp_uom,
   fuelpurchased.fp_quantity,
   fuelpurchased.fp_purchcode
 , ord_type = 0,
 0, 0, 0,0  ,
	tractorprofile.trc_type1,
	tractorprofile.trc_type2,
	tractorprofile.trc_type3,
	tractorprofile.trc_type4,
	0
FROM fuelpurchased,city,legheader, tractorprofile
WHERE (legheader.lgh_startdate > @BegDate AND legheader.lgh_startdate < DATEADD(dd,1,@EndDate))
AND fp_city = city.cty_code
AND legheader.lgh_number = fuelpurchased.lgh_number
AND (legheader.lgh_fueltaxstatus = @FuelTaxStatus)
AND legheader.lgh_outstatus = 'CMP'
AND tractorprofile.trc_number = legheader.lgh_tractor

SELECT lgh_number,
	lgh_firstlegnumber, 
	lgh_lastlegnumber,
  	lgh_startdate, 
	lgh_enddate, 
 	mov_number,
	lgh_startcity, 
	lgh_endcity, 
	lgh_outstatus, 
	lgh_class1,
	lgh_class2, 
	lgh_class3, 
	lgh_class4, 
	lgh_instatus,
	lgh_tractor, 
	lgh_fueltaxstatus, 
	stp_arrivaldate, 
	stp_type, 
	cty_name, 
	cty_state, 
	cty_zip, 
 	fp_id,
	ord_number, 
	fp_date, 
	fp_fueltype,
	fp_amount, 
	fp_cost_per, 
	fp_invoice_no, 
	fp_vendorname, 
	fp_uom,
	fp_quantity,
	fp_purchcode, 
	ord_type,
	lgh_ord_hdrnumber,
	trc_type1,
	trc_type2,
	trc_type3,
	trc_type4
FROM #t
ORDER BY lgh_number,fix_sort_ind,stp_arrivaldate,ord_type

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_sp] TO [public]
GO
