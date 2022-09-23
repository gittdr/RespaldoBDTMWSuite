CREATE TABLE [dbo].[toll_route]
(
[tr_ident] [int] NOT NULL IDENTITY(1, 1),
[tr_origin_city] [int] NOT NULL,
[tr_dest_city] [int] NOT NULL,
[tr_loadstatus] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_toll_route_loadstatus] DEFAULT ('UND')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[toll_route] ADD CONSTRAINT [pk_tollroute_ident] PRIMARY KEY CLUSTERED ([tr_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_tollroute_orig_dest_loadstatus] ON [dbo].[toll_route] ([tr_origin_city], [tr_dest_city], [tr_loadstatus]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[toll_route] TO [public]
GO
GRANT INSERT ON  [dbo].[toll_route] TO [public]
GO
GRANT SELECT ON  [dbo].[toll_route] TO [public]
GO
GRANT UPDATE ON  [dbo].[toll_route] TO [public]
GO
