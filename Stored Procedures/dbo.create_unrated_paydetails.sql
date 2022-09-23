SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


	
create procedure [dbo].[create_unrated_paydetails]
as
/*	Sp create_unrated_paydetails

	Scans all recently-created invoices for those that don't have PayDetails, and creates PayDetail rows for all, which aren't fully
	rated.  This is intended to be run regularly (daily); the PayDetails that this creates will be picked up in Settlements using
	the "line item rating".

	Parameters:	none

	Returns:	none, but creates new PayDetail rows

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	-------------------------------------------------------
	03/04/2002	Vern Jewett		13466	(none)	Original.
	03/15/2002	Vern Jewett		13644	vmj1	Maintain consistency of apocalypse date.
*/

declare	@li_count			int
		,@li_new_pyd_number	int
		,@li_batch_id		int
		,@ls_asgn_type		varchar(6)
		,@ls_asgn_id		varchar(13)
		,@ls_payto_id		varchar(12)
		,@ls_actg_type		varchar(1)
		,@ls_today			varchar(10)
		,@ls_user_id		varchar(10)
		,@ldt_today			datetime
		,@ldt_now			datetime
		,@ldt_yesterday		datetime

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--#key0 will contain the scope of PayDetails to be inserted..
create table #key0
		(ivh_hdrnumber	int			null
		,ivd_number		int			null
		,cht_itemcode	char(6)		null
		,asgn_type		varchar(6)	null
		,asgn_id		varchar(13)	null)

--#key is the same as #key0, except it has identity column counter and pyd_number.  Error conditions will be removed from #key0, 
--then this table is used to assign pyd_number's without having to waste sequence numbers on PayDetails that will not be inserted..
create table #key
		(pyd_number		int			null
		,counter		int			identity
		,ivh_hdrnumber	int			null
		,ivd_number		int			null
		,cht_itemcode	char(6)		null
		,asgn_type		varchar(6)	null
		,asgn_id		varchar(13)	null)

--#asset will contain all distinct assets affected by the current scope.  It is used to collect payto_id and actg_type info..
create table #asset
		(asgn_type		varchar(6)	null
		,asgn_id		varchar(13)	null
		,payto_id		varchar(12)	null
		,actg_type		varchar(1)	null)

--#error is used so 2 operations may be performed on the same scope of InvoiceHeaders with error conditions..
create table #error
		(ivh_hdrnumber	int			null
		,ivd_number		int			null
		,ivh_invoicenumber varchar(12) null
		,ord_number		varchar(12)	null)


--Strip off time to go back to midnight this morning..
select	@ldt_now = getdate()
		,@ls_user_id = @tmwuser
select	@ls_today = convert(varchar(10), @ldt_now, 112)
select	@ldt_today = convert(datetime, @ls_today)

--Subtract a day to get midnight yesterday morning..
select	@ldt_yesterday = dateadd(day, -1, @ldt_today)


--Select the scope.  Note that this SP is a HotFix for FirstFleet, and they currently only pay Drivers..
insert into #key0
		(ivh_hdrnumber
		,ivd_number
		,cht_itemcode
		,asgn_type
		,asgn_id)
  select ivh.ivh_hdrnumber
		,ivd.ivd_number
		,ivd.cht_itemcode
		,'DRV'
		,ivh.ivh_driver
  from	invoiceheader ivh
		,invoicedetail ivd
		,chargetype cht
  where	ivh.ivh_billdate >= @ldt_yesterday
	and	ivh.ivh_billdate < @ldt_today
	and	ivh.ivh_driver <> 'UNKNOWN'
	and ivh.ivh_driver is not null
	and	ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
	and	cht.cht_itemcode = ivd.cht_itemcode
	and	cht.cht_basis = 'ACC'


--Get a BatchId to use if we need to insert into tts_errorlog..
execute @li_batch_id = getsystemnumber 'BATCHQ', ''


--Weed out any InvoiceHeaders that have >1 Trip Segment.  Start by defining the scope of InvoiceHeaders which fit this error 
--condition (note that #error.ivd_number is always NULL here, because the error applies to the InvoiceHeader & all 
--InvoiceDetails)..
insert into #error
		(ivh_hdrnumber
		,ivh_invoicenumber
		,ord_number)
  select ivh.ivh_hdrnumber
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  from	#key0 k0
		,invoiceheader ivh
		,stops stp
		,legheader lgh
  where	ivh.ivh_hdrnumber = k0.ivh_hdrnumber
	and	stp.ord_hdrnumber = ivh.ord_hdrnumber
	and	stp.stp_event <> 'XDL'
	and	lgh.mov_number = stp.mov_number
  group by ivh.ivh_hdrnumber
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  having count(distinct lgh.lgh_number) > 1
/*insert into #error
		(ivh_hdrnumber
		,ivh_invoicenumber
		,ord_number)
  select ivh.ivh_hdrnumber
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  from	invoiceheader ivh
		,legheader lgh
  where ivh.ivh_hdrnumber in
			(select distinct k0.ivh_hdrnumber
			  from	#key0 k0)
	and	lgh.mov_number = ivh.mov_number
  group by ivh.ivh_hdrnumber
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  having count(*) > 1	*/
  
--Write to tts_errorlog table..
insert into tts_errorlog
		(err_batch
		,err_user_id
		,err_message
		,err_date
		,err_number
		,err_title
		,err_response
		,err_sequence
		,err_icon
		,err_item_number
		,err_type)
  select @li_batch_id
		,@ls_user_id
		,'Invoice ' + ltrim(rtrim(ivh_invoicenumber)) + ' for Order ' + ltrim(rtrim(ord_number)) + ' has multiple Trip Segments.  Please add ' +
			'PayDetails manually.'
		,@ldt_now
		,50000
		,'PYD'
		,'OK'
		,null
		,'E'
		,null
		,null
  from	#error

--Delete the affected InvoiceDetails from the #key table, so we won't attempt to create PayDetails for them..
delete	#key0
  from	#key0 k0
		,#error e
  where	k0.ivh_hdrnumber = e.ivh_hdrnumber


--Find PayDetails that already exist.  Start by defining the scope of InvoiceDetails which fit this error condition (note that 
--ivd_number is being filled in now, because the error may affect 1 detail on an Invoice, but not the others)..
delete from #error

insert into #error
		(ivh_hdrnumber
		,ivd_number
		,ivh_invoicenumber
		,ord_number)
  select k0.ivh_hdrnumber
		,k0.ivd_number
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  from	#key0 k0
		,invoicedetail ivd
		,invoiceheader ivh
		,paydetail pyd
  where ivd.ivh_hdrnumber = k0.ivh_hdrnumber
	and	ivd.ivd_number = k0.ivd_number
	and	ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	and	pyd.ord_hdrnumber = ivd.ord_hdrnumber
	and	pyd.asgn_type = k0.asgn_type
	and	pyd.asgn_id = k0.asgn_id
	and	pyd.pyt_itemcode = ivd.cht_itemcode
  
--Write to tts_errorlog table..
insert into tts_errorlog
		(err_batch
		,err_user_id
		,err_message
		,err_date
		,err_number
		,err_title
		,err_response
		,err_sequence
		,err_icon
		,err_item_number
		,err_type)
  select @li_batch_id
		,@ls_user_id
		,'Invoice ' + ltrim(rtrim(e.ivh_invoicenumber)) + ' for Order ' + ltrim(rtrim(e.ord_number)) + 
			' already has a PayDetail for ' + ltrim(rtrim(k0.asgn_type)) + ' ' + ltrim(rtrim(k0.asgn_id)) + ', PayType ' + 
			ltrim(rtrim(k0.cht_itemcode)) + '.'
		,@ldt_now
		,50000
		,'PYD'
		,'OK'
		,null
		,'I'
		,null
		,null
  from	#error e
		,#key0 k0
  where	k0.ivh_hdrnumber = e.ivh_hdrnumber
	and	k0.ivd_number = e.ivd_number

--Delete the affected InvoiceDetails from the #key table, so we won't attempt to create PayDetails for them..
delete	#key0
  from	#key0 k0
		,#error e
  where	k0.ivh_hdrnumber = e.ivh_hdrnumber
	and	k0.ivd_number = e.ivd_number


--Weed out any InvoiceHeaders which have a resource without a valid Accounting Type.  Start by defining the scope of 
--InvoiceHeaders which fit this error condition (note that #error.ivd_number is always NULL here, because the error applies to 
--the InvoiceHeader & all InvoiceDetails)..
delete from #error

insert into #error
		(ivh_hdrnumber
		,ivh_invoicenumber
		,ord_number)
  select distinct k0.ivh_hdrnumber
		,ivh.ivh_invoicenumber
		,ivh.ord_number
  from	#key0 k0
		,invoiceheader ivh
		,assetassignment aa
  where ivh.ivh_hdrnumber = k0.ivh_hdrnumber
	and aa.mov_number = ivh.mov_number
	and	aa.asgn_type = k0.asgn_type
	and	aa.asgn_id = k0.asgn_id
	and	isnull(aa.actg_type, 'N') = 'N'
  
--Write to tts_errorlog table..
insert into tts_errorlog
		(err_batch
		,err_user_id
		,err_message
		,err_date
		,err_number
		,err_title
		,err_response
		,err_sequence
		,err_icon
		,err_item_number
		,err_type)
  select distinct @li_batch_id
		,@ls_user_id
		,'Invoice ' + ltrim(rtrim(e.ivh_invoicenumber)) + ' for Order ' + ltrim(rtrim(e.ord_number)) + 
			': ' + ltrim(rtrim(k0.asgn_type)) + ' ' + ltrim(rtrim(k0.asgn_id)) + ' does not have a valid Accounting Type.'
		,@ldt_now
		,50000
		,'PYD'
		,'OK'
		,null
		,'I'
		,null
		,null
  from	#error e
		,#key0 k0
  where	k0.ivh_hdrnumber = e.ivh_hdrnumber

--Delete the affected InvoiceDetails from the #key table, so we won't attempt to create PayDetails for them..
delete	#key0
  from	#key0 k0
		,#error e
  where	k0.ivh_hdrnumber = e.ivh_hdrnumber


--Now that we have weeded out all the error conditions, assign new pyd_number's to the remaining key rows.  Start by copying rows
--into a table with an identity column..
insert into #key
		(ivh_hdrnumber
		,ivd_number
		,cht_itemcode
		,asgn_type
		,asgn_id)
  select ivh_hdrnumber
		,ivd_number
		,cht_itemcode
		,asgn_type
		,asgn_id
  from	#key0
  order by ivh_hdrnumber
		,ivd_number

--Reserve the new pyd_number's to be used..
select	@li_count = count(*)
  from	#key

execute	@li_new_pyd_number = getsystemnumberblock 'PYDNUM', '', @li_count
if @@error <> 0 
begin
	drop table #key0
			,#key
			,#asset
			,#error
	return
end

--Store the new pyd_number's in the scope table..
update	#key
  set	pyd_number = @li_new_pyd_number + counter - 1


--Collect asset info..
insert into #asset
		(asgn_type
		,asgn_id
		,payto_id
		,actg_type)
  select distinct asgn_type
		,asgn_id
		,null
		,null
  from	#key

--Now run the SP which will tells us the payto_id and actg_type for every asset..
declare asset_c cursor for
  select asgn_type
		,asgn_id
  from	#asset

open asset_c

--Fetch the 1st row..
fetch next from asset_c
  into	@ls_asgn_type
		,@ls_asgn_id

while @@fetch_status = 0
begin
	execute getpayto_sp @ls_asgn_type, @ls_asgn_id, @ls_payto_id output, @ls_actg_type output

	update	#asset
	  set	payto_id = @ls_payto_id
			,actg_type = @ls_actg_type
	  where	current of asset_c

	--Fetch the next row..
	fetch next from asset_c
	  into	@ls_asgn_type
			,@ls_asgn_id
end

-- close & de-allocate the cursor
close asset_c
deallocate asset_c


--Now we're ready to insert PayDetail rows..
insert into paydetail
		(pyd_number
		,pyh_number
		,lgh_number
		,asgn_number
		,asgn_type
		,asgn_id
		,ivd_number
		,pyd_prorap
		,pyd_payto
		,pyt_itemcode
		,mov_number
		,pyd_description
		,pyr_ratecode
		,pyd_quantity
		,pyd_rateunit
		,pyd_unit
		,pyd_rate
		,pyd_amount
		,pyd_pretax
		,pyd_glnum
		,pyd_currency
		,pyd_currencydate
		,pyd_status
		,pyd_refnumtype
		,pyd_refnum
		,pyh_payperiod
		,pyd_workperiod
		,lgh_startpoint
		,lgh_startcity
		,lgh_endpoint
		,lgh_endcity
		,ivd_payrevenue
		,pyd_revenueratio
		,pyd_lessrevenue
		,pyd_payrevenue
		,pyd_transdate
		,pyd_minus
		,pyd_sequence
		,std_number
		,pyd_loadstate
		,pyd_xrefnumber
		,ord_hdrnumber
		,pyt_fee1
		,pyt_fee2
		,pyd_grossamount
		,pyd_adj_flag
		,pyd_updatedby
		,psd_id
		,pyd_transferdate
		,pyd_exportstatus
		,pyd_releasedby
		,cht_itemcode
		,pyd_billedweight
		,tar_tarriffnumber
		,psd_batch_id
		,pyd_updsrc
		,pyd_updatedon
		,pyd_offsetpay_number
		,pyd_credit_pay_flag
		,pyd_ivh_hdrnumber)
  select k.pyd_number
		,0					--pyh_number
		,aa.lgh_number
		,aa.asgn_number
		,aa.asgn_type
		,aa.asgn_id
		,0					--ivd_number	Formerly ivd.ivd_number
		,a.actg_type		--pyd_prorap
		,a.payto_id			--pyd_payto
		,k.cht_itemcode		--pyt_itemcode
		,ivh.mov_number
		,pyt.pyt_description --pyd_description
		,null				--pyr_ratecode
		,ivd.ivd_quantity	--pyd_quantity
		,pyt.pyt_rateunit	--pyd_rateunit
		,pyt.pyt_unit		--pyd_unit
		,0.00				--pyd_rate
		,0.00				--pyd_amount
		,'Y'				--pyd_pretax
		,null				--pyd_glnum
		,null				--pyd_currency
		,null				--pyd_currencydate
		,'HLD'				--pyd_status
		,null				--pyd_refnumtype
		,null				--pyd_refnum
		--vmj1+
		,'2049-12-31 23:59:00.000'	--pyh_payperiod
		,'2049-12-31 23:59:00.000'	--pyd_workperiod
--		,'2049-12-31 23:59:59.000'	--pyh_payperiod
--		,'2049-12-31 23:59:59.000'	--pyd_workperiod
		--vmj1-
		,null				--lgh_startpoint
		,null				--lgh_startcity
		,null				--lgh_endpoint
		,null				--lgh_endcity
		,0.00				--ivd_payrevenue
		,0.00				--pyd_revenueratio
		,0.00				--pyd_lessrevenue
		,0.00				--pyd_payrevenue
		,ivh.ivh_deliverydate --pyd_transdate
		,1					--pyd_minus
		,1					--pyd_sequence
		,null				--std_number
		,'NA'				--pyd_loadstate
		,0					--pyd_xrefnumber
		,ivh.ord_hdrnumber
		,isnull(pyt.pyt_fee1, 0.00)
		,isnull(pyt.pyt_fee2, 0.00)
		,0.00				--pyd_grossamount
		,'N'				--pyd_adj_flag
		,@ls_user_id		--pyd_updatedby
		,null				--psd_id
		,null				--pyd_transferdate
		,null				--pyd_exportstatus
		,null				--pyd_releasedby
		,null				--cht_itemcode
		,null				--pyd_billedweight
		,''					--tar_tarriffnumber
		,null				--psd_batch_id
		,null				--pyd_updsrc
		,@ldt_now			--pyd_updatedon
		,null				--pyd_offsetpay_number
		,null				--pyd_credit_pay_flag
		,null				--pyd_ivh_hdrnumber
  from	#key k
		,#asset a
		,invoiceheader ivh
		,invoicedetail ivd
		,assetassignment aa
		,paytype pyt
  where	a.asgn_type = k.asgn_type
	and	a.asgn_id = k.asgn_id
	and	ivh.ivh_hdrnumber = k.ivh_hdrnumber
	and	ivd.ivd_number = k.ivd_number
	and aa.mov_number = ivh.mov_number
	and	aa.asgn_type = k.asgn_type
	and	aa.asgn_id = k.asgn_id
	and	pyt.pyt_itemcode = ivd.cht_itemcode


--Cleanup..
drop table #key0
		,#key
		,#asset
		,#error
GO
GRANT EXECUTE ON  [dbo].[create_unrated_paydetails] TO [public]
GO
