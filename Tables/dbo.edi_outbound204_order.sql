CREATE TABLE [dbo].[edi_outbound204_order]
(
[ob_204id] [int] NOT NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ord_refnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_bookdate] [datetime] NULL,
[ord_startdate] [datetime] NULL,
[ord_completiondate] [datetime] NULL,
[ob_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_address1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_address2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_address1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_address2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_address1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_address2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_edi_scac] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_dt] [datetime] NULL,
[edi_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_mileage] [int] NULL,
[car_charge] [money] NULL,
[broker_linehaul_charge] [money] NULL,
[broker_fuel_charge] [money] NULL,
[broker_accessorial_charge] [money] NULL,
[broker_total_charge] [money] NULL,
[ord_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_location_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_location_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_location_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sh_county] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cn_county] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ob_county] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_extrainfo11] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_conditions] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[edi_message_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_id] [int] NULL,
[ord_totalcount] [decimal] (10, 2) NULL,
[ord_totalweight] [float] NULL,
[ord_mintemp] [smallint] NULL,
[ord_maxtemp] [smallint] NULL,
[ord_tempunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalweightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalcountunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rail_load_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_international] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[it_edi_outbound204_order_dummy990forRalCarrier]  
ON [dbo].[edi_outbound204_order]  
FOR INSERT
AS  

DECLARE @ord_hdrnumber int,
		@lgh_number int,
		@brkbasisleg bit,
		@OrderOrLegNumber varchar(60)

set @ord_hdrnumber = 0
set @lgh_number = 0
		
if exists (SELECT * FROM inserted i inner join Carrier car on i.car_id = car.car_id and car.car_type1='RAL')
	and (exists (select * from generalinfo where gi_name ='Outbound204RailBilling' and gi_string2='TDA'))
	BEGIN
		
			if exists (select * from generalinfo where gi_name ='BrokerageEDIBasis' and gi_string1='Leg')
				begin
					set @brkbasisleg=1
					Select	@lgh_number=i.lgh_number
					from inserted i 
				end
			else
				begin
					set @brkbasisleg=0
					Select @ord_hdrnumber=oh.ord_hdrnumber,
						@lgh_number=i.lgh_number
					from inserted i inner join orderheader oh 
					on oh.ord_hdrnumber= i.ord_hdrnumber
				end
					
			if (@ord_hdrnumber>0 or @lgh_number > 0)
				Begin
				
						INSERT INTO [dbo].[edi_inbound990_records]
								   ([trn_id]----must match edi_outbound204_order.ob204_id
								   ,[SCAC]      --carrier SCAC
								   ,[ord_number]      --Based on GI Setting BrokerageEDIBasis. If Order then ord_hdrnumber, if Leg then lgh_number
								   ,[ord_hdrnumber]
								   ,[ISAGSID]
								   ,[edi_code]  --N=New,U=update
								   ,[Action]    --A,D
								   ,[created_dt]
								   ,[car_trip_id]     --Carriers Reference/PRO
								   ,[processed_flag] --Y
								   ,[rejection_error_reason]
								   ,[lgh_number]
								   ,[warning_reason])
						select
							i.ob_204id
							,car.car_SCAC
							,case when @brkbasisleg=1 then @lgh_number else @ord_hdrnumber end
							,@ord_hdrnumber
							,i.ord_revtype1
							,case when i.edi_code='00' then 'N' when i.edi_code='01' then 'C' when i.edi_code='04' then 'U' else '' end
							,'A'
							,getdate()
							,null
							,'Y'
							,null
							,@lgh_number
							,null
							
							FROM inserted i inner join Carrier car on i.car_id = car.car_id and car.car_type1='RAL'
							
						UPDATE LegHeader SET lgh_outstatus = 'DSP' WHERE lgh_number =  @lgh_number
				End
	END
GO
ALTER TABLE [dbo].[edi_outbound204_order] ADD CONSTRAINT [PK_ob_204id] PRIMARY KEY CLUSTERED ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_createdate_ordnum_CarId] ON [dbo].[edi_outbound204_order] ([created_dt], [ord_number], [car_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_eoo_lghnum] ON [dbo].[edi_outbound204_order] ([lgh_number], [edi_message_type], [edi_code], [created_dt]) INCLUDE ([car_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_eoo_ob_204id] ON [dbo].[edi_outbound204_order] ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eoo_ord_hdrnumber] ON [dbo].[edi_outbound204_order] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ordnum_createdate_CarId] ON [dbo].[edi_outbound204_order] ([ord_number], [created_dt], [car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_order] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_order] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound204_order] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_order] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_order] TO [public]
GO
