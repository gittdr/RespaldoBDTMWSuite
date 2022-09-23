CREATE TABLE [dbo].[fuelcomdataintradaypackets]
(
[fuelcomdataintradaypacket_id] [int] NOT NULL IDENTITY(1, 1),
[packet] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acknowledgement] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_datetime] [datetime] NULL,
[processed_datetime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_status] ON [dbo].[fuelcomdataintradaypackets] ([status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_fuelcomdataintradaypackets_transaction_number] ON [dbo].[fuelcomdataintradaypackets] ([transaction_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelcomdataintradaypackets] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelcomdataintradaypackets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelcomdataintradaypackets] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelcomdataintradaypackets] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelcomdataintradaypackets] TO [public]
GO
