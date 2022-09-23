CREATE TABLE [dbo].[legheaderbrokered_acc]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[quantity] [float] NULL,
[rate] [money] NULL,
[charges] [money] NULL,
[tar_number] [int] NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legheaderbrokered_acc] ADD CONSTRAINT [PK__legheade__3213E83F85AC7192] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lh_brokeredacc_leg] ON [dbo].[legheaderbrokered_acc] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheaderbrokered_acc] TO [public]
GO
GRANT INSERT ON  [dbo].[legheaderbrokered_acc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheaderbrokered_acc] TO [public]
GO
GRANT SELECT ON  [dbo].[legheaderbrokered_acc] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheaderbrokered_acc] TO [public]
GO
