CREATE TABLE [dbo].[TPLBillPostSettlementsActive]
(
[mov_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[ActiveDate] [datetime2] (3) NULL,
[Attempts] [int] NULL CONSTRAINT [DF__TPLBillPo__Attem__6528AE57] DEFAULT ((0)),
[LastAttemptDate] [datetime2] (3) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPLBillPostSettlementsActive] ADD CONSTRAINT [PK_TPLBillPostSettlementsActive] PRIMARY KEY CLUSTERED ([mov_number], [ord_hdrnumber], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPLBillPostSettlementsActive] TO [public]
GO
GRANT INSERT ON  [dbo].[TPLBillPostSettlementsActive] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TPLBillPostSettlementsActive] TO [public]
GO
GRANT SELECT ON  [dbo].[TPLBillPostSettlementsActive] TO [public]
GO
GRANT UPDATE ON  [dbo].[TPLBillPostSettlementsActive] TO [public]
GO
