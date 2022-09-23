CREATE TABLE [dbo].[api_ordercreated]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[norder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idrecord] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_at] [datetime] NOT NULL CONSTRAINT [DF__api_order__creat__05597F7A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[api_ordercreated] ADD CONSTRAINT [PK__api_orde__3213E83F22B9C831] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
