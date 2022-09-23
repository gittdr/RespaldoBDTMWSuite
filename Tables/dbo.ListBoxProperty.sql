CREATE TABLE [dbo].[ListBoxProperty]
(
[lbp_id] [smallint] NOT NULL,
[lbp_creation_dt] [datetime] NOT NULL,
[lbp_daysout] [int] NULL,
[lbp_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ListBoxProperty] ADD CONSTRAINT [pk_ListBoxProperty] PRIMARY KEY CLUSTERED ([lbp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ListBoxProperty] TO [public]
GO
GRANT INSERT ON  [dbo].[ListBoxProperty] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ListBoxProperty] TO [public]
GO
GRANT SELECT ON  [dbo].[ListBoxProperty] TO [public]
GO
GRANT UPDATE ON  [dbo].[ListBoxProperty] TO [public]
GO
