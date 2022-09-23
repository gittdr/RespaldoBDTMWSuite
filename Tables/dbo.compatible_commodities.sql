CREATE TABLE [dbo].[compatible_commodities]
(
[cc_id] [int] NOT NULL IDENTITY(1, 1),
[cc_cmd_code_1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_cmd_code_2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_created_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_createdate] [datetime] NULL,
[cc_updated_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_comp_comm] on [dbo].[compatible_commodities] for insert as 
SET NOCOUNT ON

declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

update compatible_commodities
   set cc_created_by = @tmwuser,
       cc_createdate = getdate()
  from inserted 
 where compatible_commodities.cc_id = inserted.cc_id

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_comp_comm] on [dbo].[compatible_commodities] for update as 
SET NOCOUNT ON

declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

update compatible_commodities
   set cc_updated_by = @tmwuser,
       cc_updatedate = getdate()
  from inserted 
 where compatible_commodities.cc_id = inserted.cc_id

GO
ALTER TABLE [dbo].[compatible_commodities] ADD CONSTRAINT [comp_commod_id] PRIMARY KEY CLUSTERED ([cc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[compatible_commodities] TO [public]
GO
GRANT INSERT ON  [dbo].[compatible_commodities] TO [public]
GO
GRANT REFERENCES ON  [dbo].[compatible_commodities] TO [public]
GO
GRANT SELECT ON  [dbo].[compatible_commodities] TO [public]
GO
GRANT UPDATE ON  [dbo].[compatible_commodities] TO [public]
GO
