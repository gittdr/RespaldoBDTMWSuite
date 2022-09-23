CREATE TABLE [dbo].[leaseagreement]
(
[la_recordid] [int] NOT NULL IDENTITY(1, 1),
[la_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[la_leaseagreement] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[la_leaseagreementrevision] [int] NOT NULL,
[la_leaseagreementremark] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[la_effectiveon] [datetime] NOT NULL,
[la_expireson] [datetime] NOT NULL,
[la_billingterms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_la_billingterms] DEFAULT ('DAY'),
[la_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[la_createdon] [datetime] NULL,
[la_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[la_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_leaseagreement] ON [dbo].[leaseagreement]
FOR INSERT
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
    exec gettmwuser @v_tmwuser output 

	update leaseagreement 
	   set la_createdby = @v_tmwuser, 
		   la_createdon = getdate() 
	  from inserted 
	 where inserted.la_recordid = leaseagreement.la_recordid
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_leaseagreement] ON [dbo].[leaseagreement]
FOR UPDATE
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
    exec gettmwuser @v_tmwuser output 

	update leaseagreement 
	   set la_updatedby = @v_tmwuser, 
		   la_updatedon = getdate() 
	  from inserted 
	 where inserted.la_recordid = leaseagreement.la_recordid
end
GO
ALTER TABLE [dbo].[leaseagreement] ADD CONSTRAINT [PK__leaseagreement__0218FDFD] PRIMARY KEY CLUSTERED ([la_recordid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[leaseagreement] ADD CONSTRAINT [FK__leaseagre__la_co__030D2236] FOREIGN KEY ([la_company]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[leaseagreement] TO [public]
GO
GRANT INSERT ON  [dbo].[leaseagreement] TO [public]
GO
GRANT SELECT ON  [dbo].[leaseagreement] TO [public]
GO
GRANT UPDATE ON  [dbo].[leaseagreement] TO [public]
GO
