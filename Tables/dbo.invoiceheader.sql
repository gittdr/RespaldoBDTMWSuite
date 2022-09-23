CREATE TABLE [dbo].[invoiceheader]
(
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_terms] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalcharge] [money] NULL,
[ivh_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_originpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_origincity] [int] NULL,
[ivh_destcity] [int] NULL,
[ivh_originstate] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_deststate] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_originregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_shipdate] [datetime] NULL,
[ivh_deliverydate] [datetime] NULL,
[ivh_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalweight] [float] NULL,
[ivh_totalpieces] [float] NULL,
[ivh_totalmiles] [float] NULL,
[ivh_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_currencydate] [datetime] NULL,
[ivh_totalvolume] [float] NULL,
[ivh_taxamount1] [money] NULL,
[ivh_taxamount2] [money] NULL,
[ivh_taxamount3] [money] NULL,
[ivh_taxamount4] [money] NULL,
[ivh_transtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_creditmemo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_applyto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shp_hdrnumber] [int] NULL,
[ivh_printdate] [datetime] NULL,
[ivh_billdate] [datetime] NULL,
[ivh_lastprintdate] [datetime] NULL,
[ivh_hdrnumber] [int] NOT NULL,
[ord_hdrnumber] [int] NULL,
[ivh_originregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_originregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_originregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destregion2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destregion3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destregion4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_hdrnumber] [int] NULL,
[ivh_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_user_id1] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_user_id2] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[timestamp] [timestamp] NULL,
[ivh_edi_flag] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_freight_miles] [float] NULL,
[ivh_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_low_temp] [smallint] NULL,
[ivh_high_temp] [smallint] NULL,
[ivh_xferdate] [datetime] NULL,
[ivh_order_by] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[ivh_bookyear] [tinyint] NULL,
[ivh_bookmonth] [tinyint] NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_maxlength] [money] NULL,
[ivh_maxwidth] [money] NULL,
[ivh_maxheight] [money] NULL,
[ivh_mbstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_mbnumber] [int] NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_quantity] [float] NULL,
[ivh_rate] [money] NULL,
[ivh_charge] [money] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_splitbill_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_archarge] [money] NULL,
[ivh_arcurrency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_loadtime] [float] NULL,
[ivh_unloadtime] [float] NULL,
[ivh_drivetime] [float] NULL,
[ivh_totaltime] [float] NULL,
[ivh_rateby] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revenue_date] [datetime] NULL,
[ivh_batch_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_stopoffs] [smallint] NULL,
[Ivh_quantity_type] [smallint] NULL,
[ivh_charge_type] [smallint] NULL,
[ivh_originzipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_destzipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_ratingquantity] [float] NULL,
[ivh_ratingunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_mileage_adjustment] [decimal] (9, 1) NULL,
[ivh_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_hideshipperaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_hideconsignaddr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_paperworkstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__invoicehe__ivh_p__11EA7D3F] DEFAULT ('UNK'),
[ivh_showshipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_showcons] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_allinclusivecharge] [money] NULL,
[ivh_order_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_applyto_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_attention] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_rate_type] [smallint] NULL,
[ivh_paperwork_override] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_cmrbill_link] [int] NULL,
[ivh_mbperiod] [datetime] NULL,
[ivh_mbperiodstart] [datetime] NULL,
[ivh_imagestatus] [tinyint] NULL,
[ivh_imagestatus_date] [datetime] NULL,
[ivh_imagecount] [smallint] NULL,
[ivh_mbimagestatus] [tinyint] NULL,
[ivh_mbimagestatus_date] [datetime] NULL,
[ivh_mbimagecount] [smallint] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IVH_last_updateby] DEFAULT (case when charindex('\',suser_sname())>(0) then left(substring(suser_sname(),charindex('\',suser_sname())+(1),len(suser_sname())),(20)) else left(suser_sname(),(20)) end),
[last_updatedate] [datetime] NULL CONSTRAINT [DF_IVH_last_updatedate] DEFAULT (getdate()),
[ivh_mileage_adj_pct] [decimal] (9, 2) NULL,
[inv_revenue_pay_fix] [int] NULL CONSTRAINT [DF__INVOICEHE__inv_r__4DA10B41] DEFAULT (0),
[inv_revenue_pay] [money] NULL,
[ivh_billto_parent] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_block_printing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_custdoc] [int] NULL,
[ivh_entryport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ivh_entryport] DEFAULT ('UNKNOWN'),
[ivh_exitport] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ivh_exitport] DEFAULT ('UNKNOWN'),
[ivh_paid_amount] [money] NULL,
[ivh_pay_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_dimfactor] [decimal] (12, 4) NULL,
[ivh_TrlConfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_fuelprice] [decimal] (19, 4) NULL,
[ivh_gp_gl_postdate] [datetime] NOT NULL CONSTRAINT [DF_ivh_gpglpostdate] DEFAULT ('19500101 00:00'),
[ivh_charge_type_lh] [smallint] NULL,
[ivh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_order_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_misc_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_paid_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_lastchecknumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_lastcheckamount] [money] NULL,
[ivh_totalpaid] [money] NULL,
[ivh_lastcheckdate] [datetime] NULL,
[ivh_exchangerate] [numeric] (19, 4) NULL,
[ivh_loaded_distance] [float] NULL,
[ivh_empty_distance] [float] NULL,
[ivh_BelongsTo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_leaseid] [int] NULL,
[ivh_leaseperiodenddate] [datetime] NULL,
[ivh_nomincharges] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_key] [int] NULL,
[ivh_docnumber] [int] NULL,
[ivh_mbnumber_custom] [int] NULL,
[rowsec_rsrv_id] [int] NULL,
[ivh_furthestpointconsignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_invoiceby] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_reprint] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPDatabase] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPserver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPTerritory] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPSalesPerson] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPPONumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPDocDescription] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPCustNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPDocnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPbachnumbeer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_GPbilldate] [datetime] NULL,
[ivh_GPDuedate] [datetime] NULL,
[ivh_GPpostdate] [datetime] NULL,
[ivh_mb_customgroupby] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_dballocate_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbh_id] [int] NULL,
[ivh_dedicated_includedate] [datetime] NULL,
[ivh_donotprint] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_billing_usedate] [datetime] NULL,
[ivh_billing_usedate_setting] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_dedicated_invnumber] [int] NULL,
[ivh_splitgroup] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalpallets] [float] NULL,
[ivh_totalpalletunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalweightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalvolumeunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalpiecesunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalmilesunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[posted_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mbgroupdata] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_lh_charge_with_rollin] [money] NULL,
[ivh_rollin_lh_rate] [money] NULL,
[ivh_lh_charge] [money] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[dt_invoiceheader] on [dbo].[invoiceheader] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	----------------------------------------------------
	05/18/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
	01/20/2004	K.W. Sundling		kws	PTS 20225
	05/13/2004	K.W. Sundling		kws	PTS 22130 Handle detail records deletion
	10/18/05    DPETE            PTS28789  MIN charges not deleting when invoice is deleted
  01/22/07    DPETE            PTS34628 when invoice deleted clear ord_lastratedate forcing recompute of rate unless another invoice exists
  09/21/2009	PMILL					PTS49172 When deleting an invoice do not delete cost plus accessorials flagged as manually added or prerated.
  06/07/10 PTS 51844 DPETE add revenue tracking option
  06/28/10  PTS51844 DPETE modify slightly
  9/22/10 PTS53952 deleting an invoice with a manual charge that is not the last invoice orphans the charge
  10/27/10 PTS 54537 SGB The function to delete all invoices needs to also delete invoicemaster if it exists 
  1/18/11   PTS55393  DPETE  add miles to revenue_tracker table (for invoice only)
  9/27/11 DPETE PTS 58090 for invoice by MOV or MOVCON need to reset ord_hdrnumber in manually added accessorials
  11/23/16 PTS 99869 Do not delete 3G '3' or 3PL 'V' details when deleting invoice
*/



--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581


declare	@ls_audit	varchar(1)
declare @nextinv int
declare @ordnumber varchar(13)
DECLARE @ivh_definition	VARCHAR(6)   --PTS68732 MBR 05/08/13

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255),
		@ivh_hdrnumber	INT,
		@ord_hdrnumber  INT,
		@count			INT
declare     @v_appid varchar(30),@v_recordzerochanges char(1), @v_now datetime  -- 51844


exec gettmwuser @tmwuser output

-- KWS PTS 20225 - update tables dependent upon the invoice header number
-- Delete detail records without accessorial 
-- LOR	PTS# 32563	check for credit and rebill
-- DPETE 53952 split a manual charge to a B invoice then delete and the manual charge gets orphaned.
--     If the invoice being deleted is not the last invoice for the order, delete all details even if manually added

-- PTS68732 MBR 05/08/13 added ivh_definition to the select
-- PTS91638 NQ	07/20/15 not delete charge(s) from 3G rating (invoicedetail.ivd_fromord = '3')

select @ord_hdrnumber = ord_hdrnumber,@ivh_hdrnumber = ivh_hdrnumber, @ivh_definition = ivh_definition
  from (select top 1 ord_hdrnumber,ivh_hdrnumber, ivh_definition from deleted) dltd
if @ord_hdrnumber > 0 
   SELECT @ordnumber = ord_number from orderheader where ord_hdrnumber = @ord_hdrnumber
ELSE
   SELECT @ordnumber = ''
   
IF (@ord_hdrnumber > 0 and exists (select 1 from invoiceheader where ord_hdrnumber = @ord_hdrnumber and @ord_hdrnumber > 0 and ivh_hdrnumber <> @ivh_hdrnumber))
   or @ord_hdrnumber = 0
 BEGIN 
  DELETE	invoicedetail
  FROM	invoicedetail ind 
  JOIN	deleted d ON ind.ivh_hdrnumber = d.ivh_hdrnumber  
 END
ELSE
 BEGIN 
  DELETE	invoicedetail
  FROM	invoicedetail ind 
  JOIN	deleted d ON ind.ivh_hdrnumber = d.ivh_hdrnumber
  JOIN	chargetype c ON ind.cht_itemcode = c.cht_itemcode
  WHERE	--ISNULL(cht_basis, '') <> 'ACC' OR  --49172 removed
	--(ISNULL(cht_basis, '') = 'ACC' AND IsNull(ivd_fromord,'N') NOT IN ('Y', 'D', 'P')) or  --49172 removed
	--49172		--99869 added 3, for 3PL billing
	isNull(ivd_fromord,'N') NOT IN ('Y', 'D', 'P', '3', 'V') OR 
	ivh_creditmemo = 'Y' or ivh_definition = 'RBIL'
	--(ISNULL(cht_basis, '') = 'ACC' AND ivd_fromord NOT IN ('Y', 'D', 'P'))
 END
UPDATE	invoicedetail
SET	ivh_hdrnumber = 0, ivd_subtotalptr = NULL, ivd_sequence = ivd_sequence + 10000
FROM	invoicedetail ind 
JOIN	deleted d ON ind.ivh_hdrnumber = d.ivh_hdrnumber
--JOIN	chargetype c ON ind.cht_itemcode = c.cht_itemcode
--WHERE	ISNULL(cht_basis, '') = 'ACC' AND ivd_fromord IN ('Y', 'D', 'P')
-- Update status of OrderHeader to Pending
--PTS30452 MBR 11/14/05
SELECT @ivh_hdrnumber = ivh_hdrnumber,
	   @ord_hdrnumber = ord_hdrnumber
  FROM deleted
SELECT @count = count(*)
  FROM invoiceheader
 WHERE ord_hdrnumber = @ord_hdrnumber AND
       ivh_hdrnumber <> @ivh_hdrnumber
if @count = 0 and @ord_hdrnumber > 0
BEGIN
	UPDATE orderheader
	   SET ord_invoicestatus = 'AVL',ord_lastratedate = null
	  FROM orderheader o JOIN deleted d ON o.ord_hdrnumber = d.ord_hdrnumber
END
-- Remove Invoice Header Number from Paydetail and Invoicebackouts
UPDATE	invoicebackouts
SET	ibo_ivh_hdrnumber = NULL
FROM	invoicebackouts ibo
JOIN	deleted d ON ibo.ibo_ivh_hdrnumber = d.ivh_hdrnumber

UPDATE	paydetail
SET	pyd_ivh_hdrnumber = NULL
FROM	paydetail p
JOIN	deleted d ON p.pyd_ivh_hdrnumber = d.ivh_hdrnumber
-- KWS PTS 20225

--	LOR	PTS# 33517
DELETE	invoiceheader_misc
FROM	invoiceheader_misc i
JOIN	deleted d ON i.ihm_hdrnumber = d.ivh_hdrnumber
--	LOR

-- PTS44235 MBR 09/25/08 Delete any orphaned referencenumber records tied to the 
-- deleted invoiceheader record for miscellaneous invoices
DELETE referencenumber
  FROM referencenumber r 
  JOIN deleted d ON r.ref_tablekey = d.ivh_hdrnumber AND
                    d.ivh_definition = 'MISC' AND
                    r.ref_table = 'invoiceheader'

--PTS 69445 delete any reference number for invoicedetail when invoice is deleted.                    
DELETE referencenumber
  FROM referencenumber r 
  JOIN deleted d ON r.ord_hdrnumber = d.ord_hdrnumber AND
                    r.ref_table = 'invoicedetail'
--end 69445

--vmj1+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and g2.gi_datein <= getdate())
if @ls_audit = 'Y'
	--vmj1-
	--Insert expedite_audit row..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(ord_hdrnumber, 0)
			,@tmwuser
			,'InvoiceHeader delete'
			,getdate()
			,''
			,convert(varchar(20), ivh_hdrnumber)
			,isnull(mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted
/* revenue tracking */
/* (1)if invoice is deleted , delete all revenue tracking records for it
  (2) if it is for an order, restore all revenue for the order */
If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100') 
and (select count(*) from deleted ) = 1
  BEGIN
    select @v_appid = rtrim(left(app_name(),30))
    --select @ord_hdrnumber = ord_hdrnumber,@ivh_hdrnumber = ivh_hdrnumber  from deleted
    --Delete from revenue_tracker 
    --where ivh_hdrnumber = @ivh_hdrnumber 
     Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
         ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
         ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
         select deleted.ord_hdrnumber
           ,deleted.ivh_hdrnumber
           ,isnull(deleted.ivh_definition,'??') 
           ,getdate()
           ,'UNK'
           ,0
           ,0
           ,''
           ,'Y'
           ,'???'
           ,'???'
           ,@tmwuser
           ,'dt_invoiceheader '+ ivh_invoicenumber
           ,@v_appid
           ,0
           ,0
           ,deleted.ivh_rateby
           ,0.0
           ,0.0
           from deleted
    select @ord_hdrnumber = ord_hdrnumber,@ivh_hdrnumber = ivh_hdrnumber  from deleted
    select @count  = 0
    if @ord_hdrnumber > 0
        select @count = count(*)  from invoiceheader where ord_hdrnumber =  @ord_hdrnumber  --and ivh_hdrnumber < @ivh_hdrnumber 
    -- if this is the first invoice for the order, restore order charges

    if @ord_hdrnumber > 0 and @count = 0
       BEGIN
          -- final argument 'Y' added to prevent creating backouts for all acessorail charges. If they aren;t delted by the
          --  call above to clean out detail (the dt_invoicedetail trigger will create the backouts) DOn't need to back out
          -- again with this call to CreateRevenue
          exec CreateRevenueForOrder @ord_hdrnumber,'ADD',@tmwuser,'dt_invoiceheader only invoice deleted','Y'
          update revenue_tracker set ivh_hdrnumber = 0,ivh_definition = 'PRERATE'  where ivh_hdrnumber = @ivh_hdrnumber  /* any charges not deleted attach back to prerate */
       END
      

  END

-- PTS 54537 SGB Clean up invoicemaster if deleting header
--PTS68732 MBR 05/08/13 added and ivh_definition <> 'SUPL' so this will not get processed for supplemental invoices for by move invoices 
IF exists (select 1 from invoicemaster where ivm_invoiceordhdrnumber = @ord_hdrnumber) AND @ivh_definition <> 'SUPL'  
	BEGIN
	  WHile 1 = 1
	   BEGIN
	     SELECT @nextinv = min(ivd_number) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
	     and ivd_ord_number <> @ordnumber
	    
	     IF @nextinv is null BREAK
	     
	      update invoicedetail
	      set invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
	      ,invoicedetail.ivd_ord_number = null
	      from invoicedetail
	      join orderheader on invoicedetail.ivd_ord_number = orderheader.ord_number
	      where invoicedetail.ivd_number = @nextinv 
	      and invoicedetail.ord_hdrnumber <> orderheader.ord_hdrnumber
	     
	    END
		DELETE invoicemaster 
		FROM 	invoicemaster i
		join deleted d on i.ivm_invoiceordhdrnumber = 	d.ord_hdrnumber
	END  

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create TRIGGER [dbo].[EmilimarComentarioOperaciones] ON [dbo].[invoiceheader] FOR INSERT
AS 
SET NOCOUNT ON 

  DECLARE @id varchar(50)
  SELECT @id = [ivh_invoicenumber]
  FROM INSERTED

  -- Insert statements for trigger here
  UPDATE  [dbo].[invoiceheader]
  SET ivh_remark = ''
  WHERE [ivh_invoicenumber] = @id 


  

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_invoiceheader] on [dbo].[invoiceheader] for insert 
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	--------------------------------------------------------------------
	05/18/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
   07/19/04 DPETE PTS 23977 log changed to trlcongifuration
   06/14/06  JLB PTS 32222
   06/0610 DPETE {PTS51844 add revenue tracking
   06/28/10 DPETE PTS51844 modified for dot net rating
   01/18/11 DPETE  PTS55393 add miles to revenue_tracker table (invoicing only)
   10/13/11 SGB PTS 59166 Added update section for new column ivh_dedicated_includedate 
   11/7/11  SGB PTS 59166 Addd subquery for MAX DBSE_ID   
   01/31/13	NQIAO PTS62719 Added more cases when updating column ivh_dedicated_includedate
*/

--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84590 MBR 01/16/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

declare	@ls_audit	varchar(1),@ord int, @newval varchar(50),@oldval varchar(50), @v_setbilldate char(1)

declare @tmwuser varchar(255), @V_status varchar(6),@v_ordhdrnumber int,@v_ivhhdrnumber int,@v_definition varchar(6)   --51844
declare     @v_appid varchar(30),@v_recordzerochanges char(1), @v_now datetime  -- 51844
exec gettmwuser @tmwuser output

/* revenue tracking start */
-- create record for status
If  exists (select 1 from generalinfo where upper(gi_name) = 'TRACKREVENUE' and gi_string1 = '100') and
    (select count(*) from inserted) = 1 
  BEGIN -- revenue tracking
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')

    select @V_status = isnull(ivh_invoicestatus,'null'),@v_ordhdrnumber = ord_hdrnumber,@v_ivhhdrnumber = ivh_hdrnumber ,@v_definition = ivh_definition  
    from inserted
    --if @v_status <> 'CAN'
    --  BEGIN
        -- add record for invoicestatus
         Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code
         ,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby
         , rvt_billmiles, rvt_billemptymiles)
          select inserted.ord_hdrnumber
          ,inserted.ivh_hdrnumber
          ,inserted.ivh_definition
          ,@v_now
          ,'UNK'
          ,0.00
          ,0
          ,ivh_currency
          ,'N'
          ,'???'
          ,isnull(inserted.ivh_invoicestatus,'null')
          ,@tmwuser
          ,'it_invoiceheader new invoice'
          ,@v_appid
          ,0
          ,0
          ,inserted.ivh_rateby
          ,0.0
          ,0.0
          from inserted

          -- update revenue_tracker fields added for detail to have the correct defintion 9deteils inserted before hdr records
          update revenue_tracker set ivh_definition = @v_definition 
          ,rvt_billmiles = (case @v_definition when 'CRD' then 0 - rvt_billmiles else rvt_billmiles end)
          ,rvt_billemptymiles = (case @v_definition when 'CRD' then 0 - rvt_billemptymiles else rvt_billemptymiles end)
          where ivh_hdrnumber = @v_ivhhdrnumber
     --   END
   -- if status is CAN, delete all revenue tracking records
    if @v_status = 'CAN'
      BEGIN  -- invoice status is not CANcelled
        -- if inovice is for an order and this is the first invoice for the order, delete all order based revenue
        if @v_ordhdrnumber > 0 and not exists (select 1 from invoiceheader where ord_hdrnumber = @v_ordhdrnumber and ivh_hdrnumber < @v_ivhhdrnumber)
           delete from revenue_tracker where ord_hdrnumber = @v_ordhdrnumber
        -- delete all revenue for this invoice
        delete from revenue_tracker where ivh_hdrnumber = @v_ivhhdrnumber
     END -- invoice status is not CANcelled
    
  END
/* end revenue tracking */


--vmj1+
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
  BEGIN
	--vmj1-
	--Log to the expedite_audit table..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(ord_hdrnumber, 0)
			,suser_sname()
			,'InvoiceHeader insert'
			,getdate()
			,''
			,convert(varchar(20), ivh_hdrnumber)
			,isnull(mov_number, 0)
			,0
			,'invoiceheader'
	  from	inserted

  Select @ord = IsNull(ord_hdrnumber,0) 
  , @Newval = IsNull(ivh_trlconfiguration ,'NULL')
  From inserted
  If @ord > 0 
    BEGIN 
     Select @oldval = IsNull(ord_trlconfiguration,'NULL') From orderheader where ord_hdrnumber = @ord
     If @oldval <> @newval
      INSERT INTO  expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, update_note, mov_number,
            lgh_number, join_to_table_name, key_value)
      SELECT @ord, UPPER(SUSER_SNAME()), GETDATE(),'TRL CONFIGURATION',
           'On insert '+isnull( @oldval, 'NULL') + ' -> ' + 
           isnull( ivh_trlconfiguration, 'NULL'),
           isnull(i.mov_number,0),0,'invoiceheader',convert(varchar(100), i.ivh_hdrnumber)
      FROM inserted i 
    END
  END

select @v_setbilldate = left(isnull(ltrim(rtrim(UPPER(gi_string1))),'N'),1)
  from generalinfo
 where gi_name = 'SetInvoiceBillDateOnRelease'

if @v_setbilldate = 'Y' and (select count(*) from inserted) = 1
begin
   if (select ivh_invoicestatus from inserted) = 'RTP'
   begin
      update invoiceheader
         set ivh_billdate = getdate()
        from inserted
       where inserted.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
   end
end

--PTS 59166 SGB
IF Update(ivh_mbstatus) 
BEGIN
	IF (select count(1) from inserted where ivh_mbstatus in ('RTP','PRO')) > 0
	BEGIN
		UPDATE invoiceheader
		SET ivh_dedicated_includedate =
		(SELECT CASE
			CASE isnull(dbse.dbse_usedate,'DELV') 
			WHEN 'UNK' THEN 'DELV'
			ELSE dbse.dbse_usedate
			END
		WHEN	'LAST' THEN isnull((select max(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number ),ih.ivh_deliverydate) 
		WHEN	'DRPA' THEN isnull((select min(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'),ih.ivh_deliverydate)
		WHEN	'DRPS' THEN	isnull((select min(s.stp_schdtearliest) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'),ih.ivh_deliverydate)
		WHEN	'AVIL' THEN ISNULL((select ord_availabledate from orderheader ord where ord.ord_hdrnumber = ih.ord_hdrnumber), ih.ivh_deliverydate)					--62719
		WHEN	'AFSP' THEN ISNULL((select min(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'PUP'), ih.ivh_deliverydate)		--62719
		WHEN	'DFSP' THEN ISNULL((select min(s.stp_departuredate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'PUP'), ih.ivh_deliverydate)	--62719
		WHEN	'DLSP' THEN ISNULL((select max(s.stp_departuredate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'), ih.ivh_deliverydate)	--62719
		WHEN	'BKDT' THEN ISNULL((select ord_bookdate from orderheader ord where ord.ord_hdrnumber = ih.ord_hdrnumber), ih.ivh_deliverydate)						--62719
		WHEN	'ESSP' THEN ISNULL((select s.stp_schdtearliest from stops s where s.mov_number = ih.mov_number and stp_sequence = 1), ih.ivh_deliverydate)			--62719
		WHEN	'FPSD' THEN ISNULL((select min(s.stp_schdtearliest) from stops s where s.mov_number = ih.mov_number and stp_type = 'PUP'), ih.ivh_deliverydate)		--62719
		END
		from inserted ih
		join dedbillingscheduleentity dbse
		on ih.ivh_billto = dbse.ord_billto
		and dbse_id = (Select MAX(dbse2.dbse_id) 
					from dedbillingscheduleentity dbse2
					where 	(dbse2.ord_revtype1 = 'UNK' or ih.ivh_revtype1 = dbse2.ord_revtype1)
							and (dbse2.ord_revtype2 = 'UNK' or ih.ivh_revtype2 = dbse2.ord_revtype2)
							and (dbse2.ord_revtype3 = 'UNK' or ih.ivh_revtype3 = dbse2.ord_revtype3)
							and (dbse2.ord_revtype4 = 'UNK' or ih.ivh_revtype4 = dbse2.ord_revtype4)
							and (dbse2.ord_booked_revtype1 = 'UNKNOWN' or ih.ivh_booked_revtype1 = dbse2.ord_booked_revtype1)
							and (dbse2.ord_billto = ih.ivh_billto ))
		join dedbillingschedule dbs
		on dbse.dbs_id = dbs.dbs_id 
		where ih.ivh_hdrnumber = ivh1.ivh_hdrnumber
		and dbs_action in ('CRTBIL','CRTDRA')
		and dbs_status = 'Active')
		from inserted ivh1
		where ivh1.ivh_mbstatus in ('RTP','PRO')
		and ivh1.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
		

	END
END
--END PTS 59166 SGB
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[ivh_checkbillto] ON [dbo].[invoiceheader] FOR INSERT,  UPDATE  
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	--------------------------------------------------------
	05/21/2001	Vern Jewett		vmj1	PTS 10379: trigger crashes on multi-row inserts/updates.
										Also changed " to ' so I could build the trigger in MS SQL 
										Query Analyzer (these chgs not labeled).
	
	03/05/2003	Doug McRowe			PTS 16842: Moved code originally in  here since they were causing problems w/each other.
    10/05/10    DPETE               PTS  53867 transferred invoice last_updated getting updated when rebill is created. 
                                     Found originstate, deststate, user_id2 and ar_charge or zipcode and reftype getting updated
                                    on trasferred invoices. Trying to stop. but no luck so far.
   02/28/11   DPETE PTS55449 update of lgh_class1 not happening when revtype1 is changed
   11/14/12  DPETE PTS61443 wants triggger to handle multiple updates at a time	for the legheader revtype values
*/

declare @legs table (lgh_number int)
declare @nextleg int , @rev1 varchar(6), @rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6) ,@ordhdr int
declare @next int 
--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84590 MBR 01/16/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

BEGIN
  /* No appropriate primary or foreign key relationships exist. */
  /*** Begin Column updates specified by user ***/
  DECLARE 	@cmpid char(8)
			,@status char(6)
			,@err varchar(64)
			,@ivhinvoicestatus varchar(6)
			,@li_row_count	int,
			@updatecount	int,
			@delcount	int,
			@ivh_number int,
			@count int
declare @oldstatus varchar(6), @newstatus varchar(6)
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

/*  PTS 55449 replaces DJM 10/29/98 code below (changes moved up because of a return if the row count is > 1 */
if update(ivh_revtype1) or update(ivh_revtype2) or update(ivh_revtype3) or update( ivh_revtype4)
BEGIN

  If (select count(*) from inserted where ord_hdrnumber > 0 ) >  0
    BEGIN
   
      select @next = min (ivh_hdrnumber ) from inserted where ord_hdrnumber > 0
     
      WHILE @next is not null
        BEGIN
      
			select @rev1 = ivh_revtype1,
			@rev2 = ivh_revtype2,
			@rev3 = ivh_revtype3,
			@rev4 = ivh_revtype4,
			@ordhdr = ord_hdrnumber
			from inserted
			WHERE ivh_hdrnumber = @next
   
			insert into @legs
			select distinct(lgh_number)
			from stops 
			where stops.ord_hdrnumber = @ordhdr
			and stops.ord_hdrnumber > 0
     
			select @nextleg = min(lgh_number) from @legs
			While @nextleg is not null
				BEGIN
					update legheader
					set lgh_class1 = @rev1,
					lgh_class2 = @rev2,
					lgh_class3 = @rev3,
					lgh_class4 = @rev4
					where lgh_number = @nextleg
					and (isnull(lgh_class1,'') <> @rev1 
					or isnull(lgh_class2,'') <> @rev2 
					or isnull(lgh_class3,'') <> @rev3
					or isnull(lgh_class4,'') <> @rev4)
	        
					select @nextleg = min(lgh_number) from @legs
					where lgh_number > @nextleg
	      
				END
	     SELECT @next = min(ivh_hdrnumber) from inserted where ord_hdrnumber > 0 and ivh_hdrnumber > @next
      END
    
    END
    
END


  select	@li_row_count = @@rowcount
  --vmj1+
   if @li_row_count > 1
	return
  --vmj1-

--PTS 79233 BEGIN
select @updatecount = count(*) from inserted  
select @delcount = count(*) from deleted  
--if inserted recs & no deleteds, that's a pure insert.
--if both, that's an update	
declare @now datetime
select @now = getdate()
 	
	if (@updatecount > 0 and @delcount > 0)--is an UPDATE ONLY.
		Update invoiceheader  
		set last_updateby = @tmwuser,  
		last_updatedate = @now  
		from inserted  inner join invoiceheader on inserted.ivh_invoicenumber = invoiceheader.ivh_invoicenumber 
--PTS 79233 END

  SELECT @ivhinvoicestatus = ivh_invoicestatus FROM inserted

  IF charindex(@ivhinvoicestatus,'RTP,PRO,PRN,XFR',1) > 0
	BEGIN
	   -- comment if status set back to HLD, value in archarge is not cleared
		UPDATE invoiceheader  
		SET ivh_archarge = inserted.ivh_totalcharge
	     	FROM inserted
	    	WHERE (invoiceheader.ivh_hdrnumber = inserted.ivh_hdrnumber)
			and (invoiceheader.ivh_hdrnumber <> inserted.ivh_hdrnumber)
	END

--	LOR	PTS# 33517
	If update(ivh_misc_number)
	BEGIN
		SELECT @ivh_number = ivh_hdrnumber FROM inserted
		select @count = count(*) from invoiceheader_misc where ihm_hdrnumber = @ivh_number

		If ( SELECT ivh_misc_number FROM inserted ) <> '' 
		Begin
			If @count = 0
				INSERT INTO invoiceheader_misc (ihm_invoicenumber, ihm_hdrnumber, 
									ihm_definition, ihm_misc_number)
				SELECT inserted.ivh_invoicenumber, inserted.ivh_hdrnumber, 
					inserted.ivh_definition, inserted.ivh_misc_number
				FROM inserted
			Else   
				UPDATE invoiceheader_misc 
				SET ihm_invoicenumber = inserted.ivh_invoicenumber, 
					ihm_hdrnumber = inserted.ivh_hdrnumber, 
					ihm_definition = inserted.ivh_definition, 
					ihm_misc_number = inserted.ivh_misc_number
				FROM inserted
				where ihm_hdrnumber = @ivh_number
		End
	END
--	LOR

  return

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[st_invoiceheader] on [dbo].[invoiceheader]  after update
as
SET NOCOUNT ON  

/* Revision History:
	18/06/09   Luis B		Enviar datos a wfactura
*/

declare	
 @ord int
 ,@status  char(3)
 ,@invoice  varchar(12)


exec quitanulosinv
 
/*--------------------------------------------------------------*/
        SELECT @invoice = ivh_invoicenumber, 
	         @status =  ivh_invoicestatus
              FROM inserted

	  If @status  = 'PRN'
	begin
		exec actualiza_wfactura @invoice  
	end


GO
DISABLE TRIGGER [dbo].[st_invoiceheader] ON [dbo].[invoiceheader]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[TMW_Perdida_ref_en_fact]
ON [dbo].[invoiceheader] AFTER UPDATE
AS
	DECLARE @ls_cmp_id 	varchar(8),
		@ls_ref_number	Varchar(50),
		@ls_invstatus	Varchar(10),
		@ld_fechaact	DateTime,
		@ls_whoupdate	Varchar(10),
		@li_ordennum	Integer

	

SELECT 	@ls_cmp_id 	= a.ivh_billto,
	@ls_ref_number	=	a.ivh_ref_number,
	@ls_invstatus	=	a.ivh_invoicestatus,
	@ld_fechaact	= a.last_updatedate,
	@ls_whoupdate	= a.last_updateby,
	@li_ordennum	= a.ord_hdrnumber
FROM [invoiceheader] a, INSERTED b
WHERE   a.ord_hdrnumber = b.ord_hdrnumber;

---se modifico las sig lineas


--IF UPDATE (ivh_ref_number) and not (@ls_ref_number) Is Null
--
	--Begin
		--Insert tmwdes..tmw_facturassinref_number(compania,ref_number,invstatus,fechaact,whoupdate,ordennum)
	--Values(@ls_cmp_id,@ls_ref_number, @ls_invstatus, @ld_fechaact, @ls_whoupdate,@li_ordennum )

	--END


GO
DISABLE TRIGGER [dbo].[TMW_Perdida_ref_en_fact] ON [dbo].[invoiceheader]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_invoiceheader] on [dbo].[invoiceheader] for update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------
	05/18/2001	Vern Jewett		(none)	PTS 10379: Original.
	02/28/2002	Vern Jewett		vmj1	PTS 12286: don't insert audit row unless the feature is turned on.
	09/09/2002	Doug McRowe			PTS 
  7/19/04 DPETE PTS 23977-22082 audit changes to trl_configuration
   04/13/06    Jason Bauwin      PTS 32222  Set the Bill Date to current time if changing to RTP
	02/26/2009	Chris Brickley	CJB		PTS 44833: Performance fixes to not update the expedite_audit table, just insert
   06/07/10 DPETE PTS51844 add revenue tracking
   06/28/10 DPETE PTS51844 revenue tracking changes for dot net pre rating
   01/18/11 DPETE  PTS55393    add miles to revenue tracker (for invoice only)
   10/13/11 SGB PTS 59166 Added update section for new column ivh_dedicated_includedate 
   11/7/11 SGB PTS 59166 Addd subquery for MAX DBSE_ID
   1/31/13 NQIAO PTS62719 Added more cases when updating column ivh_dedicated_includedate
*/
--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84590 MBR 01/16/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

declare	@ls_user 			varchar(20)
		,@ldt_updated_dt	datetime
		,@ls_msg			varchar(255)
		,@ls_audit			varchar(1)
 ,@ord int
 ,@newval varchar(50)
 ,@oldval varchar(50)
 ,@v_setbilldate char(1)
declare @v_oldstatus varchar(6),@v_newstatus varchar(6), @v_ivhhdrnumber int, @v_now datetime -- 51844
declare     @v_appid varchar(30),@v_recordzerochanges char(1) ,@v_next int  -- 51844

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

/* begin revenue tracking, only opertional if GI setting and updating singel records */
If  exists (select 1 from generalinfo where upper(gi_name) = 'TRACKREVENUE' and gi_string1 = '100') and
    (select count(*) from inserted) = 1 
  BEGIN
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
    
    Select @v_next = min(ivh_hdrnumber) from inserted
    While @v_next is not null
     BEGIN  -- next invoice loop
      select @v_oldstatus = isnull(ivh_invoicestatus,'null'), @ord = ord_hdrnumber , @v_ivhhdrnumber = ivh_hdrnumber  from deleted
      select @v_newstatus = isnull(ivh_invoicestatus,'null') from inserted

      If @v_oldstatus <> 'CAN' and @v_newstatus = 'CAN'
        BEGIN  -- invoice was cancelled
         -- delete revue for this invoice
         delete from revenue_tracking where  ivh_hdrnumber = @v_ivhhdrnumber
         If @ord > 0
           BEGIN  -- invoice is for an order 
             -- if this is the only invice for the order 
             if not exists (select 1 from invoiceheader where ord_hdrnumber = @ord and ivh_hdrnumber <> @v_ivhhdrnumber)
              delete from revenue_tracking where ord_hdrnumber = @ord
           END  -- invoice is for an order 
        END
      If @v_oldstatus = 'CAN' and @v_newstatus <> 'CAN'
        BEGIN  -- invoice was un cancelled
         -- create revenue records for all charges on the invoice.  (Assumes invoice header is updated  AFTER details)
          Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number,cur_code
          ,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource, rvt_billmiles, rvt_billemptymiles)
           select ivd.ord_hdrnumber
           ,inserted.ivh_hdrnumber
           ,inserted.ivh_definition
           ,@v_now
           ,ivd.cht_itemcode
           ,ivd.ivd_charge
           ,ivd.tar_number
           ,ivd.cur_code
           ,'N'
           ,'???'
           ,ivh_invoicestatus
           ,@tmwuser
           ,'ut_invoiceheader un cancel'
           ,convert(decimal(9,1),isnull(ivd_distance,0.0))
           ,convert(decimal(9,1),isnull(ivd_empty_distance,0.0))
           from inserted join invoicedetail ivd on inserted.ivh_hdrnumber = ivd.ivh_hdrnumber
           where ivd_charge <> 0 
           -- looking for pickup or delivery record with miles on it
           or ((ivd.ivd_distance <> 0 or ivd.ivd_empty_distance <> 0) 
                and ivd.stp_number > 0) 
        END  -- invoice was un cancelled
        If @v_oldstatus = 'CAN' and @v_newstatus = 'CAN'
          BEGIN
          -- assume if invoice is for order delete of records for order happened when status wen to CAN first time
          -- folloowing is just in case timing results in invoicedetails being added 
            delete from revenue_tracker where ivh_hdrnumber = @v_ivhhdrnumber
          END
        if UPDATE (ivh_invoicestatus)
         -- create revenue records for status change
          Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
          ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby
          , rvt_billmiles, rvt_billemptymiles)
           select inserted.ord_hdrnumber
           ,inserted.ivh_hdrnumber
           ,inserted.ivh_definition
           ,getdate()
           ,'UNK'
           ,0.00
           ,0
           ,inserted.ivh_currency
           ,'N'
           ,'???'
           ,inserted.ivh_invoicestatus
           ,@tmwuser
           ,'ut_invoiceheader Status changed'
           ,@v_appid
           ,0
           ,0
           ,inserted.ivh_rateby
           ,0.0
           ,0.0
           from inserted 
      select @v_next = min(ivh_hdrnumber) from inserted where ivh_hdrnumber > @v_next
    END  -- next invoice loop
  END
/* end revenue tracking */


--vmj1+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit <> 'Y'
	return
--vmj1-
IF UPDATE (ivh_trlconfiguration)
BEGIN
      IF (select upper(substring(gi_string1,1,1)) from generalinfo
      	  where gi_name = 'FingerprintAudit') = 'Y' 
     BEGIN
          SELECT @ord = ord_hdrnumber,
                             @newval = ivh_trlconfiguration
              FROM inserted
          SELECT @oldval = ivh_trlconfiguration
              FROM deleted
          IF @oldval <> @newval
          INSERT INTO  expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, update_note, mov_number,
                                                                         lgh_number, join_to_table_name, key_value)
                    SELECT @ord, UPPER(@tmwuser), GETDATE(),'TRL CONFIGURATION',
                                      'On update '+isnull( @oldval, 'NULL') + ' -> ' + 
                                      isnull( @newval, 'NULL'),
                                      isnull(i.mov_number,0),0,'invoiceheader',convert(varchar(100), i.ivh_hdrnumber)
                        FROM inserted i
     END
END

--Log to the expedite_audit table..
select	@ls_user = @tmwuser
		,@ldt_updated_dt = getdate()


/* TotalCharges.  Note below that -510000000.07 is a very unlikely money amount that represents 
	NULL in comparisons..	*/
if update(ivh_totalcharge)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', TotalCharges ' + 
--							isnull(convert(varchar(20), d.ivh_totalcharge), 'null') + ' -> ' + 
--							isnull(convert(varchar(20), i.ivh_totalcharge), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_totalcharge, -510000000.07) <> 
--				isnull(d.ivh_totalcharge, -510000000.07)
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'TotalCharges ' + isnull(convert(varchar(20), d.ivh_totalcharge), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.ivh_totalcharge), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_totalcharge, -510000000.07) <> 
				isnull(d.ivh_totalcharge, -510000000.07)
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833*/
end


/* BillTo.  Note below that 'nU1L' is a very unlikely string value that represents NULL in 
	comparisons..	*/
if update(ivh_billto)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', BillTo ' + 
--							ltrim(rtrim(isnull(d.ivh_billto, 'null'))) + ' -> ' + 
--							ltrim(rtrim(isnull(i.ivh_billto, 'null')))
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_billto, 'nU1L') <> isnull(d.ivh_billto, 'nU1L')
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'BillTo ' + ltrim(rtrim(isnull(d.ivh_billto, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.ivh_billto, 'null')))
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_billto, 'nU1L') <> isnull(d.ivh_billto, 'nU1L')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


--Status..
if update(ivh_invoicestatus)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', Status ' + 
--							ltrim(rtrim(isnull(d.ivh_invoicestatus, 'null'))) + ' -> ' + 
--							ltrim(rtrim(isnull(i.ivh_invoicestatus, 'null')))
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_invoicestatus, 'nU1L') <> isnull(d.ivh_invoicestatus, 'nU1L')
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'Status ' + ltrim(rtrim(isnull(d.ivh_invoicestatus, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.ivh_invoicestatus, 'null')))
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_invoicestatus, 'nU1L') <> isnull(d.ivh_invoicestatus, 'nU1L')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


/* ShipDate.  Note below that 1901-03-30 is a very unlikely date that represents NULL in 
	comparisons..	*/
if update(ivh_shipdate)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', ShipDate ' + 
--							isnull(convert(varchar(30), d.ivh_shipdate, 101), 'null') + ' -> ' + 
--							isnull(convert(varchar(30), i.ivh_shipdate, 101), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_shipdate, '1901-03-30') <> isnull(d.ivh_shipdate, '1901-03-30')
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'ShipDate ' + isnull(convert(varchar(30), d.ivh_shipdate, 101), 'null') + ' -> ' + 
				isnull(convert(varchar(30), i.ivh_shipdate, 101), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_shipdate, '1901-03-30') <> isnull(d.ivh_shipdate, '1901-03-30')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


/* BillDate..	*/
if update(ivh_billdate)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', BillDate ' + 
--							isnull(convert(varchar(30), d.ivh_billdate, 101), 'null') + ' -> ' + 
--							isnull(convert(varchar(30), i.ivh_billdate, 101), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_billdate, '1901-03-30') <> isnull(d.ivh_billdate, '1901-03-30')
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'BillDate ' + isnull(convert(varchar(30), d.ivh_billdate, 101), 'null') + ' -> ' + 
				isnull(convert(varchar(30), i.ivh_billdate, 101), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_billdate, '1901-03-30') <> isnull(d.ivh_billdate, '1901-03-30')
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


/* TotalWeight.  Note below that -510000000.07 is a very unlikely money amount that represents 
	NULL in comparisons..	*/
if update(ivh_totalweight)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', TotalWeight ' + 
--							isnull(convert(varchar(20), d.ivh_totalweight), 'null') + ' -> ' + 
--							isnull(convert(varchar(20), i.ivh_totalweight), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_totalweight, -510000000.07) <> isnull(d.ivh_totalweight, -510000000.07)
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'TotalWeight ' + isnull(convert(varchar(20), d.ivh_totalweight), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.ivh_totalweight), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_totalweight, -510000000.07) <> isnull(d.ivh_totalweight, -510000000.07)
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


/* TotalMiles..	*/
if update(ivh_totalmiles)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', TotalMiles ' + 
--							isnull(convert(varchar(20), d.ivh_totalmiles), 'null') + ' -> ' + 
--							isnull(convert(varchar(20), i.ivh_totalmiles), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_totalmiles, -510000000.07) <> isnull(d.ivh_totalmiles, -510000000.07)
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'TotalMiles ' + isnull(convert(varchar(20), d.ivh_totalmiles), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.ivh_totalmiles), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_totalmiles, -510000000.07) <> isnull(d.ivh_totalmiles, -510000000.07)
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end


/* TotalPieces..	*/
if update(ivh_totalpieces)
begin
	--Update the rows that already exist..
/*CJB START -- 44833
--	update	expedite_audit
--	  set	update_note = ea.update_note + ', TotalPieces ' + 
--							isnull(convert(varchar(20), d.ivh_totalpieces), 'null') + ' -> ' + 
--							isnull(convert(varchar(20), i.ivh_totalpieces), 'null')
--	  from	expedite_audit ea
--			,deleted d
--			,inserted i
--	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
--		and	isnull(i.ivh_totalpieces, -510000000.07) <> isnull(d.ivh_totalpieces, -510000000.07)
--		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--		and	ea.updated_by = @ls_user
--		and	ea.activity = 'InvoiceHeader update'
--		and	ea.updated_dt = @ldt_updated_dt
--		and	ea.key_value = convert(varchar(20), i.ivh_hdrnumber)
--		and	ea.mov_number = isnull(i.mov_number, 0)
--		and	ea.lgh_number = 0
--		and	ea.join_to_table_name = 'invoiceheader'
CJB END -- 44833 */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_user
			,'InvoiceHeader update'
			,@ldt_updated_dt
			,'TotalPieces ' + isnull(convert(varchar(20), d.ivh_totalpieces), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.ivh_totalpieces), 'null')
			,convert(varchar(20), i.ivh_hdrnumber)
			,isnull(i.mov_number, 0)
			,0
			,'invoiceheader'
	  from	deleted d
			,inserted i
	  where	i.ivh_hdrnumber = d.ivh_hdrnumber
		and	isnull(i.ivh_totalpieces, -510000000.07) <> isnull(d.ivh_totalpieces, -510000000.07)
/*CJB START -- 44833
--		and	not exists
--			(select	'x'
--			  from	expedite_audit ea2
--			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--				and	ea2.updated_by = @ls_user
--				and	ea2.activity = 'InvoiceHeader update'
--				and	ea2.updated_dt = @ldt_updated_dt
--				and	ea2.key_value = convert(varchar(20), i.ivh_hdrnumber)
--				and	ea2.mov_number = isnull(i.mov_number, 0)
--				and	ea2.lgh_number = 0
--				and	ea2.join_to_table_name = 'invoiceheader')
CJB END -- 44833 */
end
select @v_setbilldate = left(isnull(ltrim(rtrim(UPPER(gi_string1))),'N'),1)
  from generalinfo
 where gi_name = 'SetInvoiceBillDateOnRelease'

if @v_setbilldate = 'Y' and (select count(*) from inserted) = 1 and (select count(*) from deleted) = 1
begin
   if (select ivh_invoicestatus from deleted) <> 'RTP' and (select ivh_invoicestatus from inserted) = 'RTP'
   begin
      update invoiceheader
         set ivh_billdate = getdate()
        from inserted
       where inserted.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
   end
end

--PTS 59166 SGB
IF Update(ivh_mbstatus) 
BEGIN
	IF (select count(1) from inserted where ivh_mbstatus in ('RTP','PRO')) > 0
	BEGIN
		UPDATE invoiceheader
		SET ivh_dedicated_includedate =
		(SELECT CASE
			CASE isnull(dbse.dbse_usedate,'DELV') 
			WHEN 'UNK' THEN 'DELV'
			ELSE dbse.dbse_usedate
			END
		WHEN	'LAST' THEN isnull((select max(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number ),ih.ivh_deliverydate) 
		WHEN	'DRPA' THEN isnull((select min(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'),ih.ivh_deliverydate)
		WHEN	'DRPS' THEN	isnull((select min(s.stp_schdtearliest) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'),ih.ivh_deliverydate)
		WHEN	'AVIL' THEN ISNULL((select ord_availabledate from orderheader ord where ord.ord_hdrnumber = ih.ord_hdrnumber), ih.ivh_deliverydate)					--62719
		WHEN	'AFSP' THEN ISNULL((select min(s.stp_arrivaldate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'PUP'), ih.ivh_deliverydate)		--62719
		WHEN	'DFSP' THEN ISNULL((select min(s.stp_departuredate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'PUP'), ih.ivh_deliverydate)	--62719
		WHEN	'DLSP' THEN ISNULL((select max(s.stp_departuredate) from stops s where s.mov_number = ih.mov_number and s.stp_type = 'DRP'), ih.ivh_deliverydate)	--62719
		WHEN	'BKDT' THEN ISNULL((select ord_bookdate from orderheader ord where ord.ord_hdrnumber = ih.ord_hdrnumber), ih.ivh_deliverydate)						--62719
		WHEN	'ESSP' THEN ISNULL((select MIN(s.stp_schdtearliest) from stops s where s.mov_number = ih.mov_number and s.ord_hdrnumber > 0 and stp_sequence = 1), ih.ivh_deliverydate)			--62709
		WHEN	'FPSD' THEN ISNULL((select min(s.stp_schdtearliest) from stops s where s.mov_number = ih.mov_number and stp_type = 'PUP'), ih.ivh_deliverydate)		--62719
		END
		from inserted ih
		join dedbillingscheduleentity dbse
		on ih.ivh_billto = dbse.ord_billto
		and dbse_id = (Select MAX(dbse2.dbse_id) 
					from dedbillingscheduleentity dbse2
					where 	(dbse2.ord_revtype1 = 'UNK' or ih.ivh_revtype1 = dbse2.ord_revtype1)
							and (dbse2.ord_revtype2 = 'UNK' or ih.ivh_revtype2 = dbse2.ord_revtype2)
							and (dbse2.ord_revtype3 = 'UNK' or ih.ivh_revtype3 = dbse2.ord_revtype3)
							and (dbse2.ord_revtype4 = 'UNK' or ih.ivh_revtype4 = dbse2.ord_revtype4)
							and (dbse2.ord_booked_revtype1 = 'UNKNOWN' or ih.ivh_booked_revtype1 = dbse2.ord_booked_revtype1)
							and (dbse2.ord_billto = ih.ivh_billto ))
		join dedbillingschedule dbs
		on dbse.dbs_id = dbs.dbs_id 
		where ih.ivh_hdrnumber = ivh1.ivh_hdrnumber
		and dbs_action in ('CRTBIL','CRTDRA')
		and dbs_status = 'Active')
		from inserted ivh1
		where ivh1.ivh_mbstatus in ('RTP','PRO')
		and ivh1.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
		

	END
END
--END PTS 59166 SGB

GO
CREATE NONCLUSTERED INDEX [dk_ivh_dbhid_ivhbillto] ON [dbo].[invoiceheader] ([dbh_id], [ivh_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_applyto] ON [dbo].[invoiceheader] ([ivh_applyto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_invoiceheader_9_1125579048__K38_K40_K9_K74_K75_K51_K2_3_4_19_20_26] ON [dbo].[invoiceheader] ([ivh_billdate], [ivh_hdrnumber], [ivh_invoicestatus], [ivh_mbstatus], [ivh_mbnumber], [ivh_tractor], [ivh_billto]) INCLUDE ([ivh_terms], [ivh_totalcharge], [ivh_revtype1], [ivh_revtype2], [ivh_currency]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_billdt] ON [dbo].[invoiceheader] ([ivh_billdate], [ivh_invoicenumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_billto] ON [dbo].[invoiceheader] ([ivh_billto], [ivh_invoicestatus]) INCLUDE ([ivh_totalcharge]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_invoiceheader_billffg] ON [dbo].[invoiceheader] ([ivh_booked_revtype1], [ivh_billto], [ivh_billdate], [ivh_invoicestatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_cmrbill_link] ON [dbo].[invoiceheader] ([ivh_cmrbill_link]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_deldt] ON [dbo].[invoiceheader] ([ivh_deliverydate]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_ivh_number] ON [dbo].[invoiceheader] ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_invnum] ON [dbo].[invoiceheader] ([ivh_invoicenumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_status] ON [dbo].[invoiceheader] ([ivh_invoicestatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivh_mbnumber] ON [dbo].[invoiceheader] ([ivh_mbnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivh_mbstatus] ON [dbo].[invoiceheader] ([ivh_mbstatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_invoiceheader_ivh_ref_number] ON [dbo].[invoiceheader] ([ivh_reftype], [ivh_ref_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivh_shipdt] ON [dbo].[invoiceheader] ([ivh_shipdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivh_mfh_hdrnum] ON [dbo].[invoiceheader] ([mfh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_move] ON [dbo].[invoiceheader] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivh_ord_hdrnum] ON [dbo].[invoiceheader] ([ord_hdrnumber], [ivh_billdate]) INCLUDE ([ivh_invoicestatus], [ivh_totalcharge], [ivh_invoicenumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Invoiceheader_timestamp] ON [dbo].[invoiceheader] ([timestamp]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1125579048_38_9_74_75_51] ON [dbo].[invoiceheader] ([ivh_billdate], [ivh_invoicestatus], [ivh_mbstatus], [ivh_mbnumber], [ivh_tractor])
GO
CREATE STATISTICS [_dta_stat_1125579048_2_74_75_40_38_9] ON [dbo].[invoiceheader] ([ivh_billto], [ivh_mbstatus], [ivh_mbnumber], [ivh_hdrnumber], [ivh_billdate], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_40_2_75_38_9] ON [dbo].[invoiceheader] ([ivh_hdrnumber], [ivh_billto], [ivh_mbnumber], [ivh_billdate], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_40_75_9_74_51_38_2] ON [dbo].[invoiceheader] ([ivh_hdrnumber], [ivh_mbnumber], [ivh_invoicestatus], [ivh_mbstatus], [ivh_tractor], [ivh_billdate], [ivh_billto])
GO
CREATE STATISTICS [_dta_stat_1125579048_40_74_75_38_9] ON [dbo].[invoiceheader] ([ivh_hdrnumber], [ivh_mbstatus], [ivh_mbnumber], [ivh_billdate], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_40_51_9_74] ON [dbo].[invoiceheader] ([ivh_hdrnumber], [ivh_tractor], [ivh_invoicestatus], [ivh_mbstatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_9_40_38_74] ON [dbo].[invoiceheader] ([ivh_invoicestatus], [ivh_hdrnumber], [ivh_billdate], [ivh_mbstatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_9_74_75] ON [dbo].[invoiceheader] ([ivh_invoicestatus], [ivh_mbstatus], [ivh_mbnumber])
GO
CREATE STATISTICS [_dta_stat_1125579048_75_40_38_9] ON [dbo].[invoiceheader] ([ivh_mbnumber], [ivh_hdrnumber], [ivh_billdate], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_75_9] ON [dbo].[invoiceheader] ([ivh_mbnumber], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_75_74] ON [dbo].[invoiceheader] ([ivh_mbnumber], [ivh_mbstatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_75_51_9] ON [dbo].[invoiceheader] ([ivh_mbnumber], [ivh_tractor], [ivh_invoicestatus])
GO
CREATE STATISTICS [_dta_stat_1125579048_51_9_74_75] ON [dbo].[invoiceheader] ([ivh_tractor], [ivh_invoicestatus], [ivh_mbstatus], [ivh_mbnumber])
GO
GRANT DELETE ON  [dbo].[invoiceheader] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceheader] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceheader] TO [public]
GO
