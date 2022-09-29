CREATE TABLE [dbo].[freightdetail]
(
[fgt_number] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_weight] [float] NULL,
[fgt_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[fgt_count] [decimal] (10, 2) NULL,
[fgt_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume] [float] NULL,
[fgt_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_lowtemp] [smallint] NULL,
[fgt_hitemp] [smallint] NULL,
[fgt_sequence] [smallint] NULL,
[fgt_length] [float] NULL,
[fgt_lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_height] [float] NULL,
[fgt_heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_width] [float] NULL,
[fgt_widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[fgt_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_quantity] [float] NULL,
[fgt_rate] [money] NULL,
[fgt_charge] [money] NULL,
[fgt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skip_trigger] [tinyint] NULL,
[tare_weight] [float] NULL,
[tare_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_pallets_in] [float] NULL,
[fgt_pallets_out] [float] NULL,
[fgt_pallets_on_trailer] [float] NULL,
[fgt_carryins1] [float] NULL,
[fgt_carryins2] [float] NULL,
[fgt_stackable] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_ratingquantity] [float] NULL,
[fgt_ratingunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_quantity_type] [smallint] NULL,
[fgt_ordered_count] [real] NULL,
[fgt_ordered_weight] [float] NULL,
[tar_number] [int] NULL,
[tar_tariffnumber] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_charge_type] [smallint] NULL,
[fgt_rate_type] [smallint] NULL,
[fgt_ordered_volume] [decimal] (18, 0) NULL,
[fgt_ordered_loadingmeters] [decimal] (18, 0) NULL,
[fgt_pallet_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_loadingmeters] [decimal] (12, 4) NULL,
[fgt_loadingmetersunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_additionl_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_specific_flashpoint] [float] NULL,
[fgt_specific_flashpoint_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpr_density] [decimal] (9, 4) NULL,
[scm_subcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_terms] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_consignee] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_shipper] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_leg_origin] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_leg_dest] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_count2] [decimal] (10, 2) NULL,
[fgt_count2unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_bolid] [int] NULL,
[fgt_bol_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_osdreason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_osdquantity] [int] NULL,
[fgt_osdunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_osdcomment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_packageunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_osdstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_osdopendate] [datetime] NULL,
[fgt_osdclosedate] [datetime] NULL,
[fgt_osdorigclaimamount] [money] NULL,
[fgt_osdamtpaid] [money] NULL,
[fgt_osdamtreceived] [money] NULL,
[fgt_dispatched_quantity] [float] NULL,
[fgt_dispatched_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_actual_quantity] [float] NULL,
[fgt_actual_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_billable_quantity] [float] NULL,
[fgt_billable_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume2] [float] NULL,
[fgt_volumeunit2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_tmstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume2unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_pincode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_accountof] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_parentcmd_fgt_number] [int] NULL,
[fgt_display_sequence] [int] NULL,
[fgt_bol_image] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_bol_image_date] [datetime] NULL,
[tank_loc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_deliverytank1] [float] NULL,
[fgt_deliverytank2] [float] NULL,
[fgt_deliverytank3] [float] NULL,
[fgt_deliverytank4] [float] NULL,
[fgt_deliverytank5] [float] NULL,
[fgt_deliverytank6] [float] NULL,
[fgt_deliverytank7] [float] NULL,
[fgt_deliverytank8] [float] NULL,
[fgt_deliverytank9] [float] NULL,
[fgt_deliverytank10] [float] NULL,
[fgt_parentcmd_number] [int] NULL,
[fgt_asset] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_tempunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_hazmat_class_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_hazmat_shipping_name_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_hdrnumber] [int] NULL,
[fgt_deficit_row] [int] NULL,
[fgt_rate_per] [decimal] (10, 2) NULL,
[fgt_sub_charge] [decimal] (10, 2) NULL,
[fgt_discount_rate] [decimal] (10, 2) NULL,
[fgt_discount_per] [decimal] (10, 2) NULL,
[fgt_discount] [decimal] (10, 2) NULL,
[fgt_gross_manual] [decimal] (10, 2) NULL,
[fgt_disc_tar_number] [int] NULL,
[fgt_discount_qty] [decimal] (10, 2) NULL,
[cmd_rateclass] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_un_number] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_packing_group] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manual_description] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__freightde__manua__133172C9] DEFAULT ('N'),
[fgt_un_id] [int] NULL,
[fgt_number_copied_fromorder] [int] NULL,
[fgt_size] [decimal] (5, 2) NULL,
[fgt_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__freightde__INS_T__50B0AD11] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                              

CREATE TRIGGER [dbo].[dt_fgt] ON [dbo].[freightdetail] FOR DELETE AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*

  6/4/10 DPETE PTS51844 add revenue tracking option
  1/18/11 DPETE 55393 add miels to revenu tracking (for invoice only)
*/
/*EXECUTE timerins "dt_fgt", "START" */

declare @enhanced_plt_tracking char(1)
declare @v_ordhdrnumber int ,@v_ordstatus varchar(6) , @v_rateby char(1), @v_charge money, @V_cht varchar(6), @v_stoptype varchar(6) , @tmwuser varchar(255)  --51844
declare @v_ordcurrency varchar(6), @v_next int, @v_appid varchar(30),@v_recordzerochanges char(1), @v_now datetime

DELETE referencenumber
FROM referencenumber, deleted
WHERE referencenumber.ref_tablekey = deleted.fgt_number AND
	referencenumber.ref_table = 'freightdetail'

--JLB PTS 37866
select @enhanced_plt_tracking = left(ltrim(rtrim(gi_string1)),1)
  from generalinfo
 where gi_name = 'EnhPltTrkng'

if @enhanced_plt_tracking = 'Y'
begin
	DELETE pallet_tracking 
	  FROM deleted 
	 WHERE pallet_tracking.pt_fgt_number = deleted.fgt_number
end
--end 37866
/* revenue tracking will backout the charge on this freight record if (1) revenue trcaqckign is on for type 001
   (2) there is a charge on this freight record (3) There is an order number associated with the stop
    (4) the order status is Active (Available or greater or ICO) (5) the invoice has nto been created for the order
   (5) trigger is deleting a single record
*/
exec gettmwuser @tmwuser output
If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100') 
    and (select count(*) from (select top 2 fgt_number from deleted) a ) = 1
  BEGIN
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')

    select @v_next = min(fgt_number) from deleted 
 --   While @v_next is not null
 --     BEGIN  -- next fgt_NUMBER
        if exists (select 1 from freightdetail f join stops s on f.stp_number = s.stp_number
           where f.fgt_number = @v_next and s.stp_type = 'DRP' and (f.fgt_charge <> 0 or @v_recordzerochanges = 'Y'))
         BEGIN  -- deleted record is delivered commodity
          select @v_stoptype = 'DRP'  -- against the time we allow billing by pickup freight

          select @v_ordhdrnumber = stops.ord_hdrnumber,@v_cht = deleted.cht_itemcode, @v_charge = deleted.fgt_charge 
          from deleted join stops on deleted.stp_number = stops.stp_number
          where deleted.fgt_number = @v_next

          select @v_ordhdrnumber = isnull(@v_ordhdrnumber,0)
          If  not exists (select 1 from invoiceheader where ord_hdrnumber = @v_ordhdrnumber)
            BEGIN 
              -- Order Entry saves the order before the freight, not sure what Dispatch does.
              select @v_ordstatus = ord_status,@v_rateby = ord_rateby,@v_ordcurrency = ord_currency  from orderheader where ord_hdrnumber = @v_ordhdrnumber
              
              If @v_rateby = 'D' and (dbo.fn_StatusIsActive (@v_ordstatus)) = 'Y'  -- must be rating by detail, order is active, no invoice exists
               and not exists (select 1 from invoiceheader where ord_hdrnumber = @v_ordhdrnumber) 
                -- backout old
                Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount
                  ,tar_number,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
                  ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)

                select  @v_ordhdrnumber
                ,0
                ,'PRERATE'
                ,@v_now
                ,cht_itemcode
                ,(fgt_charge * -1) 
                ,tar_number
                ,@v_ordcurrency
                ,'Y'
                ,'???'
                ,'???'
                ,@tmwuser
               ,'dt_fgt'
               ,@v_appid
               ,fgt_quantity
               ,0
               ,@v_rateby
               ,0.0
               ,0.0
                from deleted
           
             END  -- deleted record is delivered commodity
           
         END -- next fgt_NUMBER
        --select @v_next = min(fgt_number) from deleted where fgt_number > @v_next
     -- END

  END

/* EXECUTE timerins "dt_fgt", "END"*/
return




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iut_freightdetail_net] ON [dbo].[freightdetail] FOR INSERT, UPDATE AS BEGIN
	
	--SET NOCOUNT ON 
	IF not exists (select 1 from inserted) and not exists (select 1 from deleted) return  
	
	
	IF NOT EXISTS	(	SELECT	i.skip_trigger
						FROM	inserted i
								LEFT OUTER JOIN deleted d on  i.fgt_number = d.fgt_number
						WHERE	i.skip_trigger = 1
								OR d.skip_trigger = 1
					) BEGIN 
		

		DECLARE @mov_number_parent_job int
		DECLARE	@ord_hdrnumber_parent_job int
		DECLARE	@ord_status_parent_job varchar(6)
		DECLARE @non_zero_quantity_count int

		SELECT	@ord_hdrnumber_parent_job = ohparent.ord_hdrnumber,
				@ord_status_parent_job = ohparent.ord_status,
				@mov_number_parent_job = ohparent.mov_number
		FROM	inserted
				INNER JOIN stops stpchild on inserted.stp_number = stpchild.stp_number
				INNER JOIN orderheader ohchild on stpchild.ord_hdrnumber = ohchild.ord_hdrnumber
				INNER JOIN orderheader ohparent on ohchild.ord_fromorder = ohparent.ord_number
		WHERE	ohparent.ord_job_ordered > 0



		IF @ord_hdrnumber_parent_job > 0 BEGIN
			UPDATE	freightdetail
			SET		fgt_count = CASE WHEN ISNULL(freightdetail.fgt_ordered_count, 0) - Total_fgt_count < 0 THEN 0
									ELSE ISNULL(freightdetail.fgt_ordered_count, 0) - Total_fgt_count
								END,
					fgt_weight = CASE WHEN ISNULL(freightdetail.fgt_ordered_weight, 0) - Total_fgt_weight < 0 THEN 0
									ELSE ISNULL(freightdetail.fgt_ordered_weight, 0) - Total_fgt_weight 
								END,
					fgt_volume = CASE WHEN ISNULL(freightdetail.fgt_ordered_volume, 0) - Total_fgt_volume < 0 THEN 0
									ELSE ISNULL(freightdetail.fgt_ordered_volume, 0) - Total_fgt_volume
								END
			FROM	freightdetail 
					INNER JOIN (
									SELECT	fgtchild.fgt_number_copied_fromorder,
											SUM(ISNULL(fgtchild.fgt_count, 0)) AS Total_fgt_count,
											SUM(ISNULL(fgtchild.fgt_weight, 0)) AS Total_fgt_weight,
											SUM(ISNULL(fgtchild.fgt_volume, 0)) AS Total_fgt_volume
									FROM	orderheader ohparent
											INNER JOIN orderheader ohchild on ohchild.ord_fromorder = ohparent.ord_number
											INNER JOIN stops stpchild on stpchild.ord_hdrnumber = ohchild.ord_hdrnumber
											INNER JOIN freightdetail fgtchild on fgtchild.stp_number = stpchild.stp_number
									WHERE	ohparent.ord_hdrnumber = @ord_hdrnumber_parent_job
											AND fgtchild.fgt_number_copied_fromorder IS NOT NULL
											AND ohchild.ord_status NOT IN ('CAN')
									GROUP BY fgtchild.fgt_number_copied_fromorder
								) fgtchildtotals on freightdetail.fgt_number = fgtchildtotals.fgt_number_copied_fromorder
			WHERE	ISNULL(freightdetail.fgt_count, 0) <>		CASE WHEN ISNULL(freightdetail.fgt_ordered_count, 0) - Total_fgt_count < 0 THEN 0
																	ELSE ISNULL(freightdetail.fgt_ordered_count, 0) - Total_fgt_count
																END
					OR ISNULL(freightdetail.fgt_weight, 0) <>	CASE WHEN ISNULL(freightdetail.fgt_ordered_weight, 0) - Total_fgt_weight < 0 THEN 0
																	ELSE ISNULL(freightdetail.fgt_ordered_weight, 0) - Total_fgt_weight 
																END
					OR ISNULL(freightdetail.fgt_volume, 0) <>	CASE WHEN ISNULL(freightdetail.fgt_ordered_volume, 0) - Total_fgt_volume < 0 THEN 0
																	ELSE ISNULL(freightdetail.fgt_ordered_volume, 0) - Total_fgt_volume
																END
															
			IF @@ROWCOUNT > 0 BEGIN
				--EXEC update_move @mov_number_parent_job
				
				--Find out if there's any quantities remaining on parent
				SELECT	@non_zero_quantity_count = count(*)
				FROM	stops stpparent
						INNER JOIN freightdetail fgtparent on stpparent.stp_number = fgtparent.stp_number
				WHERE	stpparent.ord_hdrnumber = @ord_hdrnumber_parent_job
						AND (fgtparent.fgt_count > 0 OR fgtparent.fgt_weight > 0 OR fgtparent.fgt_volume > 0)
					
		
				IF @non_zero_quantity_count > 0 AND @ord_status_parent_job <> 'JOB' BEGIN
					UPDATE	orderheader
					SET		ord_status = 'JOB'
					WHERE	ord_hdrnumber = @ord_hdrnumber_parent_job
					
					EXEC update_move @mov_number_parent_job
				END
				ELSE IF @non_zero_quantity_count = 0 AND @ord_status_parent_job <> 'CAN' BEGIN
					UPDATE	orderheader
					SET		ord_status = 'CAN'
					WHERE	ord_hdrnumber = @ord_hdrnumber_parent_job
					
					EXEC update_move @mov_number_parent_job
				END
			END
		END
	END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
MODIFICATIONS

DPETE PTS11054 4/9/2 add pallet counts to the stops table for a customer SR
DPETE PTS 33374 check for empty firing
DPETE PTS 51844 support Revenue tracking
DPETE PTS51844 6/28/10 rev tracking changes for dot net pre rating
DPETE  PTS51844 7/9/10 add checks on slect count(*) per Mindy suggestion
DPETE PTS53926 9/9/10 limit the revenue tracker funtion  to single rtrecord updates
DPETE PTS55393 add miles to revenue_tracker table (for invoicing only)
*/


CREATE TRIGGER [dbo].[ut_fgt] ON [dbo].[freightdetail] FOR INSERT, UPDATE  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/* EXECUTE timerins "ut_fgt", "START" */
BEGIN

/*SKIP TRIGGER CODE FOR NEW DISPATCH ONLY IS EXECUTED IF SKIP_TRIGGER COLUMN
	IS SET TO 1*/
declare @skip_trigger int, @minseq int
declare @v_ordhdrnumber int ,@v_ordstatus varchar(6) , @v_rateby char(1), @v_charge money, @V_cht varchar(6), @v_stoptype varchar(6)   --51844
declare @v_ordcurrency varchar(6), @v_now datetime, @tmwuser varchar(255)   --51844
declare @v_next int, @v_appid varchar(30),@v_recordzerochanges char(1)  ,@v_ivhhdrnumber int -- 51844
--jg prevent empty firing  
if not exists (select 1 from inserted) and not exists (select 1 from deleted) return  


/* Track revenue feature . If on and if charges changed add and or backout for an existing (not new)
  order, fgt charges for a new order are created from it_orderheader call to createrevenue proc*/

exec gettmwuser @tmwuser output
If  exists (select 1 from generalinfo where gi_name = 'TrackRevenue' and gi_string1 = '100')
    and (select count(*) from (select top 2 fgt_number from inserted) a ) = 1 
  BEGIN  -- We are tracking Revenue
    select @v_appid = rtrim(left(app_name(),30))
    select @v_now = getdate()
    /* option to record adds and backouts of zero dollars - used for debug */
    Select @v_recordzerochanges = Left(gi_string2,1) from generalinfo where gi_name = 'TrackRevenue'
    Select @v_recordzerochanges = isnull(@v_recordzerochanges,'N')
    
    select @v_next = min(fgt_number) from inserted
    while @v_next is not null  -- note above (later 53926d) addition of count check insures we loop only one time
      BEGIN  -- loop changed records

       select @v_ordhdrnumber = stops.ord_hdrnumber,@v_cht = inserted.cht_itemcode, @v_charge = inserted.fgt_charge 
        ,@v_stoptype = stops.stp_type
       from inserted join stops on inserted.stp_number = stops.stp_number
       where inserted.fgt_number = @v_next

       select @v_ordhdrnumber = isnull(@v_ordhdrnumber,0)

       if @v_ordhdrnumber > 0 and @v_stoptype = 'DRP'
         BEGIN  -- we have an order on a delivery stop
           select @v_ivhhdrnumber  =  min(ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @v_ordhdrnumber
           select @v_ivhhdrnumber = isnull(@v_ivhhdrnumber,0)
           select @v_ordstatus = ord_status,@v_rateby = ord_rateby,@v_ordcurrency = ord_currency  
           from orderheader where ord_hdrnumber = @v_ordhdrnumber
           if @v_rateby = 'D' and (dbo.fn_StatusIsActive (@v_ordstatus)) = 'Y' and @v_ivhhdrnumber = 0
             BEGIN  -- we have a rate by detail order that is active and not yet invoiced 
               /* if record inserted and there is a chaarge, add the reveue */
              If (select count(*) from (select top 2 fgt_number from deleted) a)  = 0 
                BEGIN  -- We are inserting only need to add revenue
                 Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount
                 ,tar_number,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
                 ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)

                 select @v_ordhdrnumber
                 ,0
                 ,'PRERATE'
                 ,@v_now
                 ,cht_itemcode
                 ,fgt_charge 
                 ,tar_number
                 ,@v_ordcurrency
                 ,'N'  -- is backout
                 ,'???'
                 ,'???'
                 ,@tmwuser
                 ,'ut_fgt'
                 ,@v_appid
                 ,fgt_quantity
                 ,0
                 ,@v_rateby
                 ,0.0
                 ,0.0
                 from inserted 
                 where fgt_number = @v_next and (fgt_charge <> 0 or @v_recordzerochanges = 'Y')
               END  -- We are inserting only need to add revenue
             ELse 
              if (select count(*) from deleted where fgt_number = @v_next) > 0
               BEGIN -- we have an update, check to see if update is to charge or charge type
                if UPDATE(fgt_charge) or UPDATE(cht_itemcode)
                  BEGIN  -- of add inserted and backout deleted
                    -- backout old
                    Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
                    ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
                    ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)

                    select @v_ordhdrnumber
                    ,0
                    ,'PRERATE'
                    ,@v_now
                    ,cht_itemcode
                    ,(fgt_charge * -1)
                    ,tar_number 
                    ,@v_ordcurrency
                    ,'Y'  -- is backout
					          ,'???'
                    ,'???'
                   ,@tmwuser
                   ,'ut_fgt'
                   ,@v_appid
                   ,fgt_quantity
                   ,0
                    ,@v_rateby
                    ,0.0
                    ,0.0
                    from deleted where fgt_number = @v_next and (fgt_charge <> 0 or @v_recordzerochanges = 'Y')
           
                    -- add new
                    Insert into revenue_tracker(ord_hdrnumber,ivh_hdrnumber,ivh_definition,rvt_date,cht_itemcode,rvt_amount,tar_number
                    ,cur_code,rvt_isbackout,ord_status,ivh_invoicestatus,rvt_updatedby,rvt_updatesource
                    ,rvt_appname,rvt_quantity,ivd_number,rvt_rateby, rvt_billmiles, rvt_billemptymiles)
                    select @v_ordhdrnumber
                    ,0
                    ,'PRERATE'
                    ,@v_now
                    ,cht_itemcode
                    ,fgt_charge
                    ,tar_number 
                    ,@v_ordcurrency
                    ,'N'
                    ,'???'
                    ,'???'
                    ,@tmwuser
                    ,'ut_fgt'
                    ,@v_appid
                    ,fgt_quantity
                    ,0
                    ,@v_rateby
                    ,0.0
                    ,0.0
                    from inserted 
                    where fgt_number = @v_next and (fgt_charge <> 0 or @v_recordzerochanges = 'Y')
           
                  END  -- of add inserted and backout deleted
              END  -- we have an update
         END  -- we have a rate by detail order that is active and not yet invoiced 
      END  -- we have an order on a delivery stop 
      select @v_next = min(fgt_number) from inserted where fgt_number > @v_next
    END  -- loop changed records
  END  -- We are tracking Revenue  
/* end of revenue tracking */ 

/* trip folder does not have stops pallet fields must update with trigger*/
select @minseq = min(fgt_sequence) from inserted
If @minseq = 1
Begin
	/* 02/04/2013 MDH PTS 66729: Added other columns besides just pallets in/out because 
	   stops trigger will come back and stomp on our values for these columns. */
	If (Select count(*) 
		From stops, inserted 
		Where inserted.fgt_sequence = @minseq and
		stops.stp_number = inserted.stp_number and
		Isnull(stops.stp_pallets_in,0) = IsNull(inserted.fgt_pallets_in,0) and 
		Isnull(stops.stp_pallets_out,0) = IsNUll(inserted.fgt_pallets_out,0)) = 0
		update stops
		Set stp_pallets_in = Convert(int,fgt_pallets_in),
		    stp_pallets_out=convert(int,fgt_pallets_out), 
			cmd_code = inserted.cmd_code,
			stp_description = inserted.fgt_description,
			stp_weight = inserted.fgt_weight,
			stp_weightunit = inserted.fgt_weightunit,
			stp_count = inserted.fgt_count,
			stp_countunit = inserted.fgt_countunit,
			stp_volume = inserted.fgt_volume,
			stp_volumeunit = inserted.fgt_volumeunit
		From inserted
		Where inserted.fgt_sequence = @minseq and stops.stp_number = inserted.stp_number
End
select @skip_trigger = count(*)
from inserted where skip_trigger = 1
if @skip_trigger > 0 
begin
	UPDATE freightdetail  
   	SET skip_trigger = 0
     	FROM inserted
    	WHERE (inserted.fgt_number = freightdetail.fgt_number)
   	
	return
end


END
RETURN






GO
CREATE NONCLUSTERED INDEX [sk_cmd_code] ON [dbo].[freightdetail] ([cmd_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_freightdetail_fgt_bol_status] ON [dbo].[freightdetail] ([fgt_bol_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_freightdetail_fgt_bolid] ON [dbo].[freightdetail] ([fgt_bolid]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_number] ON [dbo].[freightdetail] ([fgt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_fgt_fgt_parentcmd_fgt_number] ON [dbo].[freightdetail] ([fgt_parentcmd_fgt_number]) INCLUDE ([fgt_number], [fgt_volume], [fgt_volume2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_freightdetail_fgt_refnum] ON [dbo].[freightdetail] ([fgt_refnum], [fgt_reftype], [stp_number]) INCLUDE ([fgt_description], [fgt_bolid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [freightdetail_INS_TIMESTAMP] ON [dbo].[freightdetail] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [freightdetail_order_hdrnumber] ON [dbo].[freightdetail] ([order_hdrnumber], [fgt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shipment_include] ON [dbo].[freightdetail] ([stp_number]) INCLUDE ([fgt_length], [fgt_width], [fgt_height]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fgt_u_stp] ON [dbo].[freightdetail] ([stp_number], [fgt_width]) INCLUDE ([fgt_height], [fgt_length], [cmd_code]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_freightdetail_timestamp] ON [dbo].[freightdetail] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[freightdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[freightdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[freightdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[freightdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[freightdetail] TO [public]
GO
