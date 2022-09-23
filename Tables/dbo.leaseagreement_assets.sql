CREATE TABLE [dbo].[leaseagreement_assets]
(
[laa_recordid] [int] NOT NULL IDENTITY(1, 1),
[la_recordid] [int] NOT NULL,
[laa_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[laa_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[laa_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[laa_baserate] [money] NULL,
[laa_baserateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_variablerate] [money] NULL,
[laa_variablerateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_createdon] [datetime] NULL,
[laa_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_updatedon] [datetime] NULL,
[laa_effectiveon] [datetime] NULL,
[laa_expireson] [datetime] NULL,
[laa_flatrateflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_laa_flatrateflag] DEFAULT ('N'),
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode_base] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laa_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_leaseagreement_assets] ON [dbo].[leaseagreement_assets]
FOR INSERT
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
    exec gettmwuser @v_tmwuser output 

	update leaseagreement_assets 
	   set laa_createdby = @v_tmwuser, 
		   laa_createdon = getdate() 
	  from inserted 
	 where inserted.la_recordid = leaseagreement_assets.la_recordid
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_leaseagreement_assets] ON [dbo].[leaseagreement_assets]
FOR UPDATE
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
    exec gettmwuser @v_tmwuser output 

	update leaseagreement_assets 
	   set laa_updatedby = @v_tmwuser, 
		   laa_updatedon = getdate() 
	  from inserted 
	 where inserted.la_recordid = leaseagreement_assets.la_recordid
end
GO
ALTER TABLE [dbo].[leaseagreement_assets] ADD CONSTRAINT [PK__leaseagreement_a__05E98EE1] PRIMARY KEY CLUSTERED ([laa_recordid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[leaseagreement_assets] ADD CONSTRAINT [FK__leaseagre__la_re__06DDB31A] FOREIGN KEY ([la_recordid]) REFERENCES [dbo].[leaseagreement] ([la_recordid])
GO
GRANT DELETE ON  [dbo].[leaseagreement_assets] TO [public]
GO
GRANT INSERT ON  [dbo].[leaseagreement_assets] TO [public]
GO
GRANT SELECT ON  [dbo].[leaseagreement_assets] TO [public]
GO
GRANT UPDATE ON  [dbo].[leaseagreement_assets] TO [public]
GO
