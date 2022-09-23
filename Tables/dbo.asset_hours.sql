CREATE TABLE [dbo].[asset_hours]
(
[ah_id] [int] NOT NULL IDENTITY(1, 1),
[ah_asgntype] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ah_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ah_date] [datetime] NOT NULL,
[ah_hours] [decimal] (4, 2) NOT NULL,
[ah_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ahours_invoicestatus] DEFAULT ('AVL'),
[ah_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ah_createdon] [datetime] NULL,
[ah_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ah_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_asset_hours] ON [dbo].[asset_hours]
FOR INSERT
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
	declare @v_assettype char(3)
    exec gettmwuser @v_tmwuser output 

	update asset_hours 
	   set ah_createdby = @v_tmwuser, 
		   ah_createdon = getdate() 
	  from inserted 
	 where inserted.ah_id = asset_hours.ah_id

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_asset_hours] ON [dbo].[asset_hours]
FOR UPDATE
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
	declare @v_assettype char(3)
    exec gettmwuser @v_tmwuser output 

	update asset_hours 
	   set ah_updatedby = @v_tmwuser, 
		   ah_updatedon = getdate() 
	  from inserted 
	 where inserted.ah_id = asset_hours.ah_id

end
GO
ALTER TABLE [dbo].[asset_hours] ADD CONSTRAINT [PK__asset_hours__0BA26837] PRIMARY KEY CLUSTERED ([ah_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[asset_hours] TO [public]
GO
GRANT INSERT ON  [dbo].[asset_hours] TO [public]
GO
GRANT SELECT ON  [dbo].[asset_hours] TO [public]
GO
GRANT UPDATE ON  [dbo].[asset_hours] TO [public]
GO
