CREATE TABLE [dbo].[CSATestData]
(
[csatd_id] [int] NOT NULL IDENTITY(1, 1),
[csatd_Query_ID] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csatd_driverid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csatd_licensenumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csatd_licensestate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddt] [datetime] NULL,
[last_updatedby] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_CSATestData] ON [dbo].[CSATestData]
FOR INSERT,UPDATE
AS


declare	@tmwuser		varchar (255)
declare	@updatecount	int,
		@delcount		int

exec gettmwuser @tmwuser output  

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted


if (@updatecount > 0 and not update(last_updatedby) and not update(last_updateddt)) OR
	(@updatecount > 0 and @delcount = 0)
	Update CSATestData
	set last_updatedby = @tmwuser,
		last_updateddt = getdate()
	from inserted
	where inserted.csatd_id = CSATestData.csatd_id
		and (isNull(CSATestData.last_updatedby,'') <> @tmwuser
		OR isNull(CSATestData.last_updateddt,'') <> getdate())

GO
ALTER TABLE [dbo].[CSATestData] ADD CONSTRAINT [pk_csatd_id] PRIMARY KEY CLUSTERED ([csatd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CSATestData] TO [public]
GO
GRANT INSERT ON  [dbo].[CSATestData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CSATestData] TO [public]
GO
GRANT SELECT ON  [dbo].[CSATestData] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSATestData] TO [public]
GO
