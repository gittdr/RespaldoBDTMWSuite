CREATE TABLE [dbo].[purchased_paydetail]
(
[pp_consecutivo] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pp_paydetail] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[purchased_paydetail] ADD CONSTRAINT [PK__purchase__BE6ED67A72B740CB] PRIMARY KEY CLUSTERED ([pp_consecutivo]) ON [PRIMARY]
GO
