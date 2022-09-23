CREATE TABLE [dbo].[mb_breaks]
(
[MasterBillBreakKey] [int] NOT NULL,
[ivh_hdrnumber] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mb_breaks] ADD CONSTRAINT [pk_mb_breaks] PRIMARY KEY CLUSTERED ([MasterBillBreakKey], [ivh_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mb_breaks] TO [public]
GO
GRANT INSERT ON  [dbo].[mb_breaks] TO [public]
GO
GRANT SELECT ON  [dbo].[mb_breaks] TO [public]
GO
GRANT UPDATE ON  [dbo].[mb_breaks] TO [public]
GO
