CREATE TABLE [dbo].[paytype]
(
[pyt_number] [int] NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_quantity] [float] NULL,
[pyt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_rate] [money] NULL,
[pyt_pretax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_minus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_editflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_pr_glnum] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_ap_glnum] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[pyt_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_agedays] [int] NULL,
[pyt_fee1] [money] NULL,
[pyt_fee2] [money] NULL,
[pyt_accept_negatives] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_fservprocess] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_expchk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_maxrate] [float] NULL,
[pyt_maxenf] [int] NULL,
[pyt_minrate] [float] NULL,
[pyt_minenf] [int] NULL,
[pyt_zeroenf] [int] NULL,
[pyt_incexcoth] [int] NULL,
[pyt_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_paying_to] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_offset_percent] [float] NULL,
[pyt_offset_for] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_editindispatch] [int] NOT NULL CONSTRAINT [DF__paytype__pyt_edi__0C26B6F1] DEFAULT (0),
[pyt_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_classflag] [int] NOT NULL CONSTRAINT [DF__paytype__pyt_cla__5D96B091] DEFAULT (0),
[pyt_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_tax] [smallint] NULL CONSTRAINT [paytype_gp_tax_default] DEFAULT (0),
[pyt_authcode_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [AddAuthCodeReqDflt] DEFAULT ('N'),
[pyt_otflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_eiflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_pr_glnum_clearing] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_ap_glnum_clearing] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_exclude_guaranteed_pay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_pyt_exclude_guaranteed_pay] DEFAULT ('N'),
[pyt_superv_delete_only] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [pyt_superv_delete_only_dflt] DEFAULT ('N'),
[pyt_tppcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_category] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_rtd_exclude] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_payto_splittype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_offset_for_splittype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_taxable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_offset_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_exclude_3pp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_holiday_vacation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_oblig] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_GarnishmentClassification] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_maintenance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[pyt_PayTypeBasisUnitRule_Id] [int] NULL,
[pyt_AdjustWithNegativePay] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_sth_abbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_sth_priority] [int] NULL,
[pyt_requireaudit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_category2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_category3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_category4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[utdt_paytype] on [dbo].[paytype] for  update,delete as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @ls_status char(1),
	@li_count int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @li_count = count(*) from inserted
if @li_count = 1  
	select @ls_status = 'M' --modified
else
	select @ls_status = 'D'

if update(pyt_unit) or update(pyt_rateunit)
   update tariffheaderstl 
   set 	  tariffheaderstl.cht_unit = inserted.pyt_unit ,
	  tariffheaderstl.cht_rateunit = inserted.pyt_rateunit 
   from    inserted
   where   inserted.pyt_itemcode = tariffheaderstl.cht_itemcode

insert into paytypeaudit
	(audit_dttm       ,
	audit_user	 ,
	audit_status     ,
	pyt_number ,
	pyt_itemcode ,
	pyt_description ,
	pyt_basis ,
	pyt_basisunit ,
	pyt_quantity ,
	pyt_rateunit ,
	pyt_unit ,
	pyt_rate ,
	pyt_pretax ,
	pyt_minus ,
	pyt_editflag ,
	pyt_pr_glnum ,
	pyt_ap_glnum ,
	pyt_status ,
	pyt_agedays ,
	pyt_fee1 ,
	pyt_fee2 ,
	pyt_accept_negatives ,
	pyt_fservprocess ,
	pyt_expchk ,
	pyt_systemcode,
	pyt_maxrate ,
	pyt_maxenf ,
	pyt_minrate,
	pyt_minenf ,
	pyt_zeroenf,
	pyt_incexcoth ,
	pyt_retired ,
	pyt_paying_to,
	pyt_offset_percent,
	pyt_offset_for,
	pyt_editindispatch ) 
	(select
	getdate(),
	@tmwuser,
	@ls_status,
	pyt_number ,
	pyt_itemcode ,
	pyt_description ,
	pyt_basis ,
	pyt_basisunit ,
	pyt_quantity ,
	pyt_rateunit ,
	pyt_unit ,
	pyt_rate ,
	pyt_pretax ,
	pyt_minus ,
	pyt_editflag ,
	pyt_pr_glnum ,
	pyt_ap_glnum ,
	pyt_status ,
	pyt_agedays ,
	pyt_fee1 ,
	pyt_fee2 ,
	pyt_accept_negatives ,
	pyt_fservprocess ,
	pyt_expchk ,
	pyt_systemcode,
	pyt_maxrate ,
	pyt_maxenf ,
	pyt_minrate,
	pyt_minenf ,
	pyt_zeroenf,
	pyt_incexcoth ,
	pyt_retired ,
	pyt_paying_to,
	pyt_offset_percent,
	pyt_offset_for,
	pyt_editindispatch 
	from deleted
	)




GO
ALTER TABLE [dbo].[paytype] ADD CONSTRAINT [PK_paytype] PRIMARY KEY CLUSTERED ([pyt_itemcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_paytype_timestamp] ON [dbo].[paytype] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_number] ON [dbo].[paytype] ([pyt_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paytype] ADD CONSTRAINT [fk_paytype_pyt_PayTypeBasisUnitRule_Id] FOREIGN KEY ([pyt_PayTypeBasisUnitRule_Id]) REFERENCES [dbo].[PayTypeBasisUnitRule] ([Id])
GO
GRANT DELETE ON  [dbo].[paytype] TO [public]
GO
GRANT INSERT ON  [dbo].[paytype] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paytype] TO [public]
GO
GRANT SELECT ON  [dbo].[paytype] TO [public]
GO
GRANT UPDATE ON  [dbo].[paytype] TO [public]
GO
