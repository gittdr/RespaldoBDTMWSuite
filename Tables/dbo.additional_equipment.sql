CREATE TABLE [dbo].[additional_equipment]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Stop_Number] [int] NULL,
[Company_Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Equipment_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Incoming_Quantity] [int] NULL,
[Outgoing_Quantity] [int] NULL,
[Effective_Date] [datetime] NULL,
[Created_By] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Created_Date] [datetime] NULL,
[Last_Updated_By] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Updated_On] [datetime] NULL,
[Comment] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[additional_equipment] ADD CONSTRAINT [PK__addition__3214EC07393AE7CF] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[additional_equipment] TO [public]
GO
GRANT INSERT ON  [dbo].[additional_equipment] TO [public]
GO
GRANT SELECT ON  [dbo].[additional_equipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[additional_equipment] TO [public]
GO
