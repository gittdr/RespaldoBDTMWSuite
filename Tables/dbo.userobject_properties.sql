CREATE TABLE [dbo].[userobject_properties]
(
[uop_id] [int] NOT NULL IDENTITY(1, 1),
[uop_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uop_window] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uop_object] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uop_property] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uop_value] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_properties] ADD CONSTRAINT [pk_userobject_properties] PRIMARY KEY CLUSTERED ([uop_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_properties] ADD CONSTRAINT [uk_userobjprop] UNIQUE NONCLUSTERED ([uop_user], [uop_window], [uop_object], [uop_property]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userobject_properties] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject_properties] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userobject_properties] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject_properties] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject_properties] TO [public]
GO
