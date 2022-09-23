CREATE TABLE [dbo].[dvgroupviews]
(
[dvv_id] [int] NOT NULL IDENTITY(1, 1),
[dvg_group] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dv_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dv_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dvv_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dvgroupvi__dvv_d__0E129053] DEFAULT ('n')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvgroupviews] ADD CONSTRAINT [PK__dvgroupviews__0C2A47E1] PRIMARY KEY CLUSTERED ([dvv_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dvgv_altidx] ON [dbo].[dvgroupviews] ([dvg_group], [dv_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvgroupviews] ADD CONSTRAINT [FK__dvgroupvi__dvg_g__0D1E6C1A] FOREIGN KEY ([dvg_group]) REFERENCES [dbo].[dvgroups] ([dvg_group]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT DELETE ON  [dbo].[dvgroupviews] TO [public]
GO
GRANT INSERT ON  [dbo].[dvgroupviews] TO [public]
GO
GRANT SELECT ON  [dbo].[dvgroupviews] TO [public]
GO
GRANT UPDATE ON  [dbo].[dvgroupviews] TO [public]
GO
