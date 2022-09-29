CREATE TABLE [dbo].[chargetype]
(
[cht_number] [int] NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_primary] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisper] [float] NULL,
[cht_quantity] [float] NULL,
[cht_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rate] [money] NULL,
[cht_editflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_glnum] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[cht_sign] [smallint] NULL,
[cht_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_edicode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_currunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rollintolh] [int] NULL,
[cht_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_maxrate] [float] NULL,
[cht_maxenf] [int] NULL,
[cht_minrate] [float] NULL,
[cht_minenf] [int] NULL,
[cht_zeroenf] [int] NULL,
[cht_crchg] [smallint] NULL CONSTRAINT [DF__chargetyp__cht_c__766C7FFC] DEFAULT (0),
[cht_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rateprotect] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_tax] [smallint] NULL CONSTRAINT [gp_tax_default] DEFAULT (0),
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[cht_lh_min] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_stl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_rpt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_lh_prn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_typeofcharge] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_paperwork_requiretype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_method] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_criteria] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_groupby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_allocation_group_nbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_setrevfromchargetypelist] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_translation] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_category1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_category2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_category3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_category4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_edit_completion_rate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_glkey] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[cht_ChargeTypeBasisUnitRule_Id] [int] NULL,
[cht_car_split] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_applies_to] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_ICpercentage] [money] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__chargetyp__INS_T__3AC16BF2] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_chargetype] ON [dbo].[chargetype] 
FOR  DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
BEGIN
	--PTS 22338 referential integretity for chargetype paperwork

	DELETE chargetypepaperwork
	FROM deleted
	WHERE     (chargetypepaperwork.cht_number = deleted.cht_number )

	DELETE chargetypepaperworkcmp
	FROM deleted
	WHERE     (chargetypepaperworkcmp.cht_number = deleted.cht_number )

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_chargetype_changelog]
ON [dbo].[chargetype]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update chargetype
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.cht_number = chargetype.cht_number
		and (isNull(chargetype.last_updateby,'') <> @tmwuser
		OR isNull(chargetype.last_updatedate,'19500101') <> getdate())
		
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[utdt_chargetype] on [dbo].[chargetype] for  update,delete as
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


if update(cht_unit) or update(cht_rateunit)
   update tariffheader 
   set 	  tariffheader.cht_unit = inserted.cht_unit ,
	  tariffheader.cht_rateunit = inserted.cht_rateunit 
   from    inserted
   where   inserted.cht_itemcode = tariffheader.cht_itemcode


insert into chargetypeaudit
	(audit_dttm,
	audit_user,
	audit_status,
	cht_number,
	cht_itemcode,
	cht_description,
	cht_primary,
	cht_basis,
	cht_basisunit,
	cht_basisper,
	cht_quantity,
	cht_rateunit,
	cht_unit,
	cht_rate,
	cht_editflag,
	cht_glnum,
	cht_sign,
	cht_systemcode,
	cht_edicode,
	cht_taxtable1,
	cht_taxtable2,
	cht_taxtable3,
	cht_taxtable4,
	cht_currunit ,
	cht_remark ,
	cht_rollintolh ,
	cht_retired ,
	cht_maxrate ,
	cht_maxenf ,
	cht_minrate,
	cht_minenf ,
	cht_zeroenf,
	cht_crchg,
	cht_class )
	(select getdate(),
	@tmwuser,
	@ls_status,
	cht_number,
	cht_itemcode,
	cht_description,
	cht_primary,
	cht_basis,
	cht_basisunit,
	cht_basisper,
	cht_quantity,
	cht_rateunit,
	cht_unit,
	cht_rate,
	cht_editflag,
	cht_glnum,
	cht_sign,
	cht_systemcode,
	cht_edicode,
	cht_taxtable1,
	cht_taxtable2,
	cht_taxtable3,
	cht_taxtable4,
	cht_currunit ,
	cht_remark ,
	cht_rollintolh ,
	cht_retired ,
	cht_maxrate ,
	cht_maxenf ,
	cht_minrate,
	cht_minenf ,
	cht_zeroenf,
	cht_crchg,
	cht_class from deleted)



GO
ALTER TABLE [dbo].[chargetype] ADD CONSTRAINT [PK_chargetype] PRIMARY KEY CLUSTERED ([cht_itemcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cht_crchg] ON [dbo].[chargetype] ([cht_crchg]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_chargetype_cht_itemcode] ON [dbo].[chargetype] ([cht_itemcode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_cht_number] ON [dbo].[chargetype] ([cht_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_chargetype_timestamp] ON [dbo].[chargetype] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [chargetype_INS_TIMESTAMP] ON [dbo].[chargetype] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chargetype] ADD CONSTRAINT [fk_chargetype_cht_ChargeTypeBasisUnitRule_Id] FOREIGN KEY ([cht_ChargeTypeBasisUnitRule_Id]) REFERENCES [dbo].[ChargeTypeBasisUnitRule] ([Id])
GO
GRANT DELETE ON  [dbo].[chargetype] TO [public]
GO
GRANT INSERT ON  [dbo].[chargetype] TO [public]
GO
GRANT REFERENCES ON  [dbo].[chargetype] TO [public]
GO
GRANT SELECT ON  [dbo].[chargetype] TO [public]
GO
GRANT UPDATE ON  [dbo].[chargetype] TO [public]
GO
