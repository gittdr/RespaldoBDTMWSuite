CREATE TABLE [dbo].[TPLOrderCostDetailGenActive]
(
[mov_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[ActiveDate] [datetime2] (3) NULL,
[Attempts] [int] NULL,
[LastAttemptDate] [datetime2] (3) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPLOrderCostDetailGenActive] ADD CONSTRAINT [PK_TPLOrderCostDetailGenActive] PRIMARY KEY CLUSTERED ([mov_number], [ord_hdrnumber], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TPLOrderCostDetailGenActive] TO [public]
GO
GRANT INSERT ON  [dbo].[TPLOrderCostDetailGenActive] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TPLOrderCostDetailGenActive] TO [public]
GO
GRANT SELECT ON  [dbo].[TPLOrderCostDetailGenActive] TO [public]
GO
GRANT UPDATE ON  [dbo].[TPLOrderCostDetailGenActive] TO [public]
GO
