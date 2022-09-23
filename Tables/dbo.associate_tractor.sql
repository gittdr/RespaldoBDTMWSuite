CREATE TABLE [dbo].[associate_tractor]
(
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_tractor] ADD CONSTRAINT [associate_tractor_pk] PRIMARY KEY CLUSTERED ([trc_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_tractor] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_tractor] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_tractor] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_tractor] TO [public]
GO
