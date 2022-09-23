CREATE TABLE [dbo].[invoicedetail]
(
[ivh_hdrnumber] [int] NULL,
[ivd_number] [int] NOT NULL,
[stp_number] [int] NULL,
[ivd_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_quantity] [float] NULL,
[ivd_rate] [money] NULL,
[ivd_charge] [money] NULL,
[ivd_taxable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_taxable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_taxable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_taxable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cur_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_currencydate] [datetime] NULL,
[ivd_glnum] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ivd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_itemquantity] [float] NULL,
[ivd_subtotalptr] [int] NULL,
[ivd_allocatedrev] [money] NULL,
[ivd_sequence] [int] NULL,
[ivd_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_hdrnumber] [int] NULL,
[ivd_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_distance] [float] NULL,
[ivd_distunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_wgt] [float] NULL,
[ivd_wgtunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_count] [decimal] (10, 2) NULL,
[ivd_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_number] [int] NULL,
[ivd_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_volume] [float] NULL,
[ivd_volunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_orig_cmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[ivd_payrevenue] [money] NULL,
[ivd_sign] [smallint] NULL,
[ivd_length] [money] NULL,
[ivd_lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_width] [money] NULL,
[ivd_widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_height] [money] NULL,
[ivd_heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_remark] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[tar_tariffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_fromord] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_zipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_quantity_type] [smallint] NULL,
[cht_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_mileagetable] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_charge_type] [smallint] NULL,
[ivd_trl_rent] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_trl_rent_start] [datetime] NULL,
[ivd_trl_rent_end] [datetime] NULL,
[ivd_rate_type] [smallint] NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_IVD_last_updateby] DEFAULT (case when charindex('\',suser_sname())>(0) then left(substring(suser_sname(),charindex('\',suser_sname())+(1),len(suser_sname())),(20)) else left(suser_sname(),(20)) end),
[last_updatedate] [datetime] NULL CONSTRAINT [DF_IVD_last_updatedate] DEFAULT (getdate()),
[cht_lh_min] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_stl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rpt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rollintolh] [int] NULL,
[cht_lh_prn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number] [int] NULL,
[ivd_paylgh_number] [int] NULL,
[ivd_tariff_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_taxid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_ordered_volume] [decimal] (18, 0) NULL,
[ivd_ordered_loadingmeters] [decimal] (18, 0) NULL,
[ivd_ordered_count] [decimal] (18, 0) NULL,
[ivd_ordered_weight] [decimal] (18, 0) NULL,
[ivd_loadingmeters] [decimal] (18, 0) NULL,
[ivd_loadingmeters_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_hide] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_baserate] [decimal] (19, 4) NULL,
[ivd_rawcharge] [decimal] (19, 4) NULL,
[ivd_oradjustment] [decimal] (19, 4) NULL,
[ivd_cbadjustment] [decimal] (19, 4) NULL,
[ivd_fsc] [decimal] (19, 4) NULL,
[ivd_splitbillratetype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_bolid] [int] NULL,
[ivd_shared_wgt] [decimal] (19, 4) NULL,
[ivd_ARTaxAuth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_tollcost] [money] NULL,
[ivd_miscmoney1] [money] NULL,
[ivd_paid_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_paid_amount] [money] NULL,
[ivd_actual_quantity] [float] NULL,
[ivd_actual_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_tax_basis] [money] NULL,
[ivd_loaded_distance] [float] NULL,
[ivd_empty_distance] [float] NULL,
[fgt_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_showas_cmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_leaseassetid] [int] NULL,
[ivd_MaskFromRating] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_car_key] [int] NULL,
[ivd_post_invoice] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__invoicede__ivd_c__526F7A3C] DEFAULT (NULL),
[ivd_transdate] [datetime] NULL CONSTRAINT [DF__invoicede__ivd_t__53639E75] DEFAULT (NULL),
[dw_timestamp] [timestamp] NOT NULL,
[ivd_billable_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_ord_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_ico_pyd_number_parent] [int] NULL,
[ivd_description_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_rated_qty] [float] NULL,
[ivd_rated_rate] [money] NULL,
[dbst_rollinto_tar] [int] NULL,
[ivd_allocated_quantity] [float] NULL,
[ivd_allocated_rate] [money] NULL,
[ivd_allocated_charge] [money] NULL,
[ivd_allocated_ivd_number] [int] NULL,
[dbsd_id_tariff] [int] NULL,
[ivd_allocation_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_allocated_qty] [float] NULL,
[ivd_reconcile_tariff] [int] NULL,
[ivd_customer_char1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_delays] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_rate_factor] [float] NULL,
[ivd_rate_per] [decimal] (10, 2) NULL,
[ivd_sub_charge] [decimal] (10, 2) NULL,
[ivd_discount_rate] [decimal] (10, 2) NULL,
[ivd_discount] [decimal] (10, 2) NULL,
[disc_tar_number] [int] NULL,
[ivd_discount_qty] [decimal] (10, 2) NULL,
[ivd_discount_per] [decimal] (10, 2) NULL,
[ivd_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_pallets] [float] NULL,
[ivd_palletunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_rate_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deficit_row] [int] NULL,
[ivd_billdate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[dt_invoicedetail] on [dbo].[invoicedetail] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	05/18/2001	Vern Jewett		vmj1	PTS 10379: Add new fingerprinting mechanism, expedite_audit
										table.
	02/28/2002	Vern Jewett		vmj2	PTS 12286: Only insert audit row if the feature is turned on.
	03/14/2008      Frank Michels                   PTS 41818: Performed LEFT 20 on APP_NAME to prevent SQL 2005 Mgmt Studio errors
	06/08/10    DPETE PTS51844 add revenue tracking
   6/29/10 DPETE PTS51844altered for dot net rating
   9/13/10 DPETE 53926 if you re rate a tendered (inactive invoice) the dt_invoicedetail still backs out charges
                      when an invoice is deleted, the details are deleted as a group = cannot check for count = 1
    1/18/11      DPETE     PTS55393 add mileage to revenue_tracker from the ivoice only
    4/4/11   DPETE PTS56502 a pre rated negative charge is not backed out
*/


--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581

declare	@li_row_count	int
		,@ls_audit		varchar(1)
		,@ll_counter	int
		,@ls_unit		varchar(6)
declare @v_ordhdrnumber int,@v_ivhhdrnumber int,@v_ordstatus varchar(6), @v_IsActive char(1) , @v_charge money --51844
declare  @v_next int,@v_appid varchar(30),@v_recordzerochanges char(1), @v_now datetime,@v_type varchar(6), @v_fgt int  --51844 6/28
declare @v_rateby char(1) --51866 6/28
declare @v_miles decimal(9,1), @v_emptymiles decimal(9,1)


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--vmj1+
select	@li_row_count = @@rowcount


--vmj2+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'

if @ls_audit = 'Y'
	--vmj2-
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
			,'InvoiceDetail delete'
			,getdate()
			,''
			,convert(varchar(20), ivd_number)
			,0
			,0
			,'invoicedetailaudit'
	  from	deleted
--vmj1-
/* 51844 revenue tracking feature works when updating one record at a time*/
/* when you delete an invoice the detail rows are deleted as a group - more than one row in deleted */

If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100') 
  BEGIN  -- track revenue loop
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
    -- must always allow for more than one row being deleted because dt_invoiceheader deletes as a group
    select @v_next = min(ivd_number) from deleted
    while @v_next is not null
      BEGIN  -- next record in deleted table
       select @v_ordhdrnumber = ord_hdrnumber,@v_ivhhdrnumber = ivh_hdrnumber,@v_charge = ivd_charge
         ,@v_type = ivd_type, @v_fgt = isnull(fgt_number,0)
         ,@v_miles = convert(decimal(9,1),isnull(ivd_distance,0.0)),@v_emptymiles = convert(decimal(9,1),isnull(ivd_empty_distance,0.0))
         from deleted where ivd_number = @v_next
       if @v_ivhhdrnumber = 0 and (@v_type = 'SUB' or @v_fgt > 0 )  -- ignore dot net pre rate SUB and fgt charge lines
         BEGIN -- dot net pre rated SUB or detail charge (ignore)
           select @v_next = min(ivd_number) from deleted where ivd_number > @v_next
           CONTINUE
         END -- dot net pre rated SUB or detail charge (ignore)
       if @v_ivhhdrnumber > 0 
          select @v_rateby = ivh_rateby from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber
       else
          select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @v_ordhdrnumber
       select @v_rateby = isnull(@v_rateby,'?')  -- for tracking only so it is not critical
       -- 9/13/10 code to check for active status was commented out. Reinstated the check
       If @v_ordhdrnumber > 0 and @v_ivhhdrnumber = 0 
        BEGIN
          Select @v_ordstatus = ord_status from orderheader where ord_hdrnumber = @v_ordhdrnumber
          Select @v_IsActive = (dbo.fn_StatusIsActive (@v_ordstatus))
         END
       ELSE
          Select @v_IsActive = 'Y'

       -- if this charge is on an invoice or if it is on an active (AVL or greater or ICO) then backout charge from revenue
       --If @v_charge > 0 or @v_recordzerochanges = 'Y' --and (@v_ivhhdrnumber > 0 or (@v_ordhdrnumber > 0 and  @v_IsActive = 'Y'))
       --IF @v_IsActive = 'Y' and (@v_charge > 0 or @v_recordzerochanges = 'Y' or @v_miles > 0 or @v_emptymiles > 0) 
       IF @v_IsActive = 'Y' and (@v_charge <> 0 or @v_recordzerochanges = 'Y' or @v_miles > 0 or @v_emptymiles > 0) 

         -- backout old
         Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
         ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
         ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby,rvt_billmiles, rvt_billemptymiles)
         select ISNULL(deleted.ord_hdrnumber,-1)
           ,ISNULL(deleted.ivh_hdrnumber,-1)
           ,case ISNULL(deleted.ivh_hdrnumber,-1) when 0 then 'PRERATE' else isnull(invoiceheader.ivh_definition,'??') end
           ,@v_now
           ,deleted.cht_itemcode
           ,(ISNULL(deleted.ivd_charge,0) * -1)
           ,deleted.tar_number 
           ,deleted.cur_code
           ,'Y'
           ,'???'
           ,'???'
           ,@tmwuser
           ,'dt_invoicedetail'
           ,@v_appid
           ,deleted.ivd_quantity
           ,deleted.ivd_number
           ,@v_rateby
           ,(case deleted.ivd_type when 'LI' then 0 when 'SUB' then 0 else (convert(decimal(9,1),isnull(deleted.ivd_distance,0.0)) * -1) end) 
           ,(case deleted.ivd_type when 'LI' then 0 when 'SUB' then 0 else (convert(decimal(9,1),isnull(deleted.ivd_empty_distance,0.0)) * -1) end)
           from deleted
           left outer join invoiceheader on deleted.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
           where deleted.ivd_number = @v_next
         select @v_next = min(ivd_number) from deleted where ivd_number > @v_next
       END  -- next record in deleted table 
  END   -- track revenue loop
/* end revenue tracking */

--JLB PTS 39863  update the asset hours or miles from lease argeement details if needbe
select @ll_counter = min(ivd_number)
  from deleted
 where isnull(ivd_leaseassetid,0) > 0
while @ll_counter is not null
begin
	select @ls_unit = ivd_unit
      from deleted
     where ivd_number = @ll_counter
    if @ls_unit = 'MIL'
	begin
		update asset_hubmiles
           set ahub_invoicestatus = 'AVL'
          from asset_hubmiles
          join deleted on deleted.ivd_leaseassetid = asset_hubmiles.ahub_id
		 where deleted.ivd_number = @ll_counter
	end
	else if @ls_unit = 'HRS'
	begin
		update asset_hours
           set ah_invoicestatus = 'AVL'
		  from asset_hours
          join deleted on deleted.ivd_leaseassetid = asset_hours.ah_id
		 where deleted.ivd_number = @ll_counter
	end
	select @ll_counter = min(ivd_number)
	  from deleted
	 where isnull(ivd_leaseassetid,0) > 0 
       and ivd_number > @ll_counter	
end

--PTS 69445 delete any reference number for invoicedetail when invoice detail is deleted.                    
DELETE referencenumber
  FROM referencenumber r 
  JOIN deleted d ON r.ref_tablekey = d.ivd_number AND
                    r.ref_table = 'invoicedetail'
--end 69445

if exists (select * from generalinfo where gi_name = 'InvoiceDetailAudit' and gi_string1 = 'Y')
begin   

	--vmj1+
  	if @li_row_count > 1 
--	if @@rowcount > 1 
		--vmj1-
     	return	
--PTS 36955 JJF 20080625
--    insert into invoicedetailaudit
--		(ivd_number ,	audit_status  ,	audit_user    ,	audit_date    ,	cht_itemcode, ivd_quantity  ,
--		ivd_rate      ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber, audit_app )
--      (select ivd_number, 'D', @tmwuser ,getdate(), cht_itemcode ,ivd_quantity,
--	     ivd_rate ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber,  LEFT(APP_NAME(), 20)
--	 from  deleted) 
		INSERT INTO invoicedetailaudit(
			ivd_number
			,audit_status
			,audit_user
			,audit_date
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,audit_app
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating
			,ivd_car_key
			,ivd_leaseassetid
			,ivd_showas_cmpid
	)
	SELECT	ivd_number
			,'D'
			,@tmwuser
			,getdate()
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,LEFT(APP_NAME(),35)
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating
			,ivd_car_key
			,ivd_leaseassetid
			,ivd_showas_cmpid
	  FROM deleted

end
	     			
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_invoicedetail] on [dbo].[invoicedetail] for insert 
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	05/18/2001	Vern Jewett		vmj1	PTS 10379: Add new fingerprinting mechanism, expedite_audit
										table.
	02/28/2002	Vern Jewett		vmj2	PTS 12286: don't insert audit row unless the feature is turned on.
    06/06/10    DPETE            PTS51844 add revenue tracking
    06/28/10   DPETE    PTS51844 modify for dot net pre rating
    01/18/11     DPETE  55393 add miles to revenue tracking
    06/11/14  MCURN  79233 Removed code to update date & user who last touched. Handling w/a  Def constraint.
*/

--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581

--PTS84590 MBR 01/16/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted) 
   RETURN

declare @tar_number 	int
		,@li_row_count	int
		,@ls_audit		varchar(1)
-- PTS 29895 -- BL (start)
		, @chrgs	varchar(100)
-- PTS 29895 -- BL (end)
--PTS 35741 JJF 2007-04-30
		,@ls_update_note	varchar(255)
--END PTS 35741 JJF 2007-04-30


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
declare @v_ivhhdrnumber int, @v_ivdcharge money, @v_ordhdrnumber int ,@v_status varchar(6),@v_fgtnumber int --51844
declare @v_ivdtype varchar(6),@v_ordcurrency varchar(6),@v_charge money ,@v_StatusisActive char(1) -- 51844
declare @v_rateby char(1), @v_appid varchar(30),@v_recordzerochanges char(1), @v_type varchar(6), @v_fgt int, @v_now datetime  --51844
declare @v_billmiles decimal(9,1), @v_billemptymiles decimal(9,1), @v_MinusOneIfCredit smallint
exec gettmwuser @tmwuser output


-- PTS 29895 -- BL (start)
if exists (select * from generalinfo where gi_name = 'CHARGETYPESMARKEDASAUTO')
BEGIN	
		select @chrgs = gi_string1 From generalinfo Where gi_name = 'CHARGETYPESMARKEDASAUTO'
		select @chrgs = ',' + @chrgs + ','

		update 	invoicedetail
		set 		ivd_fromord = 'A'
		from	inserted
		where 	inserted.ivd_number = invoicedetail.ivd_number 
		and charindex((',' + rtrim(inserted.cht_itemcode)  + ','), @chrgs ,1) > 0
END
-- PTS 29895 -- BL (end)

--vmj1+	
select	@li_row_count = @@rowcount

/* revenue tracking start */
If  exists (select 1 from generalinfo where upper(gi_name) = 'TRACKREVENUE' and gi_string1 = '100') and
    (select count(*) from inserted) = 1 
  BEGIN -- revenue tracking
    select @v_appid = rtrim(left(app_name(),30))
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
    select @v_now = getdate()

    select @v_ivhhdrnumber = ivh_hdrnumber,@v_ordhdrnumber = ord_hdrnumber, @v_ivdcharge = isnull(ivd_charge,0.0),@v_ivdtype = ivd_type
    ,@v_type = ivd_type, @v_fgt = isnull(fgt_number,0)
    , @v_billmiles = (case ivd_type when 'LI' then 0 when 'SUB' then 0 else convert(decimal(9,1),isnull(ivd_distance,0.0)) end)
    ,@v_billemptymiles = (case ivd_type when 'LI' then 0 when 'SUB' then 0 else  convert(decimal(9,1),isnull(ivd_empty_distance,0.0)) end)
    from inserted
    /* does not have invoiceheader on insert all the time 
    If @v_ivhhdrnumber > 0
      select @v_rateby = ivh_rateby from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber
    else
      select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @v_ordhdrnumber
    */
    select @v_MinusOneIfCredit = 1
    If @v_ivhhdrnumber > 0 and exists(select 1 from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber )
      select @v_rateby = ivh_rateby
      ,@v_MinusOneIfCredit = (case ivh_definition when 'CRD' then -1 else 1 end) 
      from invoiceheader where ivh_hdrnumber = @v_ivhhdrnumber
    else
     BEGIN
      if  @v_ordhdrnumber > 0
        select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @v_ordhdrnumber
      else 
        select @v_rateby = 'T'
     END
    
    /* if this is a pre rated order for which the status is active or a charge on an invoice add revenue */
    If @v_ivhhdrnumber = 0 and @v_ordhdrnumber > 0 and (@v_ivdcharge <> 0 or @v_recordzerochanges = 'Y' )
       and @v_type <> 'SUB' and @v_fgt = 0  -- ignore dot net pre rate line haul invoice details
      BEGIN  -- pre rated (active) order
        select @v_status = ord_status  from orderheader where ord_hdrnumber = @v_ordhdrnumber
        if (dbo.fn_StatusIsActive (@v_status)) = 'Y' 
          -- add new

           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
           ,rvt_appname  ,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
           select ord_hdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,cht_itemcode
           ,isnull(ivd_charge,0.00) 
           ,isnull(tar_number,0)
           ,cur_code
           ,'N'
           ,'???'  
           ,'???'
           ,@tmwuser
           ,'it_invoicedetail'
           ,@v_appid
           ,ivd_quantity
           ,ivd_number
           ,@v_rateby
           ,0.0
           ,0.0
           from inserted
           where (ivd_charge <> 0 or @v_recordzerochanges = 'Y')
           and (@v_rateby = 'D' or (@v_rateby = 'T' and ivd_type in ('SUB','LI')))  /* in case a charge comes in on a delivery line for rate by total */

      END  -- pre rated order
    /* if this is an invoice with a charge, add the record (if invoice is CAN status header update after ths will delete records) */
    if @v_ivhhdrnumber  > 0 and (@v_ivdcharge <> 0 or @v_recordzerochanges = 'Y' or @v_billmiles > 0 or @v_billemptymiles > 0)
           -- add new
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
           ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)

           select inserted.ord_hdrnumber
           ,inserted.ivh_hdrnumber
           -- it_invoiceheader will update this field
           ,isnull(ivh_definition, case inserted.ord_hdrnumber when 0 then 'MISC' else 'LH' end)   -- don't know definition on new invoice, hdr updates after invoid
           ,@v_now
           ,inserted.cht_itemcode
           ,isnull(ivd_charge,0.00) 
           ,ISNULL(inserted.tar_number,0)
           ,cur_code
           ,'N'
           ,'???'
           ,'???'   -- Don't know the invoice status
           ,@tmwuser
           ,'it_invoicedetail'
           ,@v_appid
           ,ivd_quantity
           ,ivd_number
           ,@v_rateby
           -- it_invoiceheader will update this to a negative on creating a credit do not record miles on accessorial charges
           ,@v_billmiles
           ,@v_billemptymiles
           from inserted
           left outer join invoiceheader on inserted.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
           where (ivd_charge <> 0 or @v_recordzerochanges = 'Y' or @v_billmiles > 0 or @v_billemptymiles > 0)
     /* for rate by total records where we need to record mileage for delivery lines 
        or for rate by detail records for billable non PUP/DRP rows */
     /* if this is a pre rated order for which the status is active or a charge on an invoice add revenue */
     /* ##
    If (@v_ordhdrnumber > 0 and (@v_billmiles > 0 or @v_billemptymiles > 0)  and @v_fgt > 0 )
      BEGIN  -- new invoice detail for a delivery line on a rate by total order
        select @v_status = ord_status  from orderheader where ord_hdrnumber = @v_ordhdrnumber
        if (dbo.fn_StatusIsActive (@v_status)) = 'Y' 
          -- add new
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
           ,rvt_appname  ,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
           select inserted.ord_hdrnumber
           ,inserted.ivh_hdrnumber
           -- it_invoiceheader updates this field since invoiceheader may not yet exist
           ,isnull(ivh_definition, case inserted.ord_hdrnumber when 0 then 'MISC' else 'LH' end) 
           ,@v_now
           ,inserted.cht_itemcode
           ,isnull(inserted.ivd_charge,0.00) 
           ,isnull(inserted.tar_number,0)
           ,inserted.cur_code
           ,'N'
           ,'???'  
           ,'???'
           ,@tmwuser
           ,'it_invoicedetail'
           ,@v_appid
           ,inserted.ivd_quantity
           ,inserted.ivd_number
           ,@v_rateby
           -- it_invoiceheader will reverse these numbers if the invoice turns out to be a credit memeo
           ,convert(decimal(9,1),isnull(inserted.ivd_distance,0.0)) 
           ,convert(decimal(9,1),isnull(inserted.ivd_empty_distance,0.0)) 
           from inserted
           left outer join invoiceheader on inserted.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
           where (inserted.ivd_distance > 0 or inserted.ivd_empty_distance > 0)
           and (@v_rateby = 'T' and @v_fgt > 0) or (@v_rateby = 'D'  and inserted.ivd_type <> 'LI' and inserted.ivd_charge = 0)
      END
      ### */
     /* if this  is a SUB row for an order, and this is the only invoice for the order, and if it is not a dot net pre rate line haul 
       a new invoice is being created, backout the order revenue */
     If @v_ordhdrnumber > 0 and @v_ivhhdrnumber > 0 and not exists (select 1 from invoiceheader where ord_hdrnumber = @v_ordhdrnumber and ivh_hdrnumber <  @v_ivhhdrnumber)
        and @v_type = 'SUB' 
        -- backout ord charge
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
           ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
           select ord_hdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,cht_itemcode
           ,isnull((ord_charge * -1),0.00) 
           ,ISNULL(tar_number,0)
           ,ord_currency
           ,'Y'
           ,'???'
           ,'???'
           ,@tmwuser
           ,'it_invoicedetail'
           ,@v_appid
           ,ord_quantity
           ,0
           ,ord_rateby
           ,0.0
           ,0.0
           from orderheader
           where ord_hdrnumber = @v_ordhdrnumber
           and (ord_charge <> 0 or @v_recordzerochanges = 'Y')
      /* if this is a freight charge row and it is not a dot net pre rate line haul charge
         and this is the first invoice for the order, backout the fgt charge from the order */
      select @v_fgtnumber = fgt_number from inserted
      if @v_ordhdrnumber > 0  and @v_ivhhdrnumber > 0 and @v_fgtnumber > 0 and not exists (select 1 from invoiceheader where ord_hdrnumber = @v_ordhdrnumber and ivh_hdrnumber <  @v_ivhhdrnumber)
        and @v_rateby = 'D'
        BEGIN
           select  @v_status =  ord_status ,@v_ordcurrency =  ord_currency,@v_rateby = ord_rateby
           from orderheader where ord_hdrnumber = @v_ordhdrnumber
        -- backout fgt charge
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
           ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
           select @v_ordhdrnumber
           ,0
           ,'PRERATE'
           ,@v_now
           ,cht_itemcode
           ,isnull((fgt_charge * -1) ,0.000)
           ,ISNULL(tar_number,0)
           ,@v_ordcurrency
           ,'Y'
           , '???'  
           ,'???'
           ,@tmwuser
           ,'it_invoicedetail'
           ,@v_appid
           ,fgt_quantity
           ,0
           ,@v_rateby
           ,0.0  -- miles not recorded for orders, nothing to back out.
           ,0.0
           from freightdetail 
           where fgt_number = @v_fgtnumber
           and (fgt_charge <> 0 or @v_recordzerochanges = 'Y')
        END
  END -- revenue tracking

--vmj2+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
	--PTS 35741 JJF 2007-04-30
	SELECT @ls_update_note = 'ChargeType ' + ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
	FROM inserted i
	SELECT @ls_update_note =  @ls_update_note + ' Rate ' + isnull(convert(varchar(20), i.ivd_rate, 2), 'null') 
	FROM inserted i
	--END PTS 35741 JJF 2007-04-30

	--vmj2-
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
			,@tmwuser
			,'InvoiceDetail insert'
			,getdate()
			--PTS 35741 JJF 2007-04-30
			--,''
			,@ls_update_note
			--END PTS 35741 JJF 2007-04-30
			,convert(varchar(20), ivd_number)
			,0
			,0
			,'invoicedetailaudit'
	  from	inserted


if @li_row_count > 1 
--if @@rowcount > 1 
	return	
--vmj1-


if exists (select * from generalinfo where gi_name = 'InvoiceDetailAudit' and gi_string1 = 'Y')
begin   
--  	select @tar_number = tar_number from inserted 
 
--  	if @tar_number > 0 
--PTS 36955 JJF 20080625
--     	insert into invoicedetailaudit
--			(ivd_number ,	audit_status  ,	audit_user    ,	audit_date    ,	cht_itemcode,ivd_quantity  ,
--			ivd_rate      ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber, audit_app)
--		  (select ivd_number, 'C', @tmwuser ,getdate(), cht_itemcode ,ivd_quantity,
--	     	ivd_rate ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber,  APP_NAME()
--		 from inserted) 
		INSERT INTO invoicedetailaudit(
			ivd_number
			,audit_status
			,audit_user
			,audit_date
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,audit_app
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating
			,ivd_car_key
			,ivd_leaseassetid
			,ivd_showas_cmpid
	)
	SELECT	ivd_number
			,'C'
			,@tmwuser
			,getdate()
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,LEFT(APP_NAME(),35)
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,null --ivd_MaskFromRating
			,null --ivd_car_key
			,null --ivd_leaseassetid
			,null --ivd_showas_cmpid
	  FROM inserted
		
end	
/* (cons 40012) because w_inv_edit not available for hot SR (40230) had to update freight from trigger */
if update(fgt_supplier) and  exists (select 1 from inserted where fgt_number > 0) 
  BEGIN
    update freightdetail
    set fgt_supplier = inserted.fgt_supplier
    from inserted
    where freightdetail.fgt_number = inserted.fgt_number
    and isnull(freightdetail.fgt_supplier,'UNKNOWN') <> isnull(inserted.fgt_supplier,'UNKNOWN')

  END

--This is an INSERT TRIGGER, so there will never be anything in the DELETED table.
--Will be handled by a default constraint. PTS 79233
/*
--PTS 36955 JJF 20080627 Move iut_invoicedetail_changelog to here, since it caused multiple audit entries
declare @updatecount	int,
	@delcount	int

--PTS 23691 CGK 9/3/2004
--DECLARE @tmwuser varchar (255)
--exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update invoicedetail
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.ivd_number = invoicedetail.ivd_number
		and (isNull(invoicedetail.last_updateby,'') <> @tmwuser
		OR isNull(invoicedetail.last_updatedate,'19500101') <> getdate())
--END PTS 36955 JJF 20080627 Move iut_invoicedetail_changelog to here, since it caused multiple audit entries
*/

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_invoicedetail] on [dbo].[invoicedetail] for update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	----------------------------------------------------------
	05/18/2001	Vern Jewett		10379	vmj1	Add new fingerprinting mechanism, expedite_audit table.
	02/26/2002	Vern Jewett		12286	vmj2	Need to audit changes to Charge Type (cht_itemcode) also.
	03/14/2008      Frank Michels           41818           Performed LEFT 20 on APP_NAME to prevent SQL 2005 Mgmt Studio errors
	02/26/2009  Chris Brickley  44833   CJB		Performance changes to remove update statements to the expedite_audit table.
    06/07/10    DPETE           PTS51844        add revenue tracking
    06/28/10    DPETE             PTS51844 modify for dot net pre rating
    9/9/10 PTS 53926 DPETE revenue tracker creating add restriction that runs only if one record updated
    1/17/11     DPETE            55393          Add miles to revenue_tracker table  

*/

--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581
--PTS84590 MBR 01/16/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

declare @tar_number 		int
		,@ls_user	  		varchar(20)
		,@ldt_updated_dt	datetime
		,@li_row_count		int
		,@ls_audit			varchar(1)
declare @v_status varchar(6),@v_ordhdrnumber int ,@v_ivhhdrnumber int ,@v_now datetime ,@v_fromord char(1) -- 51844 
declare @v_appid varchar(30),@v_recordzerochanges char(1) , @v_next int ,@v_type varchar(6), @v_fgt int -- 51844
declare @v_ordhdr int, @v_rateby char(1)  -- 51844
declare @v_oldcharge money ,@v_newcharge money, @v_oldcht varchar(8),@v_newcht varchar(8),@v_oldhdr int,@v_newhdr int
declare @v_oldmiles decimal(9,1) , @v_newmiles decimal(9,1), @v_oldemptymiles decimal(9,1), @v_newemptymiles decimal(9,1)
declare @v_ivdtype varchar(6)


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--vmj1+	Log to the expedite_audit table.  Note that I have placed my changes at the beginning, 
--	because of the return that was in the code originally..
select	@li_row_count = @@rowcount

select	@ls_user = @tmwuser
		,@ldt_updated_dt = getdate()


--PTS 36955 JJF 20080627 Move iut_invoicedetail_changelog to here, since it caused multiple audit entries
declare @updatecount	int,
	@delcount	int

--PTS 23691 CGK 9/3/2004
--DECLARE @tmwuser varchar (255)
--exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update invoicedetail
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.ivd_number = invoicedetail.ivd_number
		and (isNull(invoicedetail.last_updateby,'') <> @tmwuser
		OR isNull(invoicedetail.last_updatedate,'19500101') <> getdate())
--END PTS 36955 JJF 20080627 Move iut_invoicedetail_changelog to here, since it caused multiple audit entries

-- NQIAO 02/12/13 PTS 62646 moved this set of code from the bottom to here
/* (cons 40012) because w_inv_edit not available for hot SR (40230) had to update freight from trigger */
if update(fgt_supplier) and  exists (select 1 from inserted where fgt_number > 0) 
  BEGIN
    update freightdetail
    set fgt_supplier = inserted.fgt_supplier
    from inserted
    where freightdetail.fgt_number = inserted.fgt_number
    and isnull(freightdetail.fgt_supplier,'UNKNOWN') <> isnull(inserted.fgt_supplier,'UNKNOWN')

  END


/* revenue tracking feature only if updating one row at a time*/
If  exists (select 1 from generalinfo where UPPER(gi_name) = 'Trackrevenue' and gi_string1 = '100') 
    and (select count(*) from (select top 2 ivd_number from inserted) a ) = 1
  BEGIN --revenue tracking
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')

    select @v_next = min(ivd_number) from inserted
    while @v_next is not null   -- since we checked above for a single record update loop should only happen once
     BEGIN  -- loop records
      select @v_oldcharge = ivd_charge, @v_oldcht = cht_itemcode,@v_oldhdr = ivh_hdrnumber ,@v_fromord = isnull(ivd_fromord,'?') 
      ,@v_oldmiles = convert(decimal(9,1),isnull(ivd_distance,0)), @v_oldemptymiles = convert(decimal(9,1), isnull(ivd_empty_distance,0))
      from deleted where ivd_number = @v_next
      select @v_newcharge = ivd_charge, @v_newcht = cht_itemcode,@v_newhdr = ivh_hdrnumber ,@v_type = ivd_type
      ,@v_ordhdr = ord_hdrnumber, @v_fgt = isnull(fgt_number,0)
      ,@v_newmiles = convert(decimal(9,1),isnull(ivd_distance,0)), @v_newemptymiles = convert(decimal(9,1), isnull(ivd_empty_distance,0))
      ,@v_ivdtype = ivd_type
      from inserted where ivd_number = @v_next
   /* ignore miles on accessorial or subtotal lines */
      If (@v_ivdtype = 'LI' or @v_ivdtype = 'SUB') select  @v_oldmiles = 0,@v_oldemptymiles= 0, @v_newmiles = 0,@v_newemptymiles = 0
     
      -- bypass pre rated SUB and freight detail records revenue changes will be taken from orderheader and freight records
      if @v_oldhdr = 0 and @v_newhdr = 0 and (@v_type = 'SUB' or @v_fgt > 0)
        BEGIN  -- change to dot net pre rated line haul or freight record, ignore charge rev is recorded form order header or fgt
           select @v_next = min(ivd_number) from inserted where ivd_number > @v_next
           CONTINUE
        END
      select @v_oldcharge = isnull(@v_oldcharge,0.00),@v_newcharge = isnull(@v_newcharge,0.00)
      select @v_oldcht = isnull(@v_oldcht,'null'),@v_newcht = isnull(@v_newcht,'null')
      if @v_newhdr > 0 
        select @v_rateby = ivh_rateby from invoiceheader where ivh_hdrnumber = @v_newhdr
      else
        select @v_rateby = ord_rateby from orderheader where ord_hdrnumber = @v_ordhdr
      if ( @v_oldcharge <> @v_newcharge)
         or ( @v_oldcht <> @v_newcht)
         OR (@v_oldhdr <> @v_newhdr )  -- split invoice or dot net pre rate brought into billing
         Or (@v_oldmiles <> @v_newmiles)
         OR (@v_oldemptymiles <> @v_newemptymiles)
        BEGIN  --charge or charge type or invoice (split) changed or dot net pre rate line haul saved with invoice
         select @v_ordhdrnumber = ord_hdrnumber,@v_ivhhdrnumber = ivh_hdrnumber from inserted
         if @v_ordhdrnumber > 0 
          select @v_status = ord_status from orderheader where ord_hdrnumber = @v_ordhdrnumber
         if  @v_ivhhdrnumber > 0 or (@v_ordhdrnumber > 0 and (dbo.fn_StatusIsActive (@v_status)) = 'Y')
          BEGIN  -- pre rated (active) order or invoice
           
           -- backout old
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus, rvt_updatedby, rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby
           ,rvt_billmiles, rvt_billemptymiles)
           select del.ord_hdrnumber
           ,del.ivh_hdrnumber
           ,case @v_oldhdr when 0 then 'PRERATE' else isnull(ivh.ivh_definition, case del.ord_hdrnumber when 0 then 'MISC' else 'LH' end) end
           ,@v_now
           ,del.cht_itemcode
           ,isnull((del.ivd_charge * -1),0.00)
           ,ISNULL(del.tar_number,0) 
           ,del.cur_code
           ,'Y'
           ,'???'
           ,'???'
           ,@tmwuser
           ,'ut_invoicedetail'
           ,@v_appid
           ,del.ivd_quantity
           ,del.ivd_number
           ,@v_rateby
           ,@v_oldmiles * -1
           ,@v_oldemptymiles  * -1
           from deleted del
           left outer join invoiceheader ivh on del.ivh_hdrnumber = ivh.ivh_hdrnumber
           where del.ivd_number = @v_next
           
          -- if dot net liine haul charge record is on a invoice being deleted, do not add back in "new charges"
          -- that will be done by the dt_invoiceheader call to restore order charges
            if @v_oldhdr > 0  and @v_newhdr = 0 and (@v_type = 'SUB' or @v_fgt > 0) and (@v_fromord = 'Y' or @v_fromord = 'D')
             BEGIN  
              select @v_next = min(ivd_number) from inserted where ivd_number > @v_next
              CONTINUE
             END
          -- add new
           Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
           ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus, rvt_updatedby, rvt_updatesource,rvt_appname,rvt_quantity,ivd_number,rvt_rateby
           ,rvt_billmiles, rvt_billemptymiles)
           select ins.ord_hdrnumber
           ,ins.ivh_hdrnumber
           ,case ins.ivh_hdrnumber when 0 then 'PRERATE' else isnull(ivh.ivh_definition, case ins.ord_hdrnumber when 0 then 'MISC' else 'LH' end) end
           ,@v_now
           ,ins.cht_itemcode
           ,isnull(ins.ivd_charge,0.00)
           ,ISNULL(ins.tar_number,0) 
           ,ins.cur_code
           ,'N'
           ,'???'
           ,'???'
           ,@tmwuser
           ,'ut_invoicedetail'
           ,@v_appid
           ,ins.ivd_quantity
           ,ins.ivd_number
           ,@v_rateby
           ,@v_newmiles  -- set zero on LI or SUB lines
           ,@v_newemptymiles -- set zero on LI or SUB
           from inserted ins
           left outer join invoiceheader ivh on ins.ivh_hdrnumber = ivh.ivh_hdrnumber
           where ins.ivd_number = @v_next
            
          END  -- pre rated (active) order or invoice
       END  -- charge or chargetyoe changed
      select @v_next = min(ivd_number) from inserted where ivd_number > @v_next
     END -- loop records
  END  -- revenu tracking
/* end reveue tracking */

--vmj2+	Don't insert audit row unless the feature is turned on..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
begin
	--vmj2-
	--PTS 36955 JJF 20080626 - put in a minimal expedit_audit entry so that invoicedetailaudit can be drilled into
	if exists (select * from generalinfo where gi_name = 'InvoiceDetailAudit' and gi_string1 = 'Y')
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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'Update occurred'
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	inserted i


	--Amount..
	if update(ivd_charge)
	begin
		/*Update the rows that already exist.  Note below that -5100000000000.07 is a very unlikely
			monetary amount that I'm using to represent NULL in comparisons..	*/
/*CJB START -- 44833
--		update	expedite_audit
--		  set	update_note = ea.update_note + ', Amount ' + 
--								isnull(convert(varchar(20), d.ivd_charge), 'null') + ' -> ' + 
--								isnull(convert(varchar(20), i.ivd_charge), 'null')
--		  from	expedite_audit ea
--				,deleted d
--				,inserted i
--		  where	i.ivd_number = d.ivd_number
--			and	isnull(i.ivd_charge, -5100000000000.07) <> isnull(d.ivd_charge, -5100000000000.07)
--			and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'InvoiceDetail update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.ivd_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'invoicedetailaudit'
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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'Amount ' + isnull(convert(varchar(20), d.ivd_charge), 'null') + ' -> ' + 
					isnull(convert(varchar(20), i.ivd_charge), 'null')
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	deleted d
				,inserted i
		  where	i.ivd_number = d.ivd_number
			and	isnull(i.ivd_charge, -5100000000000.07) <> isnull(d.ivd_charge, -5100000000000.07)
/*CJB START -- 44833
--			and	not exists
--				(select	'x'
--				  from	expedite_audit ea2
--				  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--					and	ea2.updated_by = @ls_user
--					and	ea2.activity = 'InvoiceDetail update'
--					and	ea2.updated_dt = @ldt_updated_dt
--					and	ea2.key_value = convert(varchar(20), i.ivd_number)
--					and	ea2.mov_number = 0
--					and	ea2.lgh_number = 0
--					and	ea2.join_to_table_name = 'invoicedetailaudit')
CJB END -- 44833 */
	end


	--Status..
	if update(ivd_invoicestatus)
	begin
		/* Update the rows that already exist.  Note below that 'nU1L' is an unlikely string value used
			to represent NULL in comparisons..	*/
/*CJB START -- 44833
--		update	expedite_audit
--		  set	update_note = ea.update_note + ', Status ' + 
--								ltrim(rtrim(isnull(d.ivd_invoicestatus, 'null'))) + ' -> ' + 
--								ltrim(rtrim(isnull(i.ivd_invoicestatus, 'null')))
--		  from	expedite_audit ea
--				,deleted d
--				,inserted i
--		  where	i.ivd_number = d.ivd_number
--			and	isnull(i.ivd_invoicestatus, 'nU1L') <> isnull(d.ivd_invoicestatus, 'nU1L')
--			and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'InvoiceDetail update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.ivd_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'invoicedetailaudit'
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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'Status ' + ltrim(rtrim(isnull(d.ivd_invoicestatus, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_invoicestatus, 'null')))
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	deleted d
				,inserted i
		  where	i.ivd_number = d.ivd_number
			and	isnull(i.ivd_invoicestatus, 'nU1L') <> isnull(d.ivd_invoicestatus, 'nU1L')
/*CJB START -- 44833
--			and	not exists
--				(select	'x'
--				  from	expedite_audit ea2
--				  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--					and	ea2.updated_by = @ls_user
--					and	ea2.activity = 'InvoiceDetail update'
--					and	ea2.updated_dt = @ldt_updated_dt
--					and	ea2.key_value = convert(varchar(20), i.ivd_number)
--					and	ea2.mov_number = 0
--					and	ea2.lgh_number = 0
--					and	ea2.join_to_table_name = 'invoicedetailaudit')
CJB END -- 44833 */
	end


	--PayType..
	if update(ivd_type)
	begin
		--Update the rows that already exist..
/*CJB START -- 44833
--		update	expedite_audit
--		  set	update_note = ea.update_note + ', PayType ' + 
--								ltrim(rtrim(isnull(d.ivd_type, 'null'))) + ' -> ' + 
--								ltrim(rtrim(isnull(i.ivd_type, 'null')))
--		  from	expedite_audit ea
--				,deleted d
--				,inserted i
--		  where	i.ivd_number = d.ivd_number
--			and	isnull(i.ivd_type, 'nU1L') <> isnull(d.ivd_type, 'nU1L')
--			and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'InvoiceDetail update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.ivd_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'invoicedetailaudit'
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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'PayType ' + ltrim(rtrim(isnull(d.ivd_type, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.ivd_type, 'null')))
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	deleted d
				,inserted i
		  where	i.ivd_number = d.ivd_number
			and	isnull(i.ivd_type, 'nU1L') <> isnull(d.ivd_type, 'nU1L')
/* CJB START -- 44833
--			and	not exists
--				(select	'x'
--				  from	expedite_audit ea2
--				  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--					and	ea2.updated_by = @ls_user
--					and	ea2.activity = 'InvoiceDetail update'
--					and	ea2.updated_dt = @ldt_updated_dt
--					and	ea2.key_value = convert(varchar(20), i.ivd_number)
--					and	ea2.mov_number = 0
--					and	ea2.lgh_number = 0
--					and	ea2.join_to_table_name = 'invoicedetailaudit')
CJB END -- 44833 */
	end


	--vmj2+
	--ChargeType..
	if update(cht_itemcode)
	begin
		--Update the rows that already exist..
/* CJB START -- 44833
--		update	expedite_audit
--		  set	update_note = ea.update_note + ', ChargeType ' + 
--								ltrim(rtrim(isnull(d.cht_itemcode, 'null'))) + ' -> ' + 
--								ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
--		  from	expedite_audit ea
--				,deleted d
--				,inserted i
--		  where	i.ivd_number = d.ivd_number
--			and	isnull(i.cht_itemcode, 'nU1L') <> isnull(d.cht_itemcode, 'nU1L')
--			and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'InvoiceDetail update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.ivd_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'invoicedetailaudit'
CJB END -- 44833 */

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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'ChargeType ' + ltrim(rtrim(isnull(d.cht_itemcode, 'null'))) + ' -> ' + 
					ltrim(rtrim(isnull(i.cht_itemcode, 'null')))
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	deleted d
				,inserted i
		  where	i.ivd_number = d.ivd_number
			--PTS 35741 JJF 2007-04-18 This was comparing the wrong column, so it never worked
			--and	isnull(i.ivd_type, 'nU1L') <> isnull(d.ivd_type, 'nU1L')
			and	isnull(i.cht_itemcode, 'nU1L') <> isnull(d.cht_itemcode, 'nU1L')
/*CJB START -- 44833
--			and	not exists
--				(select	'x'
--				  from	expedite_audit ea2
--				  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--					and	ea2.updated_by = @ls_user
--					and	ea2.activity = 'InvoiceDetail update'
--					and	ea2.updated_dt = @ldt_updated_dt
--					and	ea2.key_value = convert(varchar(20), i.ivd_number)
--					and	ea2.mov_number = 0
--					and	ea2.lgh_number = 0
--					and	ea2.join_to_table_name = 'invoicedetailaudit')
CJB END -- 44833 */
	end

	--PTS 35741 JJF 2007-04-18
	if update(ivd_rate)
	begin
		--Update the rows that already exist..
/*CJB START -- 44833
--		update	expedite_audit
--		  set	update_note = ea.update_note + ', Rate ' + 
--								+ isnull(convert(varchar(20), d.ivd_rate), 'null') + ' -> ' + 
--								isnull(convert(varchar(20), i.ivd_rate), 'null')
--		  from	expedite_audit ea
--				,deleted d
--				,inserted i
--		  where	i.ivd_number = d.ivd_number
--			and	isnull(i.ivd_rate, 0) <> isnull(d.ivd_rate, 0)
--			and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--			and	ea.updated_by = @ls_user
--			and	ea.activity = 'InvoiceDetail update'
--			and	ea.updated_dt = @ldt_updated_dt
--			and	ea.key_value = convert(varchar(20), i.ivd_number)
--			and	ea.mov_number = 0
--			and	ea.lgh_number = 0
--			and	ea.join_to_table_name = 'invoicedetailaudit'
CJB END -- 44833 */

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
				,'InvoiceDetail update'
				,@ldt_updated_dt
				,'Rate ' + isnull(convert(varchar(20), d.ivd_rate, 2), 'null') + ' -> ' + 
					isnull(convert(varchar(20), i.ivd_rate, 2), 'null')
				,convert(varchar(20), i.ivd_number)
				,0
				,0
				,'invoicedetailaudit'
		  from	deleted d
				,inserted i
		  where	i.ivd_number = d.ivd_number
			and	isnull(i.ivd_rate, 0) <> isnull(d.ivd_rate, 0)
/*CJB START -- 44833
--			and	not exists
--				(select	'x'
--				  from	expedite_audit ea2
--				  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
--					and	ea2.updated_by = @ls_user
--					and	ea2.activity = 'InvoiceDetail update'
--					and	ea2.updated_dt = @ldt_updated_dt
--					and	ea2.key_value = convert(varchar(20), i.ivd_number)
--					and	ea2.mov_number = 0
--					and	ea2.lgh_number = 0
--					and	ea2.join_to_table_name = 'invoicedetailaudit')
CJB END -- 44833 */
	end

end
--vmj2-


if @li_row_count > 1 
--if @@rowcount > 1 
    return	
--vmj1-


if exists (select * from generalinfo where gi_name = 'InvoiceDetailAudit' and gi_string1 = 'Y')
begin   
    
--  	if update(ivd_quantity) or update(ivd_rate) or update(ivd_charge)	
--		select @tar_number = tar_number from deleted
 
--	if @tar_number > 0 
--PTS 36955 JJF 20080625
--    	insert into invoicedetailaudit
--			(ivd_number ,	audit_status  ,	audit_user    ,	audit_date    ,	cht_itemcode ,ivd_quantity  ,
--			ivd_rate      ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber, audit_app )
--	      (select ivd_number, 'M', @tmwuser ,getdate(), cht_itemcode, ivd_quantity,
--		     ivd_rate ,	ivd_charge    ,	tar_number    ,	ivh_hdrnumber  , ord_hdrnumber,  LEFT(APP_NAME(),20)
--		 from inserted)  			
		INSERT INTO invoicedetailaudit(
			ivd_number
			,audit_status
			,audit_user
			,audit_date
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,audit_app
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating
			,ivd_car_key
			,ivd_leaseassetid
			,ivd_showas_cmpid
	)
	SELECT	ivd_number
			,'M'
			,@tmwuser
			,getdate()
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,LEFT(APP_NAME(),35)
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,null --ivd_MaskFromRating
			,null --ivd_car_key
			,null --ivd_leaseassetid
			,null --ivd_showas_cmpid
	  FROM inserted

end

GO
ALTER TABLE [dbo].[invoicedetail] ADD CONSTRAINT [pk_ivd_number] PRIMARY KEY CLUSTERED ([ivd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Invoicedetail_timestamp] ON [dbo].[invoicedetail] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivd_allocated_ivd_number] ON [dbo].[invoicedetail] ([ivd_allocated_ivd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_invoicedetail_refnum_type_ivhhdr] ON [dbo].[invoicedetail] ([ivd_refnum], [ivd_reftype], [ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_invoicedetail_ivd_refnum] ON [dbo].[invoicedetail] ([ivd_reftype], [ivd_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivd_invoice] ON [dbo].[invoicedetail] ([ivh_hdrnumber]) INCLUDE ([cht_itemcode], [tar_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ivhdtl_formanifest] ON [dbo].[invoicedetail] ([ivh_hdrnumber], [cht_itemcode], [ivd_charge], [ivd_distance]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_invoicedetail_9_519672899__K1_K17_K5_8_30] ON [dbo].[invoicedetail] ([ivh_hdrnumber], [ord_hdrnumber], [cht_itemcode]) INCLUDE ([ivd_charge], [ivd_distance]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_invoicedetail_last_updatedate] ON [dbo].[invoicedetail] ([last_updatedate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ord_number] ON [dbo].[invoicedetail] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ivd_ship] ON [dbo].[invoicedetail] ([stp_number]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_519672899_1_5] ON [dbo].[invoicedetail] ([ivh_hdrnumber], [cht_itemcode])
GO
CREATE STATISTICS [_dta_stat_519672899_17_5_1] ON [dbo].[invoicedetail] ([ord_hdrnumber], [cht_itemcode], [ivh_hdrnumber])
GO
CREATE STATISTICS [_dta_stat_519672899_17_1] ON [dbo].[invoicedetail] ([ord_hdrnumber], [ivh_hdrnumber])
GO
GRANT DELETE ON  [dbo].[invoicedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[invoicedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoicedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[invoicedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoicedetail] TO [public]
GO
