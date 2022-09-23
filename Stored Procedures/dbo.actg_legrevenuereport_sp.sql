SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_legrevenuereport_sp] 
	@p_lgh_number int,
	@p_chargeroundoff int,
	@p_rateroundoff int

as
set nocount on 

-- The work revenue allocation table that is used to hold the results as they are built.
--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_workrevalloc where sp_id = @@spid
-- CREATE TABLE #workrevalloc (
-- 	ivh_number integer NULL,           -- The invoiceheader for which this proration detail exists.
--         ivd_number integer NULL,           -- The invoicedetail for which this proration detail exists (NULL for pooled).
-- 	lgh_number integer NULL,           -- A representative legheader of those for which this proration detail was cut.
-- 	thr_id integer NULL,               -- The tariffheaderrevall record for which this proration detail was cut (if any, typically only present on Pooled).
--         ral_proratequantity money NULL,    -- The quantity that this portion of the proration was based on.
--         ral_totalprorates money NULL,      -- The total quantity for this proration rule.
--         ral_rate money NULL,               -- The prorated rate of the invoice detail.
-- 	ral_amount money NULL,             -- The prorated amount of this invoice detail.
-- 	cur_code varchar (6) NULL,         -- The currency of this particular proration detail.
-- 	ral_conversion_rate money NULL,    -- The conversion rate from the invoiceheader currency to this record's currency as of the time this record was cut.
-- 	cht_itemcode varchar (6) NULL,     -- The final chargetype of this proration detail.
--         ral_sequence int NULL,             -- The sequence in which these proration details should appear.
-- 	ral_converted_rate money NULL,     -- The effective invoicedetail rate after dealing with proration and currency conversions.
-- 	ral_converted_amount money NULL,   -- The final amount after converting this prorated line to the specified currency code (and dealing with round offs).
-- 	ral_glnum varchar (32) NULL)       -- The gl number for this proration detail.

CREATE TABLE #workrevallocreport (
	ord_hdrnumber integer NULL, 
	ivh_number integer NULL,           -- The invoiceheader for which this proration detail exists.
        ivd_number integer NULL,           -- The invoicedetail for which this proration detail exists (NULL for pooled).
	lgh_number integer NULL,           -- A representative legheader of those for which this proration detail was cut.
	thr_id integer NULL,               -- The tariffheaderrevall record for which this proration detail was cut (if any, typically only present on Pooled).
        ral_proratequantity money NULL,    -- The quantity that this portion of the proration was based on.
        ral_totalprorates money NULL,      -- The total quantity for this proration rule.
        ral_rate money NULL,               -- The prorated rate of the invoice detail.
	ral_amount money NULL,             -- The prorated amount of this invoice detail.
	cur_code varchar (6) NULL,         -- The currency of this particular proration detail.
	ral_conversion_rate money NULL,    -- The conversion rate from the invoiceheader currency to this record's currency as of the time this record was cut.
	cht_itemcode varchar (6) NULL,     -- The final chargetype of this proration detail.
        ral_sequence int NULL,             -- The sequence in which these proration details should appear.
	ral_converted_rate money NULL,     -- The effective invoicedetail rate after dealing with proration and currency conversions.
	ral_converted_amount money NULL,   -- The final amount after converting this prorated line to the specified currency code (and dealing with round offs).
	ral_glnum varchar (32) NULL)       -- The gl number for this proration detail.


declare @ivh_hdrnumber as integer
declare @ord_hdrnumber as integer

select @ord_hdrnumber = min (ord_hdrnumber) from stops where ord_hdrnumber > 0 and mov_number in (select mov_number from stops where lgh_number = @p_lgh_number)
select @ord_hdrnumber = IsNull (@ord_hdrnumber, 0)

while @ord_hdrnumber > 0
begin
	--print 'Order Header Number = ' + Cast (@ord_hdrnumber as varchar)

-- 	select @ivh_hdrnumber = IsNull (Min (ivh_hdrnumber), 0) from invoicedetail where IsNull (ivh_hdrnumber, 0) >= 0 AND ord_hdrnumber = @ord_hdrnumber
-- 	select @ivh_hdrnumber = IsNull (@ivh_hdrnumber, -1) 
-- 	print 'Invoice Header Number = ' + Cast (@ivh_hdrnumber as varchar)

	delete from actg_temp_workrevalloc where sp_id = @@spid
		
	exec dbo.actg_calcproratesorder_sp @ord_hdrnumber, @p_chargeroundoff, @p_rateroundoff, 1

	insert into #workrevallocreport (ord_hdrnumber, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
	select 	@ord_hdrnumber, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum from actg_temp_workrevalloc where sp_id = @@spid


-- 	while @ivh_hdrnumber > -1
-- 	begin
-- 		print 'Invoice Header Number Loop = ' + Cast (@ivh_hdrnumber as varchar)
-- 		delete from #workrevalloc
-- 		
-- 	        exec dbo.actg_calcprorates_sp @ivh_hdrnumber, @p_chargeroundoff, @p_rateroundoff, 1
-- 
-- 		insert into #workrevallocreport (ord_hdrnumber, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
-- 		select 	@ord_hdrnumber, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum from #workrevalloc
-- 
-- 		select @ivh_hdrnumber = IsNull (Min (ivh_hdrnumber), -1) from invoicedetail where ord_hdrnumber = @ord_hdrnumber and IsNull (ivh_hdrnumber, 0) > @ivh_hdrnumber
-- 		select @ivh_hdrnumber = IsNull (@ivh_hdrnumber, -1) 
-- 	end

	select @ord_hdrnumber = min (ord_hdrnumber) from stops where ord_hdrnumber > @ord_hdrnumber and mov_number in (select mov_number from stops where lgh_number = @p_lgh_number)
	select @ord_hdrnumber = IsNull (@ord_hdrnumber, 0)
end

--
--select * from #workrevallocreport where lgh_number = @p_lgh_number order by ral_sequence
select  #workrevallocreport.ord_hdrnumber, 
	#workrevallocreport.ivh_number, 
	#workrevallocreport.ivd_number, 
	#workrevallocreport.lgh_number, 
	#workrevallocreport.thr_id, 
	#workrevallocreport.ral_proratequantity, 
	#workrevallocreport.ral_totalprorates, 
	#workrevallocreport.ral_rate, 
	#workrevallocreport.ral_amount, 
	#workrevallocreport.cur_code, 
	#workrevallocreport.ral_conversion_rate, 
	#workrevallocreport.cht_itemcode, 
	#workrevallocreport.ral_sequence, 
	#workrevallocreport.ral_converted_rate, 
	#workrevallocreport.ral_converted_amount, 
	#workrevallocreport.ral_glnum, 
        legheader.lgh_driver1,   
	legheader.lgh_driver2,   
	legheader.lgh_tractor,   
	legheader.lgh_primary_trailer,   
	(SELECT ISNULL(SUM(stops.stp_lgh_mileage), 0) FROM stops WHERE stops.lgh_number = #workrevallocreport.lgh_number AND ISNULL(stops.stp_lgh_mileage, 0) > 0 AND stops.stp_loadstatus = 'LD') as lgh_ldmiles,  
	legheader.lgh_primary_pup,   
	legheader.lgh_miles,   
	chargetype.cht_allocation_group_nbr,   
	labelfile.name,   
	labelfile.code,
	(select Sum (ivd_charge) from invoicedetail where invoicedetail.ord_hdrnumber = #workrevallocreport.ord_hdrnumber) as order_charge
FROM #workrevallocreport  
	left outer join legheader on #workrevallocreport.lgh_number = legheader.lgh_number   
	left outer join  chargetype on #workrevallocreport.cht_itemcode = chargetype.cht_itemcode
	left outer join labelfile on chargetype.cht_allocation_group_nbr = labelfile.abbr and labelfile.labeldefinition = 'RevAllocCategory'
where #workrevallocreport.lgh_number = @p_lgh_number 
and ral_amount > 0
order by ral_sequence

set nocount off
return
GO
GRANT EXECUTE ON  [dbo].[actg_legrevenuereport_sp] TO [public]
GO
