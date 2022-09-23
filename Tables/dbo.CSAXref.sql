CREATE TABLE [dbo].[CSAXref]
(
[csax_id] [int] NOT NULL IDENTITY(1, 1),
[csax_mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csax_drivername] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddt] [datetime] NULL,
[last_updatedby] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[IUT_CSAXref] ON [dbo].[CSAXref]
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
	Update CSAXref
	set last_updatedby = @tmwuser,
		last_updateddt = getdate()
	from inserted
	where inserted.csax_id = CSAXref.csax_id
		and (isNull(CSAXref.last_updatedby,'') <> @tmwuser
		OR isNull(CSAXref.last_updateddt,'') <> getdate())

GO
ALTER TABLE [dbo].[CSAXref] ADD CONSTRAINT [pk_csax_id] PRIMARY KEY CLUSTERED ([csax_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CSAXref] TO [public]
GO
GRANT INSERT ON  [dbo].[CSAXref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CSAXref] TO [public]
GO
GRANT SELECT ON  [dbo].[CSAXref] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSAXref] TO [public]
GO
