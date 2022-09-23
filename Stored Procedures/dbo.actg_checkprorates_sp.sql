SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_checkprorates_sp] 
	@p_ivh_hdrnumber int,
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

if exists (select * from revenueallocation where ivh_number = @p_ivh_hdrnumber)
    if (select sum(ROUND(ral_amount, @p_chargeroundoff)) from revenueallocation where ivh_number = @p_ivh_hdrnumber) <> (select ROUND(ivh_totalcharge, @p_chargeroundoff) from invoiceheader where ivh_hdrnumber = @p_ivh_hdrnumber)
        delete from revenueallocation where ivh_number = @p_ivh_hdrnumber

if not exists (select * from revenueallocation where ivh_number = @p_ivh_hdrnumber)
     begin
     exec dbo.actg_calcprorates_sp @p_ivh_hdrnumber, @p_chargeroundoff, @p_rateroundoff, 1
    insert into revenueallocation (ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum, ral_prorateitem)
    select ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum, ral_prorateitem 
      from actg_temp_workrevalloc where sp_id = @@spid /*PTS 34889 CGK 10/27/2006*/
     order by ral_sequence
     end

if exists 
	(select * from sysobjects 
	where id = 	object_id('dbo.actg_prorate_delivery_line_sp') 
			and sysstat & 0xf = 4)
begin
EXEC dbo.actg_prorate_delivery_line_sp @p_ivh_hdrnumber
end

if exists (select * from generalinfo where gi_name = 'AltARGLReset' and gi_string1 like 'Y%')
	BEGIN
	DECLARE @NatGLStart int, @NatGLLen int
	SELECT @NatGLStart = gi_integer1 FROM generalinfo WHERE gi_name = 'NatStart'
	SELECT @NatGLLen = gi_integer1 FROM generalinfo WHERE gi_name = 'NatLength'
	UPDATE revenueallocation SET ral_glnum = dbo.actg_ar_glreset(0, 1, 1, @NatGLStart, @NatGLLen, 1, 1, ral_id, NULL, NULL) WHERE ivh_number = @p_ivh_hdrnumber
	END

set nocount off
return
GO
GRANT EXECUTE ON  [dbo].[actg_checkprorates_sp] TO [public]
GO
