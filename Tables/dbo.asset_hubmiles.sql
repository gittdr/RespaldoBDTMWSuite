CREATE TABLE [dbo].[asset_hubmiles]
(
[ahub_id] [int] NOT NULL IDENTITY(1, 1),
[ahub_asgntype] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ahub_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ahub_date] [datetime] NOT NULL,
[ahub_startreading] [int] NOT NULL,
[ahub_endreading] [int] NOT NULL,
[ahub_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ahub_invoicestatus] DEFAULT ('AVL'),
[ahub_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ahub_createdon] [datetime] NULL,
[ahub_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ahub_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_asset_hubmiles] ON [dbo].[asset_hubmiles]
FOR INSERT
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
	declare @v_assettype char(3)
    exec gettmwuser @v_tmwuser output 

	update asset_hubmiles 
	   set ahub_createdby = @v_tmwuser, 
		   ahub_createdon = getdate() 
	  from inserted 
	 where inserted.ahub_id = asset_hubmiles.ahub_id

	--update hub readings on the tractor profiles
	update tractorprofile
       set trc_currenthub = inserted.ahub_endreading
      from inserted
     where inserted.ahub_asgntype = 'TRC'
       and inserted.ahub_asgnid = tractorprofile.trc_number

	--update hub readings on the trailer profiles
	update trailerprofile
       set trl_currenthub = inserted.ahub_endreading
      from inserted
     where inserted.ahub_asgntype = 'TRL'
       and inserted.ahub_asgnid = trailerprofile.trl_id
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_asset_hubmiles] ON [dbo].[asset_hubmiles]
FOR UPDATE
AS
begin
	SET NOCOUNT ON

    declare @v_tmwuser varchar(255)
	declare @v_assettype char(3)
    exec gettmwuser @v_tmwuser output 

	update asset_hubmiles 
	   set ahub_updatedby = @v_tmwuser, 
		   ahub_updatedon = getdate() 
	  from inserted 
	 where inserted.ahub_id = asset_hubmiles.ahub_id

	--update hub readings on the tractor profiles
	update tractorprofile
       set trc_currenthub = inserted.ahub_endreading
      from inserted
     where inserted.ahub_asgntype = 'TRC'
       and inserted.ahub_asgnid = tractorprofile.trc_number

	--update hub readings on the trailer profiles
	update trailerprofile
       set trl_currenthub = inserted.ahub_endreading
      from inserted
     where inserted.ahub_asgntype = 'TRL'
       and inserted.ahub_asgnid = trailerprofile.trl_id
end
GO
ALTER TABLE [dbo].[asset_hubmiles] ADD CONSTRAINT [PK__asset_hubmiles__08C5FB8C] PRIMARY KEY CLUSTERED ([ahub_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[asset_hubmiles] TO [public]
GO
GRANT INSERT ON  [dbo].[asset_hubmiles] TO [public]
GO
GRANT SELECT ON  [dbo].[asset_hubmiles] TO [public]
GO
GRANT UPDATE ON  [dbo].[asset_hubmiles] TO [public]
GO
