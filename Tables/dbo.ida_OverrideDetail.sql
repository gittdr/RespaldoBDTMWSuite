CREATE TABLE [dbo].[ida_OverrideDetail]
(
[idOverrideDetail] [int] NOT NULL IDENTITY(1, 1),
[idOverride] [int] NOT NULL,
[rank] [int] NULL,
[sCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sComponentName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[curValue] [decimal] (18, 0) NULL,
[ValueError] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PowerId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ida_OverrideDetail] ADD CONSTRAINT [PK_ida_OverrideDetail] PRIMARY KEY CLUSTERED ([idOverrideDetail]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ida_OverrideDetail] ADD CONSTRAINT [FK_ida_OverrideDetail_ida_Override] FOREIGN KEY ([idOverride]) REFERENCES [dbo].[ida_Override] ([idOverride])
GO
GRANT DELETE ON  [dbo].[ida_OverrideDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[ida_OverrideDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ida_OverrideDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[ida_OverrideDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ida_OverrideDetail] TO [public]
GO
