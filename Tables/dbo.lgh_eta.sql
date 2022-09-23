CREATE TABLE [dbo].[lgh_eta]
(
[eta_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[lgh_etaalert1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_etacomment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lgh_eta] ADD CONSTRAINT [pk_lgh_eta] PRIMARY KEY CLUSTERED ([eta_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_eta_lgh_number] ON [dbo].[lgh_eta] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[lgh_eta] TO [public]
GO
GRANT INSERT ON  [dbo].[lgh_eta] TO [public]
GO
GRANT REFERENCES ON  [dbo].[lgh_eta] TO [public]
GO
GRANT SELECT ON  [dbo].[lgh_eta] TO [public]
GO
GRANT UPDATE ON  [dbo].[lgh_eta] TO [public]
GO
